import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/datasources/openf1_datasource.dart';
import '../data/models/driver_detail_model.dart';
import 'core_providers.dart';

/// Key format: "driverId:driverNumber"
/// e.g. "max_verstappen:1"
final driverDetailProvider =
    FutureProvider.family<DriverDetailModel, String>((ref, key) async {
  final parts = key.split(':');
  final driverId = parts[0];

  final jolpica = ref.watch(jolpicaDatasourceProvider);
  final currentYear = DateTime.now().year;

  // 1. Fetch driver info (dob, nationality) from current season
  final driverInfo = await jolpica.fetchDriverInfo('$currentYear', driverId);

  // 2. Fetch standings for each year in parallel
  final startYear = 2000;
  final futures = <Future<Map<String, dynamic>?>>[];
  for (int year = currentYear; year >= startYear; year--) {
    futures.add(jolpica.fetchDriverSeasonStanding('$year', driverId));
  }
  final results = await Future.wait(futures);
  final seasonStandings = results
      .where((r) => r != null)
      .map((r) => r!)
      .toList();

  // 3. Try to get headshot from OpenF1 using driver code (more reliable than number)
  final driverCode = driverInfo['code'] as String? ?? '';
  String? headshotUrl;
  if (driverCode.isNotEmpty) {
    try {
      final openF1Dio = ref.watch(openF1DioProvider);
      final openF1 = OpenF1Datasource(openF1Dio);
      final drivers = await openF1.fetchDriverByAcronym(driverCode);
      final withHeadshot = drivers.where(
          (d) => d.headshotUrl != null && d.headshotUrl!.isNotEmpty);
      if (withHeadshot.isNotEmpty) {
        headshotUrl = withHeadshot.first.headshotUrl;
      }
    } catch (_) {
      // OpenF1 may fail — headshot is optional
    }
  }

  return DriverDetailModel.fromSeasonStandings(
    driverInfo: driverInfo,
    seasonStandings: seasonStandings,
    headshotUrl: headshotUrl,
  );
});
