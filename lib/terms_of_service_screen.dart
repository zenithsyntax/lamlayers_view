import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TermsOfServiceScreen extends StatelessWidget {
  const TermsOfServiceScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Terms of Service',
          style: TextStyle(
            fontSize: _getResponsiveFontSize(context, mobile: 20, tablet: 22, desktop: 24),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: _getResponsiveFontSize(context, mobile: 20, tablet: 22, desktop: 24),
          ),
          color: const Color(0xFF0F172A),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxWidth: _getMaxWidth(context),
          ),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(_getResponsivePadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Card
                _buildHeaderCard(context),
                SizedBox(height: _getResponsiveSpacing(context)),

                // Content Sections - Grid layout for tablet and desktop
                _buildResponsiveGrid(context),

                SizedBox(height: _getResponsiveSpacing(context) * 1.5),

                // Summary Card
                _buildSummaryCard(context),

                SizedBox(height: _getResponsiveSpacing(context) * 1.5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Responsive breakpoint helpers
  bool _isMobile(BuildContext context) => MediaQuery.of(context).size.width < 600;
  bool _isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }
  bool _isDesktop(BuildContext context) => MediaQuery.of(context).size.width >= 1024;

  double _getMaxWidth(BuildContext context) {
    if (_isDesktop(context)) return 1200;
    if (_isTablet(context)) return 900;
    return double.infinity;
  }

  double _getResponsivePadding(BuildContext context) {
    if (_isDesktop(context)) return 32;
    if (_isTablet(context)) return 24;
    return 16;
  }

  double _getResponsiveSpacing(BuildContext context) {
    if (_isDesktop(context)) return 32;
    if (_isTablet(context)) return 24;
    return 16;
  }

  double _getResponsiveFontSize(BuildContext context, {
    required double mobile,
    required double tablet,
    required double desktop,
  }) {
    if (_isDesktop(context)) return desktop;
    if (_isTablet(context)) return tablet;
    return mobile;
  }

  int _getGridColumns(BuildContext context) {
    if (_isDesktop(context)) return 2;
    if (_isTablet(context)) return 2;
    return 1;
  }

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_getResponsivePadding(context) * 1.5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEC4899), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEC4899).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(_getResponsivePadding(context)),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.verified_user_rounded,
              color: Colors.white,
              size: _getResponsiveFontSize(context, mobile: 48, tablet: 56, desktop: 64),
            ),
          ),
          SizedBox(height: _getResponsiveSpacing(context)),
          Text(
            'Terms of Service',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, mobile: 24, tablet: 28, desktop: 32),
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Last updated: October 16, 2025',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, mobile: 12, tablet: 13, desktop: 14),
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponsiveGrid(BuildContext context) {
    final sections = _getAllSections(context);
    final columns = _getGridColumns(context);

    if (columns == 1) {
      // Mobile: Single column
      return Column(
        children: sections.map((section) {
          return Padding(
            padding: EdgeInsets.only(bottom: _getResponsiveSpacing(context)),
            child: section,
          );
        }).toList(),
      );
    } else {
      // Tablet & Desktop: Two columns
      return LayoutBuilder(
        builder: (context, constraints) {
          final spacing = _getResponsiveSpacing(context);
          final columnWidth = (constraints.maxWidth - spacing) / 2;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: sections.map((section) {
              return SizedBox(
                width: columnWidth,
                child: section,
              );
            }).toList(),
          );
        },
      );
    }
  }

  List<Widget> _getAllSections(BuildContext context) {
    return [
      // Introduction
      _buildSection(
        context,
        icon: Icons.description_rounded,
        iconColor: const Color(0xFF8B5CF6),
        iconBgColor: const Color(0xFFF5F3FF),
        title: 'Introduction',
        content:
            'Welcome to Lamlayers! These Terms of Service ("Terms") govern your use of our application and services. By using Lamlayers, you agree to be bound by these Terms. Please read them carefully.',
      ),

      // Acceptance
      _buildSection(
        context,
        icon: Icons.check_circle_rounded,
        iconColor: const Color(0xFF10B981),
        iconBgColor: const Color(0xFFD1FAE5),
        title: 'Acceptance of Terms',
        content:
            'By downloading, installing, or using Lamlayers, you agree to these Terms. If you do not agree to these Terms, please do not use our application.',
      ),

      // User Responsibilities
      _buildSection(
        context,
        icon: Icons.person_rounded,
        iconColor: const Color(0xFF06B6D4),
        iconBgColor: const Color(0xFFCFFAFE),
        title: 'User Responsibilities',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBulletPoint(
              context,
              'You are responsible for maintaining the security of your device',
            ),
            _buildBulletPoint(
              context,
              'You must not use the app for any illegal or unauthorized purpose',
            ),
            _buildBulletPoint(
              context,
              'You must not attempt to reverse engineer or modify the app',
            ),
            _buildBulletPoint(
              context,
              'You are responsible for backing up your own data',
            ),
            _buildBulletPoint(
              context,
              'You must ensure your content complies with applicable laws',
            ),
          ],
        ),
      ),

      // Intellectual Property
      _buildSection(
        context,
        icon: Icons.copyright_rounded,
        iconColor: const Color(0xFFF59E0B),
        iconBgColor: const Color(0xFFFEF3C7),
        title: 'Intellectual Property',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Ownership Rights:',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
                color: const Color(0xFF475569),
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• All content you create belongs to you',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
                color: const Color(0xFF475569),
                height: 1.6,
              ),
            ),
            Text(
              '• Lamlayers retains all rights to the app, its design, and technology',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
                color: const Color(0xFF475569),
                height: 1.6,
              ),
            ),
            Text(
              '• You grant us permission to use anonymous usage data to improve the app',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
                color: const Color(0xFF475569),
                height: 1.6,
              ),
            ),
          ],
        ),
      ),

      // Privacy
      _buildSection(
        context,
        icon: Icons.privacy_tip_rounded,
        iconColor: const Color(0xFFEC4899),
        iconBgColor: const Color(0xFFFCE7F3),
        title: 'Privacy',
        content:
            'Your privacy is important to us. All data is stored locally on your device. We do not collect or transmit your personal information. Please review our Privacy Policy for more details.',
      ),

      // Limitations
      _buildSection(
        context,
        icon: Icons.warning_rounded,
        iconColor: const Color(0xFFEF4444),
        iconBgColor: const Color(0xFFFEE2E2),
        title: 'Limitations and Disclaimers',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBulletPoint(
              context,
              'Lamlayers is provided "as is" without warranties of any kind',
            ),
            _buildBulletPoint(
              context,
              'We are not liable for any data loss or corruption',
            ),
            _buildBulletPoint(
              context,
              'The app may be unavailable temporarily for maintenance',
            ),
            _buildBulletPoint(
              context,
              'We reserve the right to modify or discontinue features',
            ),
          ],
        ),
      ),

      // Prohibited Activities
      _buildSection(
        context,
        icon: Icons.block_rounded,
        iconColor: const Color(0xFFEF4444),
        iconBgColor: const Color(0xFFFEE2E2),
        title: 'Prohibited Activities',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBulletPoint(
              context,
              'Using the app to create or distribute harmful content',
            ),
            _buildBulletPoint(
              context,
              'Attempting to hack, damage, or interfere with the app',
            ),
            _buildBulletPoint(
              context,
              'Copying or distributing the app without authorization',
            ),
            _buildBulletPoint(
              context,
              'Removing or circumventing security features',
            ),
            _buildBulletPoint(
              context,
              'Violating any applicable laws or regulations',
            ),
          ],
        ),
      ),

      // Updates
      _buildSection(
        context,
        icon: Icons.update_rounded,
        iconColor: const Color(0xFF06B6D4),
        iconBgColor: const Color(0xFFCFFAFE),
        title: 'Updates and Modifications',
        content:
            'We may update the app periodically to improve functionality and fix bugs. You are encouraged to keep your app updated. We reserve the right to modify these Terms, and continued use of the app constitutes acceptance of updated Terms.',
      ),

      // Termination
      _buildSection(
        context,
        icon: Icons.exit_to_app_rounded,
        iconColor: const Color(0xFFF59E0B),
        iconBgColor: const Color(0xFFFEF3C7),
        title: 'Termination',
        content:
            'We reserve the right to suspend or terminate your access to Lamlayers at any time if you violate these Terms. You may stop using the app at any time. Upon termination, all local data remains on your device.',
      ),

      // Contact
      _buildSection(
        context,
        icon: Icons.contact_support_rounded,
        iconColor: const Color(0xFF8B5CF6),
        iconBgColor: const Color(0xFFF5F3FF),
        title: 'Contact Information',
        content:
            'If you have questions about these Terms, please contact us at:\n\nEmail: zenithsyntax@gmail.com',
      ),

      // Governing Law
      _buildSection(
        context,
        icon: Icons.balance_rounded,
        iconColor: const Color(0xFF06B6D4),
        iconBgColor: const Color(0xFFCFFAFE),
        title: 'Governing Law',
        content:
            'These Terms shall be governed by and construed in accordance with applicable laws. Any disputes arising from the use of Lamlayers shall be subject to the exclusive jurisdiction of competent courts.',
      ),
    ];
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_getResponsivePadding(context) * 1.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFEC4899).withOpacity(0.1),
            const Color(0xFF8B5CF6).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFF8B5CF6).withOpacity(0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.handshake_rounded,
            color: const Color(0xFF8B5CF6),
            size: _getResponsiveFontSize(context, mobile: 40, tablet: 48, desktop: 56),
          ),
          SizedBox(height: _getResponsiveSpacing(context)),
          Text(
            'Fair Use',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, mobile: 20, tablet: 22, desktop: 24),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Respect intellectual property and use responsibly.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
              color: const Color(0xFF475569),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    String? content,
    Widget? child,
  }) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_getResponsivePadding(context)),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: _getResponsiveFontSize(context, mobile: 20, tablet: 22, desktop: 24),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: _getResponsiveFontSize(context, mobile: 16, tablet: 17, desktop: 18),
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: _getResponsiveSpacing(context)),
          if (content != null)
            Text(
              content,
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
                color: const Color(0xFF475569),
                height: 1.6,
              ),
            ),
          if (child != null) child,
        ],
      ),
    );
  }

  Widget _buildBulletPoint(BuildContext context, String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8, left: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '• ',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
              color: const Color(0xFFEC4899),
              fontWeight: FontWeight.w700,
            ),
          ),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: _getResponsiveFontSize(context, mobile: 14, tablet: 15, desktop: 16),
                color: const Color(0xFF475569),
                height: 1.6,
              ),
            ),
          ),
        ],
      ),
    );
  }
}