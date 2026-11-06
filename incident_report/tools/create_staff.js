// Creates a staff login (Firebase Auth) and its users/{uid} profile (Firestore).
// Staff cannot self-register: the security rules only let students create profiles.
//
// Setup:   cd tools && npm install
//          export GOOGLE_APPLICATION_CREDENTIALS=/path/to/serviceAccountKey.json
// Usage:   node create_staff.js <email> "<Full Name>" <position>
// Example: node create_staff.js maintenance@alueducation.com "Maintenance Team" maintenance
//
// Positions: maintenance | security | cleaning | campusOperations | nurse | other
const admin = require('firebase-admin');
const crypto = require('crypto');

const POSITIONS = ['maintenance', 'security', 'cleaning', 'campusOperations', 'nurse', 'other'];
const [email, name, position] = process.argv.slice(2);

if (!email || !name || !POSITIONS.includes(position)) {
  console.error('Usage: node create_staff.js <email> "<Full Name>" <position>');
  console.error('Positions: ' + POSITIONS.join(' | '));
  process.exit(1);
}
if (!email.toLowerCase().endsWith('@alueducation.com')) {
  console.error('Staff emails must end with @alueducation.com');
  process.exit(1);
}

admin.initializeApp({ credential: admin.credential.applicationDefault() });

(async () => {
  let user;
  try {
    user = await admin.auth().getUserByEmail(email);
    console.log('Auth account already exists; updating its profile only.');
  } catch (e) {
    if (e.code !== 'auth/user-not-found') throw e;
    const password = crypto.randomBytes(12).toString('base64url');
    user = await admin.auth().createUser({ email, password, displayName: name });
    console.log('Created login. Temporary password (shown once, change it after first login):');
    console.log('  ' + password);
  }

  const now = admin.firestore.FieldValue.serverTimestamp();
  await admin.firestore().collection('users').doc(user.uid).set(
    {
      email: email.toLowerCase(),
      name,
      role: 'staff',
      staffPosition: position,
      photo: null,
      createdAt: now,
      updatedAt: now,
    },
    { merge: true },
  );
  console.log(`Profile saved: ${email} -> staff / ${position}`);
})().catch((err) => {
  console.error(err);
  process.exit(1);
});
