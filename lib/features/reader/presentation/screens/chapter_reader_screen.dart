import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../providers/chapter_reader_provider.dart';
import '../providers/chapter_reader_state.dart';

class ChapterReaderScreen extends ConsumerStatefulWidget {
  final String mangaId;
  final String chapterId;

  const ChapterReaderScreen({
    super.key,
    required this.mangaId,
    required this.chapterId,
  });

  @override
  ConsumerState<ChapterReaderScreen> createState() => _ChapterReaderScreenState();
}

class _ChapterReaderScreenState extends ConsumerState<ChapterReaderScreen> {
  bool _showOverlays = true;
  late PageController _pageController;
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    // Enable immersive full-screen mode by hiding system overlays
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    
    final initialState = ref.read(chapterReaderProvider(widget.chapterId));
    _pageController = PageController(initialPage: initialState.currentPageIndex);
    _scrollController = ScrollController();
    
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    // Restore system UI overlays on exit
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: SystemUiOverlay.values);
    _pageController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final state = ref.read(chapterReaderProvider(widget.chapterId));
    if (state.isHorizontalLayout || state.pages.isEmpty) return;

    if (_scrollController.hasClients) {
      final itemHeight = MediaQuery.of(context).size.height * 0.9;
      final offset = _scrollController.offset;
      final newPage = (offset / itemHeight).round().clamp(0, state.pages.length - 1);
      
      if (newPage != state.currentPageIndex) {
        ref.read(chapterReaderProvider(widget.chapterId).notifier).setPage(newPage);
      }
    }
  }

  void _jumpToPage(int pageIndex, bool isHorizontal) {
    if (isHorizontal) {
      if (_pageController.hasClients) {
        _pageController.jumpToPage(pageIndex);
      }
    } else {
      if (_scrollController.hasClients) {
        final itemHeight = MediaQuery.of(context).size.height * 0.9;
        _scrollController.jumpTo(pageIndex * itemHeight);
      }
    }
  }

  void _navigateToPage(int targetPage, bool isHorizontal) {
    final state = ref.read(chapterReaderProvider(widget.chapterId));
    if (targetPage < 0 || targetPage >= state.pages.length) return;
    
    ref.read(chapterReaderProvider(widget.chapterId).notifier).setPage(targetPage);
    
    if (isHorizontal) {
      if (_pageController.hasClients) {
        _pageController.animateToPage(
          targetPage,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    } else {
      if (_scrollController.hasClients) {
        final itemHeight = MediaQuery.of(context).size.height * 0.9;
        _scrollController.animateTo(
          targetPage * itemHeight,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  void _handleTap(TapUpDetails details, ChapterReaderState state) {
    if (!state.isHorizontalLayout) {
      // In vertical scroll mode, any tap toggles overlays
      setState(() {
        _showOverlays = !_showOverlays;
      });
      return;
    }

    final screenWidth = MediaQuery.of(context).size.width;
    final tapX = details.globalPosition.dx;

    if (tapX < screenWidth / 3) {
      // Left third: previous page
      final targetPage = state.currentPageIndex - 1;
      _navigateToPage(targetPage, true);
    } else if (tapX > 2 * screenWidth / 3) {
      // Right third: next page
      final targetPage = state.currentPageIndex + 1;
      _navigateToPage(targetPage, true);
    } else {
      // Middle third: toggle overlays
      setState(() {
        _showOverlays = !_showOverlays;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(chapterReaderProvider(widget.chapterId));
    final notifier = ref.read(chapterReaderProvider(widget.chapterId).notifier);

    // Synchronize page controllers only on initial page load or when layout mode changes
    ref.listen<ChapterReaderState>(
      chapterReaderProvider(widget.chapterId),
      (previous, next) {
        if (next.isLoading || next.pages.isEmpty) return;

        final pagesLoaded = previous != null && previous.isLoading && !next.isLoading;
        final layoutChanged = previous != null && previous.isHorizontalLayout != next.isHorizontalLayout;

        if (pagesLoaded || layoutChanged) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (!mounted) return;
            if (next.isHorizontalLayout) {
              // Dispose the old controller and create a new one with correct initial page index
              _pageController.dispose();
              _pageController = PageController(initialPage: next.currentPageIndex);
              setState(() {});
            } else {
              if (_scrollController.hasClients) {
                final itemHeight = MediaQuery.of(context).size.height * 0.9;
                _scrollController.jumpTo(next.currentPageIndex * itemHeight);
              }
            }
          });
        }
      },
    );

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // 1. Interactive Viewport Area
          GestureDetector(
            onTapUp: (details) => _handleTap(details, state),
            child: _buildReaderContent(state),
          ),

          // 2. Top Bar Overlay
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            top: _showOverlays ? 0 : -100,
            left: 0,
            right: 0,
            child: _buildTopOverlay(state),
          ),

          // 3. Bottom Bar Overlay
          AnimatedPositioned(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            bottom: _showOverlays ? 0 : -200,
            left: 0,
            right: 0,
            child: _buildBottomOverlay(state, notifier),
          ),
        ],
      ),
    );
  }

  Widget _buildReaderContent(ChapterReaderState state) {
    if (state.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.red),
      );
    }

    if (state.errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 64),
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(0, 40),
                ),
                onPressed: () {
                  ref.read(chapterReaderProvider(widget.chapterId).notifier).loadPages();
                },
                child: const Text('Tentar Novamente'),
              ),
            ],
          ),
        ),
      );
    }

    if (state.pages.isEmpty) {
      return const Center(
        child: Text(
          'Este capítulo não tem páginas.',
          style: TextStyle(color: Colors.grey, fontSize: 16),
        ),
      );
    }

    if (state.isHorizontalLayout) {
      return PageView.builder(
        controller: _pageController,
        itemCount: state.pages.length,
        onPageChanged: (index) {
          ref.read(chapterReaderProvider(widget.chapterId).notifier).setPage(index);
        },
        itemBuilder: (context, index) {
          return Center(
            child: Hero(
              tag: 'chapter_page_$index',
              child: _buildPageImage(state.pages[index]),
            ),
          );
        },
      );
    } else {
      final itemHeight = MediaQuery.of(context).size.height * 0.9;
      return ListView.builder(
        controller: _scrollController,
        itemCount: state.pages.length,
        itemBuilder: (context, index) {
          return Container(
            height: itemHeight,
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: _buildPageImage(state.pages[index]),
            ),
          );
        },
      );
    }
  }

  Widget _buildPageImage(String path) {
    final isRemote = path.startsWith('http://') || path.startsWith('https://');
    if (isRemote) {
      return CachedNetworkImage(
        imageUrl: path,
        fit: BoxFit.contain,
        placeholder: (context, url) => const Center(
          child: CircularProgressIndicator(color: Colors.red),
        ),
        errorWidget: (context, url, error) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.broken_image, color: Colors.red, size: 48),
                const SizedBox(height: 8),
                const Text(
                  'Erro ao carregar a página.',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
                const SizedBox(height: 8),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    minimumSize: const Size(0, 40),
                  ),
                  onPressed: () {
                    ref.read(chapterReaderProvider(widget.chapterId).notifier).loadPages();
                  },
                  child: const Text('Recarregar'),
                ),
              ],
            ),
          );
        },
      );
    } else {
      return Image.file(
        File(path),
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image, color: Colors.red, size: 48),
                SizedBox(height: 8),
                Text(
                  'Arquivo local não encontrado.',
                  style: TextStyle(color: Colors.white, fontSize: 14),
                ),
              ],
            ),
          );
        },
      );
    }
  }

  Widget _buildTopOverlay(ChapterReaderState state) {
    return GestureDetector(
      onTap: () {}, // Swallows taps on the top bar
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.7),
            padding: EdgeInsets.only(
              top: MediaQuery.of(context).padding.top + 8,
              bottom: 16,
              left: 16,
              right: 16,
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (state.pages.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          'Página ${state.currentPageIndex + 1} de ${state.pages.length}',
                          style: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomOverlay(ChapterReaderState state, ChapterReaderNotifier notifier) {
    if (state.pages.isEmpty) return const SizedBox.shrink();

    return GestureDetector(
      onTap: () {}, // Swallows taps on the bottom bar
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            color: Colors.black.withOpacity(0.7),
            padding: EdgeInsets.only(
              top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
              left: 16,
              right: 16,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // 1. Slider & Page counter row
                Row(
                  children: [
                    Text(
                      '${state.currentPageIndex + 1}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    Expanded(
                      child: Slider(
                        value: state.currentPageIndex.toDouble(),
                        min: 0,
                        max: (state.pages.length - 1).toDouble(),
                        divisions: state.pages.length > 1 ? state.pages.length - 1 : 1,
                        activeColor: Colors.red,
                        inactiveColor: Colors.grey.shade800,
                        onChanged: (value) {
                          final targetPage = value.round();
                          notifier.setPage(targetPage);
                          _jumpToPage(targetPage, state.isHorizontalLayout);
                        },
                      ),
                    ),
                    Text(
                      '${state.pages.length}',
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // 2. Action row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Layout Mode toggle button
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey.shade900,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        minimumSize: const Size(0, 40),
                      ),
                      onPressed: () {
                        notifier.toggleLayoutMode();
                      },
                      icon: Icon(
                        state.isHorizontalLayout ? Icons.swap_vert : Icons.swap_horiz,
                        color: Colors.red,
                      ),
                      label: Text(
                        state.isHorizontalLayout ? 'Modo Vertical' : 'Modo Horizontal',
                        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                      ),
                    ),
                    
                    // Simple page info text
                    Text(
                      'Leitura: ${((state.currentPageIndex + 1) / state.pages.length * 100).round()}%',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
