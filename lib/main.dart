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
import 'home_screen.dart';

void main() {
  runApp(const MyApp());
}

// Minimal auth client that injects Google auth headers into requests
// and delegates to a real http.Client
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

// Router configuration
final GoRouter _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(path: '/', builder: (context, state) => const ViewerHomePage()),
    GoRoute(path: '/home', builder: (context, state) => const HomeScreen()),
    GoRoute(
      path: '/viewer',
      builder: (context, state) => const ViewerHomePage(),
    ),
    GoRoute(
      path: '/terms',
      builder: (context, state) => const TermsOfServiceScreen(),
    ),
    GoRoute(
      path: '/privacy',
      builder: (context, state) => const PrivacyPolicyScreen(),
    ),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp.router(
          title: 'Lambook View - Digital Scrapbook Viewer',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
          ),
          routerConfig: _router,
        );
      },
    );
  }
}

class ViewerHomePage extends StatefulWidget {
  const ViewerHomePage({super.key});

  @override
  State<ViewerHomePage> createState() => _ViewerHomePageState();
}

class _ViewerHomePageState extends State<ViewerHomePage> {
  String? fileUrl;
  Uint8List? fileBytes;
  String? error;
  bool loading = true;
  bool _openedReader = false;

  // TODO: replace with your real Web OAuth client id from Google Cloud Console
  static const String _webClientId =
      '95582377829-f64u9joo19djd769u06mp3719hh2vg1l.apps.googleusercontent.com';

  @override
  void initState() {
    super.initState();
    _loadFromQuery();
  }

  Future<void> _loadFromQuery() async {
    try {
      final uri = Uri.base;
      final param = uri.queryParameters['file'];
      if (param == null || param.isEmpty) {
        setState(() {
          loading = false;
          error =
              'Missing ?file= query parameter\n\nPlease provide a file URL or Google Drive link in the URL parameters.';
        });
        return;
      }
      setState(() {
        fileUrl = param;
      });
      if (_isGoogleDriveUrl(param)) {
        // Defer Drive auth/download until user taps the sign-in button.
        setState(() {
          loading = false;
        });
      } else {
        final response = await http.get(Uri.parse(param));
        if (response.statusCode != 200) {
          setState(() {
            loading = false;
            error = 'Failed to download file (status ${response.statusCode})';
          });
          return;
        }
        final bytes = response.bodyBytes;
        if (bytes.isEmpty) {
          setState(() {
            loading = false;
            error = 'Downloaded file is empty. Please check the file URL.';
          });
          return;
        }

        setState(() {
          fileBytes = bytes;
          loading = false;
        });
      }

      if (mounted && !_openedReader && fileUrl != null && fileBytes != null) {
        _openedReader = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  LambookReaderScreen(fileUrl: fileUrl!, bytes: fileBytes!),
            ),
          );
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
        error = 'Error: $e';
      });
    }
  }

  // Google Sign-In instance used for web OAuth (must be user-initiated)
  final GoogleSignIn _gsignIn = GoogleSignIn(
    clientId: _webClientId,
    scopes: <String>['https://www.googleapis.com/auth/drive.readonly'],
  );

  Future<void> _retryWithFreshAuth() async {
    // Sign out first to ensure fresh authentication
    await _gsignIn.signOut();
    await _signInAndLoadDrive();
  }

  Future<void> _uploadFileDirectly() async {
    try {
      // This is a placeholder for file upload functionality
      // In a real implementation, you'd use a proper file picker package like file_picker
      setState(() {
        loading = true;
        error =
            'File upload feature requires a proper file picker implementation.\n\nFor now, please use the Google Drive option or contact support for assistance.';
        loading = false;
      });
    } catch (e) {
      setState(() {
        loading = false;
        error = 'File upload failed: $e';
      });
    }
  }

  Future<void> _signInAndLoadDrive() async {
    final url = fileUrl;
    if (url == null) return;
    setState(() {
      loading = true;
      error = null;
    });

    try {
      // Try silent sign-in first
      await _gsignIn.signInSilently(suppressErrors: true);

      if (_gsignIn.currentUser == null) {
        // User needs to sign in manually
        final user = await _gsignIn.signIn();
        if (user == null) {
          // User cancelled the sign-in process
          setState(() {
            loading = false;
            error = 'Sign-in was cancelled. Please try again.';
          });
          return;
        }
      }

      // Ensure the Drive scope is granted
      const scopes = <String>['https://www.googleapis.com/auth/drive.readonly'];
      final hasScope = await _gsignIn.canAccessScopes(scopes);
      if (!hasScope) {
        final granted = await _gsignIn.requestScopes(scopes);
        if (!granted) {
          setState(() {
            loading = false;
            error =
                'Drive access permission was denied. Please grant permission to access your Google Drive files.';
          });
          return;
        }
      }

      // Get authentication headers
      final headers = await _gsignIn.currentUser!.authHeaders;
      final api = drive.DriveApi(_GoogleAuthClient(headers));

      // Extract file ID and download
      final id = _extractDriveFileId(url);
      final media =
          await api.files.get(
                id,
                downloadOptions: drive.DownloadOptions.fullMedia,
              )
              as drive.Media;

      final bytes = await media.stream.fold<List<int>>(<int>[], (a, b) {
        a.addAll(b);
        return a;
      });

      if (bytes.isEmpty) {
        setState(() {
          loading = false;
          error =
              'Downloaded file from Google Drive is empty. Please check if the file exists and is accessible.';
        });
        return;
      }

      setState(() {
        fileBytes = Uint8List.fromList(bytes);
        loading = false;
        error = null;
      });

      // Open the reader if successful
      if (mounted && !_openedReader && fileUrl != null && fileBytes != null) {
        _openedReader = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) =>
                  LambookReaderScreen(fileUrl: fileUrl!, bytes: fileBytes!),
            ),
          );
        });
      }
    } catch (e) {
      String errorMessage;

      // Handle specific error cases
      if (e.toString().contains('popup_closed')) {
        errorMessage =
            'Sign-in popup was closed. Please try again and complete the sign-in process.\n\nTip: Make sure popup blockers are disabled for this site.';
      } else if (e.toString().contains('access_denied')) {
        errorMessage =
            'Access denied. Please grant permission to access Google Drive files.';
      } else if (e.toString().contains('network')) {
        errorMessage =
            'Network error. Please check your internet connection and try again.';
      } else if (e.toString().contains('not_found')) {
        errorMessage =
            'File not found. Please check if the Google Drive file exists and is accessible.';
      } else {
        errorMessage = 'Failed to load file from Google Drive: ${e.toString()}';
      }

      setState(() {
        loading = false;
        error = errorMessage;
      });
    }
  }

  bool _isGoogleDriveUrl(String input) {
    final u = Uri.tryParse(input);
    if (u == null) return false;
    final host = u.host.toLowerCase();
    if (host.contains('drive.google.com') || host.contains('docs.google.com')) {
      return true;
    }
    return false;
  }

  String _extractDriveFileId(String input) {
    final uri = Uri.tryParse(input);
    if (uri == null) return input;
    final idParam = uri.queryParameters['id'];
    if (idParam != null && idParam.isNotEmpty) return idParam;
    final m = RegExp(r'/file/d/([^/]+)/').firstMatch(uri.path);
    if (m != null) return m.group(1)!;
    return input;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Builder(
                    builder: (_) {
                      if (loading) {
                        return const CircularProgressIndicator();
                      }
                      if (error != null) {
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 48,
                              color: Colors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              error!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 16,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            if (fileUrl != null && _isGoogleDriveUrl(fileUrl!))
                              Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.refresh),
                                        label: const Text('Try Again'),
                                        onPressed: _signInAndLoadDrive,
                                      ),
                                      const SizedBox(width: 8),
                                      ElevatedButton.icon(
                                        icon: const Icon(Icons.login),
                                        label: const Text('Fresh Sign-In'),
                                        onPressed: _retryWithFreshAuth,
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Having trouble with Google Drive?',
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  OutlinedButton.icon(
                                    icon: const Icon(Icons.upload_file),
                                    label: const Text('Upload File Instead'),
                                    onPressed: _uploadFileDirectly,
                                  ),
                                ],
                              ),
                          ],
                        );
                      }
                      return Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.menu_book_rounded,
                            size: 64,
                            color: Colors.indigo,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Loaded scrapbook from:',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            fileUrl ?? '',
                            style: Theme.of(context).textTheme.bodyMedium,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 24),
                          if (fileUrl != null &&
                              _isGoogleDriveUrl(fileUrl!) &&
                              fileBytes == null)
                            ElevatedButton.icon(
                              icon: const Icon(Icons.login),
                              label: const Text('Sign in with Google to load'),
                              onPressed: _signInAndLoadDrive,
                            ),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.open_in_new),
                            label: const Text('Open in Lambook Reader'),
                            onPressed: (fileUrl != null && fileBytes != null)
                                ? () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => LambookReaderScreen(
                                          fileUrl: fileUrl!,
                                          bytes: fileBytes!,
                                        ),
                                      ),
                                    );
                                  }
                                : null,
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
          // Footer with Privacy and Terms links
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  TextButton(
                    onPressed: () {
                      context.go('/privacy');
                    },
                    child: const Text('Privacy Policy'),
                  ),
                  const Text('•'),
                  TextButton(
                    onPressed: () {
                      context.go('/terms');
                    },
                    child: const Text('Terms of Service'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
