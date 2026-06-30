# Prueba Técnica DBA - PostgreSQL Retail Demo

Repositorio con los scripts, objetos de base de datos, automatizaciones y documentación desarrollados para la prueba técnica de Administrador de Bases de Datos.

## 1. Objetivo

Implementar y documentar una solución DBA integral sobre PostgreSQL, incluyendo administración, SQL avanzado, backup/recovery, monitoreo, automatización, seguridad, soporte 24/7, nube AWS RDS y documentación operativa.

## 2. Motor de base de datos

- Motor local: PostgreSQL 16
- Base local: `dba_retail_demo`
- Esquema: `retail`
- Base cloud: Amazon RDS PostgreSQL `rds-dba-retail-demo`

## 3. Modelo de datos

El modelo representa un caso retail con clientes, productos, ventas y detalle de ventas.

Relación principal:


clientes 1 ─ N ventas 1 ─ N detalle_ventas N ─ 1 productos
Tablas principales:

retail.clientes
retail.productos
retail.ventas
retail.detalle_ventas
retail.resumen_ventas_mensual

## 4. Estructura del repositorio
database/      Objetos SQL: DDL, procedimientos, vistas, validaciones y rollback
scripts/       Scripts Bash de backup, automatización y monitoreo
jobs/          Configuración de cron y triggers de Zabbix
docs/          Runbooks y documentación técnica
diagrams/      Diagramas de modelo y arquitectura
evidence/      Capturas de ejecución y evidencias de laboratorio

## 5. Instalación y configuración local
### 5.1 Crear base de datos

createdb -U postgres dba_retail_demo

### 5.2 Ejecutar objetos SQL

psql -U postgres -d dba_retail_demo -f database/ddl/01_create_schema.sql
psql -U postgres -d dba_retail_demo -f database/ddl/02_create_tables.sql
psql -U postgres -d dba_retail_demo -f database/ddl/03_constraints_indexes.sql
psql -U postgres -d dba_retail_demo -f database/procedures/sp_generar_resumen_ventas_mensual.sql
psql -U postgres -d dba_retail_demo -f database/views/vw_clientes_enmascarados.sql

### 5.3 Ejecutar script de automatización
chmod +x scripts/automation/dba_automation_retail.sh
bash scripts/automation/dba_automation_retail.sh

## 6. Puntos de la prueba

### Punto 1 - Administración de bases de datos
Instalación y configuración inicial de PostgreSQL.
Creación de base dba_retail_demo.
Modelo relacional con llaves primarias, foráneas, restricciones e índices.
Separación de roles y permisos.
Mantenimiento preventivo con VACUUM, ANALYZE, revisión de índices y espacio.
### Punto 2 - SQL avanzado y optimización
Consultas con múltiples JOINs.
Funciones de ventana.
Subconsultas correlacionadas.
Procedimiento retail.sp_generar_resumen_ventas_mensual.
Optimización con EXPLAIN ANALYZE.
### Punto 3 - Backup, recovery y continuidad
Backup lógico con pg_dump.
Restore en base temporal.
Simulación de fallo y recuperación.
Replicación streaming local.
Failover simulado.
### Punto 4 - Monitoreo y observabilidad
Métricas nativas con pg_stat_activity, pg_stat_database, pg_locks.
Zabbix Agent 2 con UserParameters.
Dashboard con conexiones, bloqueos, cache hit ratio y tamaño de base.
Triggers de alerta.
### Punto 5 - Automatización
Script Bash para backup, integridad, tamaño de tablas, índices no usados y limpieza histórica.
Job programado con cron.
Logs de ejecución y notificación simulada ante fallo.
Integración propuesta con CI/CD.
### Punto 6 - Seguridad y auditoría
Autenticación scram-sha-256.
Restricción por IP en pg_hba.conf.
Roles de lectura, escritura y administración.
Enmascaramiento de datos sensibles.
Logs de auditoría para accesos, DDL y operaciones sensibles.
### Punto 7 - Soporte 24/7 e incidentes críticos
Runbook para base inaccesible, saturación de conexiones y pérdida masiva de conexiones.
Procedimiento ante deadlocks, bloqueos y queries largas.
Comunicación y postmortem.
### Punto 8 - Cloud / AWS RDS
Creación de instancia Amazon RDS PostgreSQL.
Configuración de Security Groups.
Backups automáticos.
Parameter Group.
Monitoreo nativo con CloudWatch.
Comparación on-premise vs nube.
Seguridad en entorno híbrido.
### Punto 9 - Documentación y mejora continua
Runbooks operativos.
Diagrama de modelo de datos.
Procedimientos de recuperación.
Control de cambios.
Documentación viva en Git.
## 7. Evidencias

Las evidencias se encuentran en la carpeta evidence/ y corresponden a capturas de:

PostgreSQL local
Backups y restores
Zabbix
Cron jobs
Seguridad y auditoría
AWS RDS
Diagramas

## 8. Consideraciones de seguridad

No se incluyen contraseñas reales, archivos .pgpass, endpoints sensibles, backups productivos ni secretos. Las credenciales utilizadas en la documentación son de laboratorio y deben reemplazarse por variables seguras o servicios como AWS Secrets Manager / Vault.

## 9. Autor

Carlos Enrique Morales Suárez
