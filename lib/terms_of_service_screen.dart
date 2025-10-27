import 'package:flutter/material.dart';

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
            fontSize: _getResponsiveFontSize(
              context,
              mobile: 20,
              tablet: 22,
              desktop: 24,
            ),
            fontWeight: FontWeight.w700,
            color: const Color(0xFF0F172A),
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: false,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            size: _getResponsiveFontSize(
              context,
              mobile: 20,
              tablet: 22,
              desktop: 24,
            ),
          ),
          color: const Color(0xFF0F172A),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: _getMaxWidth(context)),
          child: SingleChildScrollView(
            padding: EdgeInsets.all(_getResponsivePadding(context)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeaderCard(context),
                SizedBox(height: _getResponsiveSpacing(context)),
                _buildResponsiveGrid(context),
                SizedBox(height: _getResponsiveSpacing(context) * 1.5),
                _buildSummaryCard(context),
                SizedBox(height: _getResponsiveSpacing(context) * 1.5),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool _isMobile(BuildContext context) =>
      MediaQuery.of(context).size.width < 600;
  bool _isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= 600 && width < 1024;
  }

  bool _isDesktop(BuildContext context) =>
      MediaQuery.of(context).size.width >= 1024;

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
              size: _getResponsiveFontSize(
                context,
                mobile: 48,
                tablet: 56,
                desktop: 64,
              ),
            ),
          ),
          SizedBox(height: _getResponsiveSpacing(context)),
          Text(
            'Terms of Service',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 24,
                tablet: 28,
                desktop: 32,
              ),
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Last updated: January 9, 2025',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 12,
                tablet: 13,
                desktop: 14,
              ),
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
      return Column(
        children: sections.map((section) {
          return Padding(
            padding: EdgeInsets.only(bottom: _getResponsiveSpacing(context)),
            child: section,
          );
        }).toList(),
      );
    } else {
      return LayoutBuilder(
        builder: (context, constraints) {
          final spacing = _getResponsiveSpacing(context);
          final columnWidth = (constraints.maxWidth - spacing) / 2;

          return Wrap(
            spacing: spacing,
            runSpacing: spacing,
            children: sections.map((section) {
              return SizedBox(width: columnWidth, child: section);
            }).toList(),
          );
        },
      );
    }
  }

  List<Widget> _getAllSections(BuildContext context) {
    return [
      _buildSection(
        context,
        icon: Icons.description_rounded,
        iconColor: const Color(0xFF8B5CF6),
        iconBgColor: const Color(0xFFF5F3FF),
        title: 'Introduction',
        content:
            'Welcome to LamLayers! These Terms of Service govern your use of the LamLayers mobile application and related services. By accessing or using LamLayers, you agree to be bound by these Terms. If you do not agree to these Terms, please do not use our application.',
      ),

      _buildSection(
        context,
        icon: Icons.check_circle_rounded,
        iconColor: const Color(0xFF10B981),
        iconBgColor: const Color(0xFFD1FAE5),
        title: 'Acceptance of Terms',
        content:
            'By downloading, installing, accessing, or using LamLayers, you acknowledge that you have read, understood, and agree to be bound by these Terms and our Privacy Policy. If you are using the app on behalf of an organization, you represent that you have the authority to bind that organization to these Terms.',
      ),

      _buildSection(
        context,
        icon: Icons.cloud_rounded,
        iconColor: const Color(0xFF3B82F6),
        iconBgColor: const Color(0xFFDBEAFE),
        title: 'Google Drive Integration',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LamLayers uses Google Drive to enable you to share your Lambook creations. When you choose to share via Google Drive:',
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
            SizedBox(height: 12),
            _buildBulletPoint(
              context,
              'You will be asked to sign in with your Google account',
            ),
            _buildBulletPoint(
              context,
              'LamLayers will request permission to upload files to your Google Drive',
            ),
            _buildBulletPoint(
              context,
              'Files are uploaded with "anyone with the link" sharing permissions to enable web viewing',
            ),
            _buildBulletPoint(
              context,
              'We only access files that LamLayers creates - we cannot see or access your other Google Drive files',
            ),
            _buildBulletPoint(
              context,
              'You can revoke LamLayers\' access to Google Drive at any time through your Google Account settings',
            ),
            _buildBulletPoint(
              context,
              'We do not store your Google credentials - authentication is handled securely by Google',
            ),
            SizedBox(height: 8),
            Text(
              'Google Drive integration is optional. You can use all other features of LamLayers without connecting to Google Drive.',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
                color: const Color(0xFF475569),
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),

      _buildSection(
        context,
        icon: Icons.storage_rounded,
        iconColor: const Color(0xFF8B5CF6),
        iconBgColor: const Color(0xFFF5F3FF),
        title: 'Data Storage and Processing',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Local Storage:',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
                color: const Color(0xFF475569),
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            _buildBulletPoint(
              context,
              'All your designs, Lambooks, and projects are stored locally on your device',
            ),
            _buildBulletPoint(
              context,
              'We do not have access to your locally stored content',
            ),
            _buildBulletPoint(
              context,
              'You are responsible for backing up your local data',
            ),
            SizedBox(height: 12),
            Text(
              'Cloud Storage (Google Drive):',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
                color: const Color(0xFF475569),
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            _buildBulletPoint(
              context,
              'When you share via Google Drive, files are uploaded to your personal Google Drive account',
            ),
            _buildBulletPoint(
              context,
              'Shared files are made publicly accessible via link for web viewing',
            ),
            _buildBulletPoint(
              context,
              'You control these files through your Google Drive account',
            ),
            _buildBulletPoint(
              context,
              'You can delete or unshare files at any time from your Google Drive',
            ),
          ],
        ),
      ),

      _buildSection(
        context,
        icon: Icons.person_rounded,
        iconColor: const Color(0xFF06B6D4),
        iconBgColor: const Color(0xFFCFFAFE),
        title: 'User Responsibilities',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You agree to:',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
                color: const Color(0xFF475569),
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            _buildBulletPoint(
              context,
              'Maintain the security and confidentiality of your device and accounts',
            ),
            _buildBulletPoint(
              context,
              'Use the app only for lawful purposes and in accordance with these Terms',
            ),
            _buildBulletPoint(
              context,
              'Not use the app to create, store, or share content that is illegal, harmful, threatening, abusive, harassing, defamatory, vulgar, obscene, or otherwise objectionable',
            ),
            _buildBulletPoint(
              context,
              'Not attempt to reverse engineer, decompile, or modify the app',
            ),
            _buildBulletPoint(
              context,
              'Not interfere with or disrupt the app or servers',
            ),
            _buildBulletPoint(
              context,
              'Respect the intellectual property rights of others in content you create and share',
            ),
            _buildBulletPoint(
              context,
              'Be responsible for all content you create and share through the app',
            ),
            _buildBulletPoint(context, 'Regularly back up your important data'),
          ],
        ),
      ),

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
              'Your Content:',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
                color: const Color(0xFF475569),
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            _buildBulletPoint(
              context,
              'You retain all ownership rights to content you create using LamLayers',
            ),
            _buildBulletPoint(
              context,
              'You are responsible for ensuring you have the necessary rights to any third-party content (images, fonts, etc.) you use in your creations',
            ),
            _buildBulletPoint(
              context,
              'When you share content publicly via Google Drive, you are responsible for the permissions and visibility of that content',
            ),
            SizedBox(height: 12),
            Text(
              'LamLayers\' Rights:',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
                color: const Color(0xFF475569),
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            _buildBulletPoint(
              context,
              'LamLayers and its original content, features, and functionality are owned by us and are protected by copyright, trademark, and other intellectual property laws',
            ),
            _buildBulletPoint(
              context,
              'You may not copy, modify, distribute, sell, or lease any part of the app without our express written permission',
            ),
            _buildBulletPoint(
              context,
              'We may collect anonymous usage statistics to improve the app, but we do not claim ownership of your content',
            ),
          ],
        ),
      ),

      _buildSection(
        context,
        icon: Icons.privacy_tip_rounded,
        iconColor: const Color(0xFFEC4899),
        iconBgColor: const Color(0xFFFCE7F3),
        title: 'Privacy and Data Use',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your privacy is important to us. Here\'s how we handle your data:',
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
            SizedBox(height: 12),
            _buildBulletPoint(
              context,
              'All designs and Lambooks are stored locally on your device by default',
            ),
            _buildBulletPoint(
              context,
              'We do not collect, access, or transmit your personal creative content to our servers',
            ),
            _buildBulletPoint(
              context,
              'When you use Google Drive integration, files are uploaded directly to your Google Drive account - we do not store copies on our servers',
            ),
            _buildBulletPoint(
              context,
              'We may collect anonymous analytics data (crash reports, feature usage) to improve the app',
            ),
            _buildBulletPoint(
              context,
              'We do not sell your data to third parties',
            ),
            SizedBox(height: 8),
            Text(
              'For complete details, please review our Privacy Policy.',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
                color: const Color(0xFF475569),
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),

      _buildSection(
        context,
        icon: Icons.security_rounded,
        iconColor: const Color(0xFF3B82F6),
        iconBgColor: const Color(0xFFDBEAFE),
        title: 'Third-Party Services',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LamLayers integrates with the following third-party services:',
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
            SizedBox(height: 12),
            _buildBulletPoint(
              context,
              'Google Sign-In and Google Drive API: For optional cloud sharing functionality',
            ),
            _buildBulletPoint(
              context,
              'Google Mobile Ads: For displaying advertisements',
            ),
            SizedBox(height: 8),
            Text(
              'Your use of these services is subject to their respective terms of service and privacy policies. We are not responsible for the practices of these third-party services.',
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

      _buildSection(
        context,
        icon: Icons.warning_rounded,
        iconColor: const Color(0xFFEF4444),
        iconBgColor: const Color(0xFFFEE2E2),
        title: 'Disclaimers and Limitations',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildBulletPoint(
              context,
              'LamLayers is provided "as is" and "as available" without warranties of any kind, either express or implied',
            ),
            _buildBulletPoint(
              context,
              'We do not guarantee that the app will be uninterrupted, error-free, or secure',
            ),
            _buildBulletPoint(
              context,
              'We are not liable for any data loss, corruption, or device damage',
            ),
            _buildBulletPoint(
              context,
              'We are not responsible for content you create, share, or any consequences thereof',
            ),
            _buildBulletPoint(
              context,
              'We are not liable for issues arising from third-party services (Google Drive, etc.)',
            ),
            _buildBulletPoint(context, 'You use the app at your own risk'),
            _buildBulletPoint(
              context,
              'Our total liability shall not exceed the amount you paid for the app (currently free)',
            ),
          ],
        ),
      ),

      _buildSection(
        context,
        icon: Icons.block_rounded,
        iconColor: const Color(0xFFEF4444),
        iconBgColor: const Color(0xFFFEE2E2),
        title: 'Prohibited Activities',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You must not:',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
                color: const Color(0xFF475569),
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            _buildBulletPoint(
              context,
              'Use the app to create or distribute illegal, harmful, threatening, abusive, or offensive content',
            ),
            _buildBulletPoint(
              context,
              'Infringe on the intellectual property rights of others',
            ),
            _buildBulletPoint(
              context,
              'Attempt to hack, compromise, or interfere with the app\'s functionality',
            ),
            _buildBulletPoint(
              context,
              'Distribute malware or harmful code through the app',
            ),
            _buildBulletPoint(
              context,
              'Use the app for any commercial purpose without our written consent',
            ),
            _buildBulletPoint(
              context,
              'Copy, redistribute, or create derivative works from the app',
            ),
            _buildBulletPoint(
              context,
              'Remove, obscure, or alter any proprietary notices in the app',
            ),
            _buildBulletPoint(
              context,
              'Use the app in any way that violates applicable laws or regulations',
            ),
          ],
        ),
      ),

      _buildSection(
        context,
        icon: Icons.update_rounded,
        iconColor: const Color(0xFF06B6D4),
        iconBgColor: const Color(0xFFCFFAFE),
        title: 'Updates and Modifications',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'App Updates:',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
                color: const Color(0xFF475569),
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            _buildBulletPoint(
              context,
              'We may release updates to improve functionality, fix bugs, or add new features',
            ),
            _buildBulletPoint(
              context,
              'Some updates may be required for continued use of the app',
            ),
            _buildBulletPoint(
              context,
              'We recommend keeping your app updated to the latest version',
            ),
            SizedBox(height: 12),
            Text(
              'Terms Updates:',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
                color: const Color(0xFF475569),
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            _buildBulletPoint(
              context,
              'We reserve the right to modify these Terms at any time',
            ),
            _buildBulletPoint(
              context,
              'We will notify you of material changes through the app or via email',
            ),
            _buildBulletPoint(
              context,
              'Continued use after changes constitutes acceptance of the updated Terms',
            ),
            _buildBulletPoint(
              context,
              'If you do not agree to updated Terms, you must stop using the app',
            ),
          ],
        ),
      ),

      _buildSection(
        context,
        icon: Icons.exit_to_app_rounded,
        iconColor: const Color(0xFFF59E0B),
        iconBgColor: const Color(0xFFFEF3C7),
        title: 'Termination',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'We may suspend or terminate your access to LamLayers at any time, with or without notice, for:',
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
            SizedBox(height: 8),
            _buildBulletPoint(context, 'Violation of these Terms'),
            _buildBulletPoint(context, 'Illegal or harmful use of the app'),
            _buildBulletPoint(
              context,
              'At our sole discretion for any other reason',
            ),
            SizedBox(height: 12),
            Text(
              'You may stop using the app at any time. Upon termination:',
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
            SizedBox(height: 8),
            _buildBulletPoint(
              context,
              'Your local data remains on your device',
            ),
            _buildBulletPoint(
              context,
              'Files on your Google Drive remain accessible through your Google account',
            ),
            _buildBulletPoint(
              context,
              'You should revoke LamLayers\' access in your Google Account settings if desired',
            ),
          ],
        ),
      ),

      _buildSection(
        context,
        icon: Icons.balance_rounded,
        iconColor: const Color(0xFF06B6D4),
        iconBgColor: const Color(0xFFCFFAFE),
        title: 'Governing Law and Disputes',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'These Terms shall be governed by and construed in accordance with the laws of India, without regard to its conflict of law provisions.',
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
            SizedBox(height: 12),
            Text(
              'Any disputes arising from your use of LamLayers shall be subject to the exclusive jurisdiction of the courts in Kerala, India.',
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
            SizedBox(height: 12),
            Text(
              'If any provision of these Terms is found to be unenforceable, the remaining provisions will remain in full effect.',
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

      _buildSection(
        context,
        icon: Icons.contact_support_rounded,
        iconColor: const Color(0xFF8B5CF6),
        iconBgColor: const Color(0xFFF5F3FF),
        title: 'Contact Information',
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'If you have any questions, concerns, or feedback about these Terms of Service, please contact us:',
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
            SizedBox(height: 12),
            Text(
              '📧 Email: zenithsyntax@gmail.com',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
                color: const Color(0xFF8B5CF6),
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'We will respond to inquiries within a reasonable timeframe.',
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
        border: Border.all(color: const Color(0xFF8B5CF6).withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            Icons.handshake_rounded,
            color: const Color(0xFF8B5CF6),
            size: _getResponsiveFontSize(
              context,
              mobile: 40,
              tablet: 48,
              desktop: 56,
            ),
          ),
          SizedBox(height: _getResponsiveSpacing(context)),
          Text(
            'Thank You',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 20,
                tablet: 22,
                desktop: 24,
              ),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'By using LamLayers, you agree to these terms. We\'re committed to providing you with a great creative experience while respecting your privacy and data.',
            textAlign: TextAlign.center,
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
                  size: _getResponsiveFontSize(
                    context,
                    mobile: 20,
                    tablet: 22,
                    desktop: 24,
                  ),
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
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
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 14,
                tablet: 15,
                desktop: 16,
              ),
              color: const Color(0xFFEC4899),
              fontWeight: FontWeight.w700,
            ),
          ),
          Expanded(
            child: Text(
              text,
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
          ),
        ],
      ),
    );
  }
}
