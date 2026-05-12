# 📋 Plan de Implementación: DeckTCG (Tienda de Coleccionables)

## 🎯 Objetivo General
Diseñar y desarrollar una aplicación multiplataforma (Android, iOS, Web) para la compra, venta y gestión de cartas coleccionables (TCG), utilizando **Flutter**, **Firebase**, **Provider** como gestor de estado y **VS Code** como IDE principal. El plan prioriza arquitectura limpia, experiencia de usuario fluida, seguridad de datos y escalabilidad.

---

## 🛠️ Entorno de Desarrollo y Herramientas Recomendadas
| Categoría | Herramienta | Propósito |
|-----------|-------------|-----------|
| IDE Principal | **VS Code** | Desarrollo Flutter con extensiones específicas |
| Extensiones VS Code | `Flutter`, `Dart`, `Firebase`, `Pubspec Assist`, `Error Lens`, `GitLens`, `Error Lens` | Autocompletado, depuración, gestión de paquetes y control de versiones |
| SDK | **Flutter SDK** (canal estable) | Framework multiplataforma |
| Backend | **Firebase Console** + **Firebase CLI** | Auth, Firestore, Storage, Hosting, Analytics |
| Diseño UI/UX | **Figma** + **Flutter DevTools** | Prototipado, inspección de layouts, profiling |
| Control de Versiones | **Git** + **GitHub/GitLab** | Historial, ramas, colaboración, CI/CD opcional |
| Pruebas | `flutter test`, `integration_test`, Firebase Test Lab | Unit, widget e integración |
| *Nota:* "Antigravity" no es un IDE reconocido para Flutter. Se recomienda VS Code (o Android Studio) como entorno oficial. |

---

## 📦 Dependencias (`pubspec.yaml`)
Utiliza `flutter pub add <paquete>` para instalar las versiones más estables al momento de desarrollo. Agrupadas por función:

| Categoría | Paquete | Función |
|-----------|---------|---------|
| **Firebase Core** | `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage` | Infraestructura backend |
| **Estado** | `provider` | Gestión reactiva de UI y datos |
| **Navegación** | `go_router` (opcional pero recomendado) o `provider` + `Navigator` | Rutas declarativas y protección |
| **Imágenes & Cache** | `cached_network_image`, `image_picker`, `flutter_cache_manager` | Carga eficiente y selección de archivos |
| **Formularios & Validación** | `formz`, `intl` | Validación robusta y formato de moneda/fechas |
| **Almacenamiento Local** | `shared_preferences`, `flutter_secure_storage` | Persistencia ligera y credenciales sensibles |
| **Utilidades** | `uuid`, `collection`, `equatable` | IDs únicos, manipulación de listas, igualdad de modelos |
| **Testing** | `mockito`, `flutter_test`, `integration_test` | Pruebas unitarias y de integración |

---

## 🎨 Lineamientos UI/UX para DeckTCG
- **Paleta y Tema:** Modo claro/oscuro con acentos inspirados en rarezas de cartas (común, rara, épica, legendaria). Alto contraste para legibilidad.
- **Tipografía:** Sans-serif moderna (ej. `Inter` o `Roboto`). Jerarquía clara: títulos > precios > metadatos > descripciones.
- **Componentes Clave:**
  - Tarjetas de producto con badge de rareza/estado (NM, LP, MP, DM)
  - Filtros por juego, expansión, tipo, precio y disponibilidad
  - Carrito persistente y checkout de 3 pasos
  - Vista de colección personal con estado y fecha de adquisición
- **Navegación:** `BottomNavigationBar` (Inicio, Catálogo, Carrito, Colección, Perfil) + `Drawer` o pestañas secundarias para filtros avanzados.
- **Accesibilidad:** Soporte para escalado de texto, contraste WCAG AA, etiquetas semánticas, navegación por teclado (Web).
- **Responsividad:** Grids adaptativos (`SliverGrid`, `LayoutBuilder`), manejo de orientación y safe areas en móviles/desktop.

---

## 🏗️ Arquitectura y Estructura del Proyecto
Se recomienda **Feature-First + Layered Architecture** con `Provider`:
```
lib/
├── core/           # Constantes, temas, utilidades, enrutador base, errores
├── data/           # Repositorios, fuentes de datos (Firestore, Storage, local)
├── domain/         # Modelos, entidades, casos de uso, interfaces
├── presentation/   # Widgets, pantallas, viewmodels (ChangeNotifier), providers
├── main.dart       # Punto de entrada, inicialización, MultiProvider
└── firebase_options.dart  # Generado por Firebase CLI
```
- **Provider:** Un `ChangeNotifierProvider` por dominio (`AuthProvider`, `ProductProvider`, `CartProvider`, `CollectionProvider`).
- **Repositorio Pattern:** Abstracción de Firestore para facilitar testing y migración futura.
- **Offline First:** Habilitar `FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true)`.

---

## 🔐 Flujo de Autenticación (Email/Password)
1. Registro con validación de formato, confirmación y términos.
2. Login con manejo de estados: `idle`, `loading`, `success`, `error`.
3. Recuperación de contraseña vía `sendPasswordResetEmail`.
4. Sesión persistente gestionada por Firebase Auth + `authStateChanges` stream.
5. Redirección automática a pantalla principal si ya está autenticado.
6. Cierre de sesión seguro y limpieza de estado local.

---

## 🗃️ Diseño de Base de Datos (Firestore)
Estructura relacional/documental optimizada para consultas frecuentes:

| Colección | Documentos | Campos Clave |
|-----------|------------|--------------|
| `users/{uid}` | Perfiles | `email`, `displayName`, `createdAt`, `role`, `shippingAddress`, `favorites[]` |
| `products/{id}` | Catálogo | `name`, `game`, `set`, `rarity`, `condition`, `price`, `stock`, `imageUrl`, `tags[]`, `createdAt` |
| `cart/{uid}/items` | Items temporales | `productId`, `quantity`, `addedAt` (subcolección o mapa) |
| `orders/{id}` | Compras | `userId`, `items[]`, `total`, `status`, `paymentRef`, `createdAt` |
| `collections/{uid}/cards` | Inventario personal | `productId`, `condition`, `acquisitionDate`, `notes`, `quantity` |

- **Índices compuestos:** Para filtros combinados (game + rarity + price asc/desc).
- **Reglas de Seguridad:** Acceso granular por `uid`, validación de tipos y límites de escritura.
- **Paginación:** `startAfterDocument` + `limit()` para catálogo infinito.

---

## 📝 Procedimiento Paso a Paso

### 🔹 Fase 1: Configuración Inicial
1. Instalar Flutter SDK, VS Code y extensiones requeridas.
2. Crear proyecto: `flutter create decktcg --org com.tudeck --platforms=android,ios,web`.
3. Configurar control de versiones e ignorar `build/`, `.dart_tool/`, `*.iml`.
4. Inicializar Firebase CLI y conectar proyecto con `flutterfire configure`.

### 🔹 Fase 2: Estructura y Arquitectura Base
1. Crear carpetas `core/`, `data/`, `domain/`, `presentation/`.
2. Definir modelo base para `User`, `Product`, `CartItem`.
3. Configurar tema global (`ThemeData`), tipografía y paleta en `core/theme.dart`.
4. Implementar router base con protección de rutas no autenticadas.

### 🔹 Fase 3: UI/UX y Navegación
1. Diseñar wireframes en Figma (Home, ProductDetail, Cart, Profile, Auth).
2. Implementar layout responsive con `Scaffold`, `BottomNavigationBar`, `CustomScrollView`.
3. Crear componentes reutilizables: `TCGCardWidget`, `FilterChipGroup`, `PriceLabel`, `EmptyState`.
4. Validar accesibilidad y modo oscuro/claro.

### 🔹 Fase 4: Autenticación
1. Implementar `AuthProvider` con `ChangeNotifier`.
2. Conectar `FirebaseAuth.instance.authStateChanges()` para sincronizar estado.
3. Desarrollar pantallas: `LoginScreen`, `RegisterScreen`, `ResetPasswordScreen`.
4. Manejar errores UI-friendly (email inválido, contraseña débil, usuario existente).
5. Implementar guardias de navegación.

### 🔹 Fase 5: Integración con Firestore
1. Crear `ProductRepository`, `CartRepository`, `CollectionRepository`.
2. Implementar streams (`StreamProvider`) para catálogo en tiempo real.
3. Configurar paginación y búsqueda básica (etiquetas, filtros).
4. Habilitar persistencia offline y manejo de errores de red.

### 🔹 Fase 6: Gestión de Estado con Provider
1. Envolver app en `MultiProvider`.
2. Crear `CartProvider` (agregar, eliminar, calcular total, sincronizar con Firestore).
3. Crear `CollectionProvider` (CRUD de inventario personal).
4. Optimizar rebuilds con `Consumer`, `Selector`, y `context.watch` solo donde sea necesario.

### 🔹 Fase 7: Funcionalidades Core
1. Catálogo: Grid paginado, filtros, ordenamiento, vista detalle.
2. Carrito: Edición de cantidades, resumen, checkout simulado (integración de pasarela futura).
3. Colección: Vista tipo álbum, búsqueda interna, exportación/importación (CSV/JSON opcional).
4. Perfil: Datos de usuario, historial de pedidos, configuración de tema, cierre de sesión.

### 🔹 Fase 8: Optimización y Pulido
1. Revisar rendimiento con Flutter DevTools (rebuilds, memoria, FPS).
2. Implementar lazy loading, caching de imágenes, skeletons de carga.
3. Manejar estados vacíos, errores y sin conexión con UX clara.
4. Localización básica (es/en) si se planea internacionalización.

---

## 🧪 Pruebas y Control de Calidad
- **Unit Tests:** Repositorios, modelos, lógica de `ChangeNotifier`.
- **Widget Tests:** Componentes UI, formularios, validaciones.
- **Integration Tests:** Flujo completo Auth → Catálogo → Carrito → Checkout.
- **Análisis Estático:** `flutter analyze`, `dart fix --apply`, linting estricto.
- **Pruebas Multiplataforma:** Emuladores (iOS/Android), Chrome, Firebase Test Lab.

---

## 🚀 Despliegue Multiplataforma
| Plataforma | Pasos Clave |
|------------|-------------|
| **Android** | `flutter build appbundle`, firmar APK/AAB, configurar Play Console, cumplir políticas |
| **iOS** | `flutter build ios --release`, configurar App Store Connect, certificados, `Info.plist` |
| **Web** | `flutter build web --release`, desplegar en Firebase Hosting, configurar `base-href` y service worker |
| **Beta Testing** | Firebase App Distribution (Android/iOS), TestFlight, canales internos |
| **CI/CD (Opcional)** | GitHub Actions con `flutter-action`, `firebase-tools`, pruebas automáticas por PR |

---

## 🔒 Seguridad y Buenas Prácticas
- **Firestore Rules:** Validar `request.auth != null`, restringir escrituras por `uid`, validar tipos y rangos.
- **Datos Sensibles:** Nunca almacenar contraseñas en cliente; usar `flutter_secure_storage` si es necesario.
- **Validación de Entrada:** Sanitizar inputs, limitar longitud, usar `formz` o validadores nativos.
- **Gestión de Errores:** Centralizar con `ErrorWidget`, logging con Firebase Crashlytics (opcional).
- **Privacidad:** Política de datos clara, consentimiento explícito, cumplimiento GDPR/Ley de Protección de Datos.
- **Actualizaciones:** Versionado semántico, changelog, migraciones de DB documentadas, rollback strategy.

---

✅ **Siguientes Pasos Recomendados:**
1. Validar este plan con stakeholders o equipo.
2. Crear backlog en Jira/Notion/GitHub Projects con épicos y tareas por fase.
3. Definir milestones semanales y criterios de aceptación por pantalla/módulo.
4. Iniciar Fase 1 con `flutter create` y configuración de Firebase.

¿Deseas que profundice en algún módulo específico (ej. diseño de reglas de Firestore, estructura detallada de providers, estrategia de paginación, o flujo de checkout) antes de pasar a la fase de desarrollo?
