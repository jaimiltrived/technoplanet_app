import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// Central HTTP client used by every service in the app.
///
/// Features:
/// - Bearer token injected automatically via Dio interceptor.
/// - Production-appropriate timeouts (15 s connect, 30 s receive/send).
/// - Status-code-aware error messages shown to the user.
/// - Debug-mode request/response logging (tokens are NEVER logged).
class ApiService {
  static String? _accessToken;

  static final Dio _dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
      sendTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ),
  )..interceptors.addAll([
      // ── Auth header injector ──────────────────────────────────────────────
      InterceptorsWrapper(
        onRequest: (options, handler) {
          if (_accessToken != null && _accessToken!.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $_accessToken';
          }
          if (kDebugMode) {
            // Log method + URL only — never log the token value.
            debugPrint(
              '[API] ▶ ${options.method} ${options.uri.path}'
              '${options.uri.hasQuery ? "?${options.uri.query}" : ""}',
            );
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          final data = response.data;
          // Check for API-level business failures returned with 200 OK
          if (data is Map &&
              (data['success'] == false ||
                  data['status'] == false ||
                  data['error'] != null)) {
            debugPrint('━━━━━━━━━━━━━━━━━━━━ [API BUSINESS FAILURE] ━━━━━━━━━━━━━━━━━━━━');
            debugPrint('Request: [${response.requestOptions.method}] ${response.requestOptions.uri}');
            debugPrint('Status Code: ${response.statusCode} (Backend reported failure in body)');
            debugPrint('Response Body: $data');
            debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
          } else if (kDebugMode) {
            debugPrint(
              '[API] ✓ ${response.statusCode} [${response.requestOptions.method}] ${response.requestOptions.uri.path}',
            );
          }
          return handler.next(response);
        },
        onError: (error, handler) {
          _logDioError(error);
          return handler.next(error);
        },
      ),
    ]);

  // ── Token management ──────────────────────────────────────────────────────

  static void setToken(String? token) {
    _accessToken = token;
  }

  static String? get token => _accessToken;

  // ── Request helpers ───────────────────────────────────────────────────────

  /// POST request — returns the decoded response as `Map<String, dynamic>`.
  static Future<Map<String, dynamic>> post(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post(url, data: body);
      return _asMap(response.data);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e, stack) {
      debugPrint('[API Error] Non-Dio exception on POST $url: $e\n$stack');
      throw ApiException('Network error or server unreachable: $e');
    }
  }

  /// POST request for public endpoints (no Authorization header sent).
  static Future<Map<String, dynamic>> postPublic(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.post(
        url,
        data: body,
        options: Options(headers: {'Authorization': null}),
      );
      return _asMap(response.data);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e, stack) {
      debugPrint('[API Error] Non-Dio exception on POST $url: $e\n$stack');
      throw ApiException('Network error or server unreachable: $e');
    }
  }

  /// PUT request — returns the decoded response as `Map<String, dynamic>`.
  static Future<Map<String, dynamic>> put(
    String url,
    Map<String, dynamic> body,
  ) async {
    try {
      final response = await _dio.put(url, data: body);
      return _asMap(response.data);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e, stack) {
      debugPrint('[API Error] Non-Dio exception on PUT $url: $e\n$stack');
      throw ApiException('Network error or server unreachable: $e');
    }
  }

  /// DELETE request — returns the decoded response as `Map<String, dynamic>`.
  static Future<Map<String, dynamic>> delete(String url) async {
    try {
      final response = await _dio.delete(url);
      return _asMap(response.data);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e, stack) {
      debugPrint('[API Error] Non-Dio exception on DELETE $url: $e\n$stack');
      throw ApiException('Network error or server unreachable: $e');
    }
  }

  /// GET request that expects a `Map<String, dynamic>` response body.
  static Future<Map<String, dynamic>> get(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response =
          await _dio.get(url, queryParameters: queryParameters);
      return _asMap(response.data);
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e, stack) {
      debugPrint('[API Error] Non-Dio exception on GET $url: $e\n$stack');
      throw ApiException('Network error or server unreachable: $e');
    }
  }

  /// GET request that may return either a `Map` or a `List` response body.
  /// Returns the raw decoded value so the caller can decide how to handle it.
  static Future<dynamic> getRaw(
    String url, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response =
          await _dio.get(url, queryParameters: queryParameters);
      return response.data;
    } on DioException catch (e) {
      _handleDioError(e);
      rethrow;
    } catch (e, stack) {
      debugPrint('[API Error] Non-Dio exception on GET $url: $e\n$stack');
      throw ApiException('Network error or server unreachable: $e');
    }
  }

  // ── Internal helpers ──────────────────────────────────────────────────────

  static Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map<String, dynamic>) return data;
    // Some endpoints wrap the body: try to coerce.
    if (data is Map) {
      return data.map((k, v) => MapEntry(k.toString(), v));
    }
    throw ApiException(
      'Unexpected response format from server',
      statusCode: null,
    );
  }

  static void _logDioError(DioException error) {
    final method = error.requestOptions.method;
    final uri = error.requestOptions.uri;
    final statusCode = error.response?.statusCode;
    final data = error.response?.data;

    debugPrint('━━━━━━━━━━━━━━━━━━━━ [API ERROR] ━━━━━━━━━━━━━━━━━━━━');
    debugPrint('Request: [$method] $uri');
    if (error.requestOptions.data != null) {
      final reqData = error.requestOptions.data;
      if (reqData is Map) {
        final sanitized = Map.from(reqData);
        if (sanitized.containsKey('password')) sanitized['password'] = '***';
        if (sanitized.containsKey('currentPassword')) sanitized['currentPassword'] = '***';
        if (sanitized.containsKey('newPassword')) sanitized['newPassword'] = '***';
        debugPrint('Request Body: $sanitized');
      } else {
        debugPrint('Request Body: $reqData');
      }
    }
    if (error.requestOptions.queryParameters.isNotEmpty) {
      debugPrint('Query Parameters: ${error.requestOptions.queryParameters}');
    }
    debugPrint('Status Code: ${statusCode ?? "No HTTP Status (Connection / Timeout error)"}');
    if (data != null) {
      debugPrint('Response Body: $data');
    }
    if (error.message != null && error.message!.isNotEmpty) {
      debugPrint('Dio Error: ${error.message}');
    }
    if (error.error != null) {
      debugPrint('Underlying Error: ${error.error}');
    }
    debugPrint('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  }

  static void _handleDioError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    if (e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.sendTimeout ||
        e.type == DioExceptionType.receiveTimeout) {
      throw ApiException(
        'Connection timed out. Please check your internet connection.',
        statusCode: statusCode,
        responseData: data,
      );
    }

    if (e.type == DioExceptionType.connectionError) {
      throw ApiException(
        'Unable to connect to the server. Check your internet connection.',
        statusCode: statusCode,
        responseData: data,
      );
    }

    if (e.response != null) {
      String message = _messageFromStatus(statusCode);

      // Prefer server-supplied message when available.
      if (data is Map<String, dynamic>) {
        final serverMsg =
            data['message'] ?? data['error'] ?? data['msg'];
        if (serverMsg is String && serverMsg.isNotEmpty) {
          message = serverMsg;
        }

        // Extract detailed validation errors (e.g. {"errors": {...}} or Zod issues)
        final errors = data['errors'] ?? data['error'] ?? data['issues'];
        if (errors is Map) {
          final details = <String>[];
          errors.forEach((field, msgs) {
            if (msgs is List && msgs.isNotEmpty) {
              details.add(msgs.first.toString());
            } else if (msgs is String) {
              details.add(msgs);
            }
          });
          if (details.isNotEmpty) {
            message = details.join('\n');
          }
        } else if (errors is List && errors.isNotEmpty) {
          final details = errors.map((item) {
            if (item is Map) {
              final msg = item['message'] ?? item['msg'];
              final path = item['path'];
              if (msg != null && path is List && path.isNotEmpty) {
                return '${path.join('.')}: $msg';
              } else if (msg != null) {
                return msg.toString();
              }
            }
            return item.toString();
          }).where((s) => s.isNotEmpty).toList();
          if (details.isNotEmpty) {
            message = details.join('\n');
          }
        }
      } else if (data is String && data.trim().isNotEmpty) {
        message = data.trim();
      }

      throw ApiException(message, statusCode: statusCode, responseData: data);
    }

    throw ApiException(
      'Network error or server unreachable: ${e.message}',
      statusCode: statusCode,
      responseData: data,
    );
  }

  static String _messageFromStatus(int? code) {
    switch (code) {
      case 400:
        return 'Bad request. Please check the submitted data.';
      case 401:
        return 'Your session has expired. Please log in again.';
      case 403:
        return "You don't have permission to perform this action.";
      case 404:
        return 'Requested data was not found.';
      case 409:
        return 'Conflict: the resource already exists or is already registered.';
      case 422:
        return 'Please check the entered information.';
      case 429:
        return 'Too many requests. Please wait a moment and try again.';
      case 500:
      case 502:
      case 503:
        return 'Server error. Please try again later.';
      default:
        return 'Request failed with status $code';
    }
  }
}

// ── Exception type ────────────────────────────────────────────────────────────

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic responseData;

  ApiException(this.message, {this.statusCode, this.responseData});

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}
