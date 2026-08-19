/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : database_constants.dart
///
/// DESCRIPCIÓN:
/// Centraliza toda la configuración de la base de datos SQLite.
/// Aquí se definen el nombre de la base de datos, la versión,
/// los nombres de las tablas y de sus columnas.
///
/// BENEFICIOS:
/// - Evita escribir cadenas repetidas.
/// - Reduce errores de escritura.
/// - Facilita el mantenimiento del proyecto.
/// ===============================================================

class DBConstants {

  // ==========================================================
  // Configuración general de la base de datos
  // ==========================================================

  /// Nombre del archivo SQLite.
  static const String databaseName = 'admision_amauta.db';

  /// Versión de la base de datos.
  static const int databaseVersion = 5;

  // ==========================================================
  // Tabla: Users
  // ==========================================================

  static const String usersTable = 'users';

  static const String userId = 'user_id';
  static const String firstName = 'first_name';
  static const String lastName = 'last_name';
  static const String email = 'email';
  static const String password = 'password';
  static const String createdAt = 'created_at';
  static const String role = 'role';
  static const String phone = 'phone';
  static const String bio = 'bio';

  // Roles validos
  static const String roleAdmin = 'ADMIN';
  static const String rolePostulante = 'POSTULANTE';

  // ==========================================================
  // Tabla: Universities
  // ==========================================================

  static const String universitiesTable = 'universities';

  static const String universityId = 'university_id';
  static const String universityName = 'name';
  static const String acronym = 'acronym';

  // ==========================================================
  // Tabla: Areas
  // ==========================================================

  static const String areasTable = 'areas';

  static const String areaId = 'area_id';
  static const String areaName = 'name';
  static const String areaDescription = 'description';

  // ==========================================================
  // Tabla: Mock Exams
  // ==========================================================

  static const String mockExamsTable = 'mock_exams';

  static const String mockExamId = 'mock_exam_id';
  static const String mockExamTitle = 'title';
  static const String mockExamDescription = 'description';
  static const String examYear = 'exam_year';
  static const String durationMinutes = 'duration_minutes';
  static const String totalQuestions = 'total_questions';

  // Llaves foráneas
  
  // ==========================================================
  // Tabla: Questions
  // ==========================================================

  static const String questionsTable = 'questions';

  static const String questionId = 'question_id';
  static const String questionText = 'question_text';
  static const String image = 'image';
  static const String questionScore = 'question_score';
  static const String explanation = 'explanation';
  static const String correctAlternativeId = 'correct_alternative_id';
  static const String aiExplanation = 'ai_explanation';

  // ==========================================================
  // Tabla: Alternatives
  // ==========================================================

  static const String alternativesTable = 'alternatives';

  static const String alternativeId = 'alternative_id';
  static const String alternativeText = 'alternative_text';
  static const String isCorrect = 'is_correct';
  // ==========================================================
  // Tabla: Results
  // ==========================================================

  static const String resultsTable = 'results';

  static const String resultId = 'result_id';
  static const String correctAnswers = 'correct_answers';
  static const String incorrectAnswers = 'incorrect_answers';
  static const String finalScore = 'final_score';
  static const String elapsedTime = 'elapsed_time';
  static const String completedAt = 'completed_at';
       

       
  // ==========================================================
  // Tabla: User Answers
  // ==========================================================

  static const String userAnswersTable = 'user_answers';

  static const String userAnswerId = 'user_answer_id';

  // ==========================================================
// Foreign Keys (Llaves Foráneas)
// ==========================================================

static const String userIdFk = 'user_id';

static const String universityIdFk = 'university_id';

static const String areaIdFk = 'area_id';

static const String mockExamIdFk = 'mock_exam_id';

static const String questionIdFk = 'question_id';

static const String alternativeIdFk = 'alternative_id';

  static const String resultIdFk = 'result_id';

  // ==========================================================
  // Tabla: Comments (Fase G)
  // ==========================================================

  static const String commentsTable = 'comments';

  static const String commentId = 'comment_id';
  static const String commentContent = 'content';
}