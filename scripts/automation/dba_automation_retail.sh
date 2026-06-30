#!/bin/bash

# ============================================================
# Script de automatización DBA - PostgreSQL
# Base de datos: dba_retail_demo
# Tareas:
# 1. Backup lógico de la base de datos
# 2. Verificación de integridad básica
# 3. Reporte de tamaño de tablas
# 4. Detección de índices no utilizados
# 5. Limpieza de archivos históricos
# ============================================================

DB_NAME="BD_RETAIL"
DB_USER="postgres"
DB_HOST="localhost"
DB_PORT="5432"

HOME="/home/cmorales"

BASE_DIR="$HOME/dba_automation"
BACKUP_DIR="$BASE_DIR/backups"
REPORT_DIR="$BASE_DIR/reports"
LOG_DIR="$BASE_DIR/logs"

FECHA=$(date +"%Y%m%d_%H%M%S")

BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_backup_${FECHA}.backup"
LOG_FILE="$LOG_DIR/dba_automation_${FECHA}.log"
SIZE_REPORT="$REPORT_DIR/reporte_tamano_tablas_${FECHA}.csv"
INDEX_REPORT="$REPORT_DIR/reporte_indices_no_usados_${FECHA}.csv"
INTEGRITY_REPORT="$REPORT_DIR/reporte_integridad_${FECHA}.txt"

RETENTION_DAYS=7

mkdir -p "$BACKUP_DIR"
mkdir -p "$REPORT_DIR"
mkdir -p "$LOG_DIR"

echo "============================================================" | tee -a "$LOG_FILE"
echo "INICIO SCRIPT DBA AUTOMATION - $(date)" | tee -a "$LOG_FILE"
echo "Base de datos: $DB_NAME" | tee -a "$LOG_FILE"
echo "============================================================" | tee -a "$LOG_FILE"


# ------------------------------------------------------------
# 1. BACKUP DE BASE DE DATOS
# ------------------------------------------------------------
echo "[1/5] Ejecutando backup lógico con pg_dump..." | tee -a "$LOG_FILE"

pg_dump -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" \
-F c -b -v \
-f "$BACKUP_FILE" "$DB_NAME" >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
    echo "Backup generado correctamente: $BACKUP_FILE" | tee -a "$LOG_FILE"
else
    echo "ERROR: Falló la generación del backup." | tee -a "$LOG_FILE"
    exit 1
fi


# ------------------------------------------------------------
# 2. VERIFICACIÓN DE INTEGRIDAD BÁSICA
# ------------------------------------------------------------
echo "[2/5] Ejecutando verificación de integridad básica..." | tee -a "$LOG_FILE"

{
echo "REPORTE DE INTEGRIDAD - $DB_NAME"
echo "Fecha: $(date)"
echo "------------------------------------------------------------"

echo ""
echo "Conteo de registros por tabla:"
psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -t -c "
SELECT 'clientes' AS tabla, COUNT(*) AS registros FROM retail.clientes
UNION ALL
SELECT 'productos', COUNT(*) FROM retail.productos
UNION ALL
SELECT 'ventas', COUNT(*) FROM retail.ventas
UNION ALL
SELECT 'detalle_ventas', COUNT(*) FROM retail.detalle_ventas;
"

echo ""
echo "Validación de ventas sin cliente asociado:"
psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -t -c "
SELECT COUNT(*) AS ventas_sin_cliente
FROM retail.ventas v
LEFT JOIN retail.clientes c ON v.cliente_id = c.cliente_id
WHERE c.cliente_id IS NULL;
"

echo ""
echo "Validación de detalle sin venta asociada:"
psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -t -c "
SELECT COUNT(*) AS detalle_sin_venta
FROM retail.detalle_ventas dv
LEFT JOIN retail.ventas v ON dv.venta_id = v.venta_id
WHERE v.venta_id IS NULL;
"

echo ""
echo "Validación de detalle sin producto asociado:"
psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -t -c "
SELECT COUNT(*) AS detalle_sin_producto
FROM retail.detalle_ventas dv
LEFT JOIN retail.productos p ON dv.producto_id = p.producto_id
WHERE p.producto_id IS NULL;
"

echo ""
echo "Constraints registradas en el esquema retail:"
psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -t -c "
SELECT
    tc.table_name,
    tc.constraint_name,
    tc.constraint_type
FROM information_schema.table_constraints tc
WHERE tc.table_schema = 'retail'
ORDER BY tc.table_name, tc.constraint_type;
"
} > "$INTEGRITY_REPORT"

echo "Reporte de integridad generado: $INTEGRITY_REPORT" | tee -a "$LOG_FILE"


# ------------------------------------------------------------
# 3. REPORTE DE TAMAÑO DE TABLAS
# ------------------------------------------------------------
echo "[3/5] Generando reporte de tamaño de tablas..." | tee -a "$LOG_FILE"

psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -c "\copy (
SELECT
    schemaname AS esquema,
    relname AS tabla,
    pg_size_pretty(pg_total_relation_size(relid)) AS tamano_total,
    pg_size_pretty(pg_relation_size(relid)) AS tamano_tabla,
    pg_size_pretty(pg_total_relation_size(relid) - pg_relation_size(relid)) AS tamano_indices
FROM pg_catalog.pg_statio_user_tables
WHERE schemaname = 'retail'
ORDER BY pg_total_relation_size(relid) DESC
) TO '$SIZE_REPORT' WITH CSV HEADER;"

if [ $? -eq 0 ]; then
    echo "Reporte de tamaño generado: $SIZE_REPORT" | tee -a "$LOG_FILE"
else
    echo "ERROR: Falló el reporte de tamaño de tablas." | tee -a "$LOG_FILE"
fi


# ------------------------------------------------------------
# 4. DETECCIÓN DE ÍNDICES NO UTILIZADOS
# ------------------------------------------------------------
echo "[4/5] Detectando índices no utilizados..." | tee -a "$LOG_FILE"

psql -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -d "$DB_NAME" -c "\copy (
SELECT
    schemaname AS esquema,
    relname AS tabla,
    indexrelname AS indice,
    idx_scan AS veces_usado,
    pg_size_pretty(pg_relation_size(indexrelid)) AS tamano_indice
FROM pg_stat_user_indexes
WHERE schemaname = 'retail'
  AND idx_scan = 0
ORDER BY pg_relation_size(indexrelid) DESC
) TO '$INDEX_REPORT' WITH CSV HEADER;"

if [ $? -eq 0 ]; then
    echo "Reporte de índices no utilizados generado: $INDEX_REPORT" | tee -a "$LOG_FILE"
else
    echo "ERROR: Falló el reporte de índices no utilizados." | tee -a "$LOG_FILE"
fi


# ------------------------------------------------------------
# 5. LIMPIEZA DE ARCHIVOS HISTÓRICOS
# ------------------------------------------------------------
echo "[5/5] Ejecutando limpieza de archivos históricos mayores a $RETENTION_DAYS días..." | tee -a "$LOG_FILE"

find "$BACKUP_DIR" -name "*.backup" -type f -mtime +"$RETENTION_DAYS" -delete
find "$REPORT_DIR" -name "*.csv" -type f -mtime +"$RETENTION_DAYS" -delete
find "$REPORT_DIR" -name "*.txt" -type f -mtime +"$RETENTION_DAYS" -delete
find "$LOG_DIR" -name "*.log" -type f -mtime +"$RETENTION_DAYS" -delete

echo "Limpieza de históricos finalizada." | tee -a "$LOG_FILE"

echo "============================================================" | tee -a "$LOG_FILE"
echo "FIN SCRIPT DBA AUTOMATION - $(date)" | tee -a "$LOG_FILE"
echo "Estado final: EXITOSO" | tee -a "$LOG_FILE"
echo "============================================================" | tee -a "$LOG_FILE"

exit 0
