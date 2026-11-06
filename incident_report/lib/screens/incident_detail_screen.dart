import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:incident_report/themes/app_theme.dart';
import 'package:incident_report/logic/firestore_service.dart';
import 'package:incident_report/logic/formatters.dart';
import 'package:incident_report/logic/incident_model.dart';
import 'package:incident_report/logic/user_management.dart';
import 'package:incident_report/screens/status_changing_screen.dart';
import 'package:incident_report/widgets/incident_widgets.dart';

/// Live view of one incident. Pass [staffProfile] to show the
/// "Update status" button (only if that staff member may change it).
class IncidentDetailScreen extends StatelessWidget {
  final String incidentId;
  final UserProfile? staffProfile;

  const IncidentDetailScreen({
    super.key,
    required this.incidentId,
    this.staffProfile,
  });

  Widget _panel(BuildContext context, {required Widget child}) {
    final colors = Theme.of(context).appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.background[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;

    return Scaffold(
      appBar: AppBar(
        title: Text('Incident Details', style: TextStyle(color: colors.text[950])),
        backgroundColor: colors.primary[500],
      ),
      body: StreamBuilder(
        stream: FirestoreService.incidentStream(incidentId),
        builder: (context, snapshot) {
          if (snapshot.hasError) return ErrorNotice(error: snapshot.error!);
          if (!snapshot.hasData) return const LoadingBox();
          if (!snapshot.data!.exists) {
            return Center(
              child: Text('This incident no longer exists.',
                  style: TextStyle(color: colors.text[700])),
            );
          }

          final incident = IncidentModel.fromDoc(snapshot.data!);
          final canUpdate = staffProfile != null &&
              UserManagement.canChangeStatus(staffProfile!, incident.category);

          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Incident #${incident.shortId}',
                    style: TextStyle(
                      fontSize: 14,
                      color: colors.text[700],
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  StatusBadge(status: incident.status),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                incident.title,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: colors.text[950],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(categoryIcon(incident.category),
                      size: 18, color: colors.primary[600]),
                  const SizedBox(width: 6),
                  Text(titleCase(incident.category),
                      style: TextStyle(color: colors.text[700])),
                  const Spacer(),
                  Text(incident.createdLabel,
                      style: TextStyle(fontSize: 12, color: colors.text[700])),
                ],
              ),
              const SizedBox(height: 16),
              _panel(
                context,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Description',
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: colors.text[950])),
                    const SizedBox(height: 8),
                    Text(incident.description,
                        style: TextStyle(fontSize: 14, color: colors.text[700])),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _panel(
                context,
                child: Row(
                  children: [
                    Icon(Icons.location_on, color: colors.primary[600]),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Location',
                              style: TextStyle(
                                  fontSize: 12, color: colors.text[700])),
                          Text(incident.location,
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: colors.text[950])),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (staffProfile != null) ...[
                const SizedBox(height: 16),
                _panel(
                  context,
                  child: Row(
                    children: [
                      Icon(Icons.person_outline, color: colors.primary[600]),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text('Reported by ${incident.reporterEmail}',
                            style: TextStyle(color: colors.text[700])),
                      ),
                    ],
                  ),
                ),
              ],
              if (incident.imageUrl != null) ...[
                const SizedBox(height: 16),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    incident.imageUrl!,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, progress) => progress == null
                        ? child
                        : const SizedBox(
                            height: 180,
                            child: Center(child: CircularProgressIndicator()),
                          ),
                    errorBuilder: (context, error, stack) => Container(
                      height: 100,
                      alignment: Alignment.center,
                      color: colors.background[200],
                      child: Text('Photo unavailable',
                          style: TextStyle(color: colors.text[700])),
                    ),
                  ),
                ),
              ],
              if (incident.lastNote != null) ...[
                const SizedBox(height: 16),
                _panel(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Latest note from staff',
                          style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: colors.text[950])),
                      const SizedBox(height: 8),
                      Text(incident.lastNote!,
                          style: TextStyle(color: colors.text[700])),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Text('History',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: colors.text[950])),
              const SizedBox(height: 8),
              _History(incidentId: incident.id),
              if (canUpdate) ...[
                const SizedBox(height: 24),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary[500],
                    foregroundColor: colors.text[50],
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StatusChangingScreen(
                          incident: incident,
                          profile: staffProfile!,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Update status'),
                ),
              ],
              const SizedBox(height: 24),
            ],
          );
        },
      ),
    );
  }
}

class _History extends StatelessWidget {
  final String incidentId;
  const _History({required this.incidentId});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;
    return StreamBuilder(
      stream: FirestoreService.incidentUpdatesStream(incidentId),
      builder: (context, snapshot) {
        if (snapshot.hasError) return ErrorNotice(error: snapshot.error!);
        if (!snapshot.hasData) return const LoadingBox();
        final docs = snapshot.data!.docs;
        if (docs.isEmpty) {
          return Text('No status changes yet.',
              style: TextStyle(color: colors.text[700]));
        }
        return Column(
          children: docs.map((doc) {
            final d = doc.data();
            final at = d['at'];
            final note = d['note'] as String?;
            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: colors.background[100],
              child: ListTile(
                title: Row(
                  children: [
                    StatusBadge(status: (d['fromStatus'] as String?) ?? ''),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 6),
                      child: Icon(Icons.arrow_forward, size: 14),
                    ),
                    StatusBadge(status: (d['toStatus'] as String?) ?? ''),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (note != null) ...[
                      const SizedBox(height: 6),
                      Text(note, style: TextStyle(color: colors.text[950])),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      '${d['byEmail'] ?? ''} · ${formatDateTime(at is Timestamp ? at.toDate() : null)}',
                      style: TextStyle(fontSize: 11, color: colors.text[700]),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
