import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:http/http.dart' as http;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:googleapis/drive/v3.dart' as drive;
import 'package:go_router/go_router.dart';
import 'lambook_reader_screen.dart';
import 'privacy_policy_screen.dart';
import 'terms_of_service_screen.dart';
import 'data_deletion_screen.dart';
import 'home_screen.dart';

void main() {
  runApp(const MyApp());
}

class _GoogleAuthClient extends http.BaseClient {
  final Map<String, String> _headers;
  final http.Client _inner = http.Client();
  _GoogleAuthClient(this._headers);
  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    request.headers.addAll(_headers);
    return _inner.send(request);
  }
}

final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/lambook-view',
      builder: (context, state) {
        final fileUrl = state.uri.queryParameters['file'];
        return ViewerHomePage(fileUrl: fileUrl);
      },
    ),
    GoRoute(
      path: '/terms',
      builder: (context, state) => const TermsOfServiceScreen(),
    ),
    GoRoute(
      path: '/privacy',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
    GoRoute(
      path: '/data_deletion',
      builder: (context, state) => const DataDeletionScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Lamlayers - Digital Lambook Viewer',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.indigo,
              brightness: Brightness.light,
            ),
            useMaterial3: true,
            cardTheme: CardThemeData(
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
          routerConfig: _router,
        );
      },
    );
  }
}

class ViewerHomePage extends StatefulWidget {
  final String? fileUrl;

  const ViewerHomePage({super.key, this.fileUrl});

  @override
  State<ViewerHomePage> createState() => _ViewerHomePageState();
}

class _ViewerHomePageState extends State<ViewerHomePage>
    with SingleTickerProviderStateMixin {
  String? fileUrl;
  Uint8List? fileBytes;
  String? error;
  bool loading = true;
  String loadingMessage = 'Loading...';
  bool showPopupBlockedWarning = false;
  int signInAttempts = 0;

  double downloadProgress = 0.0;
  int downloadedBytes = 0;
  int totalBytes = 0;
  bool isDownloading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  static const String _webClientId =
      '95582377829-f64u9joo19djd769u06mp3719hh2vg1l.apps.googleusercontent.com';

  // Changed to drive.file scope for restricted access
  final GoogleSignIn _gsignIn = GoogleSignIn(
    clientId: _webClientId,
    scopes: <String>['https://www.googleapis.com/auth/drive.file'],
    signInOption: SignInOption.standard,
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _loadFromQuery();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadFromQuery() async {
    try {
      final param = widget.fileUrl;
      if (param == null || param.isEmpty) {
        setState(() {
          loading = false;
          error = 'No file specified. Please provide a valid file link.';
        });
        return;
      }
      setState(() {
        fileUrl = param;
      });
      if (_isGoogleDriveUrl(param)) {
        await _attemptSilentSignIn();
      } else {
        await _downloadDirectUrl(param);
      }
    } catch (e) {
      setState(() {
        loading = false;
        error = 'Error: $e';
        isDownloading = false;
      });
    }
  }

  Future<void> _attemptSilentSignIn() async {
    setState(() {
      loading = true;
      loadingMessage = 'Checking credentials...';
    });

    try {
      final user = await _gsignIn.signInSilently(suppressErrors: true);

      if (user != null) {
        print('Silent sign-in successful');
        await _downloadFromDrive();
      } else {
        print('No existing credentials found');
        setState(() {
          loading = false;
          loadingMessage = 'Ready to sign in';
        });
      }
    } catch (e) {
      print('Silent sign-in error: $e');
      setState(() {
        loading = false;
        loadingMessage = 'Ready to sign in';
      });
    }
  }

  Future<void> _downloadDirectUrl(String url) async {
    setState(() {
      isDownloading = true;
      downloadProgress = 0.0;
      downloadedBytes = 0;
      totalBytes = 0;
      loadingMessage = 'Connecting to server...';
    });

    try {
      final request = http.Request('GET', Uri.parse(url));
      final response = await request.send();

      if (response.statusCode != 200) {
        setState(() {
          loading = false;
          isDownloading = false;
          error =
              'Unable to download file (Status: ${response.statusCode}).\n\nPlease check if the link is valid and accessible.';
        });
        return;
      }

      totalBytes = response.contentLength ?? 0;
      final chunks = <int>[];

      await for (var chunk in response.stream) {
        chunks.addAll(chunk);
        downloadedBytes = chunks.length;

        if (!mounted) return;

        setState(() {
          if (totalBytes > 0) {
            downloadProgress = downloadedBytes / totalBytes;
          }
        });
      }

      if (chunks.isEmpty) {
        setState(() {
          loading = false;
          isDownloading = false;
          error =
              'Downloaded file is empty.\n\nThe file may not exist or may have been removed.';
        });
        return;
      }

      setState(() {
        fileBytes = Uint8List.fromList(chunks);
        loading = false;
        isDownloading = false;
        downloadProgress = 1.0;
      });

      _openReaderIfReady();
    } catch (e) {
      setState(() {
        loading = false;
        isDownloading = false;
        error =
            'Download failed.\n\nPlease check your internet connection and try again.';
      });
    }
  }

  void _openReaderIfReady() {
    if (mounted && fileUrl != null && fileBytes != null) {
      // Validate bytes before opening reader
      if (fileBytes!.isEmpty) {
        setState(() {
          loading = false;
          error =
              'The downloaded file is empty.\n\nThe file may be corrupted or invalid. Please try again or contact the file owner.';
        });
        return;
      }

      if (fileBytes!.length < 100) {
        setState(() {
          loading = false;
          error =
              'The downloaded file appears to be invalid.\n\nThe file is too small to be a valid .lambook file. Please check the file and try again.';
        });
        return;
      }

      // iOS Web Memory Warning
      // Safari on iOS has strict memory limits (approx 200-300MB for canvas/images).
      // Large ZIPs + decoded images often crash it.
      final bool isIOS = Theme.of(context).platform == TargetPlatform.iOS;
      final int sizeInMB = fileBytes!.length ~/ (1024 * 1024);
      
      if (isIOS && sizeInMB > 100) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => AlertDialog(
            title: const Text('Large File Warning'),
            content: Text(
              'This file is $sizeInMB MB. iOS devices may run out of memory and crash with files larger than 100MB.\n\n'
              'If the app crashes, please use a computer or an Android device.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close dialog
                  _navigateToReader();
                },
                child: const Text('Continue Anyway'),
              ),
            ],
          ),
        );
      } else {
        _navigateToReader();
      }
    }
  }

  void _navigateToReader() {
    // Use pushReplacement to DESTROY the ViewerHomePage and free its memory.
    // This removes the reference to 'fileBytes' in this widget's state,
    // passing ownership to the next screen.
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) =>
            LambookReaderScreen(fileUrl: fileUrl!, bytes: fileBytes!),
      ),
    );
    
    // Explicitly help GC (though widget dispose should handle it)
    fileBytes = null; 
  }

  Future<void> _signInAndLoadDrive() async {
    final url = fileUrl;
    if (url == null) return;

    signInAttempts++;

    setState(() {
      loading = true;
      error = null;
      showPopupBlockedWarning = false;
      loadingMessage = 'Opening sign-in...';
    });

    try {
      final user = await _gsignIn.signIn();

      if (user == null) {
        // User cancelled or popup was blocked
        setState(() {
          loading = false;
          loadingMessage = 'Sign-in required';
          showPopupBlockedWarning = true;
          error = null; // Clear error to show the popup warning UI instead
        });
        return;
      }

      // Check and request scopes if needed
      const scopes = <String>['https://www.googleapis.com/auth/drive.file'];
      final hasScope = await _gsignIn.canAccessScopes(scopes);

      if (!hasScope) {
        setState(() => loadingMessage = 'Requesting permissions...');
        final granted = await _gsignIn.requestScopes(scopes);

        if (!granted) {
          setState(() {
            loading = false;
            loadingMessage = 'Permission required';
            error =
                'Google Drive access is required to view this file.\n\nPlease try again and click "Allow" when prompted.';
          });
          return;
        }
      }

      // Reset attempts on successful sign-in
      signInAttempts = 0;
      await _downloadFromDrive();
    } catch (e) {
      print('Sign-in error: $e');

      String errorMessage;

      if (e.toString().contains('popup_closed') ||
          e.toString().contains('popup_blocked_by_browser')) {
        setState(() {
          loading = false;
          showPopupBlockedWarning = true;
          error = null;
        });
        return;
      } else if (e.toString().contains('access_denied')) {
        errorMessage =
            'Google Drive access was denied.\n\nTo view your file, please try again and click "Allow" when prompted.';
      } else if (e.toString().contains('network')) {
        errorMessage =
            'Unable to connect to Google.\n\nPlease check your internet connection and try again.';
      } else {
        errorMessage =
            'Unable to sign in to Google.\n\nPlease try again. If the problem persists, try refreshing the page.';
      }

      setState(() {
        loading = false;
        loadingMessage = 'Sign-in required';
        error = errorMessage;
      });
    }
  }

  Future<void> _downloadFromDrive() async {
    final url = fileUrl;
    if (url == null) return;

    try {
      setState(() => loadingMessage = 'Connecting to Google Drive...');

      final headers = await _gsignIn.currentUser!.authHeaders;
      final api = drive.DriveApi(_GoogleAuthClient(headers));

      setState(() => loadingMessage = 'Verifying file access...');

      final id = _extractDriveFileId(url);

      // Get file metadata first
      drive.File fileMetadata;
      try {
        fileMetadata =
            await api.files.get(id, $fields: 'id,name,size,mimeType')
                as drive.File;

        print('File metadata: ${fileMetadata.toJson()}');
      } catch (e) {
        print('Error getting file metadata: $e');

        String errorMsg;
        String errorDetails;

        if (e.toString().contains('403')) {
          errorMsg = 'Cannot Access File';
          errorDetails =
              'You don\'t have permission to view this file.\n\n'
              '📋 What to do:\n'
              '1. Ask the file owner to share it with you\n'
              '2. Make sure you\'re signed in with the correct Google account\n'
              '3. Check that the file link is correct';
        } else if (e.toString().contains('404')) {
          errorMsg = 'File Not Found';
          errorDetails =
              'This file doesn\'t exist or has been deleted.\n\n'
              '📋 What to do:\n'
              '1. Check that the link is correct\n'
              '2. Ask the file owner to verify the file still exists\n'
              '3. Request a new link if needed';
        } else if (e.toString().contains('401')) {
          errorMsg = 'Authentication Failed';
          errorDetails =
              'Your session has expired.\n\n'
              '📋 What to do:\n'
              'Click "Try Again" below to sign in again';
        } else {
          errorMsg = 'Cannot Load File';
          errorDetails =
              'Unable to access the file from Google Drive.\n\n'
              '📋 What to do:\n'
              '1. Check your internet connection\n'
              '2. Verify the file link is correct\n'
              '3. Try signing out and signing in again';
        }

        setState(() {
          loading = false;
          loadingMessage = 'Error';
          isDownloading = false;
          error = '$errorMsg\n\n$errorDetails';
        });
        return;
      }

      final fileSize = int.tryParse(fileMetadata.size ?? '0') ?? 0;
      print('File size: $fileSize bytes');

      // Check if file is too large (over 500MB)
      if (fileSize > 500 * 1024 * 1024) {
        setState(() {
          loading = false;
          loadingMessage = 'File Too Large';
          isDownloading = false;
          error =
              'File Too Large\n\n'
              'This file is ${(fileSize / (1024 * 1024)).toStringAsFixed(0)} MB, '
              'but the maximum supported size is 500 MB.\n\n'
              '📋 What to do:\n'
              'Ask the file owner to provide a smaller version of the file.';
        });
        return;
      }

      setState(() {
        totalBytes = fileSize;
        isDownloading = true;
        downloadProgress = 0.0;
        downloadedBytes = 0;
        loadingMessage = 'Starting download...';
      });

      // Download the file
      try {
        print('Starting file download...');

        final media =
            await api.files.get(
                  id,
                  downloadOptions: drive.DownloadOptions.fullMedia,
                )
                as drive.Media;

        print('Got media stream, reading chunks...');

        final List<List<int>> chunksList = [];
        int lastUpdateTime = DateTime.now().millisecondsSinceEpoch;
        int totalDownloaded = 0;

        await for (var chunk in media.stream) {
          if (!mounted) return;

          chunksList.add(chunk);
          totalDownloaded += chunk.length;
          downloadedBytes = totalDownloaded;

          final currentTime = DateTime.now().millisecondsSinceEpoch;

          if (currentTime - lastUpdateTime > 300) {
            lastUpdateTime = currentTime;

            if (mounted) {
              setState(() {
                if (totalBytes > 0) {
                  downloadProgress = downloadedBytes / totalBytes;
                }
                loadingMessage =
                    'Downloading... ${(downloadProgress * 100).toStringAsFixed(0)}%';
              });
            }
          }
        }

        print('Stream completed. Total bytes: $totalDownloaded');

        if (chunksList.isEmpty) {
          setState(() {
            loading = false;
            loadingMessage = 'Error';
            isDownloading = false;
            error =
                'Downloaded File is Empty\n\nThe file appears to be empty or corrupted.\n\n📋 What to do:\nAsk the file owner to check the file and share a new link.';
          });
          return;
        }

        print('Combining chunks...');
        if (!mounted) return;

        setState(() {
          loadingMessage = 'Processing file...';
        });

        // Combine chunks
        int totalSize = 0;
        for (var chunk in chunksList) {
          totalSize += chunk.length;
        }

        final fileData = Uint8List(totalSize);
        int offset = 0;
        for (var chunk in chunksList) {
          fileData.setRange(offset, offset + chunk.length, chunk);
          offset += chunk.length;
        }

        if (!mounted) return;

        setState(() {
          fileBytes = fileData;
          loading = false;
          loadingMessage = 'Ready!';
          isDownloading = false;
          downloadProgress = 1.0;
          error = null;
        });

        print('Opening reader...');
        _openReaderIfReady();
      } catch (downloadError) {
        print('Download error: $downloadError');

        String errorMsg;
        String errorDetails;

        if (downloadError.toString().contains('403')) {
          errorMsg = 'Download Not Allowed';
          errorDetails =
              'You don\'t have permission to download this file.\n\n'
              '📋 What to do:\n'
              'Ask the file owner to grant you download access.';
        } else if (downloadError.toString().contains('404')) {
          errorMsg = 'File Not Found';
          errorDetails =
              'The file was not found during download.\n\n'
              '📋 What to do:\n'
              'The file may have been deleted. Request a new link.';
        } else if (downloadError.toString().contains('network') ||
            downloadError.toString().contains('connection')) {
          errorMsg = 'Connection Lost';
          errorDetails =
              'Network connection was interrupted.\n\n'
              '📋 What to do:\n'
              '1. Check your internet connection\n'
              '2. Click "Try Again" to restart the download';
        } else if (downloadError.toString().contains('timeout')) {
          errorMsg = 'Download Timeout';
          errorDetails =
              'The download took too long.\n\n'
              '📋 What to do:\n'
              '1. Check your internet connection\n'
              '2. The file may be too large\n'
              '3. Try again with a better connection';
        } else {
          errorMsg = 'Download Failed';
          errorDetails =
              'Unable to download the file.\n\n'
              '📋 What to do:\n'
              '1. Check your internet connection\n'
              '2. Click "Try Again" below\n'
              '3. If it fails again, try refreshing the page';
        }

        setState(() {
          loading = false;
          loadingMessage = 'Error';
          isDownloading = false;
          error = '$errorMsg\n\n$errorDetails';
        });
      }
    } catch (e) {
      print('General error: $e');

      setState(() {
        loading = false;
        loadingMessage = 'Error';
        isDownloading = false;
        error =
            'Unexpected Error\n\nSomething went wrong while loading your file.\n\n'
            '📋 What to do:\n'
            '1. Click "Try Again" below\n'
            '2. If that doesn\'t work, try refreshing the page\n'
            '3. Make sure you have a stable internet connection';
      });
    }
  }

  bool _isGoogleDriveUrl(String input) {
    final u = Uri.tryParse(input);
    if (u == null) return false;
    final host = u.host.toLowerCase();
    return host.contains('drive.google.com') ||
        host.contains('docs.google.com');
  }

  String _extractDriveFileId(String input) {
    final uri = Uri.tryParse(input);
    if (uri == null) return input;

    final idParam = uri.queryParameters['id'];
    if (idParam != null && idParam.isNotEmpty) return idParam;

    final m = RegExp(r'/file/d/([^/]+)').firstMatch(uri.path);
    if (m != null) return m.group(1)!;

    final m2 = RegExp(r'/d/([^/]+)').firstMatch(uri.path);
    if (m2 != null) return m2.group(1)!;

    return input;
  }

  Widget _buildPopupBlockedWarning() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.block_rounded,
                size: 56,
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(height: 28),
            Text(
              'Sign-in Window Blocked',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.grey[900],
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: Colors.orange.shade700,
                        size: 22,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Your browser blocked the sign-in window',
                          style: Theme.of(context).textTheme.titleSmall
                              ?.copyWith(
                                color: Colors.orange.shade900,
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'How to fix this:',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.orange.shade900,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildStep(
                    '1',
                    'Look for a popup blocker icon in your browser\'s address bar',
                  ),
                  _buildStep('2', 'Click it and select "Always allow popups"'),
                  _buildStep('3', 'Click "Try Again" below'),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.orange.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          color: Colors.orange.shade700,
                          size: 18,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Tip: The sign-in window may have opened behind this one. Check your other browser windows!',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(
                                  color: Colors.orange.shade900,
                                  height: 1.5,
                                  fontSize: 13,
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text(
                  'Try Again',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 18,
                  ),
                  backgroundColor: Colors.orange.shade600,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: _signInAndLoadDrive,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                text,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.orange[900],
                  height: 1.4,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDownloadingView() {
    final downloadedMB = totalBytes > 0
        ? (downloadedBytes / (1024 * 1024)).toStringAsFixed(1)
        : '0.0';
    final totalMB = totalBytes > 0
        ? (totalBytes / (1024 * 1024)).toStringAsFixed(1)
        : '0.0';
    final percentageText = totalBytes > 0
        ? (downloadProgress * 100).toStringAsFixed(1)
        : '0.0';

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: 1.0),
              duration: const Duration(seconds: 2),
              builder: (context, value, child) {
                return Container(
                  padding: const EdgeInsets.all(28),
                  decoration: BoxDecoration(
                    color: Colors.indigo.shade50,
                    shape: BoxShape.circle,
                  ),
                  child: Transform.rotate(
                    angle: value * 6.28,
                    child: Icon(
                      Icons.cloud_download_rounded,
                      size: 56,
                      color: Colors.indigo.shade700,
                    ),
                  ),
                );
              },
              onEnd: () {
                if (mounted && isDownloading) {
                  setState(() {});
                }
              },
            ),
            const SizedBox(height: 32),
            Text(
              'Downloading Your File',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.grey[900],
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'This may take a moment depending on file size',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            if (totalBytes > 0) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    downloadedMB,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.indigo.shade700,
                    ),
                  ),
                  Text(
                    ' / $totalMB MB',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
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
                      widthFactor: downloadProgress,
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
            const SizedBox(height: 12),
            Text(
              '$percentageText%',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 28),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade100),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Colors.blue.shade700,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Keep this page open while downloading',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.blue.shade900,
                        fontWeight: FontWeight.w500,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingView() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.indigo.shade50,
              shape: BoxShape.circle,
            ),
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 72,
                  height: 72,
                  child: CircularProgressIndicator(
                    strokeWidth: 4,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.indigo.shade600,
                    ),
                  ),
                ),
                Icon(
                  Icons.menu_book_rounded,
                  size: 36,
                  color: Colors.indigo.shade700,
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          Text(
            loadingMessage,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w700,
              color: Colors.grey[900],
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Please wait while we prepare your file',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildErrorView() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Text(
                error!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[700],
                  height: 1.6,
                ),
                textAlign: TextAlign.left,
              ),
            ),
            const SizedBox(height: 28),
            if (fileUrl != null && _isGoogleDriveUrl(fileUrl!)) ...[
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                  label: const Text(
                    'Try Again',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 18,
                    ),
                    backgroundColor: Colors.indigo,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  onPressed: _signInAndLoadDrive,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildReadyView() {
    // Auto-open reader if file is ready (no need for extra button click)
    if (fileBytes != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && fileBytes != null) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) =>
                  LambookReaderScreen(fileUrl: fileUrl!, bytes: fileBytes!),
            ),
          );
        }
      });
      // Show loading while transitioning
      return _buildLoadingView();
    }

    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.indigo.shade50,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 48,
                color: Colors.indigo.shade700,
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Sign in to View Your File',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.grey[900],
                letterSpacing: -0.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'We need your permission to access this file from Google Drive',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey[600],
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      Icons.cloud_rounded,
                      size: 24,
                      color: Colors.indigo.shade600,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Google Drive File',
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                                fontSize: 12,
                              ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          fileUrl!.length > 50
                              ? '${fileUrl!.substring(0, 50)}...'
                              : fileUrl!,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(color: Colors.grey[700], fontSize: 12),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.login_rounded, size: 22),
                label: const Text(
                  'Sign in with Google',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                onPressed: _signInAndLoadDrive,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.lock_outline_rounded,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 6),
                Text(
                  'Read-only access • Your data is secure',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.indigo.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SizedBox(
                      height: 24,
                      width: 24,
                      child: Image.asset(
                        'assets/logo/lamlayers_logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Lamlayers',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[900],
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Builder(
                    builder: (_) {
                      if (isDownloading) return _buildDownloadingView();
                      if (showPopupBlockedWarning)
                        return _buildPopupBlockedWarning();
                      if (loading) return _buildLoadingView();
                      if (error != null) return _buildErrorView();
                      return _buildReadyView();
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
