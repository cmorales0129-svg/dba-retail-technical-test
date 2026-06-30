CREATE TABLE IF NOT EXISTS retail.resumen_ventas_mensual (
    resumen_id SERIAL PRIMARY KEY,
    periodo DATE NOT NULL,
    ciudad VARCHAR(80) NOT NULL,
    canal_venta VARCHAR(30) NOT NULL,
    estado_venta VARCHAR(30) NOT NULL,
    cantidad_ventas INTEGER NOT NULL,
    cantidad_clientes INTEGER NOT NULL,
    cantidad_productos INTEGER NOT NULL,
    total_unidades INTEGER NOT NULL,
    total_ventas NUMERIC(14,2) NOT NULL,
    ticket_promedio NUMERIC(14,2) NOT NULL,
    fecha_generacion TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_resumen_ventas_mensual
        UNIQUE (periodo, ciudad, canal_venta, estado_venta)
);

CREATE OR REPLACE PROCEDURE retail.sp_generar_resumen_ventas_mensual(
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE,
    OUT p_registros_procesados INTEGER,
    OUT p_mensaje TEXT
)
LANGUAGE plpgsql
AS $$
BEGIN
    p_registros_procesados := 0;
    p_mensaje := '';

    IF p_fecha_inicio IS NULL OR p_fecha_fin IS NULL THEN
        RAISE EXCEPTION 'Las fechas de inicio y fin no pueden ser nulas';
    END IF;

    IF p_fecha_inicio > p_fecha_fin THEN
        RAISE EXCEPTION 'La fecha de inicio no puede ser mayor que la fecha de fin';
    END IF;

    DELETE FROM retail.resumen_ventas_mensual
    WHERE periodo BETWEEN DATE_TRUNC('month', p_fecha_inicio)::DATE
                      AND DATE_TRUNC('month', p_fecha_fin)::DATE;

    INSERT INTO retail.resumen_ventas_mensual (
        periodo,
        ciudad,
        canal_venta,
        estado_venta,
        cantidad_ventas,
        cantidad_clientes,
        cantidad_productos,
        total_unidades,
        total_ventas,
        ticket_promedio
    )
    SELECT
        DATE_TRUNC('month', v.fecha_venta)::DATE AS periodo,
        c.ciudad,
        v.canal_venta,
        v.estado_venta,
        COUNT(DISTINCT v.venta_id),
        COUNT(DISTINCT c.cliente_id),
        COUNT(DISTINCT dv.producto_id),
        COALESCE(SUM(dv.cantidad), 0),
        COALESCE(SUM(dv.subtotal), 0),
        COALESCE(ROUND(SUM(dv.subtotal) / NULLIF(COUNT(DISTINCT v.venta_id), 0), 2), 0)
    FROM retail.ventas v
    INNER JOIN retail.clientes c ON v.cliente_id = c.cliente_id
    INNER JOIN retail.detalle_ventas dv ON v.venta_id = dv.venta_id
    WHERE v.fecha_venta >= p_fecha_inicio
      AND v.fecha_venta < p_fecha_fin + INTERVAL '1 day'
    GROUP BY
        DATE_TRUNC('month', v.fecha_venta)::DATE,
        c.ciudad,
        v.canal_venta,
        v.estado_venta;

    GET DIAGNOSTICS p_registros_procesados = ROW_COUNT;
    p_mensaje := 'Resumen mensual generado correctamente';

EXCEPTION
    WHEN OTHERS THEN
        p_registros_procesados := 0;
        p_mensaje := 'Error al generar resumen mensual: ' || SQLERRM;
        RAISE;
END;
$$;
