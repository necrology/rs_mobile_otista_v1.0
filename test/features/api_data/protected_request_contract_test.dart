import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:rs_mobile_otista_v1_0/core/network/api_client.dart';
import 'package:rs_mobile_otista_v1_0/core/network/api_session.dart';
import 'package:rs_mobile_otista_v1_0/features/api_data/data/datasources/rs_api_remote_datasource.dart';

void main() {
  test(
    'patient and booking requests derive identity only from bearer',
    () async {
      final _MemorySessionStore store = _MemorySessionStore(
        SessionTokenPair(
          accessToken: 'access-token',
          refreshToken: 'refresh-token',
          accessExpiresAt: DateTime.now().add(const Duration(hours: 1)),
          refreshExpiresAt: DateTime.now().add(const Duration(days: 10)),
        ),
      );
      int requestCount = 0;
      final ApiClient client = ApiClient(
        sessionStore: store,
        httpClient: MockClient((http.Request request) async {
          requestCount++;
          expect(request.headers['Authorization'], 'Bearer access-token');
          expect(request.url.queryParameters.containsKey('email'), isFalse);
          expect(request.url.queryParameters.containsKey('no_rm'), isFalse);

          if (request.url.path.endsWith('/mobile/patient/profile')) {
            expect(request.url.queryParameters, isEmpty);
            return _jsonResponse(request, 200, <String, Object?>{
              'success': true,
              'data': <String, Object?>{
                'id': 99,
                'no_rm': '160136',
                'nama': 'Pasien Uji',
              },
            });
          }

          if (request.url.path.endsWith('/mobile/patient/visits')) {
            expect(request.url.queryParameters, <String, String>{'limit': '5'});
            return _jsonResponse(request, 200, <String, Object?>{
              'success': true,
              'data': <Object?>[],
            });
          }

          if (request.url.path.endsWith('/mobile/booking/general/mine')) {
            expect(request.url.queryParameters['all_dates'], '1');
            return _jsonResponse(request, 200, <String, Object?>{
              'success': true,
              'data': <Object?>[],
            });
          }

          if (request.url.path.endsWith('/mobile/booking/general')) {
            final Map<String, dynamic> body =
                jsonDecode(request.body) as Map<String, dynamic>;
            expect(body, <String, Object?>{
              'poli_id': 27,
              'tanggal': '2026-07-20',
              'bayar': '2',
              'jenis_pasien': 'umum',
              'dokter_id': '10',
              'queue_group': 'HD',
              'is_jkn': false,
            });
            expect(body.containsKey('identifier'), isFalse);
            expect(body.containsKey('email'), isFalse);
            expect(body.containsKey('no_rm'), isFalse);
            return _jsonResponse(request, 200, <String, Object?>{
              'success': true,
              'data': <String, Object?>{
                'message': 'booking berhasil dibuat',
                'data': <String, Object?>{
                  'registration_id': 1,
                  'queue_id': 2,
                  'queue_number': 'A001',
                  'queue_code': 'A001',
                  'queue_group': 'HD',
                  'poli_id': 27,
                  'poli_name': 'Hemodialisis',
                  'queue_date': '2026-07-20',
                  'service_mode': 'umum',
                  'existing': false,
                },
              },
            });
          }

          if (request.url.path.contains('/medical-summaries/1/pdf')) {
            expect(request.url.queryParameters, isEmpty);
            return http.Response.bytes(
              <int>[0x25, 0x50, 0x44, 0x46],
              200,
              headers: <String, String>{'content-type': 'application/pdf'},
              request: request,
            );
          }

          fail('Unexpected request: ${request.url}');
        }),
      );
      final RsApiRemoteDatasource datasource = RsApiRemoteDatasource(
        apiClient: client,
      );

      final profile = await datasource.fetchLinkedPatientProfile();
      final visits = await datasource.fetchPatientVisits(limit: 5);
      final bookings = await datasource.fetchMyGeneralBookings(allDates: true);
      final booking = await datasource.createGeneralBooking(
        poliId: 27,
        tanggal: '2026-07-20',
        bayar: '2',
        jenisPasien: 'umum',
        doctorId: '10',
        queueGroup: 'HD',
        isJkn: false,
      );
      final ApiBinaryResponse pdf = await client.getBytes(
        '/mobile/patient/medical-summaries/1/pdf',
        requiresAuth: true,
      );

      expect(profile.noRm, '160136');
      expect(visits.items, isEmpty);
      expect(bookings.items, isEmpty);
      expect(booking.queueCode, 'A001');
      expect(pdf.bytes, <int>[0x25, 0x50, 0x44, 0x46]);
      expect(requestCount, 5);
      client.close();
    },
  );
}

http.Response _jsonResponse(
  http.Request request,
  int statusCode,
  Map<String, Object?> body,
) {
  return http.Response(
    jsonEncode(body),
    statusCode,
    headers: <String, String>{'content-type': 'application/json'},
    request: request,
  );
}

class _MemorySessionStore implements ApiSessionStore {
  _MemorySessionStore(this.tokenPair);

  SessionTokenPair? tokenPair;

  @override
  Future<void> clearSession() async {
    tokenPair = null;
  }

  @override
  Future<SessionTokenPair?> readTokenPair() async => tokenPair;

  @override
  Future<void> saveTokenPair(SessionTokenPair value) async {
    tokenPair = value;
  }
}
