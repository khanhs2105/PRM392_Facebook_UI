import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/photo.dart';

class PhotoService {
  static const String photosUrl =
      'https://jsonplaceholder.typicode.com/photos?_limit=200';

  /// Lấy danh sách ảnh, ném Exception nếu server trả lỗi hoặc mạng lỗi.
  Future<List<Photo>> fetchPhotos() async {
    final res = await http
        .get(Uri.parse(photosUrl))
        .timeout(const Duration(seconds: 15));

    if (res.statusCode != 200) {
      throw Exception('Không tải được dữ liệu (mã ${res.statusCode})');
    }

    final List<dynamic> data = jsonDecode(res.body);
    return data.map((e) => Photo.fromJson(e as Map<String, dynamic>)).toList();
  }
}
