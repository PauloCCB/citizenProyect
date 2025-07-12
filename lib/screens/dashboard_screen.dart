import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/report_card.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';
import '../services/auth_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _reportService = ReportService();
  final _authService = AuthService();
  List<ReportModel> _reports = [];
  bool _isLoading = true;
  int _currentLimit = 10;
  int _currentOffset = 1;
  final _limitController = TextEditingController();
  final _offsetController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _limitController.text = _currentLimit.toString();
    _offsetController.text = _currentOffset.toString();
    _loadReports();
  }

  @override
  void dispose() {
    _limitController.dispose();
    _offsetController.dispose();
    super.dispose();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);

    try {
      final reports = await _reportService.getReports(
        limit: _currentLimit,
        offset: _currentOffset,
      );

      if (mounted) {
        setState(() {
          _reports = reports;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Error al cargar los reportes: ${e.toString()}');
      }
    }
  }

  Future<void> _logout() async {
    try {
      await _authService.logout();
      if (mounted) {
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      _showErrorSnackBar('Error al cerrar sesión');
    }
  }

  void _updatePagination() {
    final newLimit = int.tryParse(_limitController.text);
    final newOffset = int.tryParse(_offsetController.text);

    if (newLimit != null &&
        newOffset != null &&
        newLimit > 0 &&
        newOffset > 0) {
      setState(() {
        _currentLimit = newLimit;
        _currentOffset = newOffset;
      });
      _loadReports();
    } else {
      _showErrorSnackBar(
        'Los valores de límite y página deben ser números positivos',
      );
    }
  }

  void _showReportDetail(ReportModel report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(report.title),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Descripción:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(report.description),
              SizedBox(height: 12),
              Text('Fecha:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text(report.reportedDate.toString().split(' ')[0]),
              SizedBox(height: 12),
              Text('Prioridad:', style: TextStyle(fontWeight: FontWeight.bold)),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: report.priorityColor,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  report.priorityText,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(height: 12),
              Text('Ubicación:', style: TextStyle(fontWeight: FontWeight.bold)),
              Text('Lat: ${report.lat}, Long: ${report.long}'),
              if (report.tags.isNotEmpty) ...[
                SizedBox(height: 12),
                Text(
                  'Etiquetas:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Wrap(
                  spacing: 4,
                  children: report.tags
                      .map(
                        (tag) => Chip(
                          label: Text(tag),
                          backgroundColor: Colors.blue.shade100,
                        ),
                      )
                      .toList(),
                ),
              ],
              if (report.user != null) ...[
                SizedBox(height: 12),
                Text(
                  'Reportado por:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Text('${report.user!.fullName} (${report.user!.email})'),
              ],
              if (report.images.isNotEmpty) ...[
                SizedBox(height: 12),
                Text(
                  'Imágenes:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                ...report.images
                    .map(
                      (imageUrl) => Padding(
                        padding: EdgeInsets.only(top: 8),
                        child: Image.network(
                          imageUrl,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              Container(
                                height: 200,
                                color: Colors.grey.shade300,
                                child: Icon(Icons.error),
                              ),
                        ),
                      ),
                    )
                    .toList(),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Citizen'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadReports),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
            tooltip: 'Cerrar sesión',
          ),
        ],
      ),
      backgroundColor: AppColors.white,
      body: RefreshIndicator(
        onRefresh: _loadReports,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Reportes ciudadanos',
                  style: TextStyle(fontSize: 16, color: AppColors.grey),
                ),
              ),
              // Sección de crear reporte
              _buildCreateReportSection(),
              // Controles de paginación
              _buildPaginationControls(),
              // Estadísticas
              _buildStatisticsSection(),
              const SizedBox(height: 20),
              // Lista de reportes
              _buildReportsSection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCreateReportSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(30),
            ),
            child: const Icon(Icons.add, color: AppColors.white, size: 30),
          ),
          const SizedBox(height: 16),
          const Text(
            'Crear Nuevo Reporte',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Reporta problemas en tu comunidad y ayuda a mejorarla',
            style: TextStyle(fontSize: 14, color: AppColors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          CustomButton(
            text: 'Generar Reporte',
            onPressed: () {
              Navigator.pushNamed(context, '/create-report');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaginationControls() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Paginación',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _limitController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Límite',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: TextField(
                  controller: _offsetController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Página',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton(
                onPressed: _updatePagination,
                child: const Text('Actualizar'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              title: 'Total Reportes',
              value: _reportService.totalReports.toString(),
              color: AppColors.primary,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: _buildStatCard(
              title: 'Resueltos',
              value: _reportService.resolvedReports.toString(),
              color: AppColors.green,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: AppColors.shadowColor,
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: AppColors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildReportsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Reportes Recientes',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
        ),
        const SizedBox(height: 12),
        if (_isLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: CircularProgressIndicator(),
            ),
          )
        else if (_reports.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Text(
                'No hay reportes disponibles',
                style: TextStyle(color: AppColors.grey, fontSize: 16),
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _reports.length,
            itemBuilder: (context, index) {
              final report = _reports[index];
              return Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: GestureDetector(
                  onDoubleTap: () => _showReportDetail(report),
                  child: ReportCard(report: report),
                ),
              );
            },
          ),
      ],
    );
  }
}
