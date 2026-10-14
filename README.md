# Rachas

App móvil para crear hábitos y mantener su racha, con comodines y recordatorios. Flutter + Firebase (Authentication y Realtime Database por REST).

## Ejecutar

Requiere Flutter 3.38 o superior.

1. Completar `API_KEY` y `DB_URL` en `lib/core/config/firebase_config.dart`.
2. `flutter pub get`
3. `flutter run` (hábitos de ejemplo en memoria) o `flutter run --dart-define=USE_API=true` (Firebase).

Antes de abrir un PR: `dart format .`, `flutter analyze` y `flutter test`.

## Estructura

Capas: pantalla → Provider → `HabitRepository` → `ApiClient`. Ninguna pantalla importa Dio ni hace `jsonDecode`.

```
lib/
├── app/                 MaterialApp, rutas y barra inferior
├── core/
│   ├── config/          firebase_config, api_endpoints, app_strings
│   ├── errors/          AppException, ErrorHandler
│   ├── network/         ApiClient
│   ├── theme/
│   ├── utils/
│   ├── widgets/
│   └── validators.dart
├── features/
│   ├── login/
│   ├── habits/          Habit, HabitRepository, repositorios, pantalla
│   ├── habit_form/      HabitForm, crear y editar
│   └── notifications/   NotificationService
└── main.dart
```

## Decisiones

- **Firebase por REST:** cumple la ficha de consumir una API con GET, POST, PUT y DELETE usando Dio, y los datos persisten por usuario.
- **Provider:** cubre el estado compartido y la inyección del repositorio con la menor complejidad. Quedan fuera Riverpod, freezed y Retrofit.

## Ramas y commits

| Persona | Rama |
|---|---|
| 1 | `feature/base` |
| 2 | `feature/login` |
| 3 | `feature/habits` |
| 4 | `feature/habit-form` |
| 5 | `feature/edit-habit` |

- Nadie hace commit directo a `main`: todo entra por pull request. La Persona 5 revisa y hace el merge.
- Orden de merge: Persona 1, 2, 4, 3 y 5.
- Cada persona trabaja solo en su carpeta.
- Commits pequeños, uno por cambio, con el formato `tipo(alcance): descripción` en minúsculas, en imperativo y de máximo 72 caracteres.
- Tipos: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`.
- Ejemplo: `feat(habits): agrega ApiHabitRepository`.

## Firebase

### Estructura de datos

```
users/
  {uid}/
    habits/
      {habitId}/                    id que genera Firebase al hacer POST
        name: "Leer 20 min"
        iconKey: "menu_book"
        colorValue: 4281286744
        reminderTime: "20:00"       opcional
        streak: 5
        jokersLeft: 3               de 0 a 3
        completedDates: ["2026-10-12", "2026-10-13"]
        createdAt: "2026-10-13T11:40:00"
```

Reglas de seguridad (`database.rules.json`): cada usuario solo lee y escribe lo suyo.

### Endpoints de autenticación

| Acción | Petición | Respuesta |
|---|---|---|
| Crear cuenta | `POST https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=API_KEY` con `{email, password, returnSecureToken: true}` | `idToken`, `refreshToken`, `expiresIn`, `localId` (uid) |
| Iniciar sesión | `POST https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=API_KEY` con el mismo cuerpo | Igual que arriba |
| Renovar token | `POST https://securetoken.googleapis.com/v1/token?key=API_KEY` con `grant_type=refresh_token&refresh_token=...` | `id_token`, `refresh_token`, `user_id` |

### Endpoints de hábitos

Base: `{DB_URL}/users/{uid}/habits`, siempre con `?auth={idToken}`.

| Operación | Petición | Respuesta |
|---|---|---|
| `getAll` | `GET /habits.json` | Mapa `{id: {...}}`, o `null` si está vacío |
| `getById` | `GET /habits/{id}.json` | Objeto, o `null` |
| `create` | `POST /habits.json` | `{"name": "-Nabc123"}` (id nuevo) |
| `update` | `PUT /habits/{id}.json` | Objeto completo |
| `toggleComplete` | `PATCH /habits/{id}.json` con `{streak, completedDates}` | Campos enviados |
| `useJoker` | `PATCH /habits/{id}.json` con `{jokersLeft, streak, completedDates}` | Campos enviados |
| `delete` | `DELETE /habits/{id}.json` | `null` |

Todas las respuestas son 200 (también el POST). Con token vencido o sin permiso responde 401.
