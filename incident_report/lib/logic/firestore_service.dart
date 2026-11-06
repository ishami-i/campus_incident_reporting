import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:incident_report/logic/incident_rules.dart';

class FirestoreService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');
  static CollectionReference<Map<String, dynamic>> get _incidents =>
      _db.collection('incidents');

  static User _requireUser() {
    final user = _auth.currentUser;
    if (user == null || user.email == null) {
      throw StateError('Not signed in');
    }
    return user;
  }

  // ───────────────────────── users ─────────────────────────

  /// Call right after Firebase Auth sign-up. Students only; staff documents
  /// are created by an admin (see tools/create_staff.js). The rules reject
  /// any role other than 'student' from the client.
  static Future<void> createStudentProfile({required String name}) async {
    final user = _requireUser();
    await _users.doc(user.uid).set({
      'email': user.email!.toLowerCase(),
      'name': name.trim(),
      'role': 'student',
      'staffPosition': null,
      'photo': null, // {path, url} from Openinary
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Live profile for any uid (used by the auth gate).
  static Stream<DocumentSnapshot<Map<String, dynamic>>> profileStream(
    String uid,
  ) =>
      _users.doc(uid).snapshots();

  static Stream<DocumentSnapshot<Map<String, dynamic>>> myProfileStream() =>
      _users.doc(_requireUser().uid).snapshots();

  /// [photo] is `{'path': ..., 'url': ...}` as returned by OpeninaryService.
  static Future<void> updateMyProfile({
    String? name,
    Map<String, String>? photo,
  }) async {
    final user = _requireUser();
    await _users.doc(user.uid).update({
      if (name != null) 'name': name.trim(),
      if (photo != null) 'photo': photo,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // ───────────────────────── incidents ─────────────────────────

  /// [image] is `{'path': ..., 'url': ...}` from Openinary, or null.
  /// Returns the new incident id.
  static Future<String> createIncident({
    required String title,
    required String description,
    required String category,
    required String area,
    required String detail,
    Map<String, String>? image,
  }) async {
    final user = _requireUser();
    final cat = category.toLowerCase();
    final ref = await _incidents.add({
      'title': title.trim(),
      'description': description.trim(),
      'category': cat,
      'status': 'submitted',
      'location': {'area': area, 'detail': detail.trim()},
      'reporterUid': user.uid,
      'reporterEmail': user.email!.toLowerCase(),
      'image': image,
      'visibleTo': IncidentRouting.visibleTo(cat),
      'handledBy': IncidentRouting.handledBy(cat),
      'lastNote': null,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  /// Student view: only my own incidents.
  static Stream<QuerySnapshot<Map<String, dynamic>>> myIncidentsStream() {
    return _incidents
        .where('reporterUid', isEqualTo: _requireUser().uid)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  /// Staff view: incidents routed to this staff position
  /// (pass `StaffPosition.<x>.name`), optionally filtered by status.
  static Stream<QuerySnapshot<Map<String, dynamic>>> staffIncidentsStream(
    String position, {
    String? status,
  }) {
    Query<Map<String, dynamic>> q =
        _incidents.where('visibleTo', arrayContains: position);
    if (status != null) q = q.where('status', isEqualTo: status);
    return q.orderBy('createdAt', descending: true).snapshots();
  }

  static Stream<DocumentSnapshot<Map<String, dynamic>>> incidentStream(
    String incidentId,
  ) =>
      _incidents.doc(incidentId).snapshots();

  /// Updates the status and appends an audit entry atomically.
  static Future<void> updateIncidentStatus({
    required String incidentId,
    required String fromStatus,
    required String newStatus,
    String? note,
  }) async {
    final user = _requireUser();
    final ref = _incidents.doc(incidentId);
    final cleanNote =
        (note == null || note.trim().isEmpty) ? null : note.trim();

    final batch = _db.batch();
    batch.update(ref, {
      'status': newStatus.toLowerCase(),
      'lastNote': cleanNote,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(ref.collection('updates').doc(), {
      'fromStatus': fromStatus.toLowerCase(),
      'toStatus': newStatus.toLowerCase(),
      'note': cleanNote,
      'byUid': user.uid,
      'byEmail': user.email!.toLowerCase(),
      'at': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  /// Status history for the detail screen (oldest first).
  static Stream<QuerySnapshot<Map<String, dynamic>>> incidentUpdatesStream(
    String incidentId,
  ) {
    return _incidents
        .doc(incidentId)
        .collection('updates')
        .orderBy('at')
        .snapshots();
  }
}
