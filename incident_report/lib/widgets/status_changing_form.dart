import 'package:flutter/material.dart';
import 'package:incident_report/themes/app_theme.dart';
import 'package:incident_report/logic/auth_service.dart';
import 'package:incident_report/logic/firestore_service.dart';
import 'package:incident_report/logic/incident_rules.dart';

class StatusChangingForm extends StatefulWidget {
  final String incidentId;
  final String incidentLabel;
  final String currentStatus;

  const StatusChangingForm({
    super.key,
    required this.incidentId,
    required this.incidentLabel,
    required this.currentStatus,
  });

  @override
  State<StatusChangingForm> createState() => _StatusChangingFormState();
}

class _StatusChangingFormState extends State<StatusChangingForm> {
  late String _selectedStatus;
  final _reasoningController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;

  final List<String> _statuses = IncidentConst.staffSettableStatuses;

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

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);

    setState(() => _isSaving = true);
    try {
      await FirestoreService.updateIncidentStatus(
        incidentId: widget.incidentId,
        fromStatus: widget.currentStatus,
        newStatus: _selectedStatus,
        note: _reasoningController.text,
      );
      messenger.showSnackBar(
        SnackBar(
          content: Text('Status updated to ${_selectedStatus.toUpperCase()}'),
          backgroundColor: Colors.green,
        ),
      );
      navigator.pop();
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(
          content: Text('Could not update status: ${AuthService.friendlyError(e)}'),
          backgroundColor: Colors.red,
        ),
      );
      if (mounted) setState(() => _isSaving = false);
    }
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
              'Update Incident Status (${widget.incidentLabel})',
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
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
              items: _statuses
                  .map((s) => DropdownMenuItem(value: s, child: Text(s.toUpperCase())))
                  .toList(),
              onChanged: _isSaving
                  ? null
                  : (val) {
                      if (val != null) setState(() => _selectedStatus = val);
                    },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _reasoningController,
              maxLines: 3,
              maxLength: 500,
              enabled: !_isSaving,
              decoration: InputDecoration(
                labelText: _selectedStatus == 'resolved'
                    ? 'Resolution Notes (Optional)'
                    : 'Reasoning / Comments (Optional)',
                alignLabelWithHint: true,
                filled: true,
                fillColor: colors.background[100],
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.primary[500],
                foregroundColor: colors.text[50],
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save Status Update',
                      style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }
}
