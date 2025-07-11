import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/custom_button.dart';
import '../widgets/report_card.dart';
import '../models/report_model.dart';
import '../services/report_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _reportService = ReportService();
  List<ReportModel> _reports = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReports();
  }

  Future<void> _loadReports() async {
    setState(() => _isLoading = true);
    
    try {
      // Inicializar datos de ejemplo
      _reportService.initializeSampleData();
      
      // Cargar reportes
      final reports = await _reportService.getReports();
      
      if (mounted) {
        setState(() {
          _reports = reports;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        _showErrorSnackBar('Error al cargar los reportes');
      }
    }
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
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadReports,
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
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.grey,
                  ),
                ),
              ),
              // Sección de crear reporte
              _buildCreateReportSection(),
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
            child: const Icon(
              Icons.add,
              color: AppColors.white,
              size: 30,
            ),
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
            style: TextStyle(
              fontSize: 14,
              color: AppColors.grey,
            ),
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
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.grey,
            ),
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
              child: CircularProgressIndicator(
                color: AppColors.primary,
              ),
            ),
          )
        else if (_reports.isEmpty)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(
                    Icons.inbox_outlined,
                    size: 64,
                    color: AppColors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No hay reportes disponibles',
                    style: TextStyle(
                      fontSize: 16,
                      color: AppColors.grey,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Crea tu primer reporte para empezar',
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.grey,
                    ),
                  ),
                ],
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
              return ReportCard(
                report: report,
                onTap: () {
                  // Implementar navegación a detalle del reporte
                  _showReportDetail(report);
                },
              );
            },
          ),
        const SizedBox(height: 20),
      ],
    );
  }

  void _showReportDetail(ReportModel report) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(report.title),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Descripción: ${report.description}'),
            const SizedBox(height: 8),
            Text('Prioridad: ${report.priority}'),
            const SizedBox(height: 8),
            Text('Fecha: ${report.reportDate.day}/${report.reportDate.month}/${report.reportDate.year}'),
            if (report.tags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('Etiquetas: ${report.tags.join(', ')}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cerrar'),
          ),
        ],
      ),
    );
  }
} 