# Campus Incident Reporting App

A cross-platform Flutter app for reporting and managing campus incidents (water, electricity,
facility, safety, sanitation, other) across Enterprise, Learning and Social Commons.

- **Data:** Firebase Firestore (structured data) and Firebase Auth (logins)
- **Images:** Openinary (files only; Firestore stores a `{path, url}` reference)
- **Students** sign up with `name@alustudent.com`, report incidents with an optional photo, and follow their status live.
- **Staff** (`@alueducation.com`) see only incidents routed to their position and can update the status with a note. Every change is kept in a history log.

## 1. First-time setup

```bash
flutter pub get
cp .env.example .env        # then put your Openinary key in .env
```

Deploy the database rules and indexes (needs the Firebase CLI, `firebase login`):

```bash
firebase deploy --only firestore:rules,firestore:indexes
```

In the Firebase console, enable **Authentication → Email/Password** and create the **Firestore** database.

Run it:

```bash
flutter run -d chrome      # or any emulator/device
flutter test               # unit tests for routing, permissions and validators
```

## 2. Creating staff accounts

Staff cannot self-register (the security rules only allow student sign-up). Create them with the admin script:

```bash
cd tools && npm install
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccountKey.json   # Firebase console → Project settings → Service accounts
node create_staff.js maintenance@alueducation.com "Maintenance Team" maintenance
node create_staff.js security@alueducation.com    "Security Team"    security
node create_staff.js cleaning@alueducation.com    "Cleaning Team"    cleaning
node create_staff.js operations@alueducation.com  "Campus Operations" campusOperations
```

Each command prints a one-time temporary password. Staff should change it after first login
(Profile → Change Password) or use "Forgot password?" on the login screen.

## 3. Who sees and changes what

| Category | Can see | Can change status |
|---|---|---|
| water, electricity | maintenance, campus operations | same |
| facility | maintenance, campus operations, other | maintenance, campus operations |
| safety | security, nurse, campus operations | security, campus operations |
| sanitation | cleaning, campus operations | same |
| other | maintenance, nurse, campus operations, other | maintenance, campus operations |

Students see only their own incidents. This is enforced twice: in the app and in `firestore.rules`.

## 4. Project layout

```
lib/logic/       auth_service, firestore_service, openinary_service, incident_rules (routing), models
lib/screens/     auth_gate (login/home/staff routing), home, incidents, detail, staff dashboard, profile, ...
lib/widgets/     forms and shared list widgets
firestore.rules  security rules          firestore.indexes.json  composite indexes
tools/           create_staff.js         docs/FIRESTORE_SCHEMA.md  data model
```

## 5. Secrets

`.env` is **not** committed (see `.gitignore`). Note that Flutter bundles `.env` into the app as an asset,
so the Openinary key can be extracted from a built app. For anything beyond a class project, upload through a small
backend (for example a Cloud Function that checks the user's Firebase ID token) so no secret ships in the client.