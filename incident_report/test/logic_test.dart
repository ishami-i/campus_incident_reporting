import 'package:flutter_test/flutter_test.dart';
import 'package:incident_report/logic/incident_rules.dart';
import 'package:incident_report/logic/user_management.dart';
import 'package:incident_report/validators/form_validator.dart';

UserProfile staff(StaffPosition p) => UserProfile(
      uid: 'u1',
      email: 'x@alueducation.com',
      name: 'Staff',
      role: UserRole.staff,
      staffPosition: p,
    );

void main() {
  group('IncidentRouting', () {
    test('safety is visible to security, nurse and campus operations', () {
      expect(IncidentRouting.visibleTo('safety'),
          containsAll(['security', 'nurse', 'campusOperations']));
    });

    test('nurse and "other" can see but never handle', () {
      for (final c in IncidentConst.categories) {
        final handlers = IncidentRouting.handledBy(c);
        expect(handlers, isNot(contains('nurse')));
        expect(handlers, isNot(contains('other')));
        expect(handlers, contains('campusOperations'));
      }
    });

    test('every handler can also see the incident', () {
      for (final c in IncidentConst.categories) {
        expect(IncidentRouting.visibleTo(c),
            containsAll(IncidentRouting.handledBy(c)));
      }
    });
  });

  group('UserManagement.canChangeStatus', () {
    test('security handles safety only', () {
      final p = staff(StaffPosition.security);
      expect(UserManagement.canChangeStatus(p, 'safety'), isTrue);
      expect(UserManagement.canChangeStatus(p, 'water'), isFalse);
    });

    test('maintenance handles water, electricity, facility, other', () {
      final p = staff(StaffPosition.maintenance);
      for (final c in ['water', 'electricity', 'facility', 'other']) {
        expect(UserManagement.canChangeStatus(p, c), isTrue, reason: c);
      }
      expect(UserManagement.canChangeStatus(p, 'sanitation'), isFalse);
    });

    test('nurse is read-only and students can never change status', () {
      expect(UserManagement.canChangeStatus(staff(StaffPosition.nurse), 'safety'),
          isFalse);
      const student = UserProfile(
        uid: 'u2',
        email: 's@alustudent.com',
        name: 'Student',
        role: UserRole.student,
      );
      expect(UserManagement.canChangeStatus(student, 'safety'), isFalse);
    });
  });

  group('UserProfile.fromMap', () {
    test('reads role, position and photo from the Firestore document', () {
      final p = UserProfile.fromMap('abc', {
        'email': 'security@alueducation.com',
        'name': 'Security',
        'role': 'staff',
        'staffPosition': 'security',
        'photo': {'path': 'a.png', 'url': 'https://cdn.openinary.dev/x'},
      });
      expect(p.isStaff, isTrue);
      expect(p.staffPosition, StaffPosition.security);
      expect(p.photoUrl, 'https://cdn.openinary.dev/x');
    });

    test('role is never guessed from the email', () {
      final p = UserProfile.fromMap('abc', {
        'email': 'sneaky@alueducation.com',
        'name': 'Sneaky',
      });
      expect(p.isStudent, isTrue);
      expect(p.staffPosition, isNull);
    });
  });

  group('FormValidator', () {
    test('signup only accepts student emails', () {
      expect(FormValidator.validateEmail('a@alustudent.com', isSignup: true), isNull);
      expect(FormValidator.validateEmail('a@alueducation.com', isSignup: true),
          isNotNull);
    });

    test('login accepts student and staff emails', () {
      expect(FormValidator.validateEmail('a@alueducation.com'), isNull);
      expect(FormValidator.validateEmail('a@gmail.com'), isNotNull);
    });

    test('password needs at least 6 characters', () {
      expect(FormValidator.validatePassword('12345'), isNotNull);
      expect(FormValidator.validatePassword('123456'), isNull);
    });
  });
}
