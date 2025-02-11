import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:giat_cerika/constant/color.dart';
import 'package:giat_cerika/models/materi.dart';
import 'package:giat_cerika/screens/materi_detail_screen.dart';
import 'package:giat_cerika/services/materi_services.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class MateriScreen extends StatefulWidget {
  const MateriScreen({Key? key}) : super(key: key);

  @override
  State<MateriScreen> createState() => _MateriScreenState();
}

class _MateriScreenState extends State<MateriScreen> {
  final MateriService _materiService = MateriService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Materi> _materis = [];
  bool _isLoading = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadMateris();
    _scrollController.addListener(_onScroll);
  }

  void _clearImageCache() {
    imageCache.clear();
    imageCache.clearLiveImages();
  }

  Future<void> _onRefresh() async {
    _clearImageCache(); // Clear image cache
    await _loadMateris(refresh: true);
  }

  void _onSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
        _currentPage = 1;
        _materis.clear();
        _hasMoreData = true;
      });
      _loadMateris(refresh: true);
    });
  }

  void _onScroll() {
    // Tambahkan pengecekan hasMoreData
    if (!_hasMoreData || _isLoading) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadMateris();
    }
  }

  Future<void> _loadMateris({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _materis.clear();
        _hasMoreData = true;
        _totalPages = 1;
      });
    } else if (_isLoading || !_hasMoreData) {
      return; // Jangan load lagi jika sedang loading atau tidak ada data lagi
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _materiService.getAllMateri(
        page: _currentPage,
        search: _searchQuery,
      );

      setState(() {
        if (refresh) {
          _materis = result['materis'];
        } else {
          _materis.addAll(result['materis']);
        }

        _totalPages = result['totalPages'];
        _currentPage++;

        // Update hasMoreData berdasarkan current page dan total pages
        _hasMoreData = _currentPage <= _totalPages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasMoreData = false; // Set false jika terjadi error
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.accentColor4,
                const Color.fromARGB(255, 255, 255, 255).withOpacity(0.8),
              ],
            ),
          ),
        ),
        title: Text(
          'Materi',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: Colors.white,
          ),
        ),
        elevation: 4,
        shadowColor: AppColors.accentColor4.withOpacity(0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Cari materi...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _onSearch,
            ),
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _onRefresh,
              child: _materis.isEmpty && !_isLoading
                  ? Center(
                      child: Text('Tidak ada materi ditemukan'),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _materis.length +
                          (_hasMoreData || _isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _materis.length) {
                          return _isLoading
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : const SizedBox.shrink();
                        }

                        final materi = _materis[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      MateriDetailScreen(materi: materi),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12)),
                                  child: CachedNetworkImage(
                                    imageUrl: materi.thumbnail,
                                    key: ValueKey(
                                        '${materi.id}-${materi.thumbnail}'),
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) => Container(
                                      color: Colors.grey[300],
                                      child: const Center(
                                          child: CircularProgressIndicator()),
                                    ),
                                    errorWidget: (context, url, error) {
                                      print(
                                          'Error loading image: $url - $error');
                                      return Container(
                                        color: Colors.grey[300],
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(Icons.error,
                                                color: Colors.red[300]),
                                            SizedBox(height: 4),
                                            Text(
                                              'Gambar tidak tersedia',
                                              style: TextStyle(
                                                  color: Colors.red[300],
                                                  fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        materi.judul,
                                        style: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        materi.konten,
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 3,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }
}
