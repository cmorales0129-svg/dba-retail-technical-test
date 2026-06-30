# Modelo de datos retail

## Tablas principales

- `retail.clientes`
- `retail.productos`
- `retail.ventas`
- `retail.detalle_ventas`
- `retail.resumen_ventas_mensual`

## Relaciones

clientes 1 ─ N ventas 1 ─ N detalle_ventas N ─ 1 productos

## Llaves

- `clientes.cliente_id`
- `productos.producto_id`
- `ventas.venta_id`
- `detalle_ventas.detalle_id`
