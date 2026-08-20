# Evidencias de Pruebas — Admisión Amauta

Este directorio contiene las evidencias de las pruebas de aceptación de los flujos principales de la aplicación.

## Estructura

```
evidencias/
├── explicacion/
│   └── Flujos_del_Sistema.md        ← Explicación técnica completa
├── pruebas/
│   ├── admin_examen/                 ← Flujo 1: Admin sube examen
│   └── postulante_simulacro/        ← Flujo 2: Postulante toma simulacro
└── README.md                         ← Este archivo
```

## Cómo ejecutar las pruebas

### Opción A — Pruebas automáticas (recomendado)

1. Asegúrate de tener `adb` instalado y tu celular/emulador conectado
2. Ejecuta desde la raíz del proyecto:

```bash
cd admision_amauta
flutter test integration_test/app_test.dart
```

Las capturas se guardarán automáticamente en las carpetas `pruebas/admin_examen/` y `pruebas/postulante_simulacro/`.

### Opción B — Pruebas manuales

Si prefieres hacer las capturas manualmente desde tu celular:

1. Instala el APK en tu celular desde:
   `build/app/outputs/flutter-apk/app-debug.apk`

2. Sigue los flujos descritos abajo

3. Ve a la carpeta correspondiente y agrega tus capturas manualmente

---

## Flujo 1 — Admin: Cargar y subir examen

### Pasos para reproducir

1. **Login como admin**
   - Email: `kuma@gmail.com`
   - Contraseña: `kuma`

2. **Navegar a Subir Examen**
   - Tocar menú hamburguesa (≡) → "Panel de Admin"
   - Tocar "Gestionar Exámenes"
   - Tocar botón "+" o "Subir Examen"

3. **Paso 1 — Datos del examen**
   - Título: "Examen de Prueba"
   - Descripción: "Prueba de evidencias"
   - Bloque: seleccionar cualquier opción
   - Captura: `01_datos_examen.png`

4. **Paso 2 — Subir foto (OCR)**
   - Tocar "Seleccionar imagen"
   - Elegir una foto de examen (puede ser cualquier imagen con texto)
   - Esperar a que Gemini haga OCR
   - Verificar que extrae texto
   - Captura: `02_foto_subida.png`

5. **Paso 3 — Revisar preguntas extraídas**
   - Verificar que las preguntas aparecen
   - Tocar "Guardar Examen"
   - Captura: `03_preguntas_extraidas.png`

6. **Verificar en lista**
   - Volver a la lista de exámenes
   - Ver que aparece el examen recién creado
   - Captura: `04_examen_en_lista.png`

---

## Flujo 2 — Postulante: Simulacro completo

### Pasos para reproducir

1. **Login como postulante**
   - Email: `kuma@gmail.com`
   - Contraseña: `kuma`

2. **Ver catálogo**
   - Ver la lista de exámenes disponibles
   - Captura: `01_catalogo.png`

3. **Seleccionar examen**
   - Tocar el examen "Razonamiento Matemático — Bloque 1"
   - Captura: `02_examen_seleccionado.png`

4. **Tomar el examen**
   - Responder las 25 preguntas
   - Capturas sugeridas (mínimo):
     - `03_pregunta_01.png` (primera pregunta)
     - `04_pregunta_10.png` (mitad del examen)
     - `05_pregunta_25.png` (última pregunta)

5. **Pantalla de resultados**
   - Ver el puntaje, correctas/incorrectas, tiempo
   - Captura: `06_resultados.png`

6. **Revisar con IA**
   - Tocar "Revisar con IA"
   - Ver la lista de preguntas (verde = correcta, rojo = incorrecta)
   - Captura: `07_revision_lista.png`

7. **Detalle de pregunta correcta**
   - Tocar una pregunta marcada en verde
   - Ver alternativas con la correcta resaltada
   - Captura: `08_detalle_correcta.png`

8. **Detalle de pregunta incorrecta**
   - Tocar una pregunta marcada en rojo
   - Ver que muestra cuál respondió mal vs la correcta
   - Captura: `09_detalle_incorrecta.png`

---

## Convenciones de nombres

| Prefijo | Significado |
|---|---|
| `01_`, `02_`, ... | Orden de la secuencia del flujo |
| `_admin_` | Captura del flujo admin |
| `_postulante_` | Captura del flujo postulante |
| `_correcta_` | Pregunta respondida correctamente |
| `_incorrecta_` | Pregunta respondida incorrectamente |
