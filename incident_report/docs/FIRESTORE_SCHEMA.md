# Campus Incident Reporting: Firestore + Openinary design

Firestore holds all structured data. Openinary holds image files only; Firestore stores a
`{path, url}` reference to each one. `database.sql` is retired (see mapping below).

## 1. SQL → Firestore mapping

| SQL | Firestore | Notes |
|---|---|---|
| `role` table | `users.role` (`student` \| `staff`) | Lookup table not needed; value enforced in rules |
| `category` table | `incidents.category` | Allowed values in `IncidentConst` + rules |
| `status` table | `incidents.status` | Adds `submitted`, which the SQL schema lacked but the app already uses |
| `user` (email PK, `password`) | Firebase Auth + `users/{uid}` | **No password column.** Auth owns credentials |
| `staff` (position) | `users.staffPosition` | Same doc as the user; no join |
| `incident.image_url` | `incidents.image {path,url}` | File lives in Openinary |
| `incident.created_at` | `incidents.createdAt` | `serverTimestamp()` |

## 2. Collections

```
users/{uid}
  email          string   lowercased
  name           string
  role           'student' | 'staff'
  staffPosition  null | 'maintenance' | 'security' | 'cleaning'
                      | 'campusOperations' | 'nurse' | 'other'
  photo          null | { path, url }        // Openinary
  createdAt, updatedAt   timestamp

incidents/{incidentId}
  title, description     string
  category               water | electricity | facility | safety | sanitation | other
  status                 submitted | in progress | resolved | closed
  location               { area, detail }    // was a single "Area - detail" string
  reporterUid, reporterEmail
  image                  null | { path, url } // Openinary
  visibleTo              [positions]          // who can see it (drives staff query + rules)
  handledBy              [positions]          // who can change status (nurse/other excluded)
  lastNote               null | string        // latest resolution note, shown to the student
  createdAt, updatedAt   timestamp

incidents/{incidentId}/updates/{updateId}     // append-only status history
  fromStatus, toStatus, note, byUid, byEmail, at
```

Why these choices:

- **Keyed by auth `uid`, not email.** Rules can compare `request.auth.uid` directly, and an email change won't orphan data.
- **`visibleTo` / `handledBy` arrays.** Your routing logic (`IncidentAssignment`, `canChangeStatus`) currently runs on the client after downloading every incident. As an `arrayContains` query it runs on the server, and the same arrays let the rules enforce it.
- **`updates` subcollection** replaces the single overwritten `reasoning` field, so you keep who changed what and when.
- **Role comes from `users.role`**, not from the email domain. The domain check only gates student sign-up in the rules.

## 3. Images with Openinary

1. Pick image → keep the **bytes** in memory (not a base64 `data:` URL).
2. On submit: `OpeninaryService.uploadImage(...)` → `OpeninaryImage{path,url}`.
3. Save `image.toMap()` into the incident (or `users.photo`).
4. Render with `Image.network(image['url'])`.

The rules only accept URLs under your Openinary bucket, so nobody can store arbitrary URLs.

## 4. How the app uses it

- `lib/screens/auth_gate.dart` listens to Firebase Auth and to `users/{uid}`; the **role and position come from that document**, never from the email.
- `FirestoreService.myIncidentsStream()` (students) and `staffIncidentsStream(position)` (staff) feed every list live.
- `FirestoreService.updateIncidentStatus()` updates the incident and appends to `updates` in one batch.
- `OpeninaryService.uploadImage()` runs before the incident is saved; if the upload fails nothing is saved and the user sees the error.
- Routing lives in one place, `lib/logic/incident_rules.dart`, and `firestore.rules` mirrors it.

## 5. Deploy

```
firebase deploy --only firestore:rules,firestore:indexes
```

Create staff accounts with `tools/create_staff.js` (see README).

## 6. Known limits

- `visibleTo` / `handledBy` are computed by the client at creation. A tampered client could set them oddly, but only for its own incident. A Cloud Function trigger would remove this.
- Rules and query shapes should be tested in the Firebase Emulator before release (in particular the staff `arrayContains` query against the `visibleTo` rule).
- The Openinary request format (`/upload`, Bearer key, `bucket_id`, response `path`) is carried over from your existing service; I haven't verified it against Openinary's docs.
