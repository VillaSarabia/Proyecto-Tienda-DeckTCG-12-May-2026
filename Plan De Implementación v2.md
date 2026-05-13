# 📘 PLAN DE IMPLEMENTACIÓN PROFESIONAL: DeckTCG (Tienda de Coleccionables)

## 1. 🎯 Descripción del Proyecto & Visión Estratégica
**DeckTCG** es una aplicación multiplataforma (Android, iOS, Web) diseñada para la gestión, descubrimiento y adquisición de cartas coleccionables (Trading Card Games). La plataforma centraliza el catálogo de productos, la gestión de inventario personal, el carrito de compras y el perfil del usuario, ofreciendo una experiencia fluida, segura y escalable.

### 🌍 Alcance del MVP
| Módulo | Funcionalidad Principal | Criterio de Éxito |
|--------|------------------------|-------------------|
| Autenticación | Registro, login, recuperación de contraseña, sesión persistente | <2s en validación, 0 fugas de tokens |
| Catálogo | Navegación paginada, filtros avanzados, búsqueda por texto/metadata, vista detalle | Carga <1.5s en 3G, filtros exactos |
| Carrito & Checkout | Gestión temporal, cálculo automático, simulación de pago, confirmación | Consistencia offline/online, validación de stock |
| Colección Personal | Registro de adquisiciones, estado físico, valor estimado, búsqueda interna | Sincronización bidireccional, exportación opcional |
| Perfil & Configuración | Datos personales, historial, preferencias de UI, cierre seguro | Cumplimiento GDPR/LGPD, auditoría de cambios |

### 🔮 Visión a Largo Plazo (V2+)
- Pasarela de pago real (Stripe, MercadoPago, PayPal)
- Marketplace P2P entre coleccionistas
- Sistema de subastas y ofertas
- Integración con APIs de precios en tiempo real (TCGplayer, Cardmarket)
- Comunidad: listas públicas, wishlists, reseñas, eventos locales

---

## 2. 🏗️ Arquitectura de Software & Estructura de Archivos
Se adopta una arquitectura **Feature-First + Layered + Clean Architecture**, optimizada para `Provider` y escalabilidad empresarial. La separación por dominios reduce acoplamiento, facilita pruebas unitarias y permite onboarding rápido de nuevos desarrolladores.

```
lib/
├── config/                     # Constantes globales, endpoints, claves de entorno
│   ├── env/                    # Configuraciones por sabor (dev, staging, prod)
│   └── app_config.dart         # Centralización de parámetros de inicialización
├── core/                       # Capa transversal (shared kernel)
│   ├── theme/                  # Tokens de diseño, tipografía, paleta, animaciones
│   ├── router/                 # Declaración de rutas, guards, transiciones
│   ├── errors/                 # Clases de excepción, mappers, manejo global
│   ├── utils/                  # Helpers de formato, validación, extensión de tipos
│   └── widgets/                # Componentes reutilizables sin lógica de negocio
├── features/                   # Módulos independientes por dominio
│   ├── auth/
│   │   ├── data/               # Repositorios, fuentes remotas/locales, mappers
│   │   ├── domain/             # Entidades, casos de uso, contratos de repositorio
│   │   └── presentation/       # Pantallas, viewmodels (ChangeNotifier), diálogos
│   ├── catalog/
│   ├── cart/
│   ├── collection/
│   └── profile/
├── infrastructure/             # Conexiones externas y servicios de bajo nivel
│   ├── firebase/               # Inicialización, wrappers de Auth/Firestore/Storage
│   ├── storage/                # Cache local, preferencias, serialización
│   └── network/                # Gestión de conectividad, reintentos, timeouts
├── main.dart                   # Punto de entrada, inicialización de providers, routing
└── firebase_options.dart       # Generado automáticamente por FlutterFire CLI
```

### 📐 Principios Arquitectónicos
- **Inversión de Dependencias:** Los dominios no conocen implementaciones concretas; usan interfaces.
- **Single Responsibility:** Cada archivo tiene un único propósito claro.
- **Inmutabilidad de Modelos:** Uso de `freezed` o `equatable` para evitar mutaciones accidentales.
- **Offline-First por Diseño:** Firestore con `persistenceEnabled: true` + cola de escrituras pendientes.
- **Lazy Loading Modular:** Carga diferida de features para reducir bundle inicial.

---

## 3. 🎨 Guía UI/UX & Sistema de Diseño (Paleta Azul Profesional)
El sistema visual se basa en **Design Tokens**, garantizando consistencia multiplataforma, accesibilidad WCAG 2.1 AA y adaptabilidad a modo claro/oscuro.

### 🌊 Paleta de Colores (Sistema Azul Corporativo)
| Token | Hex (Light) | Hex (Dark) | Uso Principal | Ratio Contraste (vs Blanco/Negro) |
|-------|-------------|------------|---------------|----------------------------------|
| `primary` | `#1E88E5` | `#64B5F6` | Botones principales, enlaces, acentos | 4.5:1 (Light) / 4.8:1 (Dark) |
| `primaryContainer` | `#BBDEFB` | `#0D47A1` | Fondos de selección, chips activos | 3.0:1 |
| `secondary` | `#0288D1` | `#81D4FA` | Navegación secundaria, iconografía | 4.2:1 |
| `surface` | `#FFFFFF` | `#121212` | Fondos de tarjetas, diálogos, listas | Base |
| `surfaceVariant` | `#F5F7FA` | `#1E1E1E` | Fondos alternos, separadores sutiles | 1.2:1 vs surface |
| `background` | `#FAFCFF` | `#0A0A0A` | Fondo global de la aplicación | Base |
| `error` | `#D32F2F` | `#EF9A9A` | Validaciones fallidas, alertas críticas | 4.6:1 |
| `success` | `#2E7D32` | `#A5D6A7` | Confirmaciones, stock disponible | 4.4:1 |
| `warning` | `#F57C00` | `#FFCC80` | Stock bajo, acciones pendientes | 4.1:1 |
| `onPrimary` | `#FFFFFF` | `#000000` | Texto sobre `primary` | >7.0:1 |
| `textPrimary` | `#212121` | `#E0E0E0` | Títulos, descripciones principales | >10:1 |
| `textSecondary` | `#757575` | `#B0B0B0` | Metadatos, placeholders, timestamps | 4.0:1 |

### 📏 Sistema de Diseño
- **Tipografía:** `Inter` (Google Fonts). Escala: `12/14/16/18/20/24/32/40`. Pesos: `400/500/600/700`.
- **Espaciado:** Base `8px`. Tokens: `xs(4)`, `sm(8)`, `md(16)`, `lg(24)`, `xl(32)`, `xxl(48)`.
- **Radios de Borde:** `4px` (chips), `8px` (inputs), `12px` (tarjetas), `16px` (diálogos), `50%` (avatars).
- **Sombras:** `elevation0` a `elevation4` con valores `0,2,4,8,16` y opacidad `8-12%`.
- **Animaciones:** `Curves.easeInOut`, duraciones `200ms` (microinteracciones), `300ms` (transiciones de página).
- **Accesibilidad:** Soporte nativo de escalado de texto, etiquetas semánticas, navegación por teclado (Web), alto contraste forzado en modo accesible.

---

## 4. 📦 Stack Tecnológico & Dependencias Estratégicas
| Categoría | Paquete | Versión Recomendada | Propósito Estratégico |
|-----------|---------|---------------------|------------------------|
| **Firebase Core** | `firebase_core`, `firebase_auth`, `cloud_firestore`, `firebase_storage` | `^2.24+` / `^4.16+` / `^4.15+` / `^4.0+` | Backend serverless, auth, BD NoSQL, assets |
| **Estado** | `provider` | `^6.1.2` | Gestión reactiva, inyección de dependencias ligera |
| **Rutas** | `go_router` | `^13.0+` | Declaración segura, protección por rol, deep linking |
| **Imágenes** | `cached_network_image`, `image_picker`, `flutter_svg` | `^3.3+` / `^2.1+` / `^2.4+` | Cache inteligente, carga de avatares/productos |
| **Formularios** | `formz`, `validators` | `^0.4+` / `^2.0+` | Validación funcional, mensajes localizados |
| **Cache Local** | `shared_preferences`, `flutter_secure_storage` | `^2.2+` / `^1.1+` | Persistencia ligera, credenciales cifradas |
| **Utilidades** | `intl`, `uuid`, `collection`, `equatable` | `^0.18+` / `^4.0+` / `^1.18+` / `^2.0+` | Monedas/fechas, IDs, manipulación de listas |
| **Testing** | `flutter_test`, `mocktail`, `integration_test` | SDK / `^1.0+` / SDK | Unit, widget, E2E, mocking seguro |
| **DevTools** | `build_runner`, `json_serializable`, `flutter_lints` | `^2.4+` / `^2.4+` / `^5.0+` | Generación de código, serialización, linting estricto |

> 💡 **Nota de Instalación:** Utilizar `flutter pub add <paquete>` para evitar conflictos de versiones. Ejecutar `flutter pub deps --style=compact` para auditar dependencias antes de builds de producción.

---

## 5. 🔐 Estrategia de Autenticación & Seguridad
### 🔑 Flujo de Identidad
1. **Registro:** Validación en tiempo real de email, fuerza de contraseña (min 8, mayúscula, número, símbolo), aceptación de T&C.
2. **Login:** Autenticación con Firebase Auth + manejo explícito de estados (`idle → loading → authenticated/failed`).
3. **Recuperación:** Envío de email con token de un solo uso, expiración a 1 hora, redirección a reestablecimiento seguro.
4. **Sesión:** `authStateChanges()` como fuente de verdad. Persistencia automática vía Firebase SDK. Limpieza de caché al `signOut()`.
5. **Guardias:** Middleware de rutas que bloquea acceso a `/catalog`, `/cart`, `/profile` sin `User` autenticado.

### 🛡️ Políticas de Seguridad
- **Firestore Rules:** Acceso granular por `request.auth.uid`. Validación de tipos, límites de longitud, prevención de escrituras masivas no autorizadas.
- **Protección de Datos:** Nunca almacenar contraseñas o tokens en `shared_preferences`. Usar `flutter_secure_storage` para refresh tokens si se implementan APIs externas.
- **Cumplimiento:** Aviso de privacidad explícito, consentimiento de cookies (Web), derecho de eliminación de datos, logging de acceso sin PII.
- **Mitigación de Abuso:** Rate limiting en registro/login (vía Firebase App Check + Cloud Functions si se escala), validación de email real (doble verificación opcional).

---

## 6. 🗃️ Modelado de Datos en Firestore
### 📁 Estructura de Colecciones
| Colección | ID | Campos Principales | Índices Recomendados |
|-----------|----|-------------------|----------------------|
| `users/{uid}` | Document ID = Auth UID | `email`, `displayName`, `role`, `createdAt`, `preferences`, `shippingAddress` | Ninguno (acceso por UID directo) |
| `products/{productId}` | UUIDv4 | `name`, `game`, `setCode`, `rarity`, `condition`, `price`, `stock`, `imageUrl`, `tags[]`, `isActive`, `updatedAt` | `(game, rarity)`, `(setCode, price asc/desc)`, `(tags, isActive)` |
| `cart/{uid}/items/{itemId}` | Subcolección | `productId`, `quantity`, `addedAt`, `snapshotPrice` | Ninguno (tamaño < 100 items) |
| `orders/{orderId}` | UUIDv4 | `userId`, `items[]`, `subtotal`, `tax`, `total`, `status`, `paymentRef`, `createdAt` | `(userId, status)`, `(createdAt desc)` |
| `collections/{uid}/cards/{cardId}` | UUIDv4 | `productId`, `condition`, `acquisitionDate`, `acquisitionPrice`, `notes`, `isFavorite` | `(userId, isFavorite)`, `(userId, acquisitionDate)` |

### ⚙️ Optimizaciones de Base de Datos
- **Paginación:** `startAfterDocument` + `limit(20)` para evitar lecturas masivas.
- **Consistencia:** Transacciones para decrementar `stock` al crear `order`.
- **Offline Sync:** Habilitar `persistenceEnabled: true` + cola de mutaciones pendientes con reintento exponencial.
- **Backups:** Exportación automática semanal a Cloud Storage (Firebase Extensions o Cloud Scheduler + Cloud Functions).

---

## 7. 🔄 Estrategia de Estado con Provider
### 🧩 Organización de ChangeNotifiers
| Provider | Responsabilidad | Ciclo de Vida | Patrón de Uso |
|----------|----------------|---------------|---------------|
| `AuthProvider` | Estado de sesión, perfil, roles | Singleton global | `ChangeNotifierProvider.value` en `main.dart` |
| `CatalogProvider` | Lista de productos, filtros, paginación | Feature scoped | `StreamProvider` con cache de 5 min |
| `CartProvider` | Items temporales, cálculos, sync | Feature scoped | `ChangeNotifierProvider` + `Selector` para UI granular |
| `CollectionProvider` | Inventario personal, búsquedas | Feature scoped | `ChangeNotifierProxyProvider` (depende de `AuthProvider`) |
| `ThemeProvider` | Modo claro/oscuro, accesibilidad | Singleton | `ValueListenableProvider` o `ChangeNotifierProvider` |

### 🛡️ Buenas Prácticas de Provider
- **Evitar `context.watch` en métodos de negocio:** Usar `context.read` para acciones síncronas.
- **`Selector` para evitar rebuilds innecesarios:** Filtrar propiedades específicas (`select: (provider) => provider.cartTotal`).
- **Limpieza explícita:** Sobrescribir `dispose()` en providers que manejan streams o timers.
- **Inmutabilidad:** Nunca mutar listas directamente; usar `List.from()` o `toSet().toList()`.
- **Testing:** Mockear `ChangeNotifier` con `Mocktail` para validar transiciones de estado.

---

## 8. 📝 Fases de Implementación Paso a Paso

### 🔹 Fase 0: Gobernanza & Configuración Inicial
- Definir branching strategy (`main`, `develop`, `feature/*`, `release/*`).
- Configurar `pubspec.yaml` con versión semántica (`0.1.0+1`).
- Inicializar Firebase CLI, conectar proyecto, habilitar Auth & Firestore.
- Configurar `flutter_lints`, `analysis_options.yaml`, formateo automático.
- Crear repositorio con `README.md`, `CONTRIBUTING.md`, `LICENSE`.

### 🔹 Fase 1: Arquitectura Base & Core
- Implementar estructura de carpetas según especificación.
- Configurar `AppConfig`, temas base, tokens de diseño.
- Definir interfaces de repositorios (`IAuthRepository`, `IProductRepository`).
- Implementar router base con `GoRouter`, guards de autenticación.
- Validar compilación limpia en `flutter analyze`.

### 🔹 Fase 2: UI Foundation & Design System
- Desarrollar componentes atómicos: `TCGButton`, `TCGTextField`, `TCGChip`, `TCGCardSkeleton`.
- Implementar `BottomNavigationBar` con íconos adaptativos (Material 3).
- Configurar `ThemeMode` dinámico con `ThemeProvider`.
- Validar responsividad en `320px`, `768px`, `1200px`, `1920px`.
- Documentar sistema en Storybook-like interno o wiki del repo.

### 🔹 Fase 3: Autenticación & Seguridad
- Implementar `AuthProvider` con `FirebaseAuth.instance`.
- Desarrollar `LoginScreen`, `RegisterScreen`, `ResetPasswordScreen`.
- Validar formularios con `formz`, manejar errores UI-friendly.
- Configurar Firestore Rules iniciales (bloqueo público, acceso por UID).
- Pruebas de flujo completo: registro → verificación → login → logout.

### 🔹 Fase 4: Catálogo & Integración Firestore
- Crear `CatalogProvider` con `Stream<List<Product>>`.
- Implementar paginación infinita con `startAfterDocument`.
- Desarrollar filtros por `game`, `rarity`, `price range`, `availability`.
- Crear `ProductDetailScreen` con galería de imágenes, metadatos, CTA.
- Habilitar cache offline y manejo de estado de red (`Connected`, `Offline`, `Syncing`).

### 🔹 Fase 5: Carrito, Checkout & Colección
- Implementar `CartProvider` con persistencia temporal.
- Desarrollar flujo de checkout simulado (validación, resumen, confirmación).
- Crear `CollectionProvider` con CRUD personal.
- Implementar vista tipo álbum con búsqueda interna y filtros por estado.
- Sincronización bidireccional carrito ↔ Firestore al autenticar.

### 🔹 Fase 6: Perfil, Configuración & Utilidades
- Desarrollar `ProfileScreen` con datos editables, historial, preferencias.
- Implementar gestión de tema, accesibilidad, idioma.
- Agregar pantalla de historial de órdenes con estados visuales.
- Configurar logging estructurado y manejo global de errores.

### 🔹 Fase 7: Optimización & Pulido
- Auditar rebuilds con Flutter DevTools, optimizar con `Selector`.
- Implementar `Hero` animations, transiciones suaves, skeletons.
- Validar contraste, escalado de texto, navegación por teclado.
- Ejecutar `flutter build` profiling, reducir bundle size, eliminar assets no usados.

### 🔹 Fase 8: Pruebas, CI/CD & Despliegue
- Ejecutar suite completa: unit, widget, integration.
- Configurar GitHub Actions: lint → test → build → deploy (Firebase Hosting/Play/TestFlight).
- Generar builds firmados, configurar stores, metadatos, screenshots.
- Monitoreo post-lanzamiento: Crashlytics, Analytics, feedback loop.

---

## 9. 🧪 Estrategia de Pruebas & Control de Calidad
| Tipo | Herramienta | Cobertura Objetivo | Métrica de Éxito |
|------|-------------|-------------------|------------------|
| Unit Tests | `flutter_test`, `mocktail` | `data/`, `domain/`, `utils/` | ≥80% líneas, 0 falsos positivos |
| Widget Tests | `flutter_test` | Componentes UI, formularios, navegación | Interacciones validadas, accesibilidad |
| Integration Tests | `integration_test` | Flujo Auth → Catálogo → Carrito → Checkout | <5s por flujo, 0 crashes |
| Performance | DevTools, `flutter run --profile` | FPS, memoria, rebuilds | ≥60fps estable, <50MB RAM idle |
| Accessibility | `flutter a11y`, Lighthouse (Web) | WCAG 2.1 AA | 100% contraste, navegación teclado OK |
| Security | `flutter pub audit`, Firebase App Check | Dependencias, reglas, tokens | 0 vulnerabilidades críticas |

### 📋 Protocolo de QA
1. Revisión de código obligatoria antes de merge a `develop`.
2. Pipeline de CI bloqueante si `flutter analyze` o tests fallan.
3. Pruebas manuales en 3 dispositivos físicos (gama baja, media, alta).
4. Validación de rollback strategy antes de release.
5. Registro de incidencias con severidad (P0-P3) y SLA de respuesta.

---

## 10. 🚀 Despliegue, CI/CD & Monitoreo en Producción
### 🌐 Estrategia Multiplataforma
| Plataforma | Comando | Requisitos Clave | Distribución |
|------------|---------|------------------|--------------|
| Android | `flutter build appbundle` | Keystore firmado, `minSdkVersion 21`, políticas Play | Play Console, App Distribution |
| iOS | `flutter build ios --release` | Certificados, provisioning profiles, `Info.plist` | App Store Connect, TestFlight |
| Web | `flutter build web --release` | `base-href`, service worker, meta tags SEO | Firebase Hosting, Vercel opcional |

### 🔁 Pipeline CI/CD (GitHub Actions)
- **Trigger:** Push a `develop` → `test`, Push a `main` → `build & deploy`.
- **Pasos:** Checkout → Setup Flutter → Cache Pub → `flutter analyze` → `flutter test` → Build por plataforma → Upload artifacts → Deploy (Firebase Hosting/Stores).
- **Secrets:** `FIREBASE_TOKEN`, `PLAY_STORE_KEY`, `APPLE_API_KEY` gestionados vía GitHub Secrets.
- **Versionado:** SemVer automático con `pubspec.yaml` + git tags.

### 📊 Monitoreo Post-Lanzamiento
- **Crashlytics:** Reportes de crash en tiempo real, agrupación por stacktrace.
- **Analytics:** Eventos clave (`view_catalog`, `add_to_cart`, `checkout_start`, `purchase_success`).
- **Performance:** Métricas de startup time, frame drops, latencia de red.
- **Feedback:** Integración de formularios de reporte, tasa de retención 7/30 días.

---

## 11. 🔮 Mantenimiento, Escalabilidad & Gobernanza
### 📈 Roadmap de Escalado
| Horizonte | Acción | Impacto |
|-----------|--------|---------|
| 3 meses | Migrar a `Riverpod` si `Provider` muestra límites de gestión | Mayor testabilidad, menos boilerplate |
| 6 meses | Implementar Cloud Functions para validación de precios y stock | Reducción de latencia, lógica server-side segura |
| 9 meses | Integrar pasarela de pago real + webhooks | Monetización directa, cumplimiento PCI |
| 12 meses | Modo offline completo con sync diferencial | Retención en zonas de baja conectividad |

### 🛡️ Gobernanza de Datos & Código
- **Convenciones:** `dart format`, `flutter_lints`, commit messages tipo `feat:`, `fix:`, `chore:`.
- **Auditorías:** Revisión trimestral de dependencias, rotación de tokens, backup de Firestore.
- **Documentación:** `dartdoc` en modelos, arquitectura en `docs/`, diagramas C4 actualizados.
- **Compliance:** GDPR/CCPA, derecho al olvido, logs anonimizados, consentimiento explícito.

---

## 12. 📊 Criterios de Aceptación & Matriz de Riesgos
### ✅ Definition of Done (DoD)
- Código revisado y mergeado a `develop`.
- Tests unitarios/widget/integración pasan al 100%.
- `flutter analyze` sin warnings.
- UI validada en modo claro/oscuro y 3 breakpoints.
- Documentación actualizada (README, API, arquitectura).
- Desplegable en entorno de staging sin errores críticos.

### ⚠️ Matriz de Riesgos
| Riesgo | Probabilidad | Impacto | Mitigación |
|--------|--------------|---------|------------|
| Cambio de límites en Firestore Free Tier | Media | Alto | Paginación estricta, cache agresivo, monitoreo de lecturas |
| Degradación de rendimiento en Web | Media | Medio | Tree-shaking, lazy loading, `--web-renderer canvaskit/html` según caso |
| Conflictos de versiones en `pubspec.yaml` | Baja | Alto | `dependency_overrides` controlados, CI con lockfile |
| Abuso en registro/login | Baja | Medio | Firebase App Check, reCAPTCHA v3 (Web), rate limiting en Functions |
| Pérdida de datos offline | Baja | Alto | Cola de mutaciones con reintento, validación de integridad local |

---

## 13. 🚶 Siguientes Pasos & Entregables Inmediatos
1. **Kickoff Técnico:** Revisión de arquitectura, asignación de responsabilidades, setup de entorno.
2. **Backlog Detallado:** Descomposición en epics/user stories con estimación (Story Points).
3. **Prototipo Interactivo:** Figma con flujos validados, handoff a desarrollo.
4. **Sprint 0 (1 semana):** Configuración de repo, CI/CD base, Firebase, estructura `lib/`, lints.
5. **Sprint 1-2:** Autenticación + Theme System + Router + Core Widgets.
6. **Revisión de Hitos:** Demo interna, retro, ajuste de roadmap.

> 📌 **Nota Final:** Este plan está diseñado para ser ejecutado por equipos de 1-3 desarrolladores con ciclos de 2 semanas. La modularidad permite paralelizar trabajo en `auth`, `catalog` y `cart` una vez establecido `core/`.

¿Deseas que genere el **backlog detallado por sprints**, el **diagrama de arquitectura C4**, o la **plantilla de `pubspec.yaml` con versiones exactas y comentarios** para iniciar inmediatamente?
