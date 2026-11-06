import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:incident_report/themes/app_theme.dart';
import 'package:incident_report/logic/auth_service.dart';
import 'package:incident_report/logic/firestore_service.dart';
import 'package:incident_report/logic/incident_rules.dart';
import 'package:incident_report/logic/openinary_service.dart';
import 'package:incident_report/widgets/incident_widgets.dart';

class ReportingForm extends StatefulWidget {
  final Function(Map<String, dynamic> reportData)? onSubmit;

  const ReportingForm({super.key, this.onSubmit});

  @override
  State<ReportingForm> createState() => _ReportingFormState();
}

class _ReportingFormState extends State<ReportingForm> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCategory;
  String? _selectedBuilding = IncidentConst.buildings.first;

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationDetailController = TextEditingController();

  // The picked photo is kept in memory and uploaded to Openinary on submit.
  Uint8List? _imageBytes;
  String? _imageName;
  bool _isPickingImage = false;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationDetailController.dispose();
    super.dispose();
  }

  void _toast(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: error ? Colors.red : Colors.green,
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      setState(() => _isPickingImage = true);

      final picked = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1280,
        maxHeight: 1280,
        imageQuality: 85,
      );

      if (picked != null) {
        final bytes = await picked.readAsBytes();
        setState(() {
          _imageBytes = bytes;
          _imageName = picked.name;
        });
        _toast('Photo attached. It uploads when you submit.');
      }
    } catch (e) {
      _toast('Error picking image: $e', error: true);
    } finally {
      if (mounted) setState(() => _isPickingImage = false);
    }
  }

  Future<void> _submit() async {
    if (_selectedCategory == null) {
      _toast('Please select a category', error: true);
      return;
    }
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);
    try {
      // 1. Upload the photo (if any) to Openinary.
      Map<String, String>? image;
      if (_imageBytes != null) {
        final uploaded = await OpeninaryService.uploadImage(
          bytes: _imageBytes!,
          fileName: _imageName ?? 'photo.jpg',
        );
        image = uploaded.toMap();
      }

      // 2. Save the incident (with the image reference) to Firestore.
      final title = _titleController.text.trim();
      final description = _descriptionController.text.trim();
      final detail = _locationDetailController.text.trim();
      final id = await FirestoreService.createIncident(
        title: title,
        description: description,
        category: _selectedCategory!,
        area: _selectedBuilding!,
        detail: detail,
        image: image,
      );

      final reportData = {
        'id': id,
        'title': title,
        'description': description,
        'category': _selectedCategory,
        'location': '$_selectedBuilding - $detail',
        'image_url': image?['url'],
      };

      if (!mounted) return;
      if (widget.onSubmit != null) {
        widget.onSubmit!(reportData);
      } else {
        Navigator.pop(context, reportData);
      }
    } on OpeninaryException catch (e) {
      _toast('Photo upload failed: ${e.message}. Remove the photo or try again.',
          error: true);
    } catch (e) {
      _toast('Could not submit report: ${AuthService.friendlyError(e)}',
          error: true);
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;

    InputDecoration fieldDecoration(String label, {bool hint = false}) {
      return InputDecoration(
        labelText: label,
        alignLabelWithHint: hint,
        filled: true,
        fillColor: colors.background[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );
    }

    Widget heading(String text) => Text(
          text,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: colors.text[950],
          ),
        );

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            heading('Select Category'),
            const SizedBox(height: 12),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 2.2,
              ),
              itemCount: IncidentConst.categories.length,
              itemBuilder: (context, index) {
                final cat = IncidentConst.categories[index];
                final isSelected = _selectedCategory == cat;
                return InkWell(
                  onTap: _isSubmitting
                      ? null
                      : () => setState(() => _selectedCategory = cat),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colors.primary[500]
                          : colors.background[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isSelected
                            ? colors.primary[700]!
                            : colors.background[300]!,
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          categoryIcon(cat),
                          size: 20,
                          color: isSelected ? colors.text[50] : colors.primary[600],
                        ),
                        const SizedBox(width: 6),
                        Flexible(
                          child: Text(
                            cat[0].toUpperCase() + cat.substring(1),
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: isSelected ? colors.text[50] : colors.text[950],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
            if (_selectedCategory == null)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, left: 4.0),
                child: Text('Please select a category',
                    style: TextStyle(color: Colors.red[700], fontSize: 12)),
              ),
            const SizedBox(height: 24),
            heading('Incident Details'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              enabled: !_isSubmitting,
              maxLength: 120,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Please enter a title'
                  : null,
              decoration: fieldDecoration('Title'),
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              enabled: !_isSubmitting,
              maxLines: 4,
              maxLength: 2000,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Please enter a description'
                  : null,
              decoration: fieldDecoration('Description', hint: true),
            ),
            const SizedBox(height: 16),
            heading('Location'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedBuilding,
              dropdownColor: colors.background[50],
              decoration: fieldDecoration('Campus Area'),
              items: IncidentConst.buildings
                  .map((b) => DropdownMenuItem(value: b, child: Text(b)))
                  .toList(),
              onChanged: _isSubmitting
                  ? null
                  : (val) => setState(() => _selectedBuilding = val),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationDetailController,
              enabled: !_isSubmitting,
              maxLength: 120,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              validator: (value) => (value == null || value.trim().isEmpty)
                  ? 'Please specify room, class, or place name'
                  : null,
              decoration: fieldDecoration('Room, Class, or Specific Place Name'),
            ),
            const SizedBox(height: 16),
            heading('Attach Incident Image (Optional)'),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: (_isPickingImage || _isSubmitting) ? null : _pickImage,
              icon: _isPickingImage
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.add_a_photo),
              label: Text(_isPickingImage
                  ? 'Opening Gallery...'
                  : _imageBytes == null
                      ? 'Select Photo from Gallery'
                      : 'Change Attached Photo'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
            if (_imageBytes != null) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.memory(
                  _imageBytes!,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: _isSubmitting
                      ? null
                      : () => setState(() {
                            _imageBytes = null;
                            _imageName = null;
                          }),
                  icon: const Icon(Icons.close),
                  label: const Text('Remove photo'),
                ),
              ),
            ],
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary[500],
                foregroundColor: colors.text[50],
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const CircularProgressIndicator(color: Colors.white)
                  : const Text('Submit Incident Report',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
