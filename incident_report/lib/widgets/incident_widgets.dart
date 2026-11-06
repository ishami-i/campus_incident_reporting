import 'package:flutter/material.dart';
import 'package:incident_report/themes/app_theme.dart';
import 'package:incident_report/logic/incident_model.dart';

IconData categoryIcon(String category) {
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

Color statusColor(String status) {
  switch (status) {
    case 'in progress':
      return Colors.orange;
    case 'resolved':
      return Colors.green;
    case 'submitted':
      return Colors.blueGrey;
    default:
      return Colors.grey;
  }
}

class StatusBadge extends StatelessWidget {
  final String status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    final color = statusColor(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.2),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          color: color,
        ),
      ),
    );
  }
}

/// One incident in a list (used by the student and staff screens).
class IncidentCard extends StatelessWidget {
  final IncidentModel incident;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool showLocation;

  const IncidentCard({
    super.key,
    required this.incident,
    required this.onTap,
    this.trailing,
    this.showLocation = false,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      color: colors.background[100],
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: colors.primary[500]?.withOpacity(0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            categoryIcon(incident.category),
            color: colors.primary[600],
          ),
        ),
        title: Text(
          incident.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: colors.text[950],
          ),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 6.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showLocation) ...[
                Text(
                  incident.location,
                  style: TextStyle(color: colors.text[700], fontSize: 13),
                ),
                const SizedBox(height: 6),
              ],
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  StatusBadge(status: incident.status),
                  Text(
                    incident.createdLabel,
                    style: TextStyle(fontSize: 12, color: colors.text[700]),
                  ),
                ],
              ),
            ],
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}

/// Round avatar showing an Openinary profile photo, or a person icon.
class ProfileAvatar extends StatelessWidget {
  final String? photoUrl;
  final double radius;
  const ProfileAvatar({super.key, this.photoUrl, this.radius = 24});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;
    final hasPhoto = photoUrl != null && photoUrl!.isNotEmpty;
    return CircleAvatar(
      radius: radius,
      backgroundColor: colors.primary[500],
      backgroundImage: hasPhoto ? NetworkImage(photoUrl!) : null,
      child: hasPhoto
          ? null
          : Icon(Icons.person, size: radius, color: colors.text[50]),
    );
  }
}

class LoadingBox extends StatelessWidget {
  const LoadingBox({super.key});
  @override
  Widget build(BuildContext context) => const Padding(
        padding: EdgeInsets.all(24),
        child: Center(child: CircularProgressIndicator()),
      );
}

class ErrorNotice extends StatelessWidget {
  final Object error;
  const ErrorNotice({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Center(
        child: Text(
          'Something went wrong loading the data.\n\n$error',
          textAlign: TextAlign.center,
          style: TextStyle(color: colors.text[700]),
        ),
      ),
    );
  }
}
