// IMPORTANT: Avoid dart:io on web; use in-memory bytes
import 'dart:typed_data';
import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'scrap_book_page_turn/interactive_book.dart';

// Data structure for page content - using file paths like the working version
class PageData {
  final String name;
  final Uint8List? thumbnailBytes;
  final Uint8List? backgroundImageBytes;
  final Color backgroundColor;

  PageData({
    required this.name,
    this.thumbnailBytes,
    this.backgroundImageBytes,
    this.backgroundColor = Colors.white,
  });
}

class LambookReaderScreen extends StatefulWidget {
  const LambookReaderScreen({
    super.key,
    required this.fileUrl,
    required this.bytes,
  });

  final String fileUrl;
  final Uint8List bytes;

  @override
  State<LambookReaderScreen> createState() => _LambookReaderScreenState();
}

class _LambookReaderScreenState extends State<LambookReaderScreen> {
  late final List<PageData> _pages;
  String? _error;
  bool _loading = true;
  int _progress = 0; // 0..100

  // Metadata from lambook
  Color _scaffoldBgColor = const Color(0xFFF1F5F9);
  Uint8List? _scaffoldBgImageBytes;

  Color _rightCoverColor = const Color(0xFFD7B89C);
  Uint8List? _rightCoverImageBytes;

  Color _leftCoverColor = const Color.fromARGB(255, 192, 161, 134);
  Uint8List? _leftCoverImageBytes;

  double _pageWidth = 1600;
  double _pageHeight = 1200;

  // Track current page indices
  int _currentLeftPage = 0;
  int _currentRightPage = 1;

  late final PageTurnController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageTurnController();
    _parseLambook();
  }

  // Improved phone view detection
  bool _isPhoneView(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final shortestSide = size.shortestSide;
    final longestSide = size.longestSide;

    // Consider it a phone if:
    // 1. Shortest side is less than 600 (standard tablet breakpoint)
    // 2. Device has a portrait-like aspect ratio (longest/shortest > 1.4)
    // This handles most phones in both orientations
    return shortestSide < 600 || (longestSide / shortestSide) > 1.4;
  }

  // Warning widget for unsupported screen sizes
  Widget _buildUnsupportedScreenWarning() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Center(
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: 24.w),
          padding: EdgeInsets.all(32.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(24.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7).withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.phone_android,
                  size: 64.sp,
                  color: const Color(0xFFF59E0B),
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Screen Size Not Supported',
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0F172A),
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 16.h),
              Text(
                'This app is optimized for phone screens only.\nPlease use a mobile device for the best experience.',
                style: TextStyle(
                  fontSize: 16.sp,
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 32.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.info_outline,
                      size: 20.sp,
                      color: const Color(0xFFF59E0B),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'Recommended: Phone in portrait mode',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFF59E0B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _setProgress(int p) {
    final clamped = p.clamp(0, 100);
    if (!mounted) return;
    setState(() => _progress = clamped);
  }

  Future<void> _parseLambook() async {
    try {
      // Validate bytes before attempting to parse
      if (widget.bytes.isEmpty) {
        throw Exception(
          'The file is empty. Please provide a valid .lambook file.',
        );
      }

      if (widget.bytes.length < 100) {
        throw Exception(
          'The file appears to be corrupted or invalid. Please check the file and try again.',
        );
      }

      _setProgress(1);

      // Validate ZIP file signature (PK header)
      if (widget.bytes.length < 4 ||
          widget.bytes[0] != 0x50 ||
          widget.bytes[1] != 0x4B) {
        throw Exception(
          'Invalid file format. This does not appear to be a valid .lambook file. '
          'A .lambook file should be a ZIP archive. Please ensure you are using a valid .lambook file.',
        );
      }

      // Try to decode as ZIP archive
      Archive archive;
      try {
        archive = ZipDecoder().decodeBytes(widget.bytes, verify: false);
      } catch (e) {
        throw Exception(
          'Invalid file format. This does not appear to be a valid .lambook file. '
          'The file may be corrupted or in an unsupported format. Please ensure you are using a valid .lambook file.',
        );
      }

      if (archive.files.isEmpty) {
        throw Exception(
          'The file appears to be empty or corrupted. Please check the file and try again.',
        );
      }

      _setProgress(10);

      // Parse scrapbook.json - search flexibly for the file
      // Handle cases where file might be in root or subdirectory, with different path separators
      // If scrapbook.json is missing, use default values to allow the app to function
      ArchiveFile? metaFile;
      Map<String, dynamic> metaJson = {};

      // Try to find scrapbook.json flexibly (handles subdirectories, case-insensitive)
      try {
        metaFile = archive.files.firstWhere(
          (f) =>
              f.isFile &&
              f.name
                  .toLowerCase()
                  .replaceAll('\\', '/')
                  .endsWith('scrapbook.json'),
        );

        // If found, parse it
        metaJson =
            json.decode(utf8.decode(metaFile.content as List<int>))
                as Map<String, dynamic>;
      } catch (e) {
        // If scrapbook.json is not found, use default values
        // This allows the app to still function and display pages, enabling OAuth verification
        final availableFiles = archive.files
            .where((f) => f.isFile)
            .map((f) => f.name)
            .take(10)
            .toList();

        print(
          'Warning: scrapbook.json not found, using default values. Error: $e',
        );
        print('Available files in archive: ${availableFiles.join(", ")}');
        // Continue with empty metaJson - defaults will be used for all metadata
      }

      _setProgress(20);

      // Extract metadata
      if (metaJson['pageWidth'] != null) {
        _pageWidth = (metaJson['pageWidth'] as num).toDouble();
      }
      if (metaJson['pageHeight'] != null) {
        _pageHeight = (metaJson['pageHeight'] as num).toDouble();
      }
      _setProgress(25);

      // Extract scaffold background
      if (metaJson['scaffoldBackground'] != null) {
        final scaffoldBg =
            metaJson['scaffoldBackground'] as Map<String, dynamic>;
        if (scaffoldBg['color'] != null) {
          final colorData = scaffoldBg['color'] as Map<String, dynamic>;
          _scaffoldBgColor = Color(colorData['value'] as int);
        }
        if (scaffoldBg['imageBase64'] != null) {
          final base64Data = scaffoldBg['imageBase64'] as String;
          _scaffoldBgImageBytes = base64Decode(base64Data);
        }
      }
      _setProgress(35);

      // Extract left cover
      if (metaJson['leftCover'] != null) {
        final leftCover = metaJson['leftCover'] as Map<String, dynamic>;
        if (leftCover['color'] != null) {
          final colorData = leftCover['color'] as Map<String, dynamic>;
          _leftCoverColor = Color(colorData['value'] as int);
        }
        if (leftCover['imageBase64'] != null) {
          final base64Data = leftCover['imageBase64'] as String;
          _leftCoverImageBytes = base64Decode(base64Data);
        }
      }
      _setProgress(45);

      // Extract right cover
      if (metaJson['rightCover'] != null) {
        final rightCover = metaJson['rightCover'] as Map<String, dynamic>;
        if (rightCover['color'] != null) {
          final colorData = rightCover['color'] as Map<String, dynamic>;
          _rightCoverColor = Color(colorData['value'] as int);
        }
        if (rightCover['imageBase64'] != null) {
          final base64Data = rightCover['imageBase64'] as String;
          _rightCoverImageBytes = base64Decode(base64Data);
        }
      }
      _setProgress(50);

      // Parse page files
      final pageFiles =
          archive.files
              .where((f) => f.isFile && f.name.startsWith('pages/'))
              .where((f) => f.name.endsWith('.json'))
              .toList()
            ..sort((a, b) => a.name.compareTo(b.name));

      _pages = <PageData>[];

      for (int i = 0; i < pageFiles.length; i++) {
        final pageFile = pageFiles[i];
        try {
          final pageJson = json.decode(
            utf8.decode(pageFile.content as List<int>),
          );

          // Extract page name
          final String pageName = pageJson['name'] ?? 'Page ${i + 1}';

          // Extract background color
          Color backgroundColor = Colors.white;
          if (pageJson['canvasBackgroundColor'] != null) {
            final colorData =
                pageJson['canvasBackgroundColor'] as Map<String, dynamic>;
            if (colorData['value'] != null) {
              backgroundColor = Color(colorData['value'] as int);
            }
          }

          // Extract thumbnail/background image bytes
          // Support both new keys (thumbnailBase64/backgroundImageBase64)
          // and legacy keys (thumbnailData/backgroundImageData)
          Uint8List? thumbnailBytes;
          Uint8List? backgroundImageBytes;

          final String? thumbB64 =
              (pageJson['thumbnailBase64'] as String?) ??
              (pageJson['thumbnailData'] as String?);
          if (thumbB64 != null && thumbB64.isNotEmpty) {
            thumbnailBytes = base64Decode(thumbB64);
          }

          final String? bgB64 =
              (pageJson['backgroundImageBase64'] as String?) ??
              (pageJson['backgroundImageData'] as String?);
          if (bgB64 != null && bgB64.isNotEmpty) {
            backgroundImageBytes = base64Decode(bgB64);
          }

          _pages.add(
            PageData(
              name: pageName,
              thumbnailBytes: thumbnailBytes,
              backgroundImageBytes: backgroundImageBytes,
              backgroundColor: backgroundColor,
            ),
          );

          print(
            'Parsed page: $pageName, hasThumb: ${thumbnailBytes != null}, hasBg: ${backgroundImageBytes != null}',
          );
          // Allocate 45% for pages (50 -> 95)
          final pageProgress = 50 + (((i + 1) * 45) / pageFiles.length).round();
          _setProgress(pageProgress);
        } catch (e) {
          print('Error parsing page ${pageFile.name}: $e');
          _pages.add(PageData(name: 'Error Page'));
        }
      }

      print('Successfully parsed ${_pages.length} pages');
      if (mounted) setState(() => _loading = false);
      _setProgress(100);
    } catch (e) {
      // Provide user-friendly error messages
      String errorMessage;
      if (e.toString().contains('scrapbook.json') ||
          e.toString().contains('Invalid file format') ||
          e.toString().contains('corrupted') ||
          e.toString().contains('empty')) {
        errorMessage = e.toString().replaceFirst('Exception: ', '');
      } else if (e.toString().contains('Failed to parse')) {
        errorMessage =
            'Unable to open this file. It may be corrupted or in an unsupported format.\n\nPlease ensure you are using a valid .lambook file.';
      } else {
        errorMessage =
            'Unable to open this file.\n\n${e.toString().replaceFirst('Exception: ', '')}';
      }

      _error = errorMessage;
      _pages = <PageData>[];
      if (mounted) setState(() => _loading = false);
    }
  }

  void _onPageChanged(int leftPageIndex, int rightPageIndex) {
    setState(() {
      _currentLeftPage = leftPageIndex;
      _currentRightPage = rightPageIndex;
    });
  }

  void _goToPreviousPage() {
    if (_currentLeftPage > 0) {
      _pageController.previousPage();
    }
  }

  void _goToNextPage() {
    if (_currentRightPage < _pages.length - 1) {
      _pageController.nextPage();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Check if screen size is supported (phone view only)
    if (!_isPhoneView(context)) {
      return _buildUnsupportedScreenWarning();
    }

    if (_loading) {
      return Scaffold(
        backgroundColor: _scaffoldBgColor,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.menu_book_rounded,
                      size: 48,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Preparing Your Lambook',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[900],
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'This will only take a moment',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  Container(
                    width: double.infinity,
                    height: 8,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Stack(
                        children: [
                          FractionallySizedBox(
                            widthFactor: _progress / 100,
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.indigo.shade600,
                                    Colors.indigo.shade400,
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    '$_progress%',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
    if (_error != null) {
      return Scaffold(
        backgroundColor: _scaffoldBgColor,
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.error_outline_rounded,
                      size: 56,
                      color: Colors.red.shade600,
                    ),
                  ),
                  const SizedBox(height: 28),
                  Text(
                    'Unable to Load File',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[900],
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Text(
                      _error!,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[700],
                        height: 1.6,
                      ),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_pages.isEmpty) {
      return Scaffold(
        backgroundColor: _scaffoldBgColor,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFFEC4899).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.menu_book_rounded,
                  size: 64,
                  color: Color(0xFFEC4899),
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'No pages to display',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'This lambook appears to be empty',
                style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _scaffoldBgColor,
      body: Stack(
        children: [
          // Background image if exists
          if (_scaffoldBgImageBytes != null)
            Positioned.fill(
              child: Image.memory(_scaffoldBgImageBytes!, fit: BoxFit.cover),
            ),

          // Main flip book viewer
          Center(
            child: RotatedBox(
              quarterTurns: 1,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  // Calculate aspect ratio (same as InteractiveBook)
                  double aspectRatio;
                  try {
                    if (_pageWidth > 0 && _pageHeight > 0) {
                      aspectRatio = (_pageWidth * 2) / _pageHeight;
                    } else {
                      aspectRatio = 1.4;
                    }
                    if (aspectRatio <= 0 ||
                        !aspectRatio.isFinite ||
                        aspectRatio.isNaN) {
                      aspectRatio = 1.4;
                    }
                  } catch (e) {
                    aspectRatio = 1.4;
                  }

                  // Calculate book dimensions based on available space
                  final availableWidth = constraints.maxWidth;
                  final availableHeight = constraints.maxHeight;

                  // Calculate book size maintaining aspect ratio
                  double bookWidth;
                  double bookHeight;

                  if (availableWidth / availableHeight > aspectRatio) {
                    // Height constrained
                    bookHeight = availableHeight * 0.85; // Use 85% of height
                    bookWidth = bookHeight * aspectRatio;
                  } else {
                    // Width constrained
                    bookWidth = availableWidth * 0.9; // Use 90% of width
                    bookHeight = bookWidth / aspectRatio;
                  }

                  // Cover dimensions (slightly larger than book)
                  final coverWidth = bookWidth * 1.03;
                  final coverHeight = bookHeight * 1.08;
                  final leftCoverWidth = coverWidth / 2;

                  return SizedBox(
                    width: availableWidth,
                    height: availableHeight,
                    child: Stack(
                      children: [
                        // Background book cover (BOTTOM LAYER - acts as frame)
                        Center(
                          child: SizedBox(
                            width: coverWidth,
                            height: coverHeight,
                            child: Stack(
                              children: [
                                // Right cover (full background)
                                Center(
                                  child: Container(
                                    width: coverWidth,
                                    height: coverHeight,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(16),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withValues(
                                            alpha: 0.2,
                                          ),
                                          blurRadius: 10,
                                          offset: const Offset(4, 4),
                                        ),
                                      ],
                                      color: _rightCoverImageBytes == null
                                          ? _rightCoverColor
                                          : null,
                                      image: _rightCoverImageBytes != null
                                          ? DecorationImage(
                                              image: MemoryImage(
                                                _rightCoverImageBytes!,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),

                                // Left cover (overlays left half)
                                Align(
                                  alignment: Alignment.centerLeft,
                                  child: Container(
                                    width: leftCoverWidth,
                                    height: coverHeight,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.only(
                                        bottomLeft: Radius.circular(16),
                                        topLeft: Radius.circular(16),
                                      ),
                                      color: _leftCoverImageBytes == null
                                          ? _leftCoverColor
                                          : null,
                                      image: _leftCoverImageBytes != null
                                          ? DecorationImage(
                                              image: MemoryImage(
                                                _leftCoverImageBytes!,
                                              ),
                                              fit: BoxFit.cover,
                                            )
                                          : null,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        // Interactive book (MIDDLE LAYER - pages flip freely without clipping)
                        Center(
                          child: SizedBox(
                            width: bookWidth,
                            height: bookHeight,
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: InteractiveBook(
                                pagesBoundaryIsEnabled: false,
                                controller: _pageController,
                                pageCount: _pages.length,
                                aspectRatio: aspectRatio,
                                pageViewMode: PageViewMode.double,
                                onPageChanged: _onPageChanged,
                                settings: FlipSettings(
                                  startPageIndex: 0,
                                  usePortrait: false,
                                  flippingTime: 1200,
                                  swipeDistance: 1200,
                                ),
                                builder: (context, pageIndex, constraints) {
                                  if (pageIndex >= _pages.length) {
                                    return Container(
                                      color: Colors.white,
                                      child: const Center(
                                        child: Text(
                                          'End of Book',
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF64748B),
                                          ),
                                        ),
                                      ),
                                    );
                                  }

                                  final page = _pages[pageIndex];

                                  // Try to get thumbnail first, then background image
                                  final imageBytes =
                                      page.thumbnailBytes ??
                                      page.backgroundImageBytes;

                                  if (imageBytes != null) {
                                    return Container(
                                      decoration: BoxDecoration(
                                        color: page.backgroundColor,
                                      ),
                                      child: Stack(
                                        children: [
                                          // Background image
                                          Positioned.fill(
                                            child: Image.memory(
                                              imageBytes,
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  }

                                  // Fallback: show page name or default content
                                  return Container(
                                    decoration: BoxDecoration(
                                      color: page.backgroundColor,
                                      gradient:
                                          page.backgroundColor == Colors.white
                                              ? const LinearGradient(
                                                  begin: Alignment.topLeft,
                                                  end: Alignment.bottomRight,
                                                  colors: [
                                                    Color(0xFFF8FAFC),
                                                    Color(0xFFE2E8F0),
                                                  ],
                                                )
                                              : null,
                                    ),
                                    child: Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.insert_drive_file_outlined,
                                            color: Color(0xFF94A3B8),
                                            size: 48,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            page.name,
                                            style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                              color: Color(0xFF64748B),
                                            ),
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        // Navigation arrows
                        Positioned(
                          bottom: 20.h,
                          left: 20.w,
                          child: IconButton(
                            onPressed: _currentLeftPage > 0
                                ? _goToPreviousPage
                                : null,
                            icon: Icon(
                              Icons.arrow_back_ios,
                              color: _currentLeftPage > 0
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFF94A3B8),
                              size: 15.sp, // Reduced size to match snippet
                            ),
                            padding: EdgeInsets.all(8.w),
                            constraints: BoxConstraints(
                              minWidth: 50.w,
                              minHeight: 50.h,
                            ),
                          ),
                        ),

                        Positioned(
                          bottom: 20.h,
                          right: 20.w,
                          child: IconButton(
                            onPressed: _currentRightPage < _pages.length - 1
                                ? _goToNextPage
                                : null,
                            icon: Icon(
                              Icons.arrow_forward_ios,
                              color: _currentRightPage < _pages.length - 1
                                  ? const Color(0xFF0F172A)
                                  : const Color(0xFF94A3B8),
                              size: 15.sp, // Reduced size to match snippet
                            ),
                            padding: EdgeInsets.all(8.w),
                            constraints: BoxConstraints(
                              minWidth: 50.w,
                              minHeight: 50.h,
                            ),
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
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
