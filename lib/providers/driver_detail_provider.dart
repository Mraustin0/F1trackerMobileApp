import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../core/constants/hive_constants.dart';
import '../data/datasources/openf1_datasource.dart';
import '../data/models/driver_detail_model.dart';
import 'core_providers.dart';

/// Key format: "driverId:driverNumber"
/// e.g. "max_verstappen:1"
final driverDetailProvider =
    FutureProvider.family<DriverDetailModel, String>((ref, key) async {
  final parts = key.split(':');
  final driverId = parts[0];
  final currentYear = DateTime.now().year;

  final jolpica = ref.watch(jolpicaDatasourceProvider);
  final prefsBox = Hive.box(HiveConstants.prefsBox);

  // 1. Fetch driver info (dob, nationality)
  final driverInfo = await jolpica.fetchDriverInfo('$currentYear', driverId);

  // 2. Determine which years need API calls vs can be served from cache.
  //    Historical years (< currentYear) are cached permanently.
  //    Current year uses a 6h TTL.
  const startYear = 2000;
  const maxConsecutiveNulls = 4;
  const cacheDuration = Duration(hours: 6);

  final timeKey = HiveConstants.driverSeasonCacheTimePrefix + driverId;
  final cachedTime = prefsBox.get(timeKey) as int?;
  final currentYearIsStale = cachedTime == null ||
      DateTime.now().millisecondsSinceEpoch - cachedTime >
          cacheDuration.inMilliseconds;

  final yearsToFetch = <int>[];
  int consecutiveCachedNulls = 0;

  for (int year = currentYear; year >= startYear; year--) {
    if (year == currentYear && currentYearIsStale) {
      yearsToFetch.add(year);
      consecutiveCachedNulls = 0;
      continue;
    }

    final dataKey =
        '${HiveConstants.driverSeasonCachePrefix}${driverId}_$year';
    final cached = prefsBox.get(dataKey);

    if (cached != null) {
      if (cached == '__null__') {
        consecutiveCachedNulls++;
        if (consecutiveCachedNulls >= maxConsecutiveNulls &&
            year < currentYear - 2) {
          break;
        }
      } else {
        consecutiveCachedNulls = 0;
      }
    } else {
      // Cache miss
      yearsToFetch.add(year);
      consecutiveCachedNulls = 0;
    }
  }

  // 3. Fetch missing years in batches of 5 with 200ms between batches.
  //    On first open this replaces the old sequential loop; on repeat
  //    visits yearsToFetch is empty (or just [currentYear]) so it's instant.
  const batchSize = 5;
  for (int i = 0; i < yearsToFetch.length; i += batchSize) {
    final batch = yearsToFetch.skip(i).take(batchSize).toList();
    await Future.wait(batch.map((year) async {
      final result =
          await jolpica.fetchDriverSeasonStanding('$year', driverId);
      final dataKey =
          '${HiveConstants.driverSeasonCachePrefix}${driverId}_$year';
      if (result == null) {
        await prefsBox.put(dataKey, '__null__');
      } else {
        await prefsBox.put(dataKey, jsonEncode(result));
      }
      if (year == currentYear) {
        await prefsBox.put(timeKey, DateTime.now().millisecondsSinceEpoch);
      }
    }));
    if (i + batchSize < yearsToFetch.length) {
      await Future.delayed(const Duration(milliseconds: 200));
    }
  }

  // 4. Assemble results from cache (newest → oldest, skip nulls).
  //    We re-walk from currentYear down; early-stop on 4 consecutive nulls.
  final seasonStandings = <Map<String, dynamic>>[];
  int readNulls = 0;
  for (int year = currentYear; year >= startYear; year--) {
    final dataKey =
        '${HiveConstants.driverSeasonCachePrefix}${driverId}_$year';
    final cached = prefsBox.get(dataKey);
    if (cached == null || cached == '__null__') {
      readNulls++;
      if (readNulls >= maxConsecutiveNulls && year < currentYear - 2) break;
      continue;
    }
    readNulls = 0;
    seasonStandings
        .add(jsonDecode(cached as String) as Map<String, dynamic>);
  }

  // 5. Try to get headshot from OpenF1 using driver code.
  final driverCode = driverInfo['code'] as String? ?? '';
  String? headshotUrl;
  if (driverCode.isNotEmpty) {
    try {
      final openF1Dio = ref.watch(openF1DioProvider);
      final openF1 = OpenF1Datasource(openF1Dio);
      final drivers = await openF1.fetchDriverByAcronym(driverCode);
      final withHeadshot =
          drivers.where((d) => d.headshotUrl != null && d.headshotUrl!.isNotEmpty);
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
