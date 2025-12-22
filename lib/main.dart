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
  
  // State variables for UI
  String? error;
  String? errorTitle;
  bool loading = true;
  String loadingMessage = 'Preparing...';
  String? loadingSubMessage;
  
  // Specific error states
  bool showPopupBlockedWarning = false;
  bool showTroubleshooting = false;
  
  double downloadProgress = 0.0;
  int downloadedBytes = 0;
  int totalBytes = 0;
  bool isDownloading = false;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  static const String _webClientId =
      '95582377829-f64u9joo19djd769u06mp3719hh2vg1l.apps.googleusercontent.com';

  // UPDATED SCOPE: Restricted to files created or opened by this app
  final GoogleSignIn _gsignIn = GoogleSignIn(
    clientId: _webClientId,
    scopes: <String>['https://www.googleapis.com/auth/drive.file'],
    signInOption: SignInOption.standard,
  );

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: Duration.zero, // REMOVED DELAY: Instant appearance
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    
    // Slight delay to allow animations to start smoothly
    Future.delayed(const Duration(milliseconds: 100), _loadFromQuery);
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
        if (mounted) {
          setState(() {
            loading = false;
            errorTitle = 'No File Selected';
            error = 'Please open a file from our app to view it here.';
          });
        }
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
      if (mounted) {
        setState(() {
          loading = false;
          errorTitle = 'Something Went Wrong';
          error = 'Error: $e';
          isDownloading = false;
        });
      }
    }
  }

  Future<void> _attemptSilentSignIn() async {
    setState(() {
      loading = true;
      loadingMessage = 'Checking access...';
      loadingSubMessage = 'Verifying your account';
    });

    try {
      // Attempt silent sign-in
      final user = await _gsignIn.signInSilently(suppressErrors: true);

      if (user != null) {
        // We have a user, try to download. 
        // If this fails specifically with permission errors, we will fallback to sign-in.
        await _downloadFromDrive(silentMode: true);
      } else {
        if (mounted) {
          setState(() {
            loading = false;
            loadingMessage = 'Sign In Required';
            loadingSubMessage = null;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          loading = false;
          // Don't show error, just show sign-in button
        });
      }
    }
  }

  Future<void> _downloadDirectUrl(String url) async {
    int retryCount = 0;
    const maxRetries = 1;

    while (true) {
      try {
        setState(() {
          isDownloading = true;
          downloadProgress = 0.0;
          downloadedBytes = 0;
          totalBytes = 0;
          loadingMessage = retryCount > 0 ? 'Retrying Connection...' : 'Connecting...';
          loadingSubMessage = 'Getting file from server';
        });

        final request = http.Request('GET', Uri.parse(url));
        final response = await request.send();

        if (response.statusCode != 200) {
          throw Exception('Server returned status ${response.statusCode}');
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
          throw Exception('File is empty');
        }

        if (mounted) {
          setState(() {
            fileBytes = Uint8List.fromList(chunks);
            loading = false;
            isDownloading = false;
            downloadProgress = 1.0;
          });
        }

        _openReaderIfReady();
        return; // Success
      } catch (e) {
        if (retryCount < maxRetries) {
          retryCount++;
          await Future.delayed(const Duration(seconds: 1));
          continue;
        }

        if (mounted) {
          setState(() {
            loading = false;
            isDownloading = false;
            errorTitle = 'Download Failed';
            error = 'We couldn\'t download the file. Please check your internet connection.';
            showTroubleshooting = true;
          });
        }
        return;
      }
    }
  }

  void _openReaderIfReady() {
    if (mounted && fileUrl != null && fileBytes != null) {
      if (fileBytes!.isEmpty || fileBytes!.length < 100) {
        setState(() {
          loading = false;
          errorTitle = 'Invalid File';
          error = 'The downloaded file appears to be corrupted or empty.';
        });
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
           Navigator.of(context).push(
            MaterialPageRoute(
               builder: (_) =>
                  LambookReaderScreen(fileUrl: fileUrl!, bytes: fileBytes!),
            ),
          );
        }
      });
    }
  }

  Future<void> _signInAndLoadDrive() async {
    final url = fileUrl;
    if (url == null) return;

    setState(() {
      loading = true;
      error = null;
      errorTitle = null;
      showPopupBlockedWarning = false;
      loadingMessage = 'Signing In...';
      loadingSubMessage = 'Please confirm in the popup window';
    });

    try {
      final user = await _gsignIn.signIn();

      if (user == null) {
        if (mounted) {
          setState(() {
            loading = false;
            loadingMessage = 'Sign-in cancelled';
            showPopupBlockedWarning = true; 
          });
        }
        return;
      }

      // Check "drive.file" scope
      final hasScope = await _gsignIn.canAccessScopes(
          ['https://www.googleapis.com/auth/drive.file']);

      if (!hasScope) {
        setState(() => loadingMessage = 'Requesting Permission...');
        final granted = await _gsignIn.requestScopes(
            ['https://www.googleapis.com/auth/drive.file']);

        if (!granted) {
          if (mounted) {
            setState(() {
              loading = false;
              errorTitle = 'Permission Needed';
              error = 'We need permission to open this file.';
            });
          }
          return;
        }
      }

      await _downloadFromDrive(silentMode: false);
    } catch (e) {
      print('Sign-in error: $e');
      
      String title = 'Sign In Failed';
      String msg = 'We couldn\'t verify your account.';

      if (e.toString().contains('popup_closed_by_user')) {
        if (mounted) setState(() => loading = false);
        return;
      } else if (e.toString().contains('popup_blocked_by_browser')) {
        if (mounted) {
           setState(() {
            loading = false;
            showPopupBlockedWarning = true;
          });
        }
        return;
      } else if (e.toString().contains('access_denied')) {
        title = 'Access Denied';
        msg = 'You denied the permission required to view this file.';
      }

      if (mounted) {
        setState(() {
          loading = false;
          errorTitle = title;
          error = msg;
          showTroubleshooting = true;
        });
      }
    }
  }

  Future<void> _downloadFromDrive({required bool silentMode}) async {
    final url = fileUrl;
    if (url == null) return;
    
    int retryCount = 0;
    const maxRetries = 1;

    while (true) {
      try {
        setState(() {
          // Only show 'Retrying' if it's not the first attempt
          if (retryCount > 0) {
             loadingMessage = 'Retrying...';
             loadingSubMessage = 'Connection was interrupted';
          } else {
             loadingMessage = 'Opening File...';
             loadingSubMessage = 'Securely accessing your file';
          }
        });

        // Ensure we have a user
        if (_gsignIn.currentUser == null) {
           throw Exception('permission_or_missing');
        }

        final headers = await _gsignIn.currentUser!.authHeaders;
        final api = drive.DriveApi(_GoogleAuthClient(headers));

        final id = _extractDriveFileId(url);

        // Metadata check
        drive.File fileMetadata;
        try {
          fileMetadata =
              await api.files.get(id, $fields: 'id,name,size,mimeType')
                  as drive.File;
        } catch (e) {
          print('Metadata error: $e');
          // This is key: if we fail here, it usually means we don't have permission 
          // OR the token is stale.
          if (e.toString().contains('404') || e.toString().contains('403')) {
               throw Exception('permission_or_missing');
          }
          rethrow;
        }

        final fileSize = int.tryParse(fileMetadata.size ?? '0') ?? 0;
        if (fileSize > 500 * 1024 * 1024) {
          throw Exception('File too large (>500MB)');
        }

        setState(() {
          totalBytes = fileSize;
          isDownloading = true;
          downloadProgress = 0.0;
          downloadedBytes = 0;
          loadingMessage = 'Downloading...';
          loadingSubMessage = '0% complete';
        });

        // Download
        final media = await api.files.get(
              id,
              downloadOptions: drive.DownloadOptions.fullMedia,
            ) as drive.Media;

        final List<List<int>> chunksList = [];
        int totalDownloaded = 0;
        int lastUpdate = 0;

        await for (var chunk in media.stream) {
          if (!mounted) return;
          chunksList.add(chunk);
          totalDownloaded += chunk.length;
          downloadedBytes = totalDownloaded;

          final now = DateTime.now().millisecondsSinceEpoch;
          if (now - lastUpdate > 200) {
            lastUpdate = now;
            setState(() {
              if (totalBytes > 0) {
                downloadProgress = downloadedBytes / totalBytes;
              }
              loadingSubMessage =
                  '${(downloadProgress * 100).toStringAsFixed(0)}% complete';
            });
          }
        }

        if (chunksList.isEmpty) throw Exception('empty_download');

        setState(() => loadingMessage = 'Processing...');
        
        final totalSize = chunksList.fold<int>(0, (p, c) => p + c.length);
        final fileData = Uint8List(totalSize);
        int offset = 0;
        for (var chunk in chunksList) {
          fileData.setRange(offset, offset + chunk.length, chunk);
          offset += chunk.length;
        }

        if (mounted) {
          setState(() {
            fileBytes = fileData;
            loading = false;
            isDownloading = false;
            downloadProgress = 1.0;
          });
        }

        _openReaderIfReady();
        return; // Success!

      } catch (e) {
        print('Drive download error: $e');

        // CRITICAL LOGIC: If we are in silent mode (initial load), ANY major error 
        // should probably just fail over to the explicit Sign In screen.
        // Also check specifically for permission/auth errors even if not silent.
        bool isAuthError = e.toString().contains('permission_or_missing') || 
                           e.toString().contains('401') || 
                           e.toString().contains('403') || 
                           e.toString().contains('404');

        if (isAuthError || silentMode) {
          // Force sign out to clear stale state
          await _gsignIn.disconnect(); 
          await _gsignIn.signOut();

          if (mounted) {
            setState(() {
               // Go back to the sign-in screen
               isDownloading = false;
               loading = false;
               // DO NOT show error title, just show the sign in UI with a polite message
               errorTitle = null;
               error = null;
            });
          }
          return; 
        }

        // AUTO-RETRY LOGIC for network errors
        if (retryCount < maxRetries) {
           // We assume other errors might be network transient
           // Only retry if it's NOT a permission error (handled above)
           retryCount++;
           await Future.delayed(const Duration(seconds: 1));
           continue;
        }

        // Handle other errors (Max retries reached)
        String title = 'Something Went Wrong';
        String msg = 'We couldn\'t download the file. Please try again.';

        if (e.toString().contains('network')) {
          title = 'Connection Lost';
          msg = 'Please check your internet connection and try again.';
        }

        if (mounted) {
          setState(() {
            loading = false;
            isDownloading = false;
            errorTitle = title;
            error = msg;
            showTroubleshooting = true;
          });
        }
        return;
      }
    }
  }

  // Same helper methods
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

  // --- UI COMPONENTS ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50], // Slightly off-white for premium feel
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: _buildContent(),
                  ),
                ),
              ),
            ),
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFF6366F1).withOpacity(0.1), // Indigo tint
              borderRadius: BorderRadius.circular(12),
            ),
            child: Image.asset(
              'assets/logo/lamlayers_logo.png', // Assuming logo exists
              width: 24,
              height: 24,
              errorBuilder: (_,__,___) => const Icon(Icons.layers, color: Color(0xFF6366F1), size: 24),
            ),
          ),
          const SizedBox(width: 12),
          Text(
            'Lamlayers',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.grey[900],
              fontFamily: 'Inter', // Fallback to system if not avail
              letterSpacing: -0.5,
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildFooter() {
     return Padding(
       padding: const EdgeInsets.all(16.0),
       child: Text(
         'Secure Viewer • Powered by Google Drive',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[400],
            fontWeight: FontWeight.w500,
          ),
       ),
     );
  }

  Widget _buildContent() {
    if (isDownloading) return _buildDownloadingState();
    if (showPopupBlockedWarning) return _buildPopupWarning();
    if (loading) return _buildLoadingState();
    if (errorTitle != null || error != null) return _buildErrorState();
    
    return _buildSignInState();
  }

  Widget _buildSignInState() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                 BoxShadow(
                   color: Colors.black.withOpacity(0.05),
                   blurRadius: 20,
                   offset: const Offset(0, 10),
                 )
              ],
            ),
            child: const Icon(Icons.lock_open_rounded, size: 48, color: Color(0xFF6366F1)),
          ),
          const SizedBox(height: 32),
          Text(
            'See Your Lambook',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.grey[900],
              letterSpacing: -0.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            'Sign in to verify you have access to this file.',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          _buildGoogleSignInButton(),
          const SizedBox(height: 24),
          _buildInfoNote(),
        ],
      ),
    );
  }

  Widget _buildGoogleSignInButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _signInAndLoadDrive,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF6366F1), // Indigo
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          shadowColor: const Color(0xFF6366F1).withOpacity(0.3),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.login_rounded),
            SizedBox(width: 12),
            Text(
              'Sign In with Google',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoNote() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF), // Blue 50
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFDBEAFE)), // Blue 200
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.security_rounded, size: 20, color: Color(0xFF2563EB)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Your privacy is our priority. We only open files you choose.',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF1E40AF),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
     return Column(
       mainAxisSize: MainAxisSize.min,
       children: [
          SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 5,
              valueColor: AlwaysStoppedAnimation<Color>(const Color(0xFF6366F1)),
              backgroundColor: const Color(0xFFE0E7FF),
            ),
          ),
          const SizedBox(height: 32),
          Text(
            loadingMessage,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.grey[900],
            ),
            textAlign: TextAlign.center,
          ),
          if (loadingSubMessage != null) ...[
             const SizedBox(height: 8),
             Text(
               loadingSubMessage!,
               style: TextStyle(
                 fontSize: 15,
                 color: Colors.grey[500],
               ),
               textAlign: TextAlign.center,
             ),
          ]
       ],
     );
  }

  Widget _buildDownloadingState() {
     return Container(
       constraints: const BoxConstraints(maxWidth: 420),
       child: Column(
         mainAxisSize: MainAxisSize.min,
         children: [
           Stack(
             alignment: Alignment.center,
             children: [
               SizedBox(
                 width: 80,
                 height: 80,
                 child: CircularProgressIndicator(
                   value: totalBytes > 0 ? downloadProgress : null,
                   strokeWidth: 6,
                   valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF6366F1)),
                   backgroundColor: const Color(0xFFE0E7FF),
                 ),
               ),
               Icon(Icons.cloud_download_rounded, color: const Color(0xFF6366F1), size: 32),
             ],
           ),
           const SizedBox(height: 32),
           Text(
             'Downloading File',
             style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Colors.grey[900]),
           ),
           const SizedBox(height: 8),
           Text(
             loadingSubMessage ?? 'Please wait...',
             style: TextStyle(fontSize: 15, color: Colors.grey[500]),
           ),
           if (totalBytes > 0) ...[
             const SizedBox(height: 24),
             Container(
               padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
               decoration: BoxDecoration(
                 color: Colors.white,
                 borderRadius: BorderRadius.circular(50),
                 boxShadow: [
                   BoxShadow(
                     color: Colors.black.withOpacity(0.05),
                     blurRadius: 10,
                   )
                 ]
               ),
               child: Text(
                 '${(downloadedBytes / 1024 / 1024).toStringAsFixed(1)} MB / ${(totalBytes / 1024 / 1024).toStringAsFixed(1)} MB',
                 style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: Colors.grey[700]),
               ),
             ),
           ]
         ],
       ),
     );
  }

   Widget _buildErrorState() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2), // Red 50
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.error_outline_rounded, size: 48, color: Color(0xFFEF4444)),
          ),
          const SizedBox(height: 24),
          Text(
            errorTitle ?? 'Oops!',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.grey[900]),
             textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Text(
            error ?? 'Something went wrong.',
            style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                 if (fileUrl != null && _isGoogleDriveUrl(fileUrl!)) {
                    _signInAndLoadDrive();
                 } else {
                    _loadFromQuery();
                 }
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[900],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ),
          if (showTroubleshooting) ...[
            const SizedBox(height: 24),
            _buildTroubleshootingPanel(),
          ]
        ],
      ),
    );
  }

  Widget _buildPopupWarning() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.web_asset_off_rounded, size: 60, color: Colors.orange[400]),
          const SizedBox(height: 24),
          Text(
            'Pop-up Blocked',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.grey[900]),
          ),
          const SizedBox(height: 12),
          Text(
            'Your browser blocked the sign-in window. Use the "Open in..." menu to fix this.',
            style: TextStyle(fontSize: 16, color: Colors.grey[600], height: 1.5),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
           // Simplified instructions
          _buildInstructionStep(1, 'Tap the "Aa" or "..." menu button'),
          const SizedBox(height: 12),
           _buildInstructionStep(2, 'Select "Open in Chrome" or "Open in Browser"'),
           const SizedBox(height: 12),
          _buildInstructionStep(3, 'Try signing in again'),
          
          const SizedBox(height: 32),
          SizedBox(
             width: double.infinity,
             child: ElevatedButton(
               onPressed: _signInAndLoadDrive,
               style: ElevatedButton.styleFrom(
                 backgroundColor: Colors.orange[400],
                 foregroundColor: Colors.white,
                 padding: const EdgeInsets.symmetric(vertical: 16),
                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
               ),
               child: const Text('I\'ve Done This, Try Again'),
             ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructionStep(int num, String text) {
    return Row(
      children: [
        Container(
          width: 24, height: 24,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: Colors.orange[100], shape: BoxShape.circle),
          child: Text('$num', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[800])),
        ),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: TextStyle(fontSize: 15, color: Colors.grey[800])))
      ],
    );
  }

  Widget _buildTroubleshootingPanel() {
     return ExpansionTile(
       title: const Text('How to resolve this issue?', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
       collapsedBackgroundColor: Colors.white,
       backgroundColor: Colors.white,
       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
       childrenPadding: const EdgeInsets.all(16),
       children: [
         _buildTip('Files Missing?', 'Ask the person who sent the link to check if the file still exists.'),
         const SizedBox(height: 12),
         _buildTip('Not Loading?', 'Try opening this page in Chrome or Safari directly.'),
         const SizedBox(height: 12),
         _buildTip('Still Stuck?', 'Check your internet connection and try again.'),
       ],
     );
  }
  
  Widget _buildTip(String title, String desc) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF6366F1))),
        const SizedBox(height: 4),
        Text(desc, style: TextStyle(fontSize: 14, color: Colors.grey[700], height: 1.4)),
      ],
    );
  }
}
