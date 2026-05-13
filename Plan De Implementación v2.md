# 📘 PLAN DE IMPLEMENTACIÓN PROFESIONAL: DeckTCG (Tienda de Coleccionables)

> **Alcance:** Aplicación multiplataforma (Android, iOS, Web, Windows) desarrollada en Flutter/Dart, con backend en Firebase (Auth + Firestore). Gestión de estado vía `Provider`. Sin integración de analíticas ni telemetría de producción. Estructura centralizada en directorio `bin/`. Documento exclusivamente procedimental y arquitectónico.

---

## 🗂 1. Arquitectura y Estructura de Directorios (`bin/`)

Flutter exige por convención `lib/` en la raíz del proyecto. Para cumplir con la solicitud de centralizar la lógica en `bin/`, se configurará el proyecto con un *entry-point* personalizado y se mantendrá la estructura modular profesional.

```
deck_tcg/
├── bin/
│   ├── lib/
│   │   ├── main.dart                    # Punto de entrada configurado
│   │   ├── core/                        # Configuraciones globales
│   │   │   ├── constants/
│   │   │   ├── routing/
│   │   │   ├── theme/
│   │   │   └── utils/
│   │   ├── data/
│   │   │   ├── models/                  # Clases DTO/Entity
│   │   │   ├── repositories/            # Abstracción de acceso a datos
│   │   │   └── services/                # Firebase Auth & Firestore wrappers
│   │   ├── domain/                      # Reglas de negocio puras
│   │   │   ├── use_cases/
│   │   │   └── value_objects/
│   │   └── presentation/
│   │       ├── providers/               # ChangeNotifiers
│   │       ├── screens/                 # Vistas por funcionalidad
│   │       └── widgets/                 # Componentes reutilizables
│   └── assets/
│       ├── fonts/
│       ├── images/
│       └── icons/
├── android/, ios/, web/, windows/       # Carpetas de plataforma (auto-generadas)
└── pubspec.yaml                         # Configuración con `flutter: {entry-point: bin/lib/main.dart}`
```

**Nota de configuración:** En `pubspec.yaml`, se definirá explícitamente la ruta de entrada y se habilitará la generación de assets desde `bin/assets/`. El resto de carpetas de plataforma permanecen en la raíz para compatibilidad con `flutter build`.

---

## 🛠 2. Stack Tecnológico y Configuración de Entorno

| Componente | Especificación |
|------------|----------------|
| Framework | Flutter 3.24+ / Dart 3.5+ |
| IDE | VS Code + Extensiones: `Flutter`, `Dart`, `Error Lens`, `Pubspec Assist`, `Firebase` |
| Backend | Firebase Console (Auth + Firestore) |
| Autenticación | Email/Password (sin OAuth, sin 3rd party) |
| Plataformas | Android, iOS, Web, Windows |
| Analíticas | **Desactivadas** explícitamente. No se incluirán paquetes ni inicialización de `firebase_analytics`, `crashlytics` ni `remote_config`. |
| Entorno de Desarrollo | Firebase Emulators (Auth, Firestore) para pruebas locales aisladas |

---

## 🎨 3. Sistema de Diseño UI/UX y Paleta de Colores

### Principios de Diseño
- **Estética TCG Premium:** Fondos oscuros para resaltar arte de cartas, alto contraste para legibilidad de datos técnicos.
- **Jerarquía Visual:** Rareza → Condición → Precio → Metadatos. Uso de badges, iconografía vectorial y espaciado consistente.
- **Responsive:** Layouts adaptativos con `LayoutBuilder` + `ResponsiveFramework`. Grid 1-2 (móvil), 3 (tablet), 4 (desktop/web).
- **Accesibilidad:** Cumplimiento WCAG 2.1 AA. Navegación por teclado/web, semántica activada, contraste mínimo 4.5:1.
- **Feedback UI:** Estados claros: `loading`, `success`, `error`, `empty`, `offline`. Transiciones suaves entre pantallas.

### Paleta de Colores (Códigos HEX)

| Categoría | Color | HEX | Uso Principal |
|-----------|-------|-----|---------------|
| **Fondo Principal** | `bg_primary` | `#0F1115` | Canvas global, pantallas |
| **Superficie** | `surface` | `#1A1D24` | Cards, drawers, modales |
| **Primer Plano (Texto/Iconos)** | `fg_primary` | `#E8E9EC` | Títulos, datos principales |
| **Primer Plano Secundario** | `fg_secondary` | `#9CA3AF` | Subtítulos, metadatos, labels |
| **Acento Principal** | `accent_primary` | `#8B5CF6` | Botones primarios, links, indicadores |
| **Acento Secundario** | `accent_secondary` | `#F59E0B` | Destacados, ofertas, rareza alta |
| **Éxito** | `success` | `#10B981` | Stock disponible, confirmaciones |
| **Advertencia** | `warning` | `#F97316` | Stock bajo, validaciones |
| **Error** | `error` | `#EF4444` | Fallos de autenticación, errores críticos |
| **Raro (Foil)** | `rarity_foil` | `#C084FC` | Bordes/iconos cartas foil |
| **Legendario** | `rarity_legendary` | `#FBBF24` | Rareza máxima, destacados |
| **Borde/Divisor** | `border_subtle` | `#2D313A` | Separadores, inputs desactivados |

**Tipografía recomendada:** `Inter` o `Satoshi` (Google Fonts). Pesos: 400 (regular), 500 (medium), 600 (semibold), 700 (bold).
**Espaciado:** Sistema 4pt base. Componentes con padding/margin en múltiplos de 4.

---

## 🗃 4. Modelo de Datos y Mapeo a Firestore

Firestore es NoSQL. Las tablas relacionales proporcionadas se mapearán a **colecciones planas** con referencias por ID para optimizar consultas, escalabilidad y costos de lectura.

| Entidad Original | Colección Firestore | Estructura del Documento | Índices Recomendados |
|------------------|---------------------|--------------------------|----------------------|
| `Games` | `games` | `{game_id, name, manufacturer}` | `name` (ASC) |
| `Sets` | `sets` | `{set_id, game_id, name, release_date, set_code}` | `game_id`, `release_date` |
| `Master_Cards` | `cards` | `{card_id, set_id, collector_number, name, rarity, card_type}` | `set_id`, `rarity`, `card_type` |
| `Inventory_Items` | `inventory` | `{sku_id, card_id, condition, is_foil, language, price_current, stock_quantity}` | `card_id`, `condition`, `is_foil`, `language`, `stock_quantity` |
| `Users` | `users` | `{user_id, username, email, password_hash*, role}` | `email` (único), `role` |
| `Orders` | `orders` | `{order_id, user_id, order_date, total_amount, status}` | `user_id`, `order_date`, `status` |
| `Order_Items` | `order_items` | `{order_item_id, order_id, sku_id, quantity, price_at_sale}` | `order_id`, `sku_id` |
| `Price_History` | `price_history` | `{history_id, card_id, market_price, recorded_at}` | `card_id`, `recorded_at` |
| `Wishlists` | `wishlists` | `{wishlist_id, user_id, card_id, added_at}` | `user_id`, `card_id` |
| `Shipping_Details` | `shipments` | `{shipping_id, order_id, address, tracking_number, courier_name}` | `order_id` |
| `Payment_Methods` | `payment_methods` | `{payment_id, user_id, provider, last_four_digits, expiry_date}` | `user_id` |
| `Reviews` | `reviews` | `{review_id, user_id, card_id, rating, comment, created_at}` | `card_id`, `rating`, `created_at` |

**Notas de implementación:**
- `password_hash` es manejado internamente por Firebase Auth. En Firestore solo se almacenan metadatos de usuario.
- Las relaciones se resuelven mediante `card_id`, `order_id`, etc. Se recomienda mantener referencias planas y usar `where('field', isEqualTo: value)` con índices compuestos.
- `inventory` y `price_history` pueden crecer rápidamente. Se aplicarán consultas paginadas y se evitarán lecturas masivas no filtradas.
- Reglas de seguridad (esquema conceptual):
  - `games`, `sets`, `cards`, `inventory`: lectura pública, escritura solo `role == 'admin'`.
  - `users`, `orders`, `wishlists`, `payment_methods`: lectura/escritura solo `request.auth.uid == resource.data.user_id`.
  - `reviews`: escritura autenticada, moderación admin para edición/eliminación.

---

## 📦 5. Dependencias Requeridas (`pubspec.yaml`)

*(Lista conceptual sin versiones fijas para evitar conflictos. Se recomienda usar `flutter pub add` o `pubspec_assist` para resolver dependencias compatibles con la versión estable de Flutter)*

| Categoría | Paquete | Propósito |
|-----------|---------|-----------|
| **Core** | `flutter`, `dart` | Framework y lenguaje base |
| **Estado** | `provider` | Gestión de estado reactivo y ciclo de vida |
| **Firebase** | `firebase_core` | Inicialización segura |
| | `firebase_auth` | Autenticación email/password |
| | `cloud_firestore` | Persistencia y streams de datos |
| **UI/UX** | `google_fonts` | Tipografías personalizadas |
| | `flutter_svg` | Iconografía vectorial |
| | `cached_network_image` | Carga y cache de imágenes de cartas |
| | `responsive_framework` | Layouts adaptables multiplataforma |
| | `skeletonizer` o `shimmer` | Estados de carga visuales |
| **Utilidades** | `intl` | Formateo de moneda, fechas, locales |
| | `shared_preferences` | Persistencia local ligera (carrito offline, tema) |
| | `flutter_secure_storage` | Almacenamiento cifrado de tokens/sesiones |
| **Validación** | `formz` o `email_validator` | Validación estructurada de formularios |
| **Dev/Testing** | `flutter_lints` | Reglas de calidad y estilo |
| | `mocktail` | Mocking para pruebas unitarias |
| | `integration_test` | Pruebas de flujo completo |

**Exclusiones explícitas:** `firebase_analytics`, `firebase_crashlytics`, `firebase_remote_config`, `sentry_flutter`, `mixpanel`, `posthog`.

---

## 🔄 6. Arquitectura de Estado con Provider

- **Contenedor global:** `MultiProvider` en `main.dart` inyectando todos los notifiers.
- **Notifiers por dominio:**
  - `AuthProvider`: Estado de sesión, rol, token de autenticación, errores de login/registro, recuperación de contraseña.
  - `CatalogProvider`: Listado de cartas, filtros activos, paginación, estado de búsqueda, cache local.
  - `CartProvider`: Items temporales, totales, sincronización con Firestore post-login, persistencia `shared_preferences`.
  - `OrderProvider`: Creación de pedidos, historial, estados de seguimiento, integración con `shipments`.
  - `WishlistProvider`: Guardar/eliminar favoritos, sincronización con `wishlists`.
  - `UIProvider`: Tema, idioma, estado de navegación, snackbars globales, modo offline/online.
- **Ciclo de vida:** 
  - `addPostFrameCallback` para inicializaciones asíncronas.
  - `dispose()` explícito en streams de Firestore para evitar memory leaks.
  - Uso de `context.read<T>()` para acciones unidireccionales y `context.watch<T>()` para reconstrucción reactiva.
  - Evitar `Provider` dentro de bucles de renderizado. Centralizar lógica de negocio en `domain/use_cases/`.

---

## 📋 7. Procedimiento de Implementación Paso a Paso

### 🔹 Fase 1: Inicialización y Configuración del Proyecto
1. Crear proyecto Flutter multiplataforma.
2. Configurar `pubspec.yaml` con dependencias y ruta de entrada `bin/lib/main.dart`.
3. Estructurar carpetas `bin/` según arquitectura definida.
4. Crear proyecto Firebase, habilitar Email/Password y Firestore.
5. Descargar configuraciones por plataforma y almacenarlas en carpetas correspondientes.
6. Configurar Firebase Emulators para desarrollo local.

### 🔹 Fase 2: Autenticación (Email/Password)
1. Diseñar formularios de login, registro y recuperación de contraseña con validaciones estrictas.
2. Implementar `AuthService` con métodos síncronos/asíncronos para Firebase Auth.
3. Crear `AuthProvider` que escuche cambios de estado en tiempo real.
4. Configurar guardias de ruta: redirección automática según autenticación y rol.
5. Validar casos límite: correo ya registrado, contraseña débil, cuenta bloqueada, red offline.

### 🔹 Fase 3: Capa de Datos y Firestore
1. Crear clases modelo para cada entidad con `fromJson`/`toJson`.
2. Implementar repositorios que abstraigan Firestore (evitar llamadas directas desde UI).
3. Configurar índices compuestos en Firebase Console para filtros cruzados (set + rareza + condición + idioma).
4. Aplicar reglas de seguridad por colección y verificar con emuladores.
5. Implementar paginación con `limit()` y `startAfterDocument()` para catálogos grandes.

### 🔹 Fase 4: UI/UX Foundation y Navegación
1. Definir tema global con paleta de colores, tipografía y componentes base.
2. Construir widgets reutilizables: `AppBar`, `BottomNav`, `CardItem`, `FilterChip`, `PriceTag`, `ConditionBadge`.
3. Configurar enrutamiento nominal con transiciones y protección de rutas admin.
4. Implementar placeholders de carga y estados vacíos/errores.
5. Validar responsividad en Android, iOS, Web y Windows mediante `flutter run -d <device>`.

### 🔹 Fase 5: Integración Provider + Funcionalidades Core
1. Envolver app en `MultiProvider` y conectar streams de Firestore.
2. Implementar catálogo con filtros en tiempo real y búsqueda por nombre/set.
3. Desarrollar vista de detalle: galería, metadatos, stock, botón agregar.
4. Construir carrito con persistencia local y sincronización condicional post-login.
5. Implementar checkout: validación de direcciones, resumen, confirmación de pedido.

### 🔹 Fase 6: Funcionalidades Avanzadas
1. **Wishlist:** CRUD de favoritos, sincronización con `wishlists`.
2. **Reviews:** Formulario de reseñas, validación de compra previa, visualización por carta.
3. **Price History:** Gráfico simple (línea) con datos de `price_history`, actualización periódica.
4. **Perfil:** Historial de pedidos, métodos de pago guardados, edición de datos, cierre de sesión.
5. **Admin Panel:** Rutas protegidas, CRUD de productos, gestión de stock, actualización de estados de pedido.

### 🔹 Fase 7: Pruebas y Optimización
1. Pruebas unitarias: modelos, validaciones, lógica de carrito, cálculos de totales.
2. Pruebas de widget: componentes UI, estados de carga, flujos de navegación.
3. Pruebas de integración: Auth → Firestore → UI usando emuladores.
4. Optimización: compresión de imágenes, lazy loading, reducción de rebuilds, uso de `const` constructores, `ListView.builder`.
5. Manejo de errores global: snackbars, logs locales, fallbacks offline, reintentos automáticos.

### 🔹 Fase 8: Despliegue (Sin Analíticas)
1. Compilar binarios: `flutter build apk/appbundle`, `flutter build ios`, `flutter build web`, `flutter build windows`.
2. Configurar firmas, certificados y metadatos de tienda.
3. Publicar en Google Play Console, App Store Connect, GitHub Pages/Vercel (Web), y distribuir Windows vía `.exe` o Microsoft Store.
4. Desactivar cualquier telemetría automática. Mantener logs locales solo para depuración manual.
5. Documentar arquitectura, flujos, reglas de Firestore y procedimientos de mantenimiento en `README.md`.

---

## 🔒 8. Seguridad, Validación y Estrategia Offline

- **Validación de entrada:** Email regex, contraseña ≥8 caracteres (mayúscula, minúscula, número, símbolo), campos requeridos, límites de longitud.
- **Seguridad de datos:** Nunca almacenar contraseñas en Firestore. Usar Firebase Auth para hashing. Tokens de sesión gestionados por SDK. `flutter_secure_storage` para metadatos sensibles.
- **Firestore Rules:** Aplicar principio de menor privilegio. Validar tipos, rangos y permisos por rol en cada operación.
- **Offline-First:** `shared_preferences` para carrito y tema. Cache de imágenes con `cached_network_image`. Firestore persistencia local activada (`enablePersistence`). Sincronización diferida al recuperar conexión.
- **Manejo de errores:** Interceptar excepciones de red, auth y Firestore. Mostrar mensajes claros al usuario. Registrar en consola local para debugging.

---

## 🧪 9. Matriz de Pruebas y Criterios de Aceptación

| Área | Criterio de Aceptación | Método de Validación |
|------|------------------------|----------------------|
| **Autenticación** | Login/registro/exit/logout funcionales en todas las plataformas | Emuladores + dispositivos reales |
| **Catálogo** | Filtros combinados, paginación, búsqueda exacta y parcial | Pruebas manuales + mocks |
| **Carrito** | Persistencia offline, sync post-login, cálculo correcto de totales | Casos de borde + integración |
| **Checkout** | Creación de orden, generación de `order_items`, estado inicial `pending` | Verificación en Firestore |
| **UI/UX** | Responsive, accesible, transiciones fluidas, contraste válido | DevTools + Lighthouse (Web) |
| **Seguridad** | Reglas de Firestore bloquean acceso no autorizado, validación de inputs | Pruebas de penetración básicas |
| **Plataformas** | Compilación exitosa, ejecución sin crashes, navegación nativa | Build pipeline + tests manuales |

---

## 📦 10. Entregables Finales y Mantenimiento

1. Código fuente estructurado en `bin/` con arquitectura escalable.
2. `pubspec.yaml` optimizado, sin dependencias de analíticas.
3. Configuración de Firebase (Auth + Firestore + reglas de seguridad).
4. Binarios compilados para Android, iOS, Web y Windows.
5. Documentación técnica: arquitectura, flujos de datos, índice de colecciones, guías de despliegue.
6. Guía de mantenimiento: actualización de dependencias, gestión de índices, rotación de claves, respaldo de Firestore.

**Recomendación de ciclo de vida:** 
- Lanzar MVP con catálogo, carrito, checkout y perfil básico.
- Iterar con reviews, price history y panel admin.
- Mantener actualizaciones trimestrales de SDK y dependencias.
- Monitorear manualmente logs y reportes de usuarios (sin telemetría automática).

---

> ✅ **Estado del Plan:** Listo para ejecución. No requiere modificaciones arquitectónicas adicionales para comenzar la fase 1. ¿Deseas que se genere el siguiente entregable: diagrama de flujos de navegación, especificación detallada de reglas de Firestore por colección, o checklist de configuración de entorno por plataforma?


## PROMPT

CREA EL PLAN DE IMPLEMENTACION MAS PROFESIONAL Y EXTENSO basado en el anterior, en pocas palabras mejoralo.
framework:flutter dart
base de datos en la nube: console firebase, firestore
Autenticación por correo electrónico y passworf.
no usar analiticas, ni para producción.
Estructura de carpetas y archivos dentro de la carpeta bin.
aplicación para: android/web/iOS/windows
diseño UI, UX y establece que colores vas a usar en primer plano
las dependencias de pubsec.yaml
Agregar las tablas o entidades con sus atributos.
utilizar provider
agrega tambien una tabla con los colores y sus codigos para la aplicacion.
agrega la demas informacion que sea necesaria.

estos son mis tablas:
Games: game_id, name, manufacturer.
Sets: set_id, game_id, name, release_date, set_code.
Master_Cards: card_id, set_id, collector_number, name, rarity, card_type.
Inventory_Items: sku_id, card_id, condition, is_foil, language, price_current, stock_quantity.
Users: user_id, username, email, password_hash, role.
Orders: order_id, user_id, order_date, total_amount, status.
Order_Items: order_item_id, order_id, sku_id, quantity, price_at_sale.
Price_History: history_id, card_id, market_price, recorded_at.
Wishlists: wishlist_id, user_id, card_id, added_at.
Shipping_Details: shipping_id, order_id, address, tracking_number, courier_name.
Payment_Methods: payment_id, user_id, provider, last_four_digits, expiry_date.
Reviews: review_id, user_id, card_id, rating, comment, created_at.
