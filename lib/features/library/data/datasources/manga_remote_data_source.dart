import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/dio_client.dart';
import '../models/manga_model.dart';

final mangaRemoteDataSourceProvider = Provider<MangaRemoteDataSource>((ref) {
  final dio = ref.watch(dioProvider);
  return MangaRemoteDataSource(dio);
});

class MangaRemoteDataSource {
  final Dio _dio;

  MangaRemoteDataSource(this._dio);

  Future<List<MangaModel>> fetchFeed({required int limit, required int offset}) async {
    final response = await _dio.get('/manga', queryParameters: {
      'limit': limit,
      'offset': offset,
    });
    final list = response.data['data'] as List<dynamic>;
    return list.map((json) => MangaModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<List<MangaModel>> searchManga({
    required String query,
    required int limit,
    required int offset,
  }) async {
    final response = await _dio.get('/manga/search', queryParameters: {
      'title': query,
      'limit': limit,
      'offset': offset,
    });
    final list = response.data['data'] as List<dynamic>;
    return list.map((json) => MangaModel.fromJson(json as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> fetchMangaDetails(String id) async {
    final response = await _dio.get('/manga/$id');
    return response.data as Map<String, dynamic>;
  }
}
