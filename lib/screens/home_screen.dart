import 'package:flutter/material.dart';
import '../models/photo.dart';
import '../services/auth_services.dart';
import '../services/photo_service.dart';
import '../main.dart';

const Color facebookBlue = Color(0xFF4267A9);

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final searchController = TextEditingController();
  late Future<List<Photo>> _photosFuture;
  String _query = '';

  @override
  void initState() {
    super.initState();
    // Tạo Future một lần ở đây, không tạo trong build để tránh gọi API lại mỗi lần vẽ
    _photosFuture = PhotoService().fetchPhotos();
  }

  Future<void> _reload() async {
    final future = PhotoService().fetchPhotos();
    setState(() => _photosFuture = future);
    try {
      await future;
    } catch (_) {
      // Lỗi đã được FutureBuilder hiển thị
    }
  }

  Future<void> _logout() async {
    await AuthService().logout();
    if (!mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginPage()),
    );
  }

  void _openImage(Photo p) {
    showDialog(
      context: context,
      builder: (_) => Dialog(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.network(
              p.url,
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : const SizedBox(
                      height: 200,
                      child: Center(child: CircularProgressIndicator()),
                    ),
              errorBuilder: (_, _, _) => const SizedBox(
                height: 200,
                child: Center(child: Text('Không tải được ảnh')),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(p.title, textAlign: TextAlign.center),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Đóng'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: facebookBlue,
        foregroundColor: Colors.white,
        title: const Text(
          'facebook',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          // Lời chào + nút đăng xuất
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chào mừng bạn!',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text('Bạn đã đăng nhập thành công.'),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: _logout,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: facebookBlue,
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Đăng xuất'),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Photo>>(
              future: _photosFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'Lỗi: ${snapshot.error}',
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _reload,
                            child: const Text('Thử lại'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                final q = _query.toLowerCase();
                final photos = snapshot.data!
                    .where((p) => p.title.toLowerCase().contains(q))
                    .toList();

                return Column(
                  children: [
                    // Ô tìm kiếm + số mục
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: searchController,
                              onChanged: (v) => setState(() => _query = v),
                              decoration: const InputDecoration(
                                hintText: 'Tìm theo tiêu đề...',
                                prefixIcon: Icon(Icons.search),
                                isDense: true,
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text('${photos.length} mục'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Tiêu đề cột
                    Container(
                      color: Colors.grey.shade200,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      child: const Row(
                        children: [
                          SizedBox(
                            width: 40,
                            child: Text(
                              'ID',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          Expanded(
                            child: Text(
                              'Tiêu đề',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: 60,
                            child: Text(
                              'Ảnh',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                          SizedBox(
                            width: 70,
                            child: Text(
                              'Liên kết',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: RefreshIndicator(
                        onRefresh: _reload,
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          itemCount: photos.length,
                          separatorBuilder: (_, _) => const Divider(height: 1),
                          itemBuilder: (context, i) {
                            final p = photos[i];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 6,
                              ),
                              child: Row(
                                children: [
                                  SizedBox(width: 40, child: Text('${p.id}')),
                                  Expanded(
                                    child: Text(
                                      p.title,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  SizedBox(
                                    width: 60,
                                    child: Image.network(
                                      p.thumbnailUrl,
                                      width: 50,
                                      height: 50,
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, _, _) =>
                                          const Icon(Icons.broken_image),
                                    ),
                                  ),
                                  SizedBox(
                                    width: 70,
                                    child: TextButton(
                                      onPressed: () => _openImage(p),
                                      style: TextButton.styleFrom(
                                        padding: EdgeInsets.zero,
                                      ),
                                      child: const Text('Mở ảnh'),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    searchController.dispose();
    super.dispose();
  }
}
