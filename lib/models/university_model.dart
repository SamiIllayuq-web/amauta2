/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : university_model.dart
///
/// DESCRIPCIÓN:
/// Modelo que representa una universidad.
/// Cada objeto University corresponde a un registro de la tabla
/// Universities en SQLite.
/// ===============================================================

import '../database/database_constants.dart';

class University {

  // ==========================================================
  // Atributos
  // ==========================================================

  final int? universityId;
  final String universityName;
  final String acronym;

  // ==========================================================
  // Constructor
  // ==========================================================

  const University({

    this.universityId,

    required this.universityName,

    required this.acronym,

  });

  // ==========================================================
  // Convierte el objeto a Map.
  // ==========================================================

  Map<String, dynamic> toMap() {

    return {

      DBConstants.universityId: universityId,

      DBConstants.universityName: universityName,

      DBConstants.acronym: acronym,

    };

  }

  // ==========================================================
  // Convierte un Map en un objeto University.
  // ==========================================================

  factory University.fromMap(Map<String, dynamic> map) {

    return University(

      universityId: map[DBConstants.universityId],

      universityName: map[DBConstants.universityName],

      acronym: map[DBConstants.acronym],

    );

  }

  // ==========================================================
  // Copia del objeto.
  // ==========================================================

  University copyWith({

    int? universityId,

    String? universityName,

    String? acronym,

  }) {

    return University(

      universityId: universityId ?? this.universityId,

      universityName: universityName ?? this.universityName,

      acronym: acronym ?? this.acronym,

    );

  }

  @override
  String toString() {

    return '''
University(
  universityId: $universityId,
  universityName: $universityName,
  acronym: $acronym
)
''';

  }

}