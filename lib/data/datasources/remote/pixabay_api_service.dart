import 'package:dio/dio.dart';

import '../../../core/config/app_constants.dart';
import '../../../core/config/app_env.dart';
import '../../../core/error/exceptions.dart';
import '../../models/pixabay_response_model.dart';

class PixabayApiService {
  PixabayApiService(this._dio);

  final Dio _dio;

  Future<PixabayResponseModel> fetchImages({
    required int page,
    String query = '',
    String category = '',
    int perPage = AppConstants.imagesPerPage,
  }) async {
    try {
      final Response<dynamic> response = await _dio.get<dynamic>(
        AppEnv.pixabayBaseUrl,
        queryParameters: <String, dynamic>{
          'key': AppEnv.pixabayApiKey,
          'q': query.trim(),
          'category': category,
          'image_type': 'photo',
          'safesearch': true,
          'page': page,
          'per_page': perPage,
        },
      );

      final Map<String, dynamic> data = response.data as Map<String, dynamic>;
      return PixabayResponseModel.fromJson(data);
    } on DioException catch (error) {
      throw RemoteException(
        _messageFor(error),
        code: error.response?.statusCode?.toString(),
      );
    } on TypeError catch (error) {
      throw RemoteException(
        'Unexpected response shape from the server.',
        code: error.toString(),
      );
    }
  }

  String _messageFor(DioException error) {
    return switch (error.type) {
      DioExceptionType.connectionTimeout ||
      DioExceptionType.sendTimeout ||
      DioExceptionType.receiveTimeout ||
      DioExceptionType.connectionError =>
        'Connection failed. Check your internet connection and try again.',
      DioExceptionType.badResponse => _badResponseMessage(error),
      DioExceptionType.badCertificate =>
        'A secure connection could not be established.',
      _ => 'Something went wrong while reaching the server.',
    };
  }

  String _badResponseMessage(DioException error) {
    final int? status = error.response?.statusCode;
    if (status == null) return 'The server returned an unexpected response.';
    if (status == 400) {
      return 'The request was rejected by the server (bad API key or parameters).';
    }
    if (status == 401 || status == 403) {
      return 'Access denied. Please check your API key.';
    }
    if (status >= 500)
      return 'The server is having trouble. Please try again later.';
    return 'Unexpected server error ($status).';
  }
}
