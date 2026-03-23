import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../models/cached_driver_model.dart';
import '../models/session_model.dart';

class OpenF1Datasource {
  const OpenF1Datasource(this._dio);
  final Dio _dio;

  Future<List<SessionModel>> fetchSessions({
    required int year,
    int? meetingKey,
  }) async {
    final params = <String, dynamic>{'year': year};
    if (meetingKey != null) params['meeting_key'] = meetingKey;

    final resp = await _dio.get(
      ApiConstants.openf1Sessions,
      queryParameters: params,
    );
    final list = resp.data as List;
    return list
        .map((e) => SessionModel.fromOpenF1Json(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<CachedDriverModel>> fetchDrivers(int sessionKey) async {
    final resp = await _dio.get(
      ApiConstants.openf1Drivers,
      queryParameters: {'session_key': sessionKey},
    );
    final list = resp.data as List;
    return list
        .map((e) =>
            CachedDriverModel.fromOpenF1Json(e as Map<String, dynamic>))
        .toList();
  }

  // Live lap interval (race only)
  Future<List<Map<String, dynamic>>> fetchIntervals(int sessionKey) async {
    final resp = await _dio.get(
      ApiConstants.openf1Intervals,
      queryParameters: {'session_key': sessionKey},
    );
    return (resp.data as List).cast<Map<String, dynamic>>();
  }
}
