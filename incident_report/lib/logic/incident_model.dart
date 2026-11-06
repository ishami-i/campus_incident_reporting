import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:incident_report/logic/formatters.dart';

class IncidentModel {
  final String id;
  final String title;
  final String description;
  final String category;
  final String status;
  final String reporterEmail;
  final String locationArea;
  final String locationDetail;
  final String? imageUrl;
  final String? lastNote;
  final DateTime? createdAt;
  final List<String> handledBy;

  const IncidentModel({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.status,
    required this.reporterEmail,
    required this.locationArea,
    required this.locationDetail,
    this.imageUrl,
    this.lastNote,
    this.createdAt,
    this.handledBy = const [],
  });

  String get location => '$locationArea - $locationDetail';
  String get shortId =>
      id.length <= 6 ? id.toUpperCase() : id.substring(0, 6).toUpperCase();
  String get createdLabel => formatDateTime(createdAt);

  factory IncidentModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? <String, dynamic>{};
    final loc = d['location'];
    final image = d['image'];
    final created = d['createdAt'];
    return IncidentModel(
      id: doc.id,
      title: (d['title'] as String?) ?? 'Untitled incident',
      description: (d['description'] as String?) ?? '',
      category: (d['category'] as String?) ?? 'other',
      status: (d['status'] as String?) ?? 'submitted',
      reporterEmail: (d['reporterEmail'] as String?) ?? '',
      locationArea: loc is Map ? (loc['area'] as String? ?? '') : '',
      locationDetail: loc is Map ? (loc['detail'] as String? ?? '') : '',
      imageUrl: image is Map ? image['url'] as String? : null,
      lastNote: d['lastNote'] as String?,
      createdAt: created is Timestamp ? created.toDate() : null,
      handledBy: List<String>.from(d['handledBy'] ?? const <String>[]),
    );
  }
}
