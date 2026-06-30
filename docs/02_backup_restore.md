# Runbook de Backup, Restore y Validación

## 1. Objetivo

Documentar el procedimiento para realizar respaldos, validar archivos de backup, simular fallos, restaurar información y verificar la integridad de la base de datos `dba_retail_demo`.

Este procedimiento aplica para el ambiente de laboratorio PostgreSQL local y puede adaptarse a ambientes productivos.

---

## 2. Alcance

Base de datos:

- Motor: PostgreSQL
- Base: `dba_retail_demo`
- Esquema principal: `retail`
- Tablas principales:
  - `retail.clientes`
  - `retail.productos`
  - `retail.ventas`
  - `retail.detalle_ventas`
  - `retail.resumen_ventas_mensual`

---

## 3. Estrategia de backup

Para la prueba se definió una estrategia de backup lógico usando `pg_dump` en formato custom.

### Características

| Elemento | Configuración |
|---|---|
| Tipo de backup | Backup lógico completo |
| Herramienta | `pg_dump` |
| Formato | Custom `-F c` |
| Compresión | Administrada por formato custom |
| Base respaldada | `dba_retail_demo` |
| Ruta de backups | `~/dba_automation/backups` |
| Retención laboratorio | 7 días |
| Validación | `pg_restore -l` |
| Restore | `pg_restore` |

---

## 4. Estructura de carpetas

```bash
~/dba_automation/
├── backups/
├── reports/
├── logs/
└── scripts/
