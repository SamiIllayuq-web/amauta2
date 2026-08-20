# Flujos del Sistema — Admisión Amauta

Este documento explica los archivos que participan en los flujos principales del sistema.

---

## Flujo 1: Admin sube examen con Gemini OCR

### Descripción
El administrador ingresa al sistema, va a la sección de gestionar exámenes, crea un nuevo examen subiendo una foto del examen en papel. Gemini hace OCR para extraer las preguntas y alternativas automáticamente.

### Archivos participantes

#### Pantallas (Screens)

| Archivo | Descripción |
|---|---|
| `lib/screens/login_screen.dart` | Pantalla de login. Valida credenciales contra la BD SQLite. Si es admin (kuma@gmail.com / kuma) redirige a AdminScreen. Si es postulante, redirige a CatalogScreen. |
| `lib/screens/admin/admin_screen.dart` | Panel principal del administrador. Navegación a gestión de exámenes, preguntas, postulantes. |
| `lib/screens/admin/admin_exam_ingest_screen.dart` | **Pantalla principal de este flujo.** Tiene un Stepper de 3 pasos: (1) Datos del examen, (2) Subir foto y OCR con Gemini, (3) Revisar/editar preguntas extraídas. |
| `lib/screens/admin/admin_exam_manage_screen.dart` | Lista de exámenes creados. Permite editar, eliminar, ver preguntas de cada examen. |
| `lib/screens/admin/admin_question_analysis_screen.dart` | Análisis de una pregunta específica con Gemini. Muestra explicación de la respuesta correcta. |

#### Repositorios

| Archivo | Descripción |
|---|---|
| `lib/repositories/mock_exam_repository.dart` | CRUD de exámenes (`createMockExam`, `getMockExams`, `getMockExamById`, `updateMockExam`, `deleteMockExam`). |
| `lib/repositories/question_repository.dart` | CRUD de preguntas (`createQuestion`, `getQuestionsByMockExam`, `updateQuestion`, `updateQuestionAnalysis`). |
| `lib/repositories/alternative_repository.dart` | CRUD de alternativas (`createAlternative`, `getAlternativesByQuestion`, `updateAlternative`). |

#### Modelos

| Archivo | Descripción |
|---|---|
| `lib/models/mock_exam_model.dart` | Modelo del examen: id, título, descripción, bloque, fecha creación. |
| `lib/models/question_model.dart` | Modelo de pregunta: id, examen al que pertenece, texto, correctAlternativeId, aiExplanation (respuesta de Gemini). |
| `lib/models/alternative_model.dart` | Modelo de alternativa: id, pregunta padre, texto, isCorrect. |

#### Servicios

| Archivo | Descripción |
|---|---|
| `lib/services/gemini_service.dart` | **Servicio clave.** Se conecta a la API de Gemini con la clave del `.env`. Tiene dos métodos principales: `extractTextFromImage()` (OCR) y `analyzeQuestion()` (dado texto de pregunta + alternativas, devuelve cuál es la correcta y por qué). |
| `lib/services/error_service.dart` | Manejo centralizado de errores. Registra errores en la BD SQLite local. |
| `lib/services/connectivity_service.dart` | Detecta si hay conexión a internet. Se usa para decidir si se puede usar Gemini o no. |
| `lib/services/preferences_service.dart` | Guarda/lee preferencias locales como el userId del usuario logueado. |

#### Base de datos

| Archivo | Descripción |
|---|---|
| `lib/database/database_helper.dart` | Configuración de SQLite. Define `onCreate` (crea tablas y ejecuta seed) y `onUpgrade` (migraciones). |
| `lib/database/database_seed.dart` | **Datos iniciales.** Inserta el usuario admin, postulante de prueba, 1 examen de demo con 25 preguntas precargadas, alternativas y respuestas correctas. |
| `lib/database/db_constants.dart` | Nombres de tablas y columnas como constantes. Evita strings mágicos. |

#### Otros

| Archivo | Descripción |
|---|---|
| `lib/main.dart` | Punto de entrada. Inicializa BD, carga `.env`, configura tema, define rutas nombradas (`/login`, `/admin`, `/catalog`, `/exam`, `/result`, `/ai-review`). |

---

## Flujo 2: Postulante toma simulacro y revisa resultados

### Descripción
El postulante inicia sesión, ve el catálogo de exámenes disponibles, selecciona uno, responde las preguntas viendo el cronómetro, y al terminar ve su puntaje. Puede revisar cada pregunta para ver cuál respondió bien y cuál mal.

### Archivos participantes

#### Pantallas (Screens)

| Archivo | Descripción |
|---|---|
| `lib/screens/login_screen.dart` | Login del postulante. Credenciales de prueba: `kuma@gmail.com` / `kuma`. |
| `lib/screens/catalog_screen.dart` | **Punto de inicio del flujo.** Muestra la lista de exámenes disponibles con imagen, título, descripción y botón "Resolver". |
| `lib/screens/exam_screen.dart` | **Pantalla central del flujo.** Carga las preguntas del examen, muestra una por una con 4-5 alternativas, tiene cronómetro, guarda cada respuesta en `user_answers` al seleccionar. Al terminar redirige a ResultScreen. |
| `lib/screens/result_screen.dart` | Muestra puntaje final (correctas × 20), tiempo usado, cantidad de correctas/incorrectas. Botón "Revisar con IA" que lleva a AIReviewScreen. |
| `lib/screens/ai_review_screen.dart` | **Punto final del flujo.** Lista de preguntas con color verde (correcta) o rojo (incorrecta). AI_review_screen internamente usa `_QuestionDetailScreen` para el detalle de cada pregunta con explicación de IA. |

#### Repositorios

| Archivo | Descripción |
|---|---|
| `lib/repositories/user_answer_repository.dart` | Guarda las respuestas del postulante. Método clave: `createUserAnswer()` guarda la alternativa elegida. `getUserAnswersWithCorrectness()` devuelve las respuestas unidas con la tabla de alternativas para saber si fueron correctas. |
| `lib/repositories/result_repository.dart` | Crea y lee resultados de exámenes. `createResult()` se llama al iniciar el examen. `updateResult()` se llama al terminar para guardar score final. |
| `lib/repositories/question_repository.dart` | Obtiene preguntas del examen seleccionado. |
| `lib/repositories/alternative_repository.dart` | Obtiene las alternativas de cada pregunta. |
| `lib/repositories/mock_exam_repository.dart` | Obtiene la info del examen para mostrar título/descripción. |

#### Modelos

| Archivo | Descripción |
|---|---|
| `lib/models/user_answer_model.dart` | Respuesta del postulante: resultId, questionId, selectedAlternativeId, isCorrect (booleano calculado). |
| `lib/models/result_model.dart` | Resultado del examen: id, userId, examId, correctAnswers, incorrectAnswers, finalScore, elapsedTime, completedAt. |

#### Servicios

| Archivo | Descripción |
|---|---|
| `lib/services/preferences_service.dart` | `loadUserId()` recupera el ID del usuario logueado para asociar las respuestas. |

---

## Detalle del flujo de revisión de respuestas (AIReviewScreen)

Cuando el postulante entra a revisar:

1. `AIReviewScreen._loadData()` carga el examen, sus preguntas y las respuestas del usuario desde la BD.
2. Para cada pregunta, busca la alternativa correcta (de `correctAlternativeId` o de `isCorrect=1` en alternativas).
3. Compara `selectedAlternativeId` del usuario vs la correcta → determina si fue correcta.
4. Muestra cards con: número de pregunta, texto truncado, color verde/rojo, icono.
5. Al tocar una card, abre `_QuestionDetailScreen` que muestra:
   - La pregunta completa
   - Todas las alternativas (A-E) con fondo verde si es la correcta, rojo si el usuario la eligió y falló
   - Si no hay explicación de IA local, llama a `GeminiService.analyzeQuestion()` para obtener análisis

---

## Datos precargados (Seed)

El seed en `database_seed.dart` crea:

- **Usuario admin:** kuma@gmail.com / kuma (rol: admin)
- **Usuario postulante:** kuma@gmail.com / kuma (rol: postulante)
- **1 examen de demo:** "Razonamiento Matemático — Bloque 1" con 25 preguntas
- Las preguntas tienen `correctAlternativeId` que apunta a cuál alternativa es la correcta
- Las alternativas tienen `isCorrect=1` solo en la respuesta correcta

---

## Notas técnicas

- **SQLite local:** Toda la data está en el dispositivo. No hay backend externo.
- **Internet para Gemini:** Solo se necesita internet cuando se usa OCR (subir examen) o análisis de IA. Para tomar el simulacro no se necesita internet.
- **El `.env` está en el APK:** La `GEMINI_API_KEY` se incluye como asset en el APK. Por eso funciona Gemini sin configurar nada extra en el celular.
