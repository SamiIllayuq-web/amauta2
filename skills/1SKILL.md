---
name: explorar-proyecto-hermes
description: Lee y entiende TODO el contexto real del proyecto de forma exhaustiva y completa — todas las pantallas (sin asumir un número fijo), toda la base de datos creada en Android Studio (todas las tablas, sin asumir un número fijo), todos los DAOs/repositorios, y el estado real del CRUD — recorriendo el proyecto completo sin omitir archivos. Úsala SIEMPRE al arrancar una sesión nueva o cuando el contexto se haya "limpiado" (clear/compact), cuando el usuario diga cosas como "revisa el proyecto", "entiende el contexto", "mapea las pantallas y tablas", "qué falta del CRUD", "no sabemos cuántas pantallas/tablas hay, revisa todo", o antes de invocar cualquier otra skill del pipeline (grilling/PRD/Kanban/implementación) para una feature nueva. Es el PRIMER PASO obligatorio de la metodología Matt Pocock (explorar → grillar → PRD → Kanban → implementar) adaptada a este stack: Hermes Agent + MiniMax 2.7, proyecto en VS Code con emulador de Android, base de datos gestionada en Android Studio. Las demás skills del pipeline se apoyan en el documento que esta skill genera, en vez de releer el proyecto entero cada vez.
---

# Explorar Proyecto (fase 1 — mapa de contexto compartido)

## Por qué existe esta skill

Los LLM son como el personaje de "Memento": cada vez que se limpia el contexto (clear/compact),
vuelven a cero. No recuerdan tu proyecto de una sesión a otra. Además, tienen una "zona lista"
(smart zone) y una "zona torpe" (dumb zone): cuanto más contexto irrelevante se acumula, peor
razonan. Por eso, en vez de cargar todo el proyecto de golpe en cada mensaje, esta skill hace
UNA exploración estructurada y deja un resumen compacto y confiable que sirve de "concepto de
diseño compartido" para todo lo que venga después (grilling, PRD, tickets, implementación).

Esta skill NO planifica una feature nueva y NO escribe código. Solo lee, mapea y deja constancia
de cómo está el proyecto HOY. Es información que se "pull-ea" (el agente la busca cuando la
necesita), no algo que se empuja a la fuerza en cada prompt.

## Cuándo NO usar esta skill

- Si ya se hizo esta exploración COMPLETA en la MISMA sesión (mismo contexto, sin clear/compact)
  y nada cambió en el proyecto, no la repitas — sería quemar tokens en la zona torpe sin necesidad.
- No la uses para diseñar una feature nueva (para eso viene después la skill de "grilling"/PRD).
- No la uses para editar código o migraciones — esta fase es solo lectura.

## Regla de esta primera pasada: cero suposiciones, cero archivos saltados

No se sabe con certeza cuántas pantallas, cuántas tablas ni cuántos archivos tiene el proyecto
— así que NO asumas ninguna cifra de antemano (ni "8 pantallas" ni "15 tablas"). El trabajo de
esta skill es precisamente descubrir esos números revisando el proyecto entero, archivo por
archivo, y dejarlos documentados con exactitud. Si al terminar encuentras 6 pantallas, 11 o 23,
repórtalo tal cual — el número real importa más que coincidir con lo que alguien creía.

"Sin omitir archivos" significa recorrer TODO el árbol del proyecto, no solo las carpetas
obvias. Sí puedes saltarte contenido que no aporta entendimiento del proyecto (carpetas
generadas como `build/`, `.gradle/`, `node_modules/`, binarios, imágenes, `.git/`), pero
cualquier archivo de código, configuración, layout, recurso XML, script SQL o markdown debe
ser al menos abierto y considerado — no solo listado por su nombre.

## Paso 0 — Listado recursivo completo

Antes de leer contenido, genera un listado recursivo de TODO el proyecto (todas las carpetas,
todos los niveles) para tener el universo completo de archivos a revisar. Usa esto como una
checklist: a medida que vayas abriendo y entendiendo cada archivo relevante, táchalo
mentalmente. El objetivo es terminar la exploración sin haber dejado ningún archivo de código,
layout, configuración o definición de base de datos sin revisar.

Si existe un `PROYECTO_CONTEXTO.md` de una exploración anterior, NO confíes en él a ciegas:
esta vez es una relectura completa desde cero — genera la versión nueva basada en lo que
encuentres ahora, no en lo que decía el documento viejo. Los documentos viejos "se pudren"
(doc rot) y confiar en uno desactualizado es peor que no tener ninguno.

## Paso 1 — Mapa de estructura

Con el listado del Paso 0 ya recorrido, arma un mapa general: dónde están las pantallas
(screens/activities/fragments), dónde están los modelos/entidades, dónde están los
DAOs/repositorios, dónde está la definición de la base de datos (Room/SQLite), y dónde está
cualquier documentación previa (README, /docs, /issues). Este mapa es un resumen de lo ya
revisado, no un atajo para saltarte archivos.

## Paso 2 — Mapear todas las pantallas encontradas

Para CADA pantalla que encuentres (revisa carpetas de screens/activities/fragments/navigation
por completo, no solo las que parezcan principales), registra:
- Nombre y archivo (ej. `LoginScreen` → `screens/LoginScreen.kt` o equivalente).
- Qué tablas/entidades consulta o modifica.
- Qué otras pantallas la preceden o siguen (flujo de navegación).
- Si ya tiene datos reales conectados a la BD o si todavía usa datos de prueba/hardcodeados.

Al final de este paso, indica el número total real de pantallas encontradas. Es información
real, repórtala tal cual salga — no la ajustes para que "cuadre" con ninguna cifra previa.

## Paso 3 — Mapear toda la base de datos encontrada

Revisa TODAS las clases de entidad/modelo, TODOS los DAOs y el archivo de definición de la
base de datos (la clase `RoomDatabase` o el esquema SQLite) hasta confirmar que no queda
ninguna tabla sin registrar. Para cada tabla/entidad, registra en una tabla de texto:

| Tabla | Campos clave / FKs | DAO o repositorio asociado | Pantalla(s) que la usan | CRUD implementado |
|---|---|---|---|---|
| ejemplo_usuarios | id (PK), nombre, email | UsuarioDao | LoginScreen, PerfilScreen | C ✅ R ✅ U ❌ D ❌ |

Para el CRUD, verifica en el código real (no asumas) si existen y están conectados a la UI:
- **Create**: ¿hay un método de inserción y una pantalla/formulario que lo dispare?
- **Read**: ¿hay consultas y se muestran los datos en alguna pantalla (lista, detalle, dashboard)?
- **Update**: ¿hay edición real o solo lectura?
- **Delete**: ¿hay borrado real, lógico (soft delete) o no existe?

Marca explícitamente las tablas que no tienen ninguna pantalla asociada (posible dato huérfano)
y las pantallas que no tienen tabla asociada (posible dato hardcodeado o pendiente). Al final
de este paso, indica el número total real de tablas encontradas.

## Paso 4 — Clasificar los módulos (profundos vs superficiales)

Basándote en la idea de John Ousterhout (módulos profundos = interfaz simple + mucha
funcionalidad útil detrás, vs módulos superficiales = muchos archivitos pequeños con
dependencias enredadas): identifica si el acceso a datos está concentrado en repositorios/DAOs
bien definidos (bueno, fácil de testear) o si la lógica de BD está desperdigada dentro de las
pantallas (riesgo — cuesta más mantener y confunde al agente en tareas futuras). No lo arregles
ahora, solo repórtalo como una observación para tener en cuenta.

## Paso 5 — Generar el documento de contexto

Escribe (o sobreescribe) `PROYECTO_CONTEXTO.md` en la raíz del proyecto con esta estructura:

```markdown
# Contexto del proyecto — [nombre del proyecto]
_Generado por explorar-proyecto-hermes el [fecha]_

## Stack
- Frontend/pantallas: VS Code + emulador Android
- Base de datos: Android Studio (SQLite/Room) — completar motor real detectado
- Agente: Hermes Agent + MiniMax 2.7

## Pantallas (N encontradas)
[tabla o lista del Paso 2]

## Tablas (N encontradas)
[tabla del Paso 3]

## Observaciones de arquitectura
[hallazgos del Paso 4: módulos profundos/superficiales, deuda técnica visible]

## Huecos detectados
- Tablas sin pantalla:
- Pantallas sin tabla / con datos hardcodeados:
- CRUD incompleto por tabla:

## Preguntas abiertas (máximo 5)
[ver Paso 6 — solo ambigüedades reales, no interrogatorio exhaustivo]
```

## Paso 6 — Preguntas breves (solo si hay ambigüedad real)

A diferencia de una sesión de "grilling" completa (que es para diseñar una feature nueva y
puede durar decenas de preguntas), aquí solo preguntas lo mínimo indispensable para que el mapa
de contexto sea correcto — por ejemplo: "la tabla `pagos` no tiene ninguna pantalla que la use,
¿está planeada para algo que aún no se construyó, o es un resto de una prueba anterior?".
Máximo 5 preguntas, una a la vez, con tu recomendación incluida en cada una (igual que en el
método de grilling: no solo preguntes, propone también una respuesta razonable).

## Al terminar

Cierra confirmando que `PROYECTO_CONTEXTO.md` quedó actualizado, con el número real de
pantallas, tablas y archivos revisados, y sugiere el siguiente paso natural de la metodología:
usar la skill de "grilling"/PRD para la feature específica que el usuario quiera construir a
continuación, apoyándose en este mapa de contexto en vez de tener que releer todo el proyecto
desde cero.

## Nota sobre el resto del pipeline

Esta es solo la primera skill de la metodología. Las siguientes (interrogatorio/"grill me" para
alinear una feature nueva, generación de PRD, división en tickets tipo Kanban con slices
verticales, e implementación con TDD) se irán creando como skills separadas, cada una en su
propio archivo `SKILL.md`. Todas ellas deben leer `PROYECTO_CONTEXTO.md` primero en vez de
volver a escanear el proyecto completo — ese re-escaneo exhaustivo es el trabajo específico de
esta skill, no algo que haya que repetir en cada una.
