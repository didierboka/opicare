import 'package:flutter_test/flutter_test.dart';
import 'package:opicare/core/helpers/ui_helpers.dart';
import 'package:opicare/features/carnet_sante/data/models/missed_vaccine.dart';

void main() {
  group('MissedVaccine.fromJson', () {
    test('maps calendar id and vaccine type id separately', () {
      final vaccine = MissedVaccine.fromJson({
        'IDCAL': '19897594',
        'IDVAC': '84',
        'NOMVAC': 'BCG',
        'DATERAPEL': '2024-01-12',
        'RAISON': 'Absent',
        'IDPAT': '216',
        'NOMCENTR': 'INHP',
        'idc': '25',
        'idr': '11',
        'idd': '86',
        'IDUSR': '21',
      });

      expect(vaccine.id, '19897594');
      expect(vaccine.vaccineTypeId, '84');
      expect(vaccine.name, 'BCG');
      expect(vaccine.reason, 'Absent');
      expect(vaccine.centreId, '25');
      expect(vaccine.regionId, '11');
      expect(vaccine.districtId, '86');
      expect(vaccine.agentId, '21');
    });

    test('uses Non spécifiée when reason is missing', () {
      final vaccine = MissedVaccine.fromJson({
        'IDCAL': '1',
        'NOMVAC': 'Polio',
      });

      expect(vaccine.vaccineTypeId, isEmpty);
      expect(vaccine.reason, 'Non spécifiée');
      expect(vaccine.centreId, isEmpty);
      expect(vaccine.agentId, isEmpty);
    });
  });

  group('isCalendarDateBeforeToday', () {
    test('allows today even after midnight', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      expect(isCalendarDateBeforeToday(today), isFalse);
    });

    test('rejects yesterday', () {
      final now = DateTime.now();
      final yesterday = DateTime(now.year, now.month, now.day)
          .subtract(const Duration(days: 1));
      expect(isCalendarDateBeforeToday(yesterday), isTrue);
    });

    test('allows tomorrow', () {
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day)
          .add(const Duration(days: 1));
      expect(isCalendarDateBeforeToday(tomorrow), isFalse);
    });
  });
}
