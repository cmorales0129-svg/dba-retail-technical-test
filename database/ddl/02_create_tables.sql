CREATE TABLE IF NOT EXISTS retail.clientes (
    cliente_id SERIAL PRIMARY KEY,
    nombres VARCHAR(80) NOT NULL,
    apellidos VARCHAR(80) NOT NULL,
    ciudad VARCHAR(80),
    numero_documento VARCHAR(30),
    email VARCHAR(120) UNIQUE,
    telefono VARCHAR(30)
);

CREATE TABLE IF NOT EXISTS retail.productos (
    producto_id SERIAL PRIMARY KEY,
    nombre_producto VARCHAR(120) NOT NULL,
    categoria VARCHAR(80),
    precio NUMERIC(12,2) CHECK (precio >= 0)
);

CREATE TABLE IF NOT EXISTS retail.ventas (
    venta_id SERIAL PRIMARY KEY,
    cliente_id INT NOT NULL REFERENCES retail.clientes(cliente_id),
    fecha_venta TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    estado_venta VARCHAR(30) NOT NULL,
    canal_venta VARCHAR(30),
    total_venta NUMERIC(14,2) DEFAULT 0
);

CREATE TABLE IF NOT EXISTS retail.detalle_ventas (
    detalle_id SERIAL PRIMARY KEY,
    venta_id INT NOT NULL REFERENCES retail.ventas(venta_id),
    producto_id INT NOT NULL REFERENCES retail.productos(producto_id),
    cantidad INT NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(12,2) NOT NULL,
    subtotal NUMERIC(14,2) NOT NULL
);
