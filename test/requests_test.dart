import 'package:dio/dio.dart';
import 'package:exceptions/exceptions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nock/nock.dart';
import 'package:requests/requests.dart';

void main() {
  setUpAll(() => nock.init());

  setUp(() => nock.cleanAll());

  test('successful request', () async {
    nock('https://example.com/api').get('/data?id=0&base_id=5')
      ..headers({
        'Authorization': 'Bearer {}',
        'Content-Type': 'custom',
      })
      ..reply(200, null);

    var response = await Request.get(
      dio: Dio(BaseOptions(
        baseUrl: 'https://example.com/api',
        headers: {'Authorization': 'Bearer {}'},
        queryParameters: {'base_id': 5},
      )),
      headers: {'Content-Type': 'custom'},
      queryParameters: {'id': 0},
      path: '/data',
    ).execute();

    expect(response.statusCode, 200);
  });

  test('calling onFailedResponse', () async {
    nock('https://example.com/api').get('/data').reply(400, 'error');

    String errorMessage = '';

    await Request.get(
      dio: Dio(BaseOptions(baseUrl: 'https://example.com/api')),
      path: '/data',
      onFailedResponse: (response) async {
        errorMessage = response!.data.toString();
        return response;
      },
    ).execute();

    expect(errorMessage, 'error');
  });

  test('throws ServerException on catching DioException', () {
    nock('https://example.com/api').get('/data').reply(400, 'error');

    final request = Request.get(
      dio: Dio(BaseOptions(baseUrl: 'https://example.com/api')),
      path: '/data',
    );

    expect(
      () async => await request.execute(),
      throwsA(
        predicate<ServerException>(
          (exception) => exception.message == 'error',
        ),
      ),
    );
  });

  test('throws NetworkException on catching SocketException', () {
    nock('https://example.com/api').get('/data').throwNetworkError();

    expect(
      () async => await Request.get(
        dio: Dio(),
        path: 'https://example.com/api/data',
      ).execute(),
      throwsA(isA<NetworkException>()),
    );
  });
}
