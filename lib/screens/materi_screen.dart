// lib/screens/materi_screen.dart
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:giat_cerika/constant/color.dart';
import 'package:giat_cerika/models/materi.dart';
import 'package:giat_cerika/screens/materi_detail_screen.dart';
import 'package:giat_cerika/services/materi_services.dart';

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

  void _onSearch(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() {
        _searchQuery = query;
        _currentPage = 1;
        _materis.clear();
        _hasMoreData = true;
      });
      _loadMateris();
    });
  }

  Future<void> _loadMateris({bool refresh = false}) async {
    if (_isLoading || !_hasMoreData) return;
    
    setState(() {
      if (refresh) {
        _currentPage = 1;
        _materis.clear();
        _hasMoreData = true;
      }
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
        _hasMoreData = _currentPage < _totalPages;
        
        if (_hasMoreData) {
          _currentPage++;
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading materi: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= 
        _scrollController.position.maxScrollExtent - 200) {
      _loadMateris();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      appBar: AppBar(
        title: const Text('Materi'),
        backgroundColor: AppColors.primaryColor,
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
              onRefresh: () => _loadMateris(refresh: true),
              child: _materis.isEmpty && !_isLoading
                  ? Center(
                      child: Text('Tidak ada materi ditemukan'),
                    )
                  : ListView.builder(
                      controller: _scrollController,
                      padding: const EdgeInsets.all(16),
                      itemCount: _materis.length + (_hasMoreData || _isLoading ? 1 : 0),
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
                                  builder: (context) => MateriDetailScreen(materi: materi),
                                ),
                              );
                            },
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ClipRRect(
                                  borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(12)
                                  ),
                                  child: Image.network(
                                    materi.thumbnail,
                                    height: 180,
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      print('Error loading image: $error');
                                      return Container(
                                        height: 180,
                                        color: Colors.grey[300],
                                        child: const Icon(Icons.error),
                                      );
                                    },
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
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