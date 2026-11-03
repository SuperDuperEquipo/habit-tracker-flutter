# Rachas

App móvil para crear hábitos y mantener su racha, con comodines y recordatorios. Flutter + Firebase (Authentication y Realtime Database por REST).

## Ejecutar

Requiere Flutter 3.38 o superior.

1. Completar `API_KEY` y `DB_URL` en `lib/core/config/firebase_config.dart`.
2. `flutter pub get`
3. `flutter run` (hábitos de ejemplo en memoria) o `flutter run --dart-define=USE_API=true` (Firebase).

Si en el emulador de Android aparecen textos o íconos que faltan o rayas sobre la pantalla, es un fallo de Impeller con OpenGLES en el emulador, no de la app. Se arregla con `flutter run --no-enable-impeller`.

Antes de abrir un PR: `dart format .`, `flutter analyze` y `flutter test`.

## Datos de prueba (seed)

`tool/seed.dart` crea en Firebase cuatro cuentas de prueba. Cada una tiene los hábitos necesarios para ver un estado distinto de la app.

```
dart run tool/seed.dart
```

Salida esperada:

```
ana@rachas.test: 5 hábitos
luis@rachas.test: 3 hábitos
sofia@rachas.test: 2 hábitos
nuevo@rachas.test: 0 hábitos
Listo. Contraseña de todas las cuentas: rachas123
```

- **Hay que correrlo el mismo día de la prueba o la demo.** Las fechas se calculan desde el día en que se corre. Al día siguiente, lo que estaba "completado hoy" pasa a "ayer" y las rachas cambian.
- Se puede correr las veces que haga falta. Si la cuenta ya existe, inicia sesión y **reemplaza** sus hábitos, así que se borra lo que se haya creado a mano en ella. Sirve para dejar todo como al inicio después de probar.
- Los hábitos del seed solo se ven con `flutter run --dart-define=USE_API=true`. Sin esa bandera también se puede entrar con estas cuentas, pero la lista muestra los hábitos de ejemplo en memoria.
- Si el seed dice que una cuenta "ya existe con otra contraseña", hay que borrarla en Firebase Console → Authentication y volver a correrlo.
- Los perfiles están en `tool/seed_profiles.dart`. `test/seed_profiles_test.dart` comprueba que cada perfil siga mostrando lo que dicen las tablas de abajo. Si se cambia un perfil, hay que actualizar también el test y este README.

### Perfiles

Contraseña de todas las cuentas: `rachas123`. Los correos usan el dominio reservado `.test`, así que ningún correo de la app le llega a nadie.

| Correo | Nombre | Inicio | Para probar |
|---|---|---|---|
| `ana@rachas.test` | Ana | 2 de 5 completados | Todos los casos de racha y comodín. Es el perfil para la demo |
| `luis@rachas.test` | Luis | 3 de 3, "¡Lo lograste!" | Desmarcar y la semana al 100 % |
| `sofia@rachas.test` | Sofía | 0 de 2 | Usar un comodín y un hábito creado hoy |
| `nuevo@rachas.test` | Sin nombre | Lista vacía | Crear el primer hábito y el saludo sin nombre |

**Ana**

| Hábito | Hoy | Qué se ve |
|---|---|---|
| Lectura de apuntes | Completado, racha de 12 | 3 comodines, recordatorio 08:30. Es el "Hábito más constante" |
| Repaso con Pomodoro | Completado, racha de 4 | Tuvo una racha de 21 días: es la "Mejor racha" en Estadísticas |
| Tomar 2L de agua | Pendiente, ayer sí | Aparece "Usar comodín" (le quedan 2) |
| Caminar 20 minutos | Pendiente, racha rota (0) | Sin recordatorio. No ofrece comodín porque ayer no se cumplió |
| Meditar 5 minutos | Pendiente, ayer sí | 0 comodines, así que no aparece "Usar comodín" |

**Luis:** Rutina de ejercicio (racha de 30), Desayunar antes de clase (15) y Dibujar 15 minutos (9, sin recordatorio). Todos están completados hoy y toda la semana, así que Estadísticas marca 100 %. Al desmarcar uno baja su racha y el resumen cambia a 2 de 3.

**Sofía:** Practicar inglés tiene una racha de 10 hasta ayer y le queda 1 comodín, así que se puede usar. Dormir antes de las 11 se creó hoy y no tiene días completados; Estadísticas solo lo cuenta desde hoy. El resumen dice "Un paso pequeño es suficiente para empezar".

**nuevo:** sin hábitos y sin nombre. Se ve el estado vacío, el saludo "¡Buen día!", "Tu perfil" en Perfil y Estadísticas sin datos.

El calendario del detalle muestra solo el mes actual: a inicio de mes se ven pocos días marcados aunque la racha sea larga.

### Otros casos

| Caso | Cómo probarlo |
|---|---|
| Contraseña incorrecta | Cualquier perfil con otra contraseña |
| Correo ya registrado | Crear cuenta con `ana@rachas.test` |
| Recuperar contraseña | Cualquier correo. El proyecto de Firebase tiene activa la protección contra enumeración de correos: responde que envió el enlace aunque el correo no exista. Por eso el mensaje "No encontramos una cuenta con ese correo" no aparece con este proyecto |
| Sin conexión | Iniciar sesión, cerrar la app, activar el modo avión y volver a abrirla. "Reintentar" carga la lista al quitar el modo avión |
| Sesión guardada | Cerrar la app sin cerrar sesión: vuelve a abrir en Mis hábitos |
| Recordatorios | Se programan al guardar un hábito. Los del seed no tienen notificación programada hasta que se editan: editar uno, poner la hora uno o dos minutos adelante y guardar |

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
tool/                    seed de datos de prueba
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
