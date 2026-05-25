# Eventos Académicos — Flutter App

Proyecto Final | Programación para Dispositivos Móviles

## Descripción

Aplicación móvil Flutter para la **gestión de eventos académicos** (conferencias, seminarios, talleres, etc.). Permite registrarse, iniciar sesión y realizar operaciones CRUD completas sobre eventos.

## Stack

- **Frontend mobile**: Flutter (Dart)
- **Backend**: Node.js + Express 5
- **Base de datos**: PostgreSQL
- **ORM**: Drizzle ORM
- **Autenticación**: JWT + bcrypt

---

## Estructura de carpetas (Flutter)

```
flutter_app/
├── lib/
│   ├── config.dart              # URL del backend
│   ├── main.dart                # Entry point y rutas
│   ├── models/                  # Modelos de datos
│   │   ├── user.dart
│   │   ├── event.dart
│   │   ├── category.dart
│   │   ├── location.dart
│   │   ├── schedule.dart
│   │   └── registration.dart
│   ├── services/
│   │   └── api_service.dart     # Cliente HTTP (singleton)
│   └── screens/
│       ├── auth/
│       │   ├── login_screen.dart
│       │   └── register_screen.dart
│       ├── events/
│       │   ├── events_list_screen.dart   # Lista con búsqueda y filtros
│       │   ├── event_detail_screen.dart  # Detalle, agenda, inscripción
│       │   ├── event_form_screen.dart    # Crear / Editar evento
│       │   └── search_filter_screen.dart # Filtros avanzados
│       └── registrations/
│           └── my_registrations_screen.dart
└── pubspec.yaml
```

## Pantallas (≥ 5 del dominio principal)

| # | Pantalla | Ruta / Archivo | Descripción |
|---|----------|---------------|-------------|
| 1 | Login | `auth/login_screen.dart` | Inicio de sesión |
| 2 | Registro | `auth/register_screen.dart` | Alta de usuario |
| 3 | Lista de eventos | `events/events_list_screen.dart` | Lista con búsqueda y filtros por categoría |
| 4 | Detalle de evento | `events/event_detail_screen.dart` | Info completa, agenda, botón inscripción |
| 5 | Crear / Editar evento | `events/event_form_screen.dart` | Formulario CRUD |
| 6 | Buscar y filtrar | `events/search_filter_screen.dart` | Filtros avanzados |
| 7 | Mis inscripciones | `registrations/my_registrations_screen.dart` | Historial de inscripciones |

---

## Base de datos — Modelo relacional

### Tablas de autenticación (no cuentan para el requisito de 5)
- `users` — id, name, email, password_hash

### Tablas del dominio (5 tablas)

| Tabla | Descripción |
|-------|-------------|
| `categories` | Categorías de eventos (conferencia, seminario, taller...) |
| `locations` | Lugares / sedes donde se realizan los eventos |
| `events` | Eventos académicos (entidad principal) |
| `schedules` | Agenda/sesiones de cada evento (ponencias, charlas) |
| `registrations` | Inscripciones de usuarios a eventos |

### Diagrama de relaciones

```
categories ──┐
             ├──> events <── schedules
locations  ──┘       │
                     └──> registrations <── users
```

---

## Endpoints de la API

Base URL: `https://YOUR_APP.replit.app/api`

### Autenticación
| Método | Ruta | Descripción |
|--------|------|-------------|
| POST | `/register` | Registro de usuario |
| POST | `/login` | Inicio de sesión (devuelve JWT) |

### Eventos (CRUD principal)
| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/events` | Listar eventos (filtro por categoría y búsqueda) |
| POST | `/events` | Crear evento |
| GET | `/events/:id` | Obtener evento por ID |
| PUT | `/events/:id` | Actualizar evento |
| DELETE | `/events/:id` | Eliminar evento |

### Categorías
| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/categories` | Listar categorías |
| POST | `/categories` | Crear categoría |

### Lugares
| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/locations` | Listar lugares |
| POST | `/locations` | Crear lugar |

### Agenda
| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/events/:id/schedules` | Agenda de un evento |
| POST | `/events/:id/schedules` | Agregar sesión |
| PUT | `/schedules/:id` | Editar sesión |
| DELETE | `/schedules/:id` | Eliminar sesión |

### Inscripciones
| Método | Ruta | Descripción |
|--------|------|-------------|
| GET | `/registrations?userId=X` | Mis inscripciones |
| POST | `/registrations` | Inscribirse a un evento |
| DELETE | `/registrations/:id` | Cancelar inscripción |

---

## Cómo correr la app Flutter

### 1. Instalar dependencias

```bash
cd flutter_app
flutter pub get
```

### 2. Configurar la URL del backend

Editá `lib/config.dart` y reemplazá `YOUR_REPLIT_APP` con la URL de tu backend desplegado:

```dart
static const String baseUrl = 'https://YOUR_APP.replit.app/api';
```

**Para desarrollo local:**
- Emulador Android: `http://10.0.2.2:5000/api`
- Simulador iOS: `http://localhost:5000/api`
- Dispositivo físico: `http://TU_IP_LOCAL:5000/api`

### 3. Correr la app

```bash
# Android
flutter run -d android

# iOS
flutter run -d ios

# Ambos a la vez
flutter run
```

---

## Despliegue del backend

El backend está desplegado en Replit. Para publicarlo:
1. Click en **Deploy** en Replit
2. La URL de producción quedará disponible en `https://TU_APP.replit.app`
3. Actualizá `lib/config.dart` con esa URL

### Opción Docker Compose (local)

```yaml
# docker-compose.yml (para referencia)
version: '3.8'
services:
  db:
    image: postgres:16
    environment:
      POSTGRES_DB: eventos_academicos
      POSTGRES_USER: postgres
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"
  
  adminer:
    image: adminer
    ports:
      - "8080:8080"
```

---

## Criterios de evaluación cubiertos

- [x] Registro e inicio de sesión funcionales (bcrypt + JWT)
- [x] CRUD completo en backend (eventos)
- [x] Base de datos relacional SQL (PostgreSQL) con 5 tablas de dominio
- [x] Conexión App ↔ Backend mediante URL pública (Replit deploy)
- [x] Aplicación móvil operativa en Android e iOS (Flutter)
- [x] 7 pantallas (5 del dominio principal + auth)
- [x] Documentación con README y endpoints
