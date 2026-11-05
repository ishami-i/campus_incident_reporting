# Campus Incident Reporting App

A cross-platform Flutter application for reporting and managing campus incidents (water, electricity, facility, safety, sanitation, and other) across campus areas like Enterprise Commons, Learning Commons, and Social Commons.

## Authentication & Account Roles

- **Students**: Only students are allowed to sign up for new accounts. Student email addresses must follow the format: `name@alustudent.com`.
- **Staff**: Staff accounts are pre-configured or role-assigned. Staff logins use role-based email formats such as:
  - `facility@alueducation.com`
  - `security@alueducation.com`
  - `maintenance@alueducation.com`
  - `cleaning@alueducation.com`

## Default Staff Passwords (Before Changing)

| Staff Role / Email | Default Initial Password |
|---|---|
| `facility@alueducation.com` | `StaffFacility123!` |
| `security@alueducation.com` | `StaffSecurity123!` |
| `maintenance@alueducation.com` | `StaffMaintenance123!` |
| `cleaning@alueducation.com` | `StaffCleaning123!` |
| `operations@alueducation.com` | `StaffOperations123!` |

*Note: Staff and students can change their passwords via the Profile -> Change Password screen.*

## Database & Backend

- Includes a relational database schema (`database.sql` and SQLite database implementation) for roles, categories, statuses, users, incidents, and staff.
- Integrated with Firebase authentication and Firestore (configured via `firebase_options.dart` and `.env`).
