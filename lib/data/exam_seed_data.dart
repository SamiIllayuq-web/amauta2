/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : exam_seed_data.dart
///
/// DESCRIPCION:
/// Datos seed de examenes para pruebas de desarrollo.
/// Contiene 26 preguntas del examen de admision UNH
/// basadas en las fotos capturasDeExamen/ (unh1-unh5).
///
/// Este archivo permite cargar examenes de prueba sin necesidad
/// de usar Gemini Vision.
///
// ===============================================================

const Map<String, dynamic> examSeedData = {
  'exam_title': 'Examen de Admision UNH',
  'university': 'Universidad Nacional de Huancavelica',
  'year': '2023',
  'questions': [
    {
      'number': 1,
      'text':
          'La comunicacion es un proceso esencialmente simbolico. Esta definicion corresponde a:',
      'correct': 'B',
      'alternatives': [
        {'letter': 'A', 'text': 'Freire'},
        {'letter': 'B', 'text': 'Berlo'},
        {'letter': 'C', 'text': 'Chomsky'},
        {'letter': 'D', 'text': 'Piaget'},
      ]
    },
    {
      'number': 2,
      'text':
          'El emisor en el proceso de comunicacion es quien:',
      'correct': 'A',
      'alternatives': [
        {'letter': 'A', 'text': 'Codifica y transmite el mensaje'},
        {'letter': 'B', 'text': 'Decodifica la informacion'},
        {'letter': 'C', 'text': 'Es el canal de la comunicacion'},
        {'letter': 'D', 'text': 'Retroalimenta el mensaje'},
      ]
    },
    {
      'number': 3,
      'text': 'El lenguaje esta constituido por:',
      'correct': 'C',
      'alternatives': [
        {'letter': 'A', 'text': 'Solo gestos y mimicas'},
        {'letter': 'B', 'text': 'Solo sonidos'},
        {'letter': 'C', 'text': 'Un sistema de signos arbitrarios'},
        {'letter': 'D', 'text': 'Unicamente imagenes'},
      ]
    },
    {
      'number': 4,
      'text':
          'La funcion del lenguaje que predomina en la publicidad es:',
      'correct': 'B',
      'alternatives': [
        {'letter': 'A', 'text': 'Referencial'},
        {'letter': 'B', 'text': 'Conativa'},
        {'letter': 'C', 'text': 'Emotiva'},
        {'letter': 'D', 'text': 'Metalinguistica'},
      ]
    },
    {
      'number': 5,
      'text': 'Un buen recurso no verbal es:',
      'correct': 'D',
      'alternatives': [
        {'letter': 'A', 'text': 'No utilizar las manos al hablar'},
        {'letter': 'B', 'text': 'Mantener el mismo tono de voz en todo momento'},
        {'letter': 'C', 'text': 'La distancia mas proxima posible'},
        {'letter': 'D', 'text': 'La mirada directa a los ojos del receptor'},
      ]
    },
    {
      'number': 6,
      'text': 'El canal en el proceso comunicativo es:',
      'correct': 'A',
      'alternatives': [
        {'letter': 'A', 'text': 'El medio por el cual viaja el mensaje'},
        {'letter': 'B', 'text': 'El emisor del mensaje'},
        {'letter': 'C', 'text': 'El receptor que interpreta'},
        {'letter': 'D', 'text': 'El codigo utilizado'},
      ]
    },
    {
      'number': 7,
      'text':
          'La comunicacion no verbal puede representar hasta:',
      'correct': 'C',
      'alternatives': [
        {'letter': 'A', 'text': '20% del mensaje total'},
        {'letter': 'B', 'text': '30% del mensaje total'},
        {'letter': 'C', 'text': 'Mas del 60% del mensaje total'},
        {'letter': 'D', 'text': '10% del mensaje total'},
      ]
    },
    {
      'number': 8,
      'text':
          'El entorno fisico donde se desarrolla la comunicacion se denomina:',
      'correct': 'B',
      'alternatives': [
        {'letter': 'A', 'text': 'Codigo'},
        {'letter': 'B', 'text': 'Contexto o escenario'},
        {'letter': 'C', 'text': 'Canal auditivo'},
        {'letter': 'D', 'text': 'Retroalimentacion'},
      ]
    },
    {
      'number': 9,
      'text': 'Cuando el receptor responde al emisor, se produce:',
      'correct': 'A',
      'alternatives': [
        {'letter': 'A', 'text': 'Retroalimentacion'},
        {'letter': 'B', 'text': 'Redundancia'},
        {'letter': 'C', 'text': 'Interferencia'},
        {'letter': 'D', 'text': 'Canalizacion'},
      ]
    },
    {
      'number': 10,
      'text': 'La kinestesica estudia:',
      'correct': 'D',
      'alternatives': [
        {'letter': 'A', 'text': 'Los sonidos de la voz'},
        {'letter': 'B', 'text': 'El espacio fisico'},
        {'letter': 'C', 'text': 'El contacto fisico y movimientos corporales'},
        {'letter': 'D', 'text': 'Los objetos y el entorno'},
      ]
    },
    {
      'number': 11,
      'text':
          'El tiempo cronologico y el tiempo biologico se diferencian en que:',
      'correct': 'B',
      'alternatives': [
        {'letter': 'A', 'text': 'Son exactamente iguales'},
        {'letter': 'B', 'text': 'El biologico es subjetivo y el cronologico es objetivo'},
        {'letter': 'C', 'text': 'No tienen ninguna diferencia'},
        {'letter': 'D', 'text': 'El biologico se mide en horas'},
      ]
    },
    {
      'number': 12,
      'text': 'La proxemia fue estudiada por:',
      'correct': 'A',
      'alternatives': [
        {'letter': 'A', 'text': 'Edward Hall'},
        {'letter': 'B', 'text': 'Desmond Morris'},
        {'letter': 'C', 'text': 'Ray Birdwhistell'},
        {'letter': 'D', 'text': 'Paul Ekman'},
      ]
    },
    {
      'number': 13,
      'text': 'La distancia intima esta comprendida entre:',
      'correct': 'C',
      'alternatives': [
        {'letter': 'A', 'text': '1.20 a 2 metros'},
        {'letter': 'B', 'text': '3.60 a 7.50 metros'},
        {'letter': 'C', 'text': '0 a 45 centimetros'},
        {'letter': 'D', 'text': '7.50 a 12 metros'},
      ]
    },
    {
      'number': 14,
      'text':
          'La mirada directa a los ojos del receptor indica:',
      'correct': 'D',
      'alternatives': [
        {'letter': 'A', 'text': 'Desinteres'},
        {'letter': 'B', 'text': 'Agresividad'},
        {'letter': 'C', 'text': 'Timidez'},
        {'letter': 'D', 'text': 'Seguridad y interes'},
      ]
    },
    {
      'number': 15,
      'text': 'El codigo en la comunicacion es:',
      'correct': 'A',
      'alternatives': [
        {
          'letter': 'A',
          'text': 'El sistema de signos utilizado por emisor y receptor'
        },
        {'letter': 'B', 'text': 'El medio fisico de transmision'},
        {'letter': 'C', 'text': 'El mensaje mismo'},
        {'letter': 'D', 'text': 'La respuesta del receptor'},
      ]
    },
    {
      'number': 16,
      'text':
          'El emisor y receptor ocupan posiciones fijas en la comunicacion:',
      'correct': 'B',
      'alternatives': [
        {'letter': 'A', 'text': 'En la comunicacion circular'},
        {'letter': 'B', 'text': 'En la comunicacion lineal'},
        {'letter': 'C', 'text': 'En toda comunicacion'},
        {'letter': 'D', 'text': 'En la comunicacion virtual'},
      ]
    },
    {
      'number': 17,
      'text':
          'La comunicacion interna de una organizacion incluye:',
      'correct': 'A',
      'alternatives': [
        {'letter': 'A', 'text': 'Comunicacion formal e informal'},
        {'letter': 'B', 'text': 'Solo comunicacion con clientes'},
        {'letter': 'C', 'text': 'Unicamente boletines externos'},
        {'letter': 'D', 'text': 'Solo comunicacion oral'},
      ]
    },
    {
      'number': 18,
      'text': 'El ruido en la comunicacion puede ser:',
      'correct': 'C',
      'alternatives': [
        {'letter': 'A', 'text': 'Solo fisico'},
        {'letter': 'B', 'text': 'Solo psicologico'},
        {
          'letter': 'C',
          'text': 'Fisico, fisiologico, psicologico y semantico'
        },
        {'letter': 'D', 'text': 'Unicamente semantico'},
      ]
    },
    {
      'number': 19,
      'text': 'La comunicacion ascendente es la que fluye:',
      'correct': 'B',
      'alternatives': [
        {'letter': 'A', 'text': 'De arriba hacia abajo en la organizacion'},
        {'letter': 'B', 'text': 'De abajo hacia arriba en la organizacion'},
        {'letter': 'C', 'text': 'Entre pares de la organizacion'},
        {'letter': 'D', 'text': 'Hacia afuera de la organizacion'},
      ]
    },
    {
      'number': 20,
      'text': 'El informe de una investigacion es un documento que:',
      'correct': 'D',
      'alternatives': [
        {'letter': 'A', 'text': 'Solo presenta graficos y tablas'},
        {'letter': 'B', 'text': 'Contiene solo conclusiones'},
        {'letter': 'C', 'text': 'Describe paso a paso la metodologia'},
        {
          'letter': 'D',
          'text': 'Sistematiza los resultados de una investigacion'
        },
      ]
    },
    {
      'number': 21,
      'text': 'La comunicacion escrita permite:',
      'correct': 'A',
      'alternatives': [
        {
          'letter': 'A',
          'text': 'Dejar constancia y constancia de lo comunicado'
        },
        {'letter': 'B', 'text': 'Recibir retroalimentacion inmediata'},
        {'letter': 'C', 'text': 'Usar solo gestos'},
        {'letter': 'D', 'text': 'Eliminar el lenguaje verbal'},
      ]
    },
    {
      'number': 22,
      'text': 'La inteligencia emocional implica:',
      'correct': 'B',
      'alternatives': [
        {'letter': 'A', 'text': 'Solo el coeficiente intelectual'},
        {
          'letter': 'B',
          'text': 'Reconocer y manejar emociones propias y ajenas'
        },
        {'letter': 'C', 'text': 'Evitar toda emocion'},
        {'letter': 'D', 'text': 'Solo controlar a otros'},
      ]
    },
    {
      'number': 23,
      'text': 'La empatia en la comunicacion significa:',
      'correct': 'C',
      'alternatives': [
        {'letter': 'A', 'text': 'Tener lastima del otro'},
        {'letter': 'B', 'text': 'Estar de acuerdo siempre'},
        {'letter': 'C', 'text': 'Ponerse en el lugar del otro'},
        {'letter': 'D', 'text': 'Hablar mas que el otro'},
      ]
    },
    {
      'number': 24,
      'text': 'El objetivo general de una investigacion indica:',
      'correct': 'A',
      'alternatives': [
        {'letter': 'A', 'text': 'El proposito central del estudio'},
        {'letter': 'B', 'text': 'Resultados especificos'},
        {'letter': 'C', 'text': 'Solo la bibliografia consultada'},
        {'letter': 'D', 'text': 'El presupuesto del proyecto'},
      ]
    },
    {
      'number': 25,
      'text': 'El marco teorico de una investigacion sirve para:',
      'correct': 'D',
      'alternatives': [
        {'letter': 'A', 'text': 'Solo citar autores'},
        {'letter': 'B', 'text': 'Redactar conclusiones'},
        {'letter': 'C', 'text': 'Disenar la caratula'},
        {'letter': 'D', 'text': 'Fundamentar teoricamente el estudio'},
      ]
    },
    {
      'number': 26,
      'text': 'En la comunicacion asertiva el emisor:',
      'correct': 'C',
      'alternatives': [
        {'letter': 'A', 'text': 'Agrede verbalmente'},
        {'letter': 'B', 'text': 'Expresa sus ideas sin respetar al otro'},
        {'letter': 'C', 'text': 'Expresa sus derechos respetando a los demas'},
        {'letter': 'D', 'text': 'Se calla para evitar conflictos'},
      ]
    },
  ],
};
