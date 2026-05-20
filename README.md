# PackTrack

Una aplicación de rastreo de paquetes con diseño minimalista, moderno y funcional. Construida con Flutter y Firebase bajo la premisa de **"cero desorden"** para el usuario.

## Arquitectura del Proyecto

```
packtrack/
├── lib/
│   ├── main.dart                              # Punto de entrada + Firebase init
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart             # Constantes globales
│   │   ├── theme/
│   │   │   └── app_theme.dart                 # Tema visual minimalista
│   │   ├── localization/
│   │   │   ├── app_localizations.dart         # Sistema de traducciones (5 idiomas)
│   │   │   └── locale_provider.dart           # Gestión de idioma
│   │   ├── firebase/
│   │   │   └── firebase_options.dart          # Configuración Firebase
│   │   └── utils/
│   │       └── helpers.dart                   # Utilidades generales
│   ├── data/
│   │   ├── models/
│   │   │   ├── package_model.dart             # Modelo de paquete
│   │   │   ├── tracking_event_model.dart      # Modelo de evento
│   │   │   ├── order_model.dart               # Modelo de pedido
│   │   │   ├── search_entry_model.dart        # Modelo de búsqueda
│   │   │   └── models.dart                    # Barrel file
│   │   ├── providers/
│   │   │   ├── tracking_provider.dart         # Estado de rastreo
│   │   │   ├── search_history_provider.dart   # Estado de historial
│   │   │   └── auth_provider.dart             # Estado de autenticación
│   │   └── repositories/
│   │       └── firestore_repository.dart      # Repositorio Firestore
│   ├── services/
│   │   ├── tracking/
│   │   │   ├── tracking_service.dart          # Servicio de rastreo API
│   │   │   └── carrier_detector.dart          # Auto-detección de carrier
│   │   ├── maps/
│   │   │   └── maps_service.dart              # Servicio Google Maps
│   │   ├── storage/
│   │   │   ├── local_storage_service.dart     # SharedPreferences
│   │   │   └── database_service.dart          # SQLite local
│   │   ├── auth/
│   │   │   └── auth_service.dart              # Firebase Auth + Social Login
│   │   ├── support/
│   │   │   └── carrier_support_service.dart   # Contacto directo con paquetería
│   │   ├── monetization/
│   │   │   └── purchase_service.dart          # In-App Purchases
│   │   └── services.dart                      # Barrel file
│   └── features/
│       ├── auth/
│       │   └── screens/
│       │       ├── welcome_screen.dart        # Pantalla de bienvenida
│       │       ├── login_screen.dart          # Inicio de sesión
│       │       └── register_screen.dart       # Registro
│       ├── home/
│       │   ├── screens/
│       │   │   └── home_screen.dart           # Pantalla principal
│       │   └── widgets/
│       │       ├── smart_search_bar.dart      # Buscador inteligente
│       │       ├── live_map_carousel.dart      # Carrusel de mapa
│       │       ├── order_group_card.dart       # Tarjeta de pedido
│       │       ├── language_selector.dart      # Selector de idioma
│       │       └── empty_state_widget.dart     # Estado vacío
│       ├── detail/
│       │   ├── screens/
│       │   │   └── package_detail_screen.dart # Pantalla de detalle
│       │   └── widgets/
│       │       ├── detail_map_widget.dart      # Mapa ampliado
│       │       ├── tracking_timeline.dart      # Línea de tiempo
│       │       ├── package_info_header.dart    # Info del paquete
│       │       └── contact_carrier_button.dart # Botón contacto inteligente
│       └── extras/
│           ├── screens/
│           │   └── extras_screen.dart         # Pantalla de extras
│           └── widgets/
│               ├── premium_card.dart          # Suscripción Premium
│               ├── micro_insurance_card.dart   # Microseguros
│               ├── affiliate_offers_card.dart  # Marketing de afiliados
│               ├── carrier_partnerships_card.dart # Alianzas transportistas
│               └── business_analytics_card.dart   # Analítica para negocios
├── assets/
│   ├── images/
│   └── translations/
├── android/
│   └── app/src/main/AndroidManifest.xml
├── ios/
│   └── Runner/Info.plist
├── pubspec.yaml
└── README.md
```

## Características Principales

### Autenticación y Onboarding

| Característica | Descripción |
|---|---|
| **Pantalla de Bienvenida** | Diseño limpio con highlights de funcionalidades |
| **Registro/Login** | Email + contraseña con validación completa |
| **Google Sign-In** | Inicio de sesión con un toque |
| **Apple Sign-In** | Disponible en iOS para cumplir con App Store |
| **Recuperar Contraseña** | Envío de email de reseteo |

### Pantalla Principal (Dashboard - 100% Simple)

| Característica | Descripción |
|---|---|
| **Buscador Inteligente** | Barra con auto-detección de transportista, soporte para pegar y escanear QR/código de barras |
| **Mapa en Tiempo Real** | Carrusel deslizable con mapa enfocado en el paquete más cercano a entregarse |
| **Agrupación por Pedidos** | Paquetes organizados por orden de compra con estado visual y progreso |
| **Selector de Idioma** | Cambio instantáneo entre 5 idiomas (ES, EN, PT, FR, DE) |
| **Menú de Perfil** | Acceso a Extras, Configuración y Cerrar Sesión |

### Pantalla de Detalle

| Característica | Descripción |
|---|---|
| **Mapa Interactivo Ampliado** | Muestra el recorrido completo con marcadores y polylines |
| **Timeline Vertical** | Cada parada con estado, ubicación, fecha y hora |
| **Botón Contactar Paquetería** | Se activa tras 48h sin movimiento, copia guía y abre marcador |
| **Compartir Estado** | Botón nativo para compartir enlace de rastreo |
| **Copiar Número de Guía** | Acceso rápido al portapapeles |

### Contacto Directo Inteligente (NUEVA FUNCIÓN)

El botón "Contactar a la Paquetería" resuelve el problema de tener que buscar números de atención al cliente manualmente:

- Se **activa automáticamente** cuando un paquete lleva 48+ horas sin movimiento
- **Copia el número de guía** al portapapeles antes de llamar
- **Abre el marcador telefónico** con el número correcto del transportista
- Soporta múltiples regiones (MX, US, Internacional)
- Incluye opción de abrir sitio web de soporte

| Transportista | Teléfono MX | Teléfono US |
|---|---|---|
| FedEx | 800-900-1100 | 800-463-3339 |
| UPS | 800-742-5877 | 800-742-5877 |
| DHL | 800-765-6345 | 800-225-5345 |
| Estafeta | 800-378-2338 | - |
| Amazon | 800-288-0013 | 888-280-4331 |
| 99 Minutos | 55-4170-8842 | - |
| Correos de México | 800-701-7000 | - |

### Monetización Avanzada (Invisible en Dashboard)

Todas las opciones de monetización están en la sección **Extras**, accesible solo bajo demanda:

| Módulo | Descripción |
|---|---|
| **Premium (\$4.99/mes)** | Rastreo ilimitado, notificaciones prioritarias, analítica, sin ads |
| **Microseguros** | Protección por paquete: \$0.99 (básico), \$2.99 (estándar), \$7.99 (premium) |
| **Marketing de Afiliados** | Ofertas contextuales de socios (empaque, cerraduras, e-commerce) |
| **Alianzas con Transportistas** | Descuentos exclusivos de envío (10-15% OFF) |
| **Analítica para Negocios** | Dashboard de métricas, comparación de carriers, reportes CSV |

### Auto-Detección de Transportista

La app detecta automáticamente el transportista basándose en patrones de número de guía:

| Transportista | Patrón de Ejemplo |
|---|---|
| FedEx | 12 dígitos, 15 dígitos, 20 dígitos |
| UPS | Prefijo `1Z` + 16 caracteres |
| DHL | 10 dígitos, prefijo `JD` |
| USPS | 20-22 dígitos, prefijo `94`, `92` |
| Amazon | Prefijo `TBA` |
| Estafeta | 10 dígitos, prefijo `806` |
| 99 Minutos | Prefijo `99M` |
| Correos de México | Sufijo `MX` |

## Configuración

### 1. Prerrequisitos

```bash
flutter --version  # Flutter 3.16+ requerido
```

### 2. Instalar Dependencias

```bash
cd packtrack
flutter pub get
```

### 3. Configurar Firebase

```bash
# Instalar FlutterFire CLI
dart pub global activate flutterfire_cli

# Configurar proyecto Firebase
flutterfire configure
```

### 4. Configurar Google Maps API Key

Reemplazar `YOUR_GOOGLE_MAPS_API_KEY` en:

- `lib/core/constants/app_constants.dart`
- `android/app/src/main/AndroidManifest.xml`
- `ios/Runner/AppDelegate.swift` (agregar `GMSServices.provideAPIKey()`)

### 5. Configurar API de Rastreo

Obtener API key de [TrackingMore](https://www.trackingmore.com/) o [AfterShip](https://www.aftership.com/) y configurar en el servicio de rastreo.

### 6. Configurar Google Sign-In

- Android: Agregar SHA-1 fingerprint en Firebase Console
- iOS: Agregar `GoogleService-Info.plist` y configurar URL schemes

### 7. Ejecutar

```bash
flutter run
```

## Idiomas Soportados

- Español (MX) - Predeterminado
- English (US)
- Português (BR)
- Français (FR)
- Deutsch (DE)

## Tecnologías

| Categoría | Tecnología |
|---|---|
| Framework | Flutter 3.16+ |
| Estado | Provider |
| Backend | Firebase (Firestore, Auth) |
| Autenticación | Firebase Auth + Google Sign-In + Apple Sign-In |
| Mapas | Google Maps Flutter |
| DB Local | SQLite (sqflite) + SharedPreferences |
| Scanner | mobile_scanner |
| HTTP | dio + http |
| Compartir | share_plus |
| Llamadas | url_launcher |
| Compras | in_app_purchase |

## Diseño

La aplicación sigue los principios de diseño **"Zero Clutter"**:

- Paleta de colores limitada y consistente
- Tipografía Inter con jerarquía clara
- Espaciado generoso y bordes suaves
- Animaciones sutiles y funcionales
- Sin elementos decorativos innecesarios
- Información visible de un vistazo
- Monetización invisible en el dashboard principal
- Soporte inteligente que no molesta al usuario

## Licencia

MIT License - Uso libre para proyectos personales y comerciales.
