import 'dart:async';
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:exceptions/exceptions.dart';

final class Request {
  factory Request.get({
    required Dio dio,
    required String path,
    dynamic body,
    Map<String, dynamic> headers = const {},
    Map<String, dynamic> queryParameters = const {},
    FutureOr<Response> Function(Response?)? onFailedResponse,
  }) =>
      Request._(
        dio: dio,
        path: path,
        body: body,
        method: 'GET',
        headers: headers,
        queryParameters: queryParameters,
        onFailedResponse: onFailedResponse,
      );

  factory Request.post({
    required Dio dio,
    required String path,
    dynamic body,
    Map<String, dynamic> headers = const {},
    Map<String, dynamic> queryParameters = const {},
    FutureOr<Response> Function(Response?)? onFailedResponse,
  }) =>
      Request._(
        dio: dio,
        path: path,
        body: body,
        method: 'POST',
        headers: headers,
        queryParameters: queryParameters,
        onFailedResponse: onFailedResponse,
      );

  factory Request.put({
    required Dio dio,
    required String path,
    dynamic body,
    Map<String, dynamic> headers = const {},
    Map<String, dynamic> queryParameters = const {},
    FutureOr<Response> Function(Response?)? onFailedResponse,
  }) =>
      Request._(
        dio: dio,
        path: path,
        body: body,
        method: 'PUT',
        headers: headers,
        queryParameters: queryParameters,
        onFailedResponse: onFailedResponse,
      );

  factory Request.delete({
    required Dio dio,
    required String path,
    dynamic body,
    Map<String, dynamic> headers = const {},
    Map<String, dynamic> queryParameters = const {},
    FutureOr<Response> Function(Response?)? onFailedResponse,
  }) =>
      Request._(
        dio: dio,
        path: path,
        body: body,
        method: 'DELETE',
        headers: headers,
        queryParameters: queryParameters,
        onFailedResponse: onFailedResponse,
      );

  Request._({
    required Dio dio,
    required String path,
    dynamic body,
    required String method,
    Map<String, dynamic> headers = const {},
    Map<String, dynamic> queryParameters = const {},
    FutureOr<Response> Function(Response?)? onFailedResponse,
  }) {
    _dio = dio;
    _path = path;
    _body = body;
    _method = method;
    _headers = headers;
    _queryParameters = queryParameters;
    _onFailedResponse = onFailedResponse;
  }

  late final Dio _dio;
  late final String _path;
  late final dynamic _body;
  late final String _method;
  late final Map<String, dynamic> _headers;
  late final Map<String, dynamic> _queryParameters;
  late final FutureOr<Response> Function(Response?)? _onFailedResponse;

  FutureOr<Response> execute() async {
    try {
      return await _dio.fetch(
        RequestOptions(
          path: _path,
          data: _body,
          method: _method,
          headers: Map.from(_headers)..addAll(_dio.options.headers),
          baseUrl: _dio.options.baseUrl,
          queryParameters: Map.from(_queryParameters)
            ..addAll(_dio.options.queryParameters),
          validateStatus: _dio.options.validateStatus,
        ),
      );
    } on DioException catch (exception) {
      return switch (exception.error) {
        (SocketException _) => throw NetworkException(),
        (_) => await _handleFailedResponse(exception.response)
      };
    }
  }

  FutureOr<Response> _handleFailedResponse(Response? response) {
    return (_onFailedResponse ?? __onFailedResponse).call(response);
  }

  FutureOr<Response> __onFailedResponse(Response? response) async {
    throw ServerException(message: response?.data.toString() ?? '');
  }
}
