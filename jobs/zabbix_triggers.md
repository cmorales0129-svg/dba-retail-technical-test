# Triggers configurados en Zabbix

## Bloqueos activos
- Item: `pgsql.retail.locks.waiting`
- Condición: `last(/PostgreSQL-BD_RETAIL/pgsql.retail.locks.waiting)>0`
- Severidad: High
- Acción: notificación al equipo DBA y revisión de sesiones bloqueadas.

## Queries largas
- Item: `pgsql.retail.long_queries`
- Condición: valor mayor a `0`
- Severidad: Average
- Acción: revisar `pg_stat_activity`, plan de ejecución y usuario responsable.

## Cache hit ratio bajo
- Item: `pgsql.retail.cache_hit_ratio`
- Condición: menor a `95`
- Severidad: Warning
- Acción: revisar memoria, índices y patrones de consulta.
