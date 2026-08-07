/// ===============================================================
/// PROYECTO : ADMISIÓN AMAUTA
/// ARCHIVO  : area_model.dart
///
/// DESCRIPCIÓN:
/// Modelo que representa un área académica.
/// ===============================================================

import '../database/database_constants.dart';

class Area {

  final int? areaId;
  final String areaName;
  final String areaDescription;

  const Area({

    this.areaId,

    required this.areaName,

    required this.areaDescription,

  });

  Map<String, dynamic> toMap() {

    return {

      DBConstants.areaId: areaId,

      DBConstants.areaName: areaName,

      DBConstants.areaDescription: areaDescription,

    };

  }

  factory Area.fromMap(Map<String, dynamic> map) {

    return Area(

      areaId: map[DBConstants.areaId],

      areaName: map[DBConstants.areaName],

      areaDescription: map[DBConstants.areaDescription],

    );

  }

  Area copyWith({

    int? areaId,

    String? areaName,

    String? areaDescription,

  }) {

    return Area(

      areaId: areaId ?? this.areaId,

      areaName: areaName ?? this.areaName,

      areaDescription: areaDescription ?? this.areaDescription,

    );

  }

  @override
  String toString() {

    return '''
Area(
  areaId: $areaId,
  areaName: $areaName
)
''';

  }

}