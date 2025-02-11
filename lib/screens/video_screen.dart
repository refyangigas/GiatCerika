import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../constant/color.dart';
import '../models/video.dart';
import '../services/video_services.dart';
import 'video_player_screen.dart';

class VideoScreen extends StatefulWidget {
  const VideoScreen({Key? key}) : super(key: key);

  @override
  State<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends State<VideoScreen> {
  final VideoService _videoService = VideoService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  List<Video> _videos = [];
  bool _isLoading = false;
  bool _hasMoreData = true;
  int _currentPage = 1;
  int _totalPages = 1;
  String _searchQuery = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _loadVideos();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _onRefresh() async {
    await _loadVideos(refresh: true);
  }

  void _onSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
        _currentPage = 1;
        _videos.clear();
        _hasMoreData = true;
      });
      _loadVideos(refresh: true);
    });
  }

  void _onScroll() {
    if (!_hasMoreData || _isLoading) return;

    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      _loadVideos();
    }
  }

  Future<void> _loadVideos({bool refresh = false}) async {
    if (refresh) {
      setState(() {
        _currentPage = 1;
        _videos.clear();
        _hasMoreData = true;
        _totalPages = 1;
      });
    } else if (_isLoading || !_hasMoreData) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final result = await _videoService.getAllVideos(
        page: _currentPage,
        search: _searchQuery,
      );

      setState(() {
        if (refresh) {
          _videos = result['videos'];
        } else {
          _videos.addAll(result['videos']);
        }

        _totalPages = result['totalPages'];
        _currentPage++;
        _hasMoreData = _currentPage <= _totalPages;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasMoreData = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    }
  }

  void _navigateToVideoPlayer(Video video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoPlayerScreen(
          title: video.judul,
          youtubeUrl: video.youtube_url,
        ),
      ),
    );
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
                AppColors.accentColor2,
                const Color.fromARGB(255, 255, 255, 255).withOpacity(0.8),
              ],
            ),
          ),
        ),
        title: const Text(
          'Video Pembelajaran',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
            color: Colors.white,
          ),
        ),
        elevation: 4,
        shadowColor: AppColors.accentColor2.withOpacity(0.5),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
        systemOverlayStyle: const SystemUiOverlayStyle(
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
                hintText: 'Cari video...',
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
              child: _videos.isEmpty && !_isLoading
                  ? const Center(
                      child: Text('Tidak ada video ditemukan'),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount:
                          _videos.length + (_hasMoreData || _isLoading ? 1 : 0),
                      itemBuilder: (context, index) {
                        if (index == _videos.length) {
                          return _isLoading
                              ? const Center(
                                  child: Padding(
                                    padding: EdgeInsets.all(16.0),
                                    child: CircularProgressIndicator(),
                                  ),
                                )
                              : const SizedBox.shrink();
                        }

                        final video = _videos[index];
                        final youtubeId =
                            YoutubePlayer.convertUrlToId(video.youtube_url) ?? '';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: InkWell(
                            onTap: () => _navigateToVideoPlayer(video),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(12)),
                                  child: Image.network(
                                    'https://img.youtube.com/vi/$youtubeId/maxresdefault.jpg',
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        height: 180,
                                        color: Colors.grey[300],
                                        child: const Center(
                                          child: Icon(
                                            Icons.error_outline,
                                            size: 50,
                                            color: Colors.grey,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    video.judul,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
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