Actúa como un administrador de base de datos; proyecto tienda de coleccionables (DeckTCG), que entidades se necesitan para su gestión
<img width="999" height="442" alt="AdobeExpressPhotos_eaaad6cb5aab4a14957049779d26ce08_CopyEdited" src="https://github.com/user-attachments/assets/2350f71b-e767-494d-91e8-4b5047173d1e" />
Como DBA para DeckTCG (tienda de coleccionables), aquí están las entidades principales que necesita el sistema, agrupadas por dominio:

**Catálogo de productos**
`Producto`, `Categoría`, `Marca`, `Edición` (sets/expansiones de cartas), `Condición` (mint, near mint, played…)

**Inventario**
`Inventario` (stock por producto/condición), `Ubicación` (estante, caja, almacén), `MovimientoInventario` (entradas y salidas)

**Clientes y usuarios**
`Usuario`, `Cliente`, `Dirección`, `ListaDeseos`

**Ventas**
`Orden`, `DetalleOrden`, `Pago`, `Envío`, `Devolución`

**Compras (abastecimiento)**
`Proveedor`, `OrdenCompra`, `DetalleOrdenCompra`

**Precios y promociones**
`Precio` (historial de precios), `Descuento`, `Cupón`

Aquí el diagrama ERD con las relaciones clave:Algunas decisiones de diseño importantes para DeckTCG en particular:

`Edición` merece su propia tabla porque en TCG las expansiones (sets) son fundamentales para el valor y búsqueda de cartas. Lo mismo con `Condición`, que afecta directamente el precio y el inventario.

`Precio` como tabla separada permite manejar historial de precios, que en el mercado de coleccionables es muy relevante (los precios fluctúan bastante).

`MovimientoInventario` es clave para auditoría: registra cada entrada y salida con su motivo (compra, venta, devolución, ajuste por inventario físico).

¿Quieres que profundice en algún dominio específico, como el modelo de precios dinámicos, la gestión de condición de cartas únicas (singles), o el esquema de descuentos y cupones?


## Tablas 
Las entidades con sus atributos y tipo, en forma de tabla para cada uno de las entidades

<img width="714" height="566" alt="image" src="https://github.com/user-attachments/assets/cb0444dd-d367-4694-b500-aaa78f4af9ef" />
<img width="627" height="620" alt="image" src="https://github.com/user-attachments/assets/72d2f75a-d3db-47e4-a908-e135acbff779" />
<img width="613" height="741" alt="image" src="https://github.com/user-attachments/assets/65c7de3e-56a3-4b63-b5e6-04eafee2fa01" />
<img width="607" height="751" alt="image" src="https://github.com/user-attachments/assets/543fa8ec-90b1-4815-83cd-1b1a94038fb7" />
<img width="705" height="690" alt="image" src="https://github.com/user-attachments/assets/10b6ff25-254a-433a-bf19-29994e70d345" />
<img width="613" height="614" alt="image" src="https://github.com/user-attachments/assets/9cfe6fb0-ddd2-4809-902f-6c258f498673" />
<img width="597" height="334" alt="image" src="https://github.com/user-attachments/assets/7f58d73e-17cb-4dd7-9755-4e511c9abd4e" />
<img width="547" height="719" alt="image" src="https://github.com/user-attachments/assets/513fa6a2-462d-492a-bdd7-a2e62e7cfdb9" />
<img width="637" height="601" alt="image" src="https://github.com/user-attachments/assets/48f9ff35-4ef7-49d3-868c-782a0f2b9ea9" />










