# Contexto del proyecto — admision_amauta
_Generado por explorar-proyecto-hermes el 2026-08-13_

## Stack
- **Framework**: Flutter 3.12 / Dart SDK ^3.12
- **BD local**: SQLite vía `sqflite` ^2.4.2
- **Estado**: `provider` ^6.1.5 (solo 1 provider registrado, está vacío)
- **Prefs**: `shared_preferences` ^2.5.5
- **Rutas**: Navigation declarativa con `Navigator.pushReplacementNamed` (8 rutas definidas en main.dart)

---

## Pantallas (8 declaradas en routes, 1 FALTANTE)

| Pantalla | Archivo | Tablas que consulta/escribe | Flujo | BD real |
|---|---|---|---|---|
| LoginScreen | `screens/login_screen.dart` | users (read) | → Home o Register | ✅ SQLite via UserRepository |
| RegisterScreen | `screens/register_screen.dart` | users (create) | → Login | ✅ SQLite |
| **HomeScreen** | **`screens/home_screen.dart`** | **NO EXISTE — error de compilación** | — | — |
| CatalogScreen | `screens/catalog_screen.dart` | mock_exams (read) | → Exam | ✅ SQLite via MockExamRepository |
| ExamScreen | `screens/exam_screen.dart` | questions, alternatives (read); results (create); user_answers (NO SE USA) | → Result | ⚠️ Parcial: no persiste respuestas intermedias ni tiempo |
| ResultScreen | `screens/result_screen.dart` | results (create) | → Progress | ✅ SQLite via ResultRepository |
| ProgressScreen | `screens/progress_screen.dart` | results (read) | Detalle del usuario actual | ⚠️ Muestra score pero no el nombre del examen ni universidad |
| ProfileScreen | `screens/profile_screen.dart` | Ninguna (solo logout) | — | ❌ Sin datos de usuario |

### Problema crítico
`HomeScreen` está importado en `main.dart` (línea 16) y registrado en rutas (`'/home'`) pero **el archivo no existe en el filesystem**. La app no compila. `BottomNav` case 0 intenta navegar a `/home` — crash inmediato.

---

## Tablas (8 tablas, todas definidas en database_helper.dart)

| Tabla | Campos clave / FKs | DAO/Repositorio | Pantalla(s) | CRUD |
|---|---|---|---|---|
| users | user_id (PK), first_name, last_name, email, password, created_at | UserRepository | Login, Register, Profile | C✅ R✅ U✅ D✅ |
| universities | university_id (PK), name, acronym | UniversityRepository | Catalog (JOIN futuro) | C✅ R✅ U✅ D✅ |
| areas | area_id (PK), name, description | AreaRepository | Catalog (JOIN futuro) | C✅ R✅ U✅ D✅ |
| mock_exams | mock_exam_id (PK), university_id FK, area_id FK, title, description, exam_year, duration_minutes, total_questions | MockExamRepository | Catalog, Exam, Result | C✅ R✅ U✅ D✅ |
| questions | question_id (PK), mock_exam_id FK, question_text, image, question_score, explanation | QuestionRepository | ExamScreen | C✅ R✅ U✅ D✅ |
| alternatives | alternative_id (PK), question_id FK, alternative_text, is_correct | AlternativeRepository | ExamScreen | C✅ R✅ U✅ D✅ |
| results | result_id (PK), user_id FK, mock_exam_id FK, correct_answers, incorrect_answers, final_score, elapsed_time, completed_at | ResultRepository | Result, Progress | C✅ R✅ U❌ D✅ |
| user_answers | user_answer_id (PK), result_id FK, question_id FK, alternative_id FK | UserAnswerRepository | ExamScreen | C⚠️ R⚠️ U❌ D❌ |

### Huecos de datos
- **ExamScreen** responde preguntas pero **no persiste cada `UserAnswer`** — no se sabe qué respondió el usuario en cada pregunta tras el examen.
- **ExamScreen** hardcodea `incorrectAnswers: 5 - score` en ResultScreen (línea 114) — asume siempre 5 preguntas, no usa `totalQuestions` del mock_exam.
- **ExamScreen** no mide tiempo real: `elapsedTime` siempre es 0.

---

## Arquitectura

**Patrón**: Repository + SQLite (no Room, SQLite crudo con sqflite).
**Acceso a BD**: Singleton `DatabaseHelper.instance` → `BaseRepository.database` getter.

### Módulos profundos (bien diseñados)
- Todos los repositories heredan de `BaseRepository` → acceso centralizado a la conexión.
- Modelos con `toMap`/`fromMap`/`copyWith` completos.
- `DBConstants` centraliza todos los nombres de tablas y columnas.

### Módulos superficiales / deuda técnica
- **`ExamScreen`**: lógica de negocio mezclada en el widget (calcular score, decidir fin de examen). Si el examen crece, esta pantalla se vuelve inmanejable.
- **`ResultScreen`**: recibe `score` directamente del widget anterior en memoria (no de BD) — si el usuario refresca, pierde el resultado.
- **`ProgressScreen`**: muestra `finalScore` y `correctAnswers` pero no el nombre del examen ni universidad — el usuario no sabe a qué examen corresponde cada resultado.
- **`ProfileScreen`**: solo muestra hardcoded "User Profile" + ícono genérico — no consulta `users` para mostrar nombre ni email.
- **`exam_provider.dart`**: archivo vacío (0 bytes) — provider registrado pero sin uso.
- **`auth_service.dart`**: archivo vacío (0 bytes) — importado desde main.dart pero sin contenido.
- **`storage_service.dart`**: archivo vacío (0 bytes) — importado pero sin contenido.

---

## Huecos detectados

**Tablas sin pantalla:**
- `universities` y `areas` existen en BD y repositorios pero ninguna pantalla las muestra ni filtra por ellas (CatalogScreen muestra todos los simulacros sin filtro).

**Pantallas sin tabla / con datos hardcodeados:**
- `ProfileScreen`: sin consulta a `users` (muestra ícono y texto genérico).
- `HomeScreen`: NO EXISTE el archivo — bloquea compilación.
- `auth_service.dart`, `storage_service.dart`, `exam_provider.dart`: todos vacíos.

**CRUD incompleto por tabla:**
- `results`: Update no existe (`updateResult` no implementado en ResultRepository).
- `user_answers`: Create se llama en `UserAnswerRepository` pero nunca se invoca desde ExamScreen.

---

## Datos de prueba (database_seed.dart)

- 2 universidades: UNH (UNH), UNCP (UNCP)
- 2 áreas: Systems Engineering, Civil Engineering
- 2 simulacros con 5 preguntas cada uno (10 preguntas total)
- Cada pregunta tiene 4 alternativas (solo 1 correcta)
- 40 alternativas insertadas

---

## Observaciones de arquitectura

1. **Punto de entrada roto**: `main.dart` importa `home_screen.dart` que no existe → la app no compila.
2. **`BottomNav` depende de HomeScreen**: case 0 del switch intenta navegar a `/home` — crash.
3. **El examen es de flujos lineales**: el usuario responde pregunta por pregunta secuencialmente, sin posibilidad de navegar entre preguntas o cambiar respuesta — flujo correcto para un simulacro básico.
4. **No hay paginación ni filtros en CatalogScreen**: lista todos los mock_exams sin filtro por universidad ni área.
5. **El examen no tiene cronómetro funcional**: `elapsedTime` siempre es 0.
6. **Los resultados no muestran contexto**: ProgressScreen lista puntajes pero sin saber a qué examen corresponden.
7. **Provider no se usa**: `exam_provider.dart` está vacío y no hay `ChangeNotifierProvider` en el widget tree.

---

## Siguiente paso natural

Según la metodología Matt Pocock, el siguiente paso es la **fase 2: grilling** (interrogatorio) para alinear qué features se quieren construir o corregir a continuación. candidates obvias:

1. **BUG BLOQUEANTE**: Crear `home_screen.dart` faltante para que la app compile.
2. **Perfil vacío**: Conectar `ProfileScreen` a `UserRepository` para mostrar nombre/email real.
3. **Progress inútil**: `ProgressScreen` necesita JOIN con `mock_exams` para mostrar nombres de exámenes.
4. **user_answers huérfano**: `ExamScreen` debería llamar a `UserAnswerRepository` para guardar cada respuesta.
5. **Sin filtros**: `CatalogScreen` podría filtrar por universidad/área.

Antes de cualquier feature nueva, **fase 2 (grilling)** debería priorizar qué se aborda primero.
