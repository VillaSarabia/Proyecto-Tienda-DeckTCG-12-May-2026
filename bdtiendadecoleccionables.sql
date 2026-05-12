-- ============================================================
--  DeckTCG - Base de Datos: Tienda de Coleccionables
--  Archivo : bdtiendadecoleccionables.sql
--  Motor   : PostgreSQL 15+
-- ============================================================

-- ============================================================
-- EXTENSIONES
-- ============================================================
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================
-- DOMINIO: CATÁLOGO DE PRODUCTOS
-- ============================================================

CREATE TABLE categoria (
    id          SERIAL       PRIMARY KEY,
    nombre      VARCHAR(100) NOT NULL UNIQUE,
    descripcion TEXT,
    padre_id    INT          REFERENCES categoria(id) ON DELETE SET NULL
);

CREATE TABLE marca (
    id      SERIAL       PRIMARY KEY,
    nombre  VARCHAR(100) NOT NULL UNIQUE,
    contacto VARCHAR(150),
    email   VARCHAR(150),
    url     VARCHAR(255)
);

CREATE TABLE edicion (
    id            SERIAL       PRIMARY KEY,
    nombre        VARCHAR(150) NOT NULL,
    codigo        VARCHAR(20)  UNIQUE,
    marca_id      INT          NOT NULL REFERENCES marca(id) ON DELETE RESTRICT,
    fecha_lanzamiento DATE,
    descripcion   TEXT
);

CREATE TABLE condicion (
    id          SERIAL      PRIMARY KEY,
    nombre      VARCHAR(50) NOT NULL UNIQUE,   -- Mint, Near Mint, Played…
    descripcion TEXT
);

CREATE TABLE producto (
    id            SERIAL        PRIMARY KEY,
    nombre        VARCHAR(200)  NOT NULL,
    sku           VARCHAR(60)   UNIQUE,
    categoria_id  INT           NOT NULL REFERENCES categoria(id) ON DELETE RESTRICT,
    marca_id      INT           NOT NULL REFERENCES marca(id)     ON DELETE RESTRICT,
    edicion_id    INT           REFERENCES edicion(id)            ON DELETE SET NULL,
    condicion_id  INT           NOT NULL REFERENCES condicion(id) ON DELETE RESTRICT,
    descripcion   TEXT,
    bool          BOOLEAN       NOT NULL DEFAULT TRUE,  -- activo/inactivo
    imagen_url    VARCHAR(255)
);

-- ============================================================
-- DOMINIO: PRECIOS Y PROMOCIONES
-- ============================================================

CREATE TABLE precio (
    id          SERIAL         PRIMARY KEY,
    producto_id INT            NOT NULL REFERENCES producto(id) ON DELETE CASCADE,
    precio      NUMERIC(10,2)  NOT NULL CHECK (precio >= 0),
    fecha       TIMESTAMPTZ    NOT NULL DEFAULT NOW(),
    motivo      VARCHAR(100)                             -- rebaja, revalorización…
);

CREATE TABLE descuento (
    id               SERIAL        PRIMARY KEY,
    nombre           VARCHAR(100)  NOT NULL,
    tipo             VARCHAR(20)   NOT NULL CHECK (tipo IN ('porcentaje','monto_fijo')),
    valor            NUMERIC(10,2) NOT NULL CHECK (valor > 0),
    fecha_inicio     DATE          NOT NULL,
    fecha_fin        DATE,
    activo           BOOLEAN       NOT NULL DEFAULT TRUE
);

CREATE TABLE cupon (
    id           SERIAL        PRIMARY KEY,
    codigo       VARCHAR(50)   NOT NULL UNIQUE,
    descuento_id INT           NOT NULL REFERENCES descuento(id) ON DELETE CASCADE,
    uso_maximo   INT,
    usos_actuales INT          NOT NULL DEFAULT 0,
    fecha_inicio DATE          NOT NULL,
    fecha_fin    DATE
);

-- ============================================================
-- DOMINIO: INVENTARIO
-- ============================================================

CREATE TABLE ubicacion (
    id      SERIAL      PRIMARY KEY,
    nombre  VARCHAR(100) NOT NULL,   -- Estante A2, Caja 3, Almacén…
    detalle TEXT
);

CREATE TABLE inventario (
    id           SERIAL        PRIMARY KEY,
    producto_id  INT           NOT NULL REFERENCES producto(id)  ON DELETE CASCADE,
    ubicacion_id INT           REFERENCES ubicacion(id)          ON DELETE SET NULL,
    stock        INT           NOT NULL DEFAULT 0 CHECK (stock >= 0),
    stock_minimo INT           NOT NULL DEFAULT 1
);

CREATE TABLE movimiento_inv (
    id           SERIAL        PRIMARY KEY,
    producto_id  INT           NOT NULL REFERENCES producto(id)  ON DELETE RESTRICT,
    tipo         VARCHAR(20)   NOT NULL CHECK (tipo IN ('entrada','salida','ajuste')),
    cantidad     INT           NOT NULL,
    motivo       VARCHAR(100),          -- compra, venta, devolución, ajuste físico
    referencia   VARCHAR(100),          -- nro. de orden, nro. de compra…
    fecha        TIMESTAMPTZ   NOT NULL DEFAULT NOW()
);

-- ============================================================
-- DOMINIO: CLIENTES Y USUARIOS
-- ============================================================

CREATE TABLE usuario (
    id             SERIAL        PRIMARY KEY,
    nombre         VARCHAR(100)  NOT NULL,
    email          VARCHAR(150)  NOT NULL UNIQUE,
    telefono       VARCHAR(20),
    fecha_registro TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    rol            VARCHAR(20)   NOT NULL DEFAULT 'cliente'
                                 CHECK (rol IN ('admin','staff','cliente'))
);

CREATE TABLE cliente (
    id          SERIAL       PRIMARY KEY,
    usuario_id  INT          NOT NULL UNIQUE REFERENCES usuario(id) ON DELETE CASCADE,
    rfc         VARCHAR(20),
    notas       TEXT
);

CREATE TABLE direccion (
    id          SERIAL        PRIMARY KEY,
    cliente_id  INT           NOT NULL REFERENCES cliente(id) ON DELETE CASCADE,
    calle       VARCHAR(200)  NOT NULL,
    ciudad      VARCHAR(100)  NOT NULL,
    estado      VARCHAR(100),
    cp          VARCHAR(10),
    pais        VARCHAR(60)   NOT NULL DEFAULT 'México',
    principal   BOOLEAN       NOT NULL DEFAULT FALSE
);

CREATE TABLE lista_deseos (
    id          SERIAL      PRIMARY KEY,
    cliente_id  INT         NOT NULL REFERENCES cliente(id)  ON DELETE CASCADE,
    producto_id INT         NOT NULL REFERENCES producto(id) ON DELETE CASCADE,
    fecha       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (cliente_id, producto_id)
);

-- ============================================================
-- DOMINIO: VENTAS
-- ============================================================

CREATE TABLE orden (
    id           SERIAL        PRIMARY KEY,
    cliente_id   INT           NOT NULL REFERENCES cliente(id) ON DELETE RESTRICT,
    fecha        TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    estado       VARCHAR(30)   NOT NULL DEFAULT 'pendiente'
                               CHECK (estado IN ('pendiente','confirmada','enviada',
                                                 'entregada','cancelada','devuelta')),
    total        NUMERIC(12,2) NOT NULL CHECK (total >= 0),
    cupon_id     INT           REFERENCES cupon(id) ON DELETE SET NULL,
    notas        TEXT
);

CREATE TABLE detalle_orden (
    id              SERIAL        PRIMARY KEY,
    orden_id        INT           NOT NULL REFERENCES orden(id)    ON DELETE CASCADE,
    producto_id     INT           NOT NULL REFERENCES producto(id) ON DELETE RESTRICT,
    cantidad        INT           NOT NULL CHECK (cantidad > 0),
    precio_unitario NUMERIC(10,2) NOT NULL CHECK (precio_unitario >= 0),
    descuento_id    INT           REFERENCES descuento(id)         ON DELETE SET NULL,
    precio_final    NUMERIC(10,2) NOT NULL CHECK (precio_final >= 0)
);

CREATE TABLE pago (
    id          SERIAL        PRIMARY KEY,
    orden_id    INT           NOT NULL REFERENCES orden(id) ON DELETE RESTRICT,
    monto       NUMERIC(12,2) NOT NULL CHECK (monto > 0),
    metodo      VARCHAR(50)   NOT NULL,   -- tarjeta, transferencia, efectivo…
    estado      VARCHAR(20)   NOT NULL DEFAULT 'pendiente'
                              CHECK (estado IN ('pendiente','completado','fallido','reembolsado')),
    fecha       TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    referencia  VARCHAR(100)
);

CREATE TABLE envio (
    id            SERIAL       PRIMARY KEY,
    orden_id      INT          NOT NULL REFERENCES orden(id)     ON DELETE RESTRICT,
    direccion_id  INT          NOT NULL REFERENCES direccion(id) ON DELETE RESTRICT,
    paqueteria    VARCHAR(100),
    numero_guia   VARCHAR(100),
    estado        VARCHAR(30)  NOT NULL DEFAULT 'preparando'
                               CHECK (estado IN ('preparando','en_camino','entregado','devuelto')),
    fecha_envio   TIMESTAMPTZ,
    fecha_entrega TIMESTAMPTZ
);

CREATE TABLE devolucion (
    id          SERIAL       PRIMARY KEY,
    orden_id    INT          NOT NULL REFERENCES orden(id)    ON DELETE RESTRICT,
    motivo      TEXT         NOT NULL,
    estado      VARCHAR(30)  NOT NULL DEFAULT 'solicitada'
                             CHECK (estado IN ('solicitada','aprobada','rechazada','completada')),
    fecha       TIMESTAMPTZ  NOT NULL DEFAULT NOW()
);

-- ============================================================
-- DOMINIO: COMPRAS (ABASTECIMIENTO)
-- ============================================================

CREATE TABLE proveedor (
    id        SERIAL       PRIMARY KEY,
    nombre    VARCHAR(150) NOT NULL,
    contacto  VARCHAR(100),
    email     VARCHAR(150),
    telefono  VARCHAR(20),
    url       VARCHAR(255)
);

CREATE TABLE orden_compra (
    id            SERIAL        PRIMARY KEY,
    proveedor_id  INT           NOT NULL REFERENCES proveedor(id) ON DELETE RESTRICT,
    fecha         TIMESTAMPTZ   NOT NULL DEFAULT NOW(),
    estado        VARCHAR(30)   NOT NULL DEFAULT 'pendiente'
                                CHECK (estado IN ('pendiente','recibida','cancelada')),
    total         NUMERIC(12,2) NOT NULL CHECK (total >= 0)
);

CREATE TABLE detalle_orden_compra (
    id               SERIAL        PRIMARY KEY,
    orden_compra_id  INT           NOT NULL REFERENCES orden_compra(id) ON DELETE CASCADE,
    producto_id      INT           NOT NULL REFERENCES producto(id)     ON DELETE RESTRICT,
    cantidad         INT           NOT NULL CHECK (cantidad > 0),
    precio_unitario  NUMERIC(10,2) NOT NULL CHECK (precio_unitario >= 0),
    subtotal         NUMERIC(12,2) GENERATED ALWAYS AS (cantidad * precio_unitario) STORED
);

-- ============================================================
-- ÍNDICES DE RENDIMIENTO
-- ============================================================

CREATE INDEX idx_producto_categoria  ON producto(categoria_id);
CREATE INDEX idx_producto_marca      ON producto(marca_id);
CREATE INDEX idx_producto_edicion    ON producto(edicion_id);
CREATE INDEX idx_producto_condicion  ON producto(condicion_id);
CREATE INDEX idx_inventario_producto ON inventario(producto_id);
CREATE INDEX idx_precio_producto     ON precio(producto_id);
CREATE INDEX idx_orden_cliente       ON orden(cliente_id);
CREATE INDEX idx_detalle_orden       ON detalle_orden(orden_id);
CREATE INDEX idx_pago_orden          ON pago(orden_id);
CREATE INDEX idx_movimiento_producto ON movimiento_inv(producto_id);
CREATE INDEX idx_lista_deseos_cli    ON lista_deseos(cliente_id);
CREATE INDEX idx_direccion_cliente   ON direccion(cliente_id);

-- ============================================================
-- FIN DEL SCRIPT
-- ============================================================
