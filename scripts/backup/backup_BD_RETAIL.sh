#!/bin/bash

# =====================================================
# Script de backup automático PostgreSQL
# Base: dba_retail_demo
# Tipo: Backup completo lógico con pg_dump
# =====================================================

DB_NAME="BD_RETAIL"
DB_USER="postgres"
DB_HOST="localhost"
DB_PORT="5432"

HOME="/home/cmorales"

BASE_DIR="$HOME/postgres_backups"
BACKUP_DIR="$BASE_DIR/full"
LOG_DIR="$BASE_DIR/logs"

FECHA=$(date +"%Y%m%d_%H%M%S")

BACKUP_FILE="$BACKUP_DIR/${DB_NAME}_full_${FECHA}.backup"
LOG_FILE="$LOG_DIR/${DB_NAME}_backup_${FECHA}.log"

RETENTION_DAYS=7

mkdir -p "$BACKUP_DIR"
mkdir -p "$LOG_DIR"

echo "=====================================================" | tee -a "$LOG_FILE"
echo "Inicio backup PostgreSQL: $(date)" | tee -a "$LOG_FILE"
echo "Base de datos: $DB_NAME" | tee -a "$LOG_FILE"
echo "Archivo backup: $BACKUP_FILE" | tee -a "$LOG_FILE"
echo "=====================================================" | tee -a "$LOG_FILE"

pg_dump -U "$DB_USER" -h "$DB_HOST" -p "$DB_PORT" -F c -b -v \
-f "$BACKUP_FILE" "$DB_NAME" >> "$LOG_FILE" 2>&1

if [ $? -eq 0 ]; then
    echo "Backup finalizado correctamente: $(date)" | tee -a "$LOG_FILE"
    echo "Archivo generado: $BACKUP_FILE" | tee -a "$LOG_FILE"
else
    echo "ERROR: Falló el backup: $(date)" | tee -a "$LOG_FILE"
    exit 1
fi

echo "Aplicando política de retención: eliminar backups mayores a $RETENTION_DAYS días" | tee -a "$LOG_FILE"

find "$BACKUP_DIR" -name "*.backup" -type f -mtime +"$RETENTION_DAYS" -delete >> "$LOG_FILE" 2>&1

echo "Proceso finalizado: $(date)" | tee -a "$LOG_FILE"
echo "Estado final: EXITOSO" | tee -a "$LOG_FILE"

exit 0
