import 'package:flutter/material.dart';
import 'package:incident_report/themes/app_theme.dart';

class ReportingForm extends StatefulWidget {
  final Function(Map<String, dynamic> reportData)? onSubmit;

  const ReportingForm({super.key, this.onSubmit});

  @override
  State<ReportingForm> createState() => _ReportingFormState();
}

class _ReportingFormState extends State<ReportingForm> {
  final _formKey = GlobalKey<FormState>();

  String? _selectedCategory;
  final List<String> _categories = [
    'water',
    'electricity',
    'facility',
    'safety',
    'sanitation',
    'other'
  ];

  String? _selectedBuilding = 'Enterprise commons';
  final List<String> _buildings = [
    'Enterprise commons',
    'Learning commons',
    'Social commons'
  ];

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationDetailController = TextEditingController();
  String? _imagePath;

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'water':
        return Icons.water_drop;
      case 'electricity':
        return Icons.electric_bolt;
      case 'facility':
        return Icons.business;
      case 'safety':
        return Icons.security;
      case 'sanitation':
        return Icons.cleaning_services;
      default:
        return Icons.category;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationDetailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;

    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Category',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.text[950],
              ),
            ),
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
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final cat = _categories[index];
                final isSelected = _selectedCategory == cat;
                return InkWell(
                  onTap: () {
                    setState(() {
                      _selectedCategory = cat;
                    });
                  },
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
                          _getCategoryIcon(cat),
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
                child: Text(
                  'Please select a category',
                  style: TextStyle(color: Colors.red[700], fontSize: 12),
                ),
              ),
            const SizedBox(height: 24),
            Text(
              'Incident Details',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.text[950],
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _titleController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a title';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Title',
                filled: true,
                fillColor: colors.background[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter a description';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Description',
                alignLabelWithHint: true,
                filled: true,
                fillColor: colors.background[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Location',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.text[950],
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedBuilding,
              dropdownColor: colors.background[50],
              decoration: InputDecoration(
                labelText: 'Campus Area',
                filled: true,
                fillColor: colors.background[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _buildings.map((building) {
                return DropdownMenuItem(
                  value: building,
                  child: Text(building),
                );
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedBuilding = val;
                });
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _locationDetailController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please specify room, class, or place name';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'Room, Class, or Specific Place Name',
                filled: true,
                fillColor: colors.background[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Attachment (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: colors.text[950],
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _imagePath = 'sample_image_path.jpg';
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Image attached successfully')),
                );
              },
              icon: const Icon(Icons.add_a_photo),
              label: Text(_imagePath == null ? 'AddPhoto' : 'Photo Attached'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary[500],
                foregroundColor: colors.text[50],
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (_selectedCategory == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Please select a category')),
                  );
                  return;
                }
                if (_formKey.currentState!.validate()) {
                  final reportData = {
                    'title': _titleController.text.trim(),
                    'description': _descriptionController.text.trim(),
                    'category': _selectedCategory,
                    'location': '$_selectedBuilding - ${_locationDetailController.text.trim()}',
                    'image_url': _imagePath,
                    'created_at': DateTime.now().toIso8601String(),
                  };
                  if (widget.onSubmit != null) {
                    widget.onSubmit!(reportData);
                  } else {
                    Navigator.pop(context, reportData);
                  }
                }
              },
              child: const Text(
                'Submit Incident Report',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
