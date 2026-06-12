import 'package:dio/dio.dart';
import 'package:ta_pa2_pa3_project/core/constants/api_constants.dart';
import 'package:ta_pa2_pa3_project/core/services/auth_session.dart';
import '../models/perawatan_model.dart';

class PerawatanApiService {
  final Dio dio;
  late String baseUrl;

  PerawatanApiService({
    required this.dio,
  }) {
    baseUrl = '${ApiConstants.baseUrl}/ibu';
    
    // Add interceptor untuk authorization
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = AuthSession.token;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
      ),
    );
  }

  // Get all kategori capaian
  Future<List<KategoriCapaianModel>> getAllKategoriCapaian() async {
    try {
      final response = await dio.get('$baseUrl/kategori-capaian');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as List?;
        if (data != null) {
          return data
              .map((item) => KategoriCapaianModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
      }
      throw Exception('Failed to load kategori capaian');
    } catch (e) {
      throw Exception('Error loading kategori capaian: $e');
    }
  }

  // Get kategori capaian by rentang usia
  Future<List<KategoriCapaianModel>> getKategoriCapaianByRentangUsia(
      String rentangUsia) async {
    try {
      final encodedUsia = Uri.encodeComponent(rentangUsia);
      print('Fetching: $baseUrl/kategori-capaian/rentang-usia/$encodedUsia');
      
      final response = await dio.get(
        '$baseUrl/kategori-capaian/rentang-usia/$encodedUsia',
      );
      
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as List?;
        if (data != null && data.isNotEmpty) {
          return data
              .map((item) => KategoriCapaianModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      }
      throw Exception('Failed to load kategori capaian for $rentangUsia: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error loading kategori capaian: $e');
    }
  }

  // Create perawatan
  Future<PerawatanModel> createPerawatan(CreatePerawatanRequest request) async {
    try {
      print('POST perawatan payload: ${request.toJson()}');
      final response = await dio.post(
        '$baseUrl/perawatan',
        data: request.toJson(),
      );
      
      if ((response.statusCode == 201 || response.statusCode == 200) &&
          response.data != null) {
        return PerawatanModel.fromJson(
            response.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to create perawatan: ${response.statusMessage}');
    } on DioException catch (e) {
      final detail = _extractErrorDetail(e);
      throw Exception('Error creating perawatan: $detail');
    } catch (e) {
      throw Exception('Error creating perawatan: $e');
    }
  }

  // Get perawatan by ID
  Future<PerawatanModel> getPerawatanById(int id) async {
    try {
      final response = await dio.get('$baseUrl/perawatan/$id');
      
      if (response.statusCode == 200 && response.data != null) {
        return PerawatanModel.fromJson(
            response.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to load perawatan');
    } catch (e) {
      throw Exception('Error loading perawatan: $e');
    }
  }

  // Get perawatan by anak ID
  Future<List<PerawatanModel>> getPerawatanByAnakId(int anakId) async {
    try {
      final response = await dio.get('$baseUrl/perawatan/anak/$anakId');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as List?;
        if (data != null) {
          return data
              .map((item) => PerawatanModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      }
      throw Exception('Failed to load perawatan');
    } catch (e) {
      throw Exception('Error loading perawatan: $e');
    }
  }

  // Get perawatan by anak ID and rentang usia
  Future<List<PerawatanModel>> getPerawatanByAnakIdAndRentangUsia(
      int anakId, String rentangUsia) async {
    try {
      final encodedUsia = Uri.encodeComponent(rentangUsia);
      final url = '$baseUrl/perawatan/anak/$anakId/rentang-usia/$encodedUsia';
      print('Fetching perawatan: $url');
      
      final response = await dio.get(url);
      
      print('Response status: ${response.statusCode}');
      print('Response data: ${response.data}');
      
      if (response.statusCode == 200 && response.data != null) {
        final data = response.data['data'] as List?;
        if (data != null && data.isNotEmpty) {
          return data
              .map((item) => PerawatanModel.fromJson(item as Map<String, dynamic>))
              .toList();
        }
        return [];
      }
      throw Exception('Failed to load perawatan: ${response.statusCode}');
    } catch (e) {
      throw Exception('Error loading perawatan: $e');
    }
  }

  // Update perawatan
  Future<PerawatanModel> updatePerawatan(
      int id, UpdatePerawatanRequest request) async {
    try {
      print('PUT perawatan payload: ${request.toJson()}');
      final response = await dio.put(
        '$baseUrl/perawatan/$id',
        data: request.toJson(),
      );
      
      if (response.statusCode == 200 && response.data != null) {
        return PerawatanModel.fromJson(
            response.data['data'] as Map<String, dynamic>);
      }
      throw Exception('Failed to update perawatan');
    } on DioException catch (e) {
      final detail = _extractErrorDetail(e);
      throw Exception('Error updating perawatan: $detail');
    } catch (e) {
      throw Exception('Error updating perawatan: $e');
    }
  }

  // Delete perawatan
  Future<void> deletePerawatan(int id) async {
    try {
      final response = await dio.delete('$baseUrl/perawatan/$id');
      
      if (response.statusCode != 200) {
        throw Exception(
            'Failed to delete perawatan: ${response.statusMessage}');
      }
    } catch (e) {
      throw Exception('Error deleting perawatan: $e');
    }
  }

  String _extractErrorDetail(DioException error) {
    final data = error.response?.data;
    if (data is Map<String, dynamic>) {
      final messages = data['messages'];
      if (messages is List && messages.isNotEmpty) {
        return messages.first.toString();
      }

      final message = data['message'];
      if (message != null) {
        return message.toString();
      }
    }

    return error.message ?? 'request gagal';
  }
}
