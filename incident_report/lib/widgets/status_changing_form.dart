import 'package:flutter/material.dart';
import 'package:incident_report/themes/app_theme.dart';

class StatusChangingForm extends StatefulWidget {
  final String incidentId;
  final String currentStatus;
  final Function(String newStatus, String? reasoning)? onStatusChanged;

  const StatusChangingForm({
    super.key,
    required this.incidentId,
    required this.currentStatus,
    this.onStatusChanged,
  });

  @override
  State<StatusChangingForm> createState() => _StatusChangingFormState();
}

class _StatusChangingFormState extends State<StatusChangingForm> {
  late String _selectedStatus;
  final _reasoningController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  final List<String> _statuses = ['in progress', 'resolved', 'closed'];

  @override
  void initState() {
    super.initState();
    _selectedStatus = widget.currentStatus.toLowerCase();
    if (!_statuses.contains(_selectedStatus)) {
      _selectedStatus = 'in progress';
    }
  }

  @override
  void dispose() {
    _reasoningController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;

    return Form(
      key: _formKey,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Update Incident Status (#${widget.incidentId})',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: colors.text[950],
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _selectedStatus,
              dropdownColor: colors.background[50],
              decoration: InputDecoration(
                labelText: 'Status',
                filled: true,
                fillColor: colors.background[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              items: _statuses.map((status) {
                return DropdownMenuItem(
                  value: status,
                  child: Text(status.toUpperCase()),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) {
                  setState(() {
                    _selectedStatus = val;
                  });
                }
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasoningController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: _selectedStatus == 'resolved'
                    ? 'Resolution Notes / Reasoning (Optional)'
                    : 'Reasoning / Comments (Optional)',
                alignLabelWithHint: true,
                filled: true,
                fillColor: colors.background[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary[500],
                foregroundColor: colors.text[50],
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  final reasoning = _reasoningController.text.trim().isEmpty
                      ? null
                      : _reasoningController.text.trim();
                  if (widget.onStatusChanged != null) {
                    widget.onStatusChanged!(_selectedStatus, reasoning);
                  }
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Status updated to ${_selectedStatus.toUpperCase()}'),
                      backgroundColor: Colors.green,
                    ),
                  );
                }
              },
              child: const Text(
                'Save Status Update',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
