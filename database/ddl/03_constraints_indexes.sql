CREATE INDEX IF NOT EXISTS idx_ventas_cliente_id
ON retail.ventas(cliente_id);

CREATE INDEX IF NOT EXISTS idx_ventas_fecha_venta
ON retail.ventas(fecha_venta);

CREATE INDEX IF NOT EXISTS idx_detalle_ventas_venta_id
ON retail.detalle_ventas(venta_id);

CREATE INDEX IF NOT EXISTS idx_detalle_ventas_producto_id
ON retail.detalle_ventas(producto_id);

CREATE INDEX IF NOT EXISTS idx_productos_categoria
ON retail.productos(categoria);
