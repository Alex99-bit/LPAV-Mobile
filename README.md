# LPAV Mobile

Aplicaciones móviles nativas para el marketplace de LPAV, una plataforma SaaS para agencias de viaje. El proyecto permite a viajeros descubrir paquetes turísticos, comunicarse con agencias y gestionar sus compras desde iOS y Android.

Este repositorio se publica exclusivamente como muestra de portafolio y demostración técnica.

## Descripción

LPAV Mobile extiende la experiencia del marketplace y el portal de agencias a dispositivos móviles, con funcionalidades para:

- Explorar paquetes turísticos, itinerarios y perfiles de agencias.
- Buscar y consultar detalles de experiencias de viaje.
- Gestionar carrito, checkout, pedidos y pagos.
- Registrar usuarios e iniciar sesión mediante autenticación segura.
- Mantener conversaciones en tiempo real entre viajeros y agencias.
- Recibir notificaciones relacionadas con pedidos y actividad de la cuenta.
- Consultar y administrar perfiles de usuario y agencia.
- Gestionar leads y operaciones comerciales desde el entorno móvil.
- Proteger credenciales locales mediante Keychain y almacenamiento cifrado.
- Compartir modelos, contratos de API y reglas de negocio con la plataforma principal.

## Arquitectura

```text
Aplicaciones móviles
├── iOS: Swift + SwiftUI
└── Android: Kotlin + Jetpack Compose

Backend compartido
├── Supabase Auth
├── PostgreSQL y PostgREST
├── Edge Functions
├── Storage
└── Realtime

Servicios externos
├── Stripe para pagos
└── Servicios de IA para calificación de leads
```

Las aplicaciones consumen un backend compartido basado en Supabase y siguen una arquitectura orientada a separación de responsabilidades, autenticación por tokens, aislamiento multi-tenant y comunicación en tiempo real.

## Tecnologías

| Plataforma | Tecnologías |
| --- | --- |
| iOS | Swift 5.9+, SwiftUI, iOS 17+, Swift Package Manager |
| Android | Kotlin, Jetpack Compose, Material 3, Android SDK 34 |
| Arquitectura | MVVM en iOS; MVVM y Clean Architecture en Android |
| Inyección de dependencias | Factory en iOS; Hilt en Android |
| Backend | Supabase, PostgreSQL, Auth, Storage, Realtime y Edge Functions |
| Red | Clientes Supabase para Swift y Kotlin |
| Pagos | Stripe Payments, Stripe Checkout y Stripe Billing |
| Pruebas | XCTest, pruebas de integración Android y UI tests |

## Módulos Principales

### Marketplace

Catálogo de paquetes, filtros, tarjetas de flyers, favoritos, perfiles de agencias, detalles de paquetes, itinerarios y reseñas.

### Autenticación Y Perfiles

Registro, inicio de sesión, onboarding, autenticación biométrica, Google Sign-In y gestión de perfiles.

### Carrito Y Pedidos

Carrito persistente, checkout, estados de pago, historial de pedidos y seguimiento de pagos diferidos.

### Chat Y Notificaciones

Mensajería entre viajeros y agencias mediante Supabase Realtime, lista de conversaciones y notificaciones dentro de la aplicación.

### Portal De Agencia

Funciones móviles para consultar el perfil de agencia, gestionar leads y dar seguimiento a la relación con clientes.

### Seguridad

El proyecto contempla almacenamiento seguro de credenciales, validación de sesiones, separación de responsabilidades, configuración por entorno y pruebas de integración con el backend.

## Documentación Técnica

- [Contratos de API](docs/API_CONTRACTS.md)
- [Modelos de datos](docs/DATABASE_MODELS.md)
- [Reglas de negocio](docs/BUSINESS_RULES.md)
- [Configuración de Supabase](docs/SUPABASE_CONFIG.md)

## Estado Del Proyecto

Proyecto personal en desarrollo, publicado con fines demostrativos y de portafolio. Algunas funcionalidades dependen de servicios privados, credenciales de entorno, configuración de Supabase y cuentas de terceros.

El sistema de puntos de lealtad **Avimo Puntos** se encuentra temporalmente desactivado en las aplicaciones. Las estructuras relacionadas se conservan para una posible reactivación futura.

## Visualización

Este repositorio puede visualizarse públicamente en GitHub únicamente con fines demostrativos. No se autoriza descargar, clonar, copiar, ejecutar, modificar, redistribuir, crear forks ni utilizar el contenido en otros proyectos.

Para conocer las condiciones completas, consulta el archivo [`LICENSE`](./LICENSE).

## Autor

**Carlos Alejandro Coronado Obregón**

Contacto: [alejandro.co.dev@gmail.com](mailto:alejandro.co.dev@gmail.com)

## Derechos Reservados

Copyright (c) 2026 Carlos Alejandro Coronado Obregón. Todos los derechos reservados.
