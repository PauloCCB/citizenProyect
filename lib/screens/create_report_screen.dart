import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
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
  final _generatedDetailsController = TextEditingController();
  final _reportService = ReportService();

  DateTime _selectedDate = DateTime.now();
  List<String> _tags = [];
  File? _selectedImage;
  String? _imageUrl;
  int? _priority;
  bool _isLoading = false;
  bool _isUploadingImage = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _tagsController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _generatedDetailsController.dispose();
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

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      setState(() {
        _selectedImage = File(image.path);
        _isUploadingImage = true;
      });

      await _uploadImage();
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;

    try {
      final result = await _reportService.uploadImage(_selectedImage!);

      setState(() {
        _imageUrl = result['imageUrl'];
        _generatedDetailsController.text = result['generatedDetails'] ?? '';
        _priority = result['priority'];
        _isUploadingImage = false;
      });

      _showSuccessSnackBar('Imagen procesada exitosamente');
    } catch (e) {
      setState(() {
        _isUploadingImage = false;
      });
      _showErrorSnackBar('Error al procesar imagen: $e');
    }
  }

  void _clearImage() {
    setState(() {
      _selectedImage = null;
      _imageUrl = null;
      _generatedDetailsController.clear();
      _priority = null;
    });
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    // Mostrar modal de carga
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const LoadingModal(message: 'Creando reporte...'),
    );

    try {
      final success = await _reportService.createReport(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        generatedDetails: _generatedDetailsController.text.trim(),
        reportDate: _selectedDate,
        tags: _tags,
        lat: _latitudeController.text.trim(),
        long: _longitudeController.text.trim(),
        priority: _priority,
        images: _imageUrl != null ? [_imageUrl!] : [],
      );

      if (mounted) {
        Navigator.pop(context); // Cerrar modal

        if (success) {
          _showSuccessSnackBar('Reporte creado exitosamente');
          // Esperar un poco para que se vea el mensaje
          await Future.delayed(const Duration(seconds: 2));
          Navigator.pushReplacementNamed(context, '/dashboard');
        } else {
          _showErrorSnackBar('Error al crear el reporte');
        }
      }
    } catch (e) {
      if (mounted) {
        Navigator.pop(context); // Cerrar modal
        String errorMessage = 'Error al crear el reporte.';

        if (e.toString().contains('Token inválido')) {
          errorMessage =
              'Sesión expirada. Por favor, inicia sesión nuevamente.';
        } else if (e.toString().contains('Error al crear reporte')) {
          errorMessage = e.toString().replaceFirst('Exception: ', '');
        }

        _showErrorSnackBar(errorMessage);
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
                'Completa la información del reporte',
                style: TextStyle(fontSize: 14, color: AppColors.grey),
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
                  return _reportService.validateDescription(
                    value?.trim() ?? '',
                  );
                },
              ),
              const SizedBox(height: 20),
              // Sección de imagen
              _buildImageSection(),
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
              // Detalles generados (solo lectura)
              CustomTextField(
                labelText: 'Detalles Generados por IA',
                hintText: 'Se generarán automáticamente al subir una imagen...',
                controller: _generatedDetailsController,
                maxLines: 3,
                enabled: false,
              ),
              const SizedBox(height: 20),
              // Mostrar prioridad si está disponible
              if (_priority != null) _buildPriorityDisplay(),
              const SizedBox(height: 32),
              // Botón crear reporte
              CustomButton(
                text: 'Crear Reporte',
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

  Widget _buildImageSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Imagen del Problema',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            color: AppColors.lightGrey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.grey, width: 1),
          ),
          child: _selectedImage != null
              ? Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        _selectedImage!,
                        width: double.infinity,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                    ),
                    if (_isUploadingImage)
                      Container(
                        width: double.infinity,
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    Positioned(
                      top: 8,
                      right: 8,
                      child: IconButton(
                        onPressed: _clearImage,
                        icon: const Icon(Icons.close, color: Colors.white),
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              : InkWell(
                  onTap: _pickImage,
                  child: const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.add_photo_alternate,
                        size: 48,
                        color: AppColors.grey,
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Seleccionar Imagen',
                        style: TextStyle(fontSize: 16, color: AppColors.grey),
                      ),
                    ],
                  ),
                ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.photo_library),
                label: const Text('Seleccionar'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton.icon(
                onPressed: _clearImage,
                icon: const Icon(Icons.clear),
                label: const Text('Limpiar'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
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
              child: TextField(
                controller: _tagsController,
                decoration: const InputDecoration(
                  hintText: 'Escribe una etiqueta...',
                  border: OutlineInputBorder(),
                ),
                onSubmitted: (_) => _addTag(),
              ),
            ),
            const SizedBox(width: 12),
            ElevatedButton(onPressed: _addTag, child: const Text('Agregar')),
          ],
        ),
        const SizedBox(height: 8),
        if (_tags.isNotEmpty)
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: _tags
                .map(
                  (tag) => Chip(
                    label: Text(tag),
                    onDeleted: () => _removeTag(tag),
                    backgroundColor: Colors.blue.shade100,
                  ),
                )
                .toList(),
          ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Ubicación *',
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
                labelText: 'Latitud',
                hintText: '-12.046374',
                controller: _latitudeController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  return _reportService.validateLocation(value?.trim() ?? '');
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                labelText: 'Longitud',
                hintText: '-77.042793',
                controller: _longitudeController,
                keyboardType: TextInputType.number,
                validator: (value) {
                  return _reportService.validateLocation(value?.trim() ?? '');
                },
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
              firstDate: DateTime(2020),
              lastDate: DateTime.now(),
            );
            if (picked != null && picked != _selectedDate) {
              setState(() {
                _selectedDate = picked;
              });
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              border: Border.all(color: AppColors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(fontSize: 16),
                ),
                const Icon(Icons.calendar_today, color: AppColors.grey),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPriorityDisplay() {
    String priorityText;
    Color priorityColor;

    if (_priority! >= 7) {
      priorityText = 'ALTA';
      priorityColor = Colors.red;
    } else if (_priority! >= 4) {
      priorityText = 'MEDIA';
      priorityColor = Colors.orange;
    } else {
      priorityText = 'BAJA';
      priorityColor = Colors.green;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Prioridad Detectada',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: priorityColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: priorityColor),
          ),
          child: Row(
            children: [
              Icon(Icons.warning, color: priorityColor),
              const SizedBox(width: 8),
              Text(
                '$priorityText (Nivel $_priority)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: priorityColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
