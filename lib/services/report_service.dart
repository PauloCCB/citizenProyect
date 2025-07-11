import '../models/report_model.dart';

class ReportService {
  static final ReportService _instance = ReportService._internal();
  factory ReportService() => _instance;
  ReportService._internal();

  final List<ReportModel> _reports = [];

  List<ReportModel> get reports => _reports;

  int get totalReports => _reports.length;

  int get resolvedReports => _reports.where((report) => report.isResolved).length;

  Future<bool> createReport({
    required String title,
    required String description,
    required String generatedDetails,
    required DateTime reportDate,
    required List<String> tags,
    required double latitude,
    required double longitude,
    required String priority,
    required List<String> images,
    required List<String> relatedPersons,
  }) async {
    try {
      // Simular llamada a API
      await Future.delayed(const Duration(seconds: 2));
      
      final report = ReportModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        generatedDetails: generatedDetails,
        reportDate: reportDate,
        tags: tags,
        latitude: latitude,
        longitude: longitude,
        priority: priority,
        images: images,
        relatedPersons: relatedPersons,
        createdAt: DateTime.now(),
      );
      
      _reports.add(report);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<ReportModel>> getReports() async {
    // Simular llamada a API
    await Future.delayed(const Duration(milliseconds: 500));
    return _reports;
  }

  Future<ReportModel?> getReportById(String id) async {
    // Simular llamada a API
    await Future.delayed(const Duration(milliseconds: 500));
    try {
      return _reports.firstWhere((report) => report.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<bool> updateReport(ReportModel report) async {
    try {
      // Simular llamada a API
      await Future.delayed(const Duration(seconds: 1));
      
      final index = _reports.indexWhere((r) => r.id == report.id);
      if (index != -1) {
        _reports[index] = report;
        return true;
      }
      return false;
    } catch (e) {
      return false;
    }
  }

  Future<bool> deleteReport(String id) async {
    try {
      // Simular llamada a API
      await Future.delayed(const Duration(seconds: 1));
      
      _reports.removeWhere((report) => report.id == id);
      return true;
    } catch (e) {
      return false;
    }
  }

  List<ReportModel> getReportsByPriority(String priority) {
    return _reports.where((report) => report.priority == priority).toList();
  }

  List<ReportModel> getReportsByTag(String tag) {
    return _reports.where((report) => report.tags.contains(tag)).toList();
  }

  List<ReportModel> getRecentReports({int limit = 10}) {
    final sortedReports = List<ReportModel>.from(_reports)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return sortedReports.take(limit).toList();
  }

  // Método para inicializar datos de ejemplo
  void initializeSampleData() {
    if (_reports.isEmpty) {
      _reports.addAll([
        ReportModel(
          id: '1',
          title: 'Bache en la vía principal',
          description: 'Hay un bache grande que puede causar accidentes',
          generatedDetails: 'Información adicional del bache',
          reportDate: DateTime.now().subtract(const Duration(days: 1)),
          tags: ['infraestructura', 'urgente'],
          latitude: -12.046374,
          longitude: -77.042793,
          priority: 'alta',
          images: [],
          relatedPersons: [],
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
        ),
        ReportModel(
          id: '2',
          title: 'Basura acumulada',
          description: 'Acumulación de basura en el parque',
          generatedDetails: 'Información adicional de la basura',
          reportDate: DateTime.now().subtract(const Duration(days: 2)),
          tags: ['limpieza', 'salud'],
          latitude: -12.046374,
          longitude: -77.042793,
          priority: 'media',
          images: [],
          relatedPersons: [],
          createdAt: DateTime.now().subtract(const Duration(days: 2)),
        ),
      ]);
    }
  }

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

  String? validatePriority(String priority) {
    final validPriorities = ['Baja', 'Media', 'Alta', 'Crítica'];
    if (priority == 'Selecciona la prioridad') {
      return 'Debe seleccionar una prioridad';
    }
    if (!validPriorities.contains(priority)) {
      return 'Prioridad inválida';
    }
    return null;
  }
} 