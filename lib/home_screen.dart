import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: _getMaxWidth(context)),
                child: Padding(
                  padding: EdgeInsets.all(_getResponsivePadding(context)),
                  child: Column(
                    children: [
                      _buildHeroSection(context),
                      SizedBox(height: _getResponsiveSpacing(context) * 2),
                      _buildFeaturesSection(context),
                      SizedBox(height: _getResponsiveSpacing(context) * 2),
                      _buildHowItWorksSection(context),
                      SizedBox(height: _getResponsiveSpacing(context) * 2),
                      _buildGoogleAuthInfoSection(context),
                      SizedBox(height: _getResponsiveSpacing(context) * 2),
                      _buildCTASection(context),
                      SizedBox(height: _getResponsiveSpacing(context) * 2),
                      _buildFooter(context),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Responsive helpers
  bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
  bool _isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

  double _getMaxWidth(BuildContext context) {
    if (_isDesktop(context)) return 1400;
    if (_isTablet(context)) return 900;
    return double.infinity;
  }

  double _getResponsivePadding(BuildContext context) {
    if (_isDesktop(context)) return 40;
    if (_isTablet(context)) return 24;
    return 16;
  }

  double _getResponsiveSpacing(BuildContext context) {
    if (_isDesktop(context)) return 32;
    if (_isTablet(context)) return 24;
    return 16;
  }

  double _getResponsiveFontSize(
    BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (_isDesktop(context)) return desktop;
    if (_isTablet(context)) return tablet;
    return mobile;
  }

  int _getGridColumns(BuildContext context) {
    if (_isDesktop(context)) return 3;
    if (_isTablet(context)) return 2;
    return 1;
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverAppBar(
      floating: true,
      snap: true,
      backgroundColor: Colors.white,
      elevation: 0,
      shadowColor: Colors.black.withOpacity(0.1),
      toolbarHeight: _isMobile(context) ? 70 : 80,
      flexibleSpace: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: _getMaxWidth(context)),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: _getResponsivePadding(context),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(
                      'assets/logo/lamlayers_logo.png',
                      width: _getResponsiveFontSize(
                        context,
                        mobile: 40,
                        tablet: 48,
                        desktop: 56,
                      ),
                      height: _getResponsiveFontSize(
                        context,
                        mobile: 40,
                        tablet: 48,
                        desktop: 56,
                      ),
                      fit: BoxFit.contain,
                    ),
                    SizedBox(width: 12),
                    Text(
                      'Lamlayers',
                      style: TextStyle(
                        fontSize: _getResponsiveFontSize(
                          context,
                          mobile: 18,
                          tablet: 22,
                          desktop: 26,
                        ),
                        fontWeight: FontWeight.w900,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.5,
                      ),
                    ),
                  ],
                ),
                if (!_isMobile(context))
                  Row(
                    children: [
                      _buildNavButton(
                        context,
                        'Privacy Policy',
                        () => context.go('/privacy'),
                      ),
                      SizedBox(width: 8),
                      _buildNavButton(
                        context,
                        'Terms of Service',
                        () => context.go('/terms'),
                      ),
                    ],
                  )
                else
                  PopupMenuButton<String>(
                    icon: const Icon(
                      Icons.menu_rounded,
                      color: Color(0xFF0F172A),
                    ),
                    onSelected: (value) {
                      if (value == 'privacy') context.go('/privacy');
                      if (value == 'terms') context.go('/terms');
                    },
                    itemBuilder: (context) => [
                      const PopupMenuItem(
                        value: 'privacy',
                        child: Text('Privacy Policy'),
                      ),
                      const PopupMenuItem(
                        value: 'terms',
                        child: Text('Terms of Service'),
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

  Widget _buildNavButton(
    BuildContext context,
    String text,
    VoidCallback onPressed,
  ) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        foregroundColor: const Color(0xFF475569),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: _getResponsiveFontSize(
            context,
            mobile: 14,
            tablet: 15,
            desktop: 16,
          ),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_getResponsivePadding(context) * 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF8B5CF6), Color(0xFFEC4899), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withOpacity(0.4),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(_getResponsivePadding(context)),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(0.5),
                width: 3,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Image.asset(
              'assets/logo/lamlayers_logo.png',
              width: _getResponsiveFontSize(
                context,
                mobile: 80,
                tablet: 100,
                desktop: 120,
              ),
              height: _getResponsiveFontSize(
                context,
                mobile: 80,
                tablet: 100,
                desktop: 120,
              ),
              fit: BoxFit.contain,
            ),
          ),
          SizedBox(height: _getResponsiveSpacing(context)),
          Text(
            'Lamlayers Digital Viewer',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 32,
                tablet: 42,
                desktop: 56,
              ),
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -1,
              height: 1.1,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'View your Lamlayers scrapbooks with stunning page-turn animations',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 16,
                tablet: 18,
                desktop: 20,
              ),
              color: Colors.white.withOpacity(0.95),
              height: 1.6,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: _getResponsiveSpacing(context) * 1.5),
          ElevatedButton.icon(
            onPressed: () => _showUsageDialog(context),
            icon: const Icon(Icons.rocket_launch_rounded),
            label: const Text('Get Started'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: _getResponsivePadding(context) * 1.5,
                vertical: _getResponsivePadding(context),
              ),
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF8B5CF6),
              textStyle: TextStyle(
                fontSize: _getResponsiveFontSize(
                  context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
              shadowColor: Colors.black.withOpacity(0.3),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturesSection(BuildContext context) {
    final features = [
      {
        'icon': Icons.auto_awesome_rounded,
        'title': 'Page Turn Animation',
        'description':
            'Realistic page-turning experience that feels like reading a real book',
        'gradient': [const Color(0xFF8B5CF6), const Color(0xFF6366F1)],
      },
      {
        'icon': Icons.cloud_sync_rounded,
        'title': 'Google Drive Integration',
        'description':
            'Seamlessly fetch and view .lamlayers files directly from Google Drive',
        'gradient': [const Color(0xFFEC4899), const Color(0xFFF43F5E)],
      },
      {
        'icon': Icons.devices_rounded,
        'title': 'Cross-Platform',
        'description': 'Works perfectly on desktop, tablet, and mobile devices',
        'gradient': [const Color(0xFF06B6D4), const Color(0xFF0EA5E9)],
      },
      {
        'icon': Icons.touch_app_rounded,
        'title': 'Interactive Reading',
        'description': 'Swipe, tap, and navigate pages with smooth animations',
        'gradient': [const Color(0xFFF59E0B), const Color(0xFFF97316)],
      },
      {
        'icon': Icons.hd_rounded,
        'title': 'High Quality Display',
        'description':
            'Crystal-clear rendering of your scrapbook pages and images',
        'gradient': [const Color(0xFF10B981), const Color(0xFF14B8A6)],
      },
      {
        'icon': Icons.security_rounded,
        'title': 'Secure Access',
        'description':
            'Your Google credentials are never stored - uses secure OAuth2',
        'gradient': [const Color(0xFFEF4444), const Color(0xFFDC2626)],
      },
    ];

    return Column(
      children: [
        Text(
          'Powerful Features',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: _getResponsiveFontSize(
              context,
              mobile: 32,
              tablet: 40,
              desktop: 48,
            ),
            fontWeight: FontWeight.w900,
            color: const Color(0xFF0F172A),
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: 12),
        Text(
          'Everything you need for the perfect digital reading experience',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: _getResponsiveFontSize(
              context,
              mobile: 14,
              tablet: 16,
              desktop: 18,
            ),
            color: const Color(0xFF475569),
            height: 1.5,
          ),
        ),
        SizedBox(height: _getResponsiveSpacing(context) * 2),
        LayoutBuilder(
          builder: (context, constraints) {
            final columns = _getGridColumns(context);
            final spacing = _getResponsiveSpacing(context);

            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: features.map((feature) {
                final width = columns == 1
                    ? constraints.maxWidth
                    : (constraints.maxWidth - (spacing * (columns - 1))) /
                          columns;

                return SizedBox(
                  width: width,
                  child: _buildFeatureCard(context, feature),
                );
              }).toList(),
            );
          },
        ),
      ],
    );
  }

  Widget _buildFeatureCard(BuildContext context, Map<String, dynamic> feature) {
    return Container(
      padding: EdgeInsets.all(_getResponsivePadding(context) * 1.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(_getResponsivePadding(context)),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: feature['gradient'] as List<Color>,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: (feature['gradient'] as List<Color>)[0].withOpacity(
                    0.3,
                  ),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Icon(
              feature['icon'] as IconData,
              size: _getResponsiveFontSize(
                context,
                mobile: 36,
                tablet: 40,
                desktop: 48,
              ),
              color: Colors.white,
            ),
          ),
          SizedBox(height: _getResponsiveSpacing(context)),
          Text(
            feature['title'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 18,
                tablet: 20,
                desktop: 22,
              ),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.3,
            ),
          ),
          SizedBox(height: 8),
          Text(
            feature['description'] as String,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 14,
                tablet: 15,
                desktop: 16,
              ),
              color: const Color(0xFF475569),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHowItWorksSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_getResponsivePadding(context) * 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF8B5CF6).withOpacity(0.1),
            const Color(0xFFEC4899).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.2),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Text(
            'How It Works',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 32,
                tablet: 40,
                desktop: 48,
              ),
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
              letterSpacing: -1,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'View your lamlayers in three simple steps',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 14,
                tablet: 16,
                desktop: 18,
              ),
              color: const Color(0xFF475569),
            ),
          ),
          SizedBox(height: _getResponsiveSpacing(context) * 2),
          _buildStep(
            context,
            '1',
            'Get Your File Link',
            'Upload your .lamlayers file to Google Drive and get the shareable link',
            const Color(0xFF8B5CF6),
          ),
          SizedBox(height: _getResponsiveSpacing(context) * 1.5),
          _buildStep(
            context,
            '2',
            'Add File ID to URL',
            'Extract the file ID from your Drive link and add it as a query parameter',
            const Color(0xFFEC4899),
          ),
          SizedBox(height: _getResponsiveSpacing(context) * 1.5),
          _buildStep(
            context,
            '3',
            'Sign In & Read',
            'Authenticate with Google to access the file and enjoy your lamlayers',
            const Color(0xFFF59E0B),
          ),
        ],
      ),
    );
  }

  Widget _buildStep(
    BuildContext context,
    String number,
    String title,
    String description,
    Color color,
  ) {
    return Container(
      padding: EdgeInsets.all(_getResponsivePadding(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: _isMobile(context) ? 56 : 70,
            height: _isMobile(context) ? 56 : 70,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(
                    context,
                    mobile: 28,
                    tablet: 32,
                    desktop: 36,
                  ),
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          SizedBox(width: _getResponsiveSpacing(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(
                      context,
                      mobile: 18,
                      tablet: 20,
                      desktop: 22,
                    ),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(
                      context,
                      mobile: 14,
                      tablet: 15,
                      desktop: 16,
                    ),
                    color: const Color(0xFF475569),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoogleAuthInfoSection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_getResponsivePadding(context) * 2),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF4285F4).withOpacity(0.1),
            const Color(0xFFDB4437).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        border: Border.all(
          color: const Color(0xFF4285F4).withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF4285F4).withOpacity(0.2),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.shield_outlined,
              size: _getResponsiveFontSize(
                context,
                mobile: 48,
                tablet: 56,
                desktop: 64,
              ),
              color: const Color(0xFF4285F4),
            ),
          ),
          SizedBox(height: _getResponsiveSpacing(context)),
          Text(
            'About Google Sign-In',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 28,
                tablet: 36,
                desktop: 42,
              ),
              fontWeight: FontWeight.w900,
              color: const Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 16),
          Container(
            padding: EdgeInsets.all(_getResponsivePadding(context) * 1.5),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFFF59E0B).withOpacity(0.3),
                width: 2,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: const Color(0xFFF59E0B),
                  size: 28,
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'You may see an "unverified app" warning during Google sign-in. This is normal and safe.',
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(
                        context,
                        mobile: 14,
                        tablet: 15,
                        desktop: 16,
                      ),
                      color: const Color(0xFF92400E),
                      fontWeight: FontWeight.w600,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: _getResponsiveSpacing(context) * 1.5),
          _buildAuthInfoCard(
            context,
            'Why the Warning Appears',
            'This viewer app is currently in development and pending Google verification. The warning is a standard security measure for apps not yet verified by Google.',
            Icons.warning_amber_rounded,
            const Color(0xFFF59E0B),
          ),
          SizedBox(height: _getResponsiveSpacing(context)),
          _buildAuthInfoCard(
            context,
            'Is It Safe to Continue?',
            'Yes! This app only requests read-only access to view your .lamlayers files from Google Drive. We never store your credentials or access any other data.',
            Icons.verified_user_rounded,
            const Color(0xFF10B981),
          ),
          SizedBox(height: _getResponsiveSpacing(context)),
          _buildAuthInfoCard(
            context,
            'What Permissions Are Requested',
            'The app only asks for:\n• View files you open with this app (drive.file scope)\n• Your email address for authentication\n\nNo write access, no access to other files.',
            Icons.security_rounded,
            const Color(0xFF4285F4),
          ),
          SizedBox(height: _getResponsiveSpacing(context)),
          _buildAuthInfoCard(
            context,
            'How to Proceed',
            'When you see the warning screen, click "Advanced" → "Go to Lamlayers Viewer (unsafe)" to continue. Your data remains completely safe.',
            Icons.touch_app_rounded,
            const Color(0xFFEC4899),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthInfoCard(
    BuildContext context,
    String title,
    String description,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_getResponsivePadding(context) * 1.5),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(_getResponsivePadding(context) * 0.8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color, color.withOpacity(0.7)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: _getResponsiveFontSize(
                context,
                mobile: 28,
                tablet: 32,
                desktop: 36,
              ),
            ),
          ),
          SizedBox(width: _getResponsiveSpacing(context)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(
                      context,
                      mobile: 18,
                      tablet: 20,
                      desktop: 22,
                    ),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(
                      context,
                      mobile: 14,
                      tablet: 15,
                      desktop: 16,
                    ),
                    color: const Color(0xFF475569),
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCTASection(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_getResponsivePadding(context) * 2),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(_getResponsivePadding(context)),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8B5CF6).withOpacity(0.5),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Icon(
              Icons.rocket_launch_rounded,
              size: _getResponsiveFontSize(
                context,
                mobile: 48,
                tablet: 56,
                desktop: 64,
              ),
              color: Colors.white,
            ),
          ),
          SizedBox(height: _getResponsiveSpacing(context)),
          Text(
            'Ready to Get Started?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 28,
                tablet: 36,
                desktop: 42,
              ),
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 12),
          Text(
            'View your digital scrapbooks with stunning animations',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 16,
                tablet: 18,
                desktop: 20,
              ),
              color: Colors.white.withOpacity(0.8),
              height: 1.5,
            ),
          ),
          SizedBox(height: _getResponsiveSpacing(context) * 1.5),
          ElevatedButton.icon(
            onPressed: () => _showUsageDialog(context),
            icon: const Icon(Icons.play_circle_filled_rounded),
            label: const Text('Learn How to Use'),
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(
                horizontal: _getResponsivePadding(context) * 1.5,
                vertical: _getResponsivePadding(context),
              ),
              backgroundColor: Colors.white,
              foregroundColor: const Color(0xFF0F172A),
              textStyle: TextStyle(
                fontSize: _getResponsiveFontSize(
                  context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
                fontWeight: FontWeight.w700,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 8,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        Divider(color: Colors.grey.shade300, thickness: 2),
        SizedBox(height: _getResponsiveSpacing(context)),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.menu_book_rounded,
                size: 20,
                color: Colors.white,
              ),
            ),
            SizedBox(width: 12),
            Text(
              'Lamlayers Digital Viewer',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(
                  context,
                  mobile: 16,
                  tablet: 18,
                  desktop: 20,
                ),
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0F172A),
              ),
            ),
          ],
        ),
        SizedBox(height: _getResponsiveSpacing(context)),
        // Privacy and Terms Links
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              onPressed: () => context.go('/privacy'),
              icon: const Icon(Icons.privacy_tip_outlined, size: 18),
              label: const Text('Privacy Policy'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF8B5CF6),
                textStyle: TextStyle(
                  fontSize: _getResponsiveFontSize(
                    context,
                    mobile: 14,
                    tablet: 15,
                    desktop: 16,
                  ),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            Text(
              ' • ',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
                color: const Color(0xFF94A3B8),
              ),
            ),
            TextButton.icon(
              onPressed: () => context.go('/terms'),
              icon: const Icon(Icons.verified_user_outlined, size: 18),
              label: const Text('Terms of Service'),
              style: TextButton.styleFrom(
                foregroundColor: const Color(0xFF8B5CF6),
                textStyle: TextStyle(
                  fontSize: _getResponsiveFontSize(
                    context,
                    mobile: 14,
                    tablet: 15,
                    desktop: 16,
                  ),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8),
        Text(
          '© ${DateTime.now().year} Lamlayers. All rights reserved',
          style: TextStyle(
            fontSize: _getResponsiveFontSize(
              context,
              mobile: 14,
              tablet: 15,
              desktop: 16,
            ),
            color: const Color(0xFF475569),
          ),
        ),
        SizedBox(height: 4),
        Text(
          'Part of the Lamlayers ecosystem',
          style: TextStyle(
            fontSize: _getResponsiveFontSize(
              context,
              mobile: 12,
              tablet: 13,
              desktop: 14,
            ),
            color: const Color(0xFF94A3B8),
          ),
        ),
      ],
    );
  }

  void _showUsageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        contentPadding: EdgeInsets.zero,
        content: Container(
          width: _isMobile(context)
              ? MediaQuery.of(context).size.width * 0.9
              : 600,
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          padding: EdgeInsets.all(_getResponsivePadding(context) * 1.5),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFF8B5CF6).withOpacity(0.05),
                const Color(0xFFEC4899).withOpacity(0.05),
              ],
            ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF8B5CF6), Color(0xFFEC4899)],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.info_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
                SizedBox(height: 16),
                Text(
                  'How to Use Lamlayers Viewer',
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(
                      context,
                      mobile: 22,
                      tablet: 24,
                      desktop: 26,
                    ),
                    fontWeight: FontWeight.w900,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                SizedBox(height: 24),
                _buildDialogSection(
                  context,
                  'Step 1: Upload to Google Drive',
                  '1. Open the Lamlayers mobile app\n2. Create or open your lamlayers\n3. Tap "Share via Google Drive"\n4. Sign in with your Google account\n5. The .lamlayers file will be uploaded',
                ),
                SizedBox(height: 20),
                _buildDialogSection(
                  context,
                  'Step 2: Get the File ID',
                  'After uploading, you\'ll get a link like:\nhttps://drive.google.com/file/d/1ABC...XYZ/view\n\nThe file ID is the part between /d/ and /view:\n1ABC...XYZ',
                ),
                SizedBox(height: 20),
                _buildDialogSection(
                  context,
                  'Step 3: Create Viewer URL',
                  'Add the file ID to this viewer URL:\n\nhttps://lamlayers-view.web.app/?fileId=YOUR_FILE_ID',
                ),
                SizedBox(height: 20),
                _buildDialogSection(
                  context,
                  'Step 4: View Your Lamlayers',
                  '1. Open the URL in your browser\n2. Sign in with Google (you may see an "unverified app" warning - click Advanced → Continue)\n3. Enjoy your interactive lamlayers!',
                ),
                SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFDCFCE7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF10B981).withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.tips_and_updates_rounded,
                        color: const Color(0xFF059669),
                        size: 24,
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Tip: Save the viewer URL with your file ID to easily access your lamlayers anytime!',
                          style: TextStyle(
                            fontSize: _getResponsiveFontSize(
                              context,
                              mobile: 13,
                              tablet: 14,
                              desktop: 15,
                            ),
                            color: const Color(0xFF065F46),
                            fontWeight: FontWeight.w600,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                    backgroundColor: const Color(0xFF8B5CF6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Got it!',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDialogSection(
    BuildContext context,
    String title,
    String content,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: _getResponsiveFontSize(
              context,
              mobile: 16,
              tablet: 17,
              desktop: 18,
            ),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
          ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.2)),
          ),
          child: SelectableText(
            content,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 13,
                tablet: 14,
                desktop: 15,
              ),
              color: const Color(0xFF475569),
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }
}
