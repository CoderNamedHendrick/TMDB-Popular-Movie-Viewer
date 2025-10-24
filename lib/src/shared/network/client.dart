import 'package:dart_mappable/dart_mappable.dart';
import 'package:dio/dio.dart';
import 'package:either_dart/either.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;

typedef FutureExceptionOr<T> = Future<Either<Exception, T>>;

enum RequestType { get, post, delete, put }

final networkClientProvider = Provider<DioNetworkClient>((ref) {
  return DioNetworkClient();
});

final class DioNetworkClient {
  DioNetworkClient();

  final _dio = Dio()..interceptors.addAll([if (kDebugMode) LogInterceptor(requestBody: true, responseBody: true)]);

  FutureExceptionOr<Response> call<T>({
    required String path,
    Map<String, dynamic> queryParams = const {},
    Object? body,
    required RequestType request,
  }) async {
    try {
      final response = await switch (request) {
        RequestType.get => _dio.get(path, queryParameters: queryParams, data: body),
        RequestType.post => _dio.post(path, queryParameters: queryParams, data: body),
        RequestType.delete => _dio.delete(path, queryParameters: queryParams, data: body),
        RequestType.put => _dio.put(path, queryParameters: queryParams, data: body),
      };

      if (response.statusCode case int code when code == 200) {
        return Right(response);
      }

      if (response.data case Map json when json.containsKey('status_message')) {
        return Left(Exception(json['status_message']));
      }

      return Left(Exception('Failed to receive response from the server'));
    } on DioException catch (e) {
      debugPrint(
        "A dio exception occurred\ntype: ${e.type.toString()}\ndata:${e.response?.data}\nmessage:${e.message}",
      );
      return Left(switch (e.type) {
        DioExceptionType.badResponse => Exception(e.response?.data['status_message'] ?? 'Request to server failed'),
        DioExceptionType.connectionTimeout => Exception('Failed to make request'),
        _ => Exception(e.message),
      });
    }
  }
}

Future<Either<Exception, T>> processData<T>(
  T Function(dynamic) transformer,
  Either<Exception, Response<dynamic>> r,
) async {
  if (r.isLeft) return Left(r.left);

  return await compute((m) => _transformResponse(m, transformer), r.right.data!);
}

Either<Exception, E> _transformResponse<E>(dynamic data, E Function(dynamic) transform) {
  try {
    return Right(transform(data));
  } on TypeError {
    return Left(Exception('Failed to decode response'));
  } on MapperException catch (e) {
    debugPrint(e.message);
    return Left(Exception('Failed to decode response, try again later'));
  } on Exception catch (e) {
    return Left(Exception(e.toString()));
  }
}
