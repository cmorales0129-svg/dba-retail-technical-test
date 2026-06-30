#!/bin/bash

# ============================================================
# Wrapper de ejecución programada para script DBA
# Ejecuta el script principal, registra logs y alerta fallos
# ============================================================

BASE_DIR="$HOME/dba_automation"
SCRIPT="$BASE_DIR/scripts/dba_automation_retail.sh"
LOG_DIR="$BASE_DIR/logs"

FECHA=$(date +"%Y%m%d_%H%M%S")
CRON_LOG="$LOG_DIR/cron_dba_automation_${FECHA}.log"
ALERT_LOG="$LOG_DIR/alertas_dba.log"

mkdir -p "$LOG_DIR"

echo "============================================================" >> "$CRON_LOG"
echo "INICIO JOB PROGRAMADO DBA - $(date)" >> "$CRON_LOG"
echo "Script ejecutado: $SCRIPT" >> "$CRON_LOG"
echo "Usuario ejecución: $(whoami)" >> "$CRON_LOG"
echo "Directorio base: $BASE_DIR" >> "$CRON_LOG"
echo "============================================================" >> "$CRON_LOG"

# Validar que el script principal exista
if [ ! -f "$SCRIPT" ]; then
    echo "ERROR: No existe el script principal: $SCRIPT" >> "$CRON_LOG"
    echo "ESTADO JOB: FALLIDO" >> "$CRON_LOG"
    echo "$(date) - FALLA JOB DBA - No existe script principal: $SCRIPT" >> "$ALERT_LOG"
    exit 1
fi

# Validar que el script principal tenga permisos de ejecución
if [ ! -x "$SCRIPT" ]; then
    echo "ADVERTENCIA: El script principal no tiene permisos de ejecución. Se intentará ejecutar con bash." >> "$CRON_LOG"
fi

# Ejecutar script principal
bash "$SCRIPT" >> "$CRON_LOG" 2>&1

ESTADO=$?

echo "============================================================" >> "$CRON_LOG"

if [ $ESTADO -eq 0 ]; then
    echo "ESTADO JOB: EXITOSO" >> "$CRON_LOG"
    echo "Fecha fin: $(date)" >> "$CRON_LOG"
else
    echo "ESTADO JOB: FALLIDO" >> "$CRON_LOG"
    echo "Código de error: $ESTADO" >> "$CRON_LOG"
    echo "Fecha fin: $(date)" >> "$CRON_LOG"
    echo "ALERTA: Falló la ejecución del job DBA. Revisar log: $CRON_LOG" >> "$CRON_LOG"
    echo "$(date) - FALLA JOB DBA - Revisar log: $CRON_LOG" >> "$ALERT_LOG"
fi

echo "============================================================" >> "$CRON_LOG"

exit $ESTADO
