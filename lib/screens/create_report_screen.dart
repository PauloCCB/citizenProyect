import 'package:flutter/material.dart';
import '../constants/app_colors.dart';
import '../widgets/loading_modal.dart';
import '../widgets/custom_button.dart';
import '../widgets/custom_text_field.dart';
import '../services/report_service.dart';

class CreateReportScreen extends StatefulWidget {
  const CreateReportScreen({super.key});

  @override
  State<CreateReportScreen> createState() => _CreateReportScreenState();
}

class _CreateReportScreenState extends State<CreateReportScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _tagsController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _additionalDetailsController = TextEditingController();
  final _personController = TextEditingController();
  final _reportService = ReportService();
  
  DateTime _selectedDate = DateTime.now();
  String _selectedPriority = 'Selecciona la prioridad';
  List<String> _tags = [];
  List<String> _relatedPersons = [];
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _additionalDetailsController.dispose();
    _personController.dispose();
    super.dispose();
  }

  void _addTag() {
    if (_tagsController.text.trim().isNotEmpty) {
      setState(() {
        _tags.add(_tagsController.text.trim());
        _tagsController.clear();
      });
    }
  }

  void _removeTag(String tag) {
    setState(() {
      _tags.remove(tag);
    });
  }

  void _addPerson() {
    if (_personController.text.trim().isNotEmpty) {
      setState(() {
        _relatedPersons.add(_personController.text.trim());
        _personController.clear();
      });
    }
  }

  void _removePerson(String person) {
    setState(() {
      _relatedPersons.remove(person);
    });
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    
    // Validar prioridad
    if (_selectedPriority == 'Selecciona la prioridad') {
      _showErrorSnackBar('Debe seleccionar una prioridad');
      return;
    }

    setState(() => _isLoading = true);

    // Mostrar modal de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingModal(message: 'Generando reporte...'),
    );

    try {
      final success = await _reportService.createReport(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        generatedDetails: _additionalDetailsController.text.trim(),
        reportDate: _selectedDate,
        tags: _tags,
        latitude: double.tryParse(_latitudeController.text.trim()) ?? 0.0,
        longitude: double.tryParse(_longitudeController.text.trim()) ?? 0.0,
        priority: _selectedPriority,
        images: [], // Por ahora sin imágenes
        relatedPersons: _relatedPersons,
      );

      if (mounted) {
        Navigator.pop(context); // Cerrar modal
        
        if (success) {
          _showSuccessSnackBar('Reporte generado con éxito');
          // Esperar un poco para que se vea el mensaje
          await Future.delayed(const Duration(seconds: 1));
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          _showErrorSnackBar('Error al generar el reporte');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar modal
        _showErrorSnackBar('Error de conexión. Inténtalo nuevamente.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green.shade300,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Reporte'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      backgroundColor: AppColors.white,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Completa la información',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 24),
              // Título del reporte
              CustomTextField(
                labelText: 'Título del Reporte *',
                hintText: 'Describe brevemente el problema',
                controller: _titleController,
                validator: (value) {
                  return _reportService.validateTitle(value?.trim() ?? '');
                },
              ),
              const SizedBox(height: 20),
              // Descripción
              CustomTextField(
                labelText: 'Descripción *',
                hintText: 'Proporciona más detalles sobre el problema...',
                controller: _descriptionController,
                maxLines: 4,
                validator: (value) {
                  return _reportService.validateDescription(value?.trim() ?? '');
                },
              ),
              const SizedBox(height: 20),
              // Seleccionar imagen o video
              _buildImageVideoSection(),
              const SizedBox(height: 20),
              // Personas relacionadas
              _buildRelatedPersonsSection(),
              const SizedBox(height: 20),
              // Etiquetas
              _buildTagsSection(),
              const SizedBox(height: 20),
              // Ubicación
              _buildLocationSection(),
              const SizedBox(height: 20),
              // Fecha del reporte
              _buildDateSection(),
              const SizedBox(height: 20),
              // Prioridad
              _buildPrioritySection(),
              const SizedBox(height: 20),
              // Detalles adicionales
              CustomTextField(
                labelText: 'Detalles Adicionales',
                hintText: 'Información adicional generada automáticamente...',
                controller: _additionalDetailsController,
                maxLines: 3,
              ),
              const SizedBox(height: 32),
              // Botón generar reporte
              CustomButton(
                text: 'Generar Reporte',
                onPressed: _isLoading ? null : _submitReport,
                isLoading: _isLoading,
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageVideoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Seleccionar Imagen o Video',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 150,
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.camera_alt,
                size: 40,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 8),
              const Text(
                'Agrega evidencia visual',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  // Implementar selección de archivo
                  _showErrorSnackBar('Funcionalidad en desarrollo');
                },
                child: const Text('Seleccionar Archivo'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRelatedPersonsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Personas Relacionadas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                hintText: 'Agregar persona...',
                controller: _personController,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: AppColors.white),
                onPressed: _addPerson,
              ),
            ),
          ],
        ),
        if (_relatedPersons.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _relatedPersons.map((person) => Chip(
              label: Text(person),
              onDeleted: () => _removePerson(person),
              deleteIcon: const Icon(Icons.close, size: 16),
              backgroundColor: AppColors.greenLight,
              labelStyle: const TextStyle(color: AppColors.green),
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildTagsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Etiquetas',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                hintText: 'Agregar etiqueta...',
                controller: _tagsController,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: IconButton(
                icon: const Icon(Icons.add, color: AppColors.white),
                onPressed: _addTag,
              ),
            ),
          ],
        ),
        if (_tags.isNotEmpty) ...[
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _tags.map((tag) => Chip(
              label: Text(tag),
              onDeleted: () => _removeTag(tag),
              deleteIcon: const Icon(Icons.close, size: 16),
              backgroundColor: AppColors.blueLight,
              labelStyle: const TextStyle(color: AppColors.blue),
            )).toList(),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ubicación',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            border: Border.all(color: AppColors.primary),
            borderRadius: BorderRadius.circular(8),
          ),
          child: InkWell(
            onTap: () {
              // Implementar obtener ubicación actual
              setState(() {
                _latitudeController.text = '4.711';
                _longitudeController.text = '-74.0721';
              });
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.location_on,
                  color: AppColors.primary,
                ),
                SizedBox(width: 8),
                Text(
                  'Agregar Ubicación Actual',
                  style: TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                hintText: '4.711',
                controller: _latitudeController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                hintText: '-74.0721',
                controller: _longitudeController,
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDateSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Fecha del Reporte',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: () async {
            final DateTime? picked = await showDatePicker(
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2101),
            );
            if (picked != null && picked != _selectedDate) {
              setState(() {
                _selectedDate = picked;
              });
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Spacer(),
                const Icon(Icons.calendar_today, color: AppColors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPrioritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prioridad *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedPriority,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
          ),
          items: [
            'Selecciona la prioridad',
            'Baja',
            'Media',
            'Alta',
            'Crítica'
          ].map((String value) {
            return DropdownMenuItem<String>(
              value: value,
              child: Text(value),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedPriority = newValue!;
            });
          },
        ),
      ],
    );
  }
} 