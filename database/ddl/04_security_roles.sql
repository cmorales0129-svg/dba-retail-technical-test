CREATE ROLE rol_lectura;
CREATE ROLE rol_escritura;
CREATE ROLE rol_dba;

GRANT CONNECT ON DATABASE dba_retail_demo TO rol_lectura, rol_escritura;
GRANT USAGE ON SCHEMA retail TO rol_lectura, rol_escritura;

GRANT SELECT ON ALL TABLES IN SCHEMA retail TO rol_lectura;

GRANT SELECT, INSERT, UPDATE, DELETE
ON ALL TABLES IN SCHEMA retail
TO rol_escritura;

GRANT ALL PRIVILEGES ON DATABASE dba_retail_demo TO rol_dba;
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA retail TO rol_dba;
