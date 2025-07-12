import 'dart:io';
import '../models/report_model.dart';
import 'api_service.dart';

class ReportService {
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  List<ReportModel> _reports = [];
  int _totalReports = 0;
  int _resolvedReports = 0;

  List<ReportModel> get reports => _reports;
  int get totalReports => _totalReports;
  int get resolvedReports => _resolvedReports;

  // Obtener reportes con paginación
  Future<List<ReportModel>> getReports({int limit = 10, int offset = 1}) async {
    try {
      final response = await ApiService.get(
        '/incidencia',
        requiresAuth: true,
        queryParams: {'limit': limit.toString(), 'offset': offset.toString()},
      );

      if (response['success'] == true) {
        final List<dynamic> data = response['data'] ?? [];
        _reports = data.map((json) => ReportModel.fromJson(json)).toList();

        // Actualizar estadísticas
        _totalReports = _reports.length;
        _resolvedReports = _reports.where((r) => r.isResolved == true).length;

        return _reports;
      }
      return [];
    } catch (e) {
      throw Exception('Error al obtener reportes: $e');
    }
  }

  // Crear nuevo reporte
  Future<bool> createReport({
    required String title,
    required String description,
    String? generatedDetails,
    required DateTime reportDate,
    required List<String> tags,
    required String lat,
    required String long,
    int? priority,
    required List<String> images,
  }) async {
    try {
      final response = await ApiService.post('/incidencia', {
        'title': title,
        'description': description,
        'generated_details': generatedDetails,
        'reported_date': reportDate.toIso8601String(),
        'tags': tags,
        'lat': lat,
        'long': long,
        'priority': priority,
        'images': images,
      }, requiresAuth: true);

      if (response['success'] == true) {
        return true;
      }
      return false;
    } catch (e) {
      throw Exception('Error al crear reporte: $e');
    }
  }

  // Subir imagen y obtener análisis
  Future<Map<String, dynamic>> uploadImage(File imageFile) async {
    try {
      final response = await ApiService.postMultipart(
        '/files/incidencia/images',
        imageFile,
        requiresAuth: true,
      );

      if (response['success'] == true) {
        return {
          'imageUrl': response['imageUrl'],
          'generatedDetails': response['modelResult']['clase'],
          'priority': response['modelResult']['urgencia'],
          'confidence': response['modelResult']['confianza'],
        };
      }
      throw Exception('Error al procesar imagen');
    } catch (e) {
      throw Exception('Error al subir imagen: $e');
    }
  }

  // Validaciones
  String? validateTitle(String title) {
    if (title.isEmpty) {
      return 'El título es requerido';
    }
    if (title.length < 5) {
      return 'El título debe tener al menos 5 caracteres';
    }
    return null;
  }

  String? validateDescription(String description) {
    if (description.isEmpty) {
      return 'La descripción es requerida';
    }
    if (description.length < 10) {
      return 'La descripción debe tener al menos 10 caracteres';
    }
    return null;
  }

  String? validateLocation(String location) {
    if (location.isEmpty) {
      return 'La ubicación es requerida';
    }

    // Validar formato de coordenadas
    final double? coord = double.tryParse(location);
    if (coord == null) {
      return 'Formato de coordenada inválido';
    }

    return null;
  }

  // Obtener colores para tags
  static List<String> getTagColors() {
    return [
      '#FF6B6B', // Rojo
      '#4ECDC4', // Turquesa
      '#45B7D1', // Azul
      '#FFA07A', // Salmón
      '#98D8C8', // Menta
      '#F7DC6F', // Amarillo
      '#BB8FCE', // Morado
      '#85C1E9', // Azul claro
      '#F8C471', // Naranja
      '#82E0AA', // Verde
    ];
  }

  // Obtener color para prioridad
  static String getPriorityColor(String priority) {
    switch (priority.toUpperCase()) {
      case 'ALTA':
        return '#FF6B6B';
      case 'MEDIA':
        return '#FFA07A';
      case 'BAJA':
        return '#82E0AA';
      default:
        return '#DDDDDD';
    }
  }
}
