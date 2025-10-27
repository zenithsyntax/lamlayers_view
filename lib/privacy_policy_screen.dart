import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Responsive breakpoints
          final isDesktop = constraints.maxWidth >= 1024;
          final isTablet =
              constraints.maxWidth >= 600 && constraints.maxWidth < 1024;
          final isMobile = constraints.maxWidth < 600;

          // Responsive values
          final maxWidth = isDesktop
              ? 1200.0
              : (isTablet ? 800.0 : double.infinity);
          final horizontalPadding = isDesktop ? 48.0 : (isTablet ? 32.0 : 20.0);
          final verticalPadding = isDesktop ? 40.0 : (isTablet ? 32.0 : 20.0);
          final cardColumns = isDesktop ? 2 : 1;
          final sectionSpacing = isDesktop ? 24.0 : (isTablet ? 20.0 : 16.0);

          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxWidth),
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: horizontalPadding,
                  vertical: verticalPadding,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Card
                    _buildHeaderCard(isDesktop, isTablet, isMobile),

                    SizedBox(height: sectionSpacing * 1.5),

                    // Content Grid/List
                    if (isDesktop || isTablet)
                      _buildResponsiveGrid(
                        children: _getAllSections(),
                        columns: cardColumns,
                        spacing: sectionSpacing,
                      )
                    else
                      _buildMobileContent(sectionSpacing),

                    SizedBox(height: sectionSpacing * 1.5),

                    // Summary Card
                    _buildSummaryCard(isDesktop, isTablet, isMobile),

                    SizedBox(height: verticalPadding),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeaderCard(bool isDesktop, bool isTablet, bool isMobile) {
    final iconSize = isDesktop ? 56.0 : (isTablet ? 48.0 : 40.0);
    final titleSize = isDesktop ? 32.0 : (isTablet ? 28.0 : 24.0);
    final subtitleSize = isDesktop ? 14.0 : (isTablet ? 13.0 : 12.0);
    final padding = isDesktop ? 40.0 : (isTablet ? 32.0 : 24.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF06B6D4), Color(0xFF8B5CF6)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isMobile ? 20 : 24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF06B6D4).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(isMobile ? 12 : 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.privacy_tip_rounded,
              color: Colors.white,
              size: iconSize,
            ),
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            'Privacy Policy',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Last updated: January 9, 2025',
            style: TextStyle(
              fontSize: subtitleSize,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _getAllSections() {
    return [
      _buildIntroSection(),
      _buildDataCollectionSection(),
      _buildGoogleDriveSection(),
      _buildDataUsageSection(),
      _buildDataSharingSection(),
      _buildThirdPartySection(),
      _buildDataSecuritySection(),
      _buildDataRetentionSection(),
      _buildYourRightsSection(),
      _buildChildrenPrivacySection(),
      _buildChangesSection(),
      _buildContactSection(),
    ];
  }

  Widget _buildResponsiveGrid({
    required List<Widget> children,
    required int columns,
    required double spacing,
  }) {
    List<Widget> rows = [];

    for (int i = 0; i < children.length; i += columns) {
      List<Widget> rowChildren = [];

      for (int j = 0; j < columns; j++) {
        if (i + j < children.length) {
          rowChildren.add(Expanded(child: children[i + j]));

          if (j < columns - 1 && i + j + 1 < children.length) {
            rowChildren.add(SizedBox(width: spacing));
          }
        } else {
          rowChildren.add(const Expanded(child: SizedBox()));
        }
      }

      rows.add(
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: rowChildren,
        ),
      );

      if (i + columns < children.length) {
        rows.add(SizedBox(height: spacing));
      }
    }

    return Column(children: rows);
  }

  Widget _buildMobileContent(double spacing) {
    final sections = _getAllSections();
    return Column(
      children:
          sections
              .expand((section) => [section, SizedBox(height: spacing)])
              .toList()
            ..removeLast(),
    );
  }

  Widget _buildIntroSection() {
    return _buildSection(
      icon: Icons.description_rounded,
      iconColor: const Color(0xFF8B5CF6),
      iconBgColor: const Color(0xFFF5F3FF),
      title: 'Introduction',
      content:
          'Welcome to Lamlayers! This privacy policy explains how Lamlayers ("we", "our", or "the app") collects, uses, and protects your information when you use our mobile application. We are committed to protecting your privacy and handling your data transparently.',
    );
  }

  Widget _buildDataCollectionSection() {
    return _buildSection(
      icon: Icons.storage_rounded,
      iconColor: const Color(0xFF06B6D4),
      iconBgColor: const Color(0xFFCFFAFE),
      title: 'Information We Collect',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 400;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lamlayers primarily stores data locally on your device. We collect the following types of information:',
                style: TextStyle(
                  fontSize: isSmall ? 13 : 14,
                  color: const Color(0xFF475569),
                  height: 1.6,
                ),
              ),
              SizedBox(height: isSmall ? 12 : 16),
              _buildSubheading('Information Stored Locally:'),
              _buildBulletPoint(
                'Your design projects, lambooks, and creative content',
              ),
              _buildBulletPoint(
                'Images, text, shapes, and other media you add to projects',
              ),
              _buildBulletPoint('App settings and preferences'),
              _buildBulletPoint('Font favorites and recently used colors'),
              _buildBulletPoint('Canvas dimensions and layout configurations'),
              SizedBox(height: isSmall ? 12 : 16),
              _buildSubheading('Information for Google Drive Integration:'),
              _buildBulletPoint(
                'Google account email address (when you sign in)',
              ),
              _buildBulletPoint('OAuth tokens for Drive API access'),
              _buildBulletPoint(
                'File metadata (names, sizes, creation dates) of files you upload',
              ),
              SizedBox(height: isSmall ? 8 : 12),
              Container(
                padding: EdgeInsets.all(isSmall ? 12 : 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFCFFAFE).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF06B6D4).withOpacity(0.2),
                  ),
                ),
                child: Text(
                  'Important: All your creative content is stored locally on your device using Hive database. We do not collect, transmit, or store your projects on our servers.',
                  style: TextStyle(
                    fontSize: isSmall ? 12 : 13,
                    color: const Color(0xFF0E7490),
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGoogleDriveSection() {
    return _buildSection(
      icon: Icons.cloud_upload_rounded,
      iconColor: const Color(0xFF10B981),
      iconBgColor: const Color(0xFFD1FAE5),
      title: 'Google Drive Integration',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 400;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lamlayers uses Google Drive API to enable you to share your lambooks via web viewer. Here\'s how we use Google Drive:',
                style: TextStyle(
                  fontSize: isSmall ? 13 : 14,
                  color: const Color(0xFF475569),
                  height: 1.6,
                ),
              ),
              SizedBox(height: isSmall ? 12 : 16),
              _buildSubheading('What We Access:'),
              _buildBulletPoint(
                'We only access files that YOU create and upload through Lamlayers',
              ),
              _buildBulletPoint(
                'We DO NOT access, read, or modify any other files in your Google Drive',
              ),
              _buildBulletPoint(
                'We only use the following limited scopes: drive.file and drive (for setting public permissions)',
              ),
              SizedBox(height: isSmall ? 12 : 16),
              _buildSubheading('How We Use Google Drive:'),
              _buildBulletPoint(
                'Upload .lambook files when you choose to share via Google Drive',
              ),
              _buildBulletPoint(
                'Set files to "anyone with the link can view" for web sharing',
              ),
              _buildBulletPoint('Generate shareable web viewer links'),
              SizedBox(height: isSmall ? 12 : 16),
              _buildSubheading('Important Clarifications:'),
              _buildBulletPoint(
                'Google Drive upload is entirely OPTIONAL - you can use Lamlayers without ever signing in to Google',
              ),
              _buildBulletPoint(
                'We NEVER upload your files without your explicit action',
              ),
              _buildBulletPoint(
                'Files are uploaded to YOUR Google Drive, not ours',
              ),
              _buildBulletPoint(
                'You can revoke access anytime from your Google Account settings',
              ),
              _buildBulletPoint(
                'We do not store your Google credentials - authentication is handled securely by Google',
              ),
              SizedBox(height: isSmall ? 8 : 12),
              Container(
                padding: EdgeInsets.all(isSmall ? 12 : 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_rounded,
                      color: const Color(0xFF10B981),
                      size: isSmall ? 18 : 20,
                    ),
                    SizedBox(width: isSmall ? 8 : 12),
                    Expanded(
                      child: Text(
                        'Google Sign-In is only used for uploading lambooks to YOUR Google Drive for web sharing. We never access your existing Drive files.',
                        style: TextStyle(
                          fontSize: isSmall ? 12 : 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF065F46),
                          height: 1.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDataUsageSection() {
    return _buildSection(
      icon: Icons.assignment_rounded,
      iconColor: const Color(0xFFF59E0B),
      iconBgColor: const Color(0xFFFEF3C7),
      title: 'How We Use Your Information',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 400;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'We use the information we collect for the following purposes:',
                style: TextStyle(
                  fontSize: isSmall ? 13 : 14,
                  color: const Color(0xFF475569),
                  height: 1.6,
                ),
              ),
              SizedBox(height: isSmall ? 8 : 12),
              _buildBulletPoint(
                'Save and manage your design projects and lambooks',
              ),
              _buildBulletPoint('Remember your app preferences and settings'),
              _buildBulletPoint('Provide auto-save functionality'),
              _buildBulletPoint(
                'Enable Google Drive sharing when you choose to use it',
              ),
              _buildBulletPoint(
                'Generate web viewer links for shared lambooks',
              ),
              _buildBulletPoint('Improve app performance and user experience'),
              SizedBox(height: isSmall ? 8 : 12),
              Container(
                padding: EdgeInsets.all(isSmall ? 12 : 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: const Color(0xFFF59E0B),
                      size: isSmall ? 18 : 20,
                    ),
                    SizedBox(width: isSmall ? 8 : 12),
                    Expanded(
                      child: Text(
                        'Your data is processed locally on your device and never leaves it unless you explicitly choose to share via Google Drive',
                        style: TextStyle(
                          fontSize: isSmall ? 12 : 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF92400E),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDataSharingSection() {
    return _buildSection(
      icon: Icons.share_rounded,
      iconColor: const Color(0xFFEC4899),
      iconBgColor: const Color(0xFFFCE7F3),
      title: 'Data Sharing and Disclosure',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 400;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'We do NOT sell, rent, or trade your personal information. Here\'s how data may be shared:',
                style: TextStyle(
                  fontSize: isSmall ? 13 : 14,
                  color: const Color(0xFF475569),
                  height: 1.6,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: isSmall ? 12 : 16),
              _buildSubheading('With Your Consent:'),
              _buildBulletPoint(
                'When you upload lambooks to Google Drive, files are stored in YOUR Google Drive account',
              ),
              _buildBulletPoint(
                'When you share a web viewer link, recipients can view your lambook',
              ),
              SizedBox(height: isSmall ? 12 : 16),
              _buildSubheading('With Third-Party Services:'),
              _buildBulletPoint(
                'Google Drive API (only when you explicitly sign in and upload)',
              ),
              _buildBulletPoint('Google Fonts (for font rendering)'),
              _buildBulletPoint(
                'Google Mobile Ads (for displaying advertisements)',
              ),
              SizedBox(height: isSmall ? 12 : 16),
              _buildSubheading('Legal Requirements:'),
              Text(
                'We may disclose information if required by law, court order, or legal process.',
                style: TextStyle(
                  fontSize: isSmall ? 13 : 14,
                  color: const Color(0xFF475569),
                  height: 1.6,
                ),
              ),
              SizedBox(height: isSmall ? 8 : 12),
              Container(
                padding: EdgeInsets.all(isSmall ? 12 : 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFCE7F3).withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFFEC4899).withOpacity(0.3),
                  ),
                ),
                child: Text(
                  'Important: All your projects, images, and creative content remain private and local to your device unless you explicitly share them.',
                  style: TextStyle(
                    fontSize: isSmall ? 12 : 13,
                    color: const Color(0xFF9F1239),
                    height: 1.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildThirdPartySection() {
    return _buildSection(
      icon: Icons.extension_rounded,
      iconColor: const Color(0xFF8B5CF6),
      iconBgColor: const Color(0xFFF5F3FF),
      title: 'Third-Party Services',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 400;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lamlayers integrates with the following third-party services:',
                style: TextStyle(
                  fontSize: isSmall ? 13 : 14,
                  color: const Color(0xFF475569),
                  height: 1.6,
                ),
              ),
              SizedBox(height: isSmall ? 8 : 12),
              _buildServiceItem(
                'Google Sign-In',
                'For authenticating with Google Drive (optional)',
              ),
              _buildServiceItem(
                'Google Drive API',
                'For uploading and sharing lambooks (optional)',
              ),
              _buildServiceItem(
                'Google Fonts',
                'For providing typography options in your designs',
              ),
              _buildServiceItem(
                'Google Mobile Ads',
                'For displaying advertisements to support the app',
              ),
              SizedBox(height: isSmall ? 8 : 12),
              Text(
                'These services have their own privacy policies. We recommend reviewing them:',
                style: TextStyle(
                  fontSize: isSmall ? 12 : 13,
                  color: const Color(0xFF64748B),
                  height: 1.5,
                ),
              ),
              SizedBox(height: 4),
              _buildLink(
                'Google Privacy Policy',
                'https://policies.google.com/privacy',
              ),
              _buildLink(
                'Google Drive API Terms',
                'https://developers.google.com/terms',
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDataSecuritySection() {
    return _buildSection(
      icon: Icons.lock_rounded,
      iconColor: const Color(0xFF06B6D4),
      iconBgColor: const Color(0xFFCFFAFE),
      title: 'Data Security',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 400;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'We take the security of your data seriously and implement appropriate measures:',
                style: TextStyle(
                  fontSize: isSmall ? 13 : 14,
                  color: const Color(0xFF475569),
                  height: 1.6,
                ),
              ),
              SizedBox(height: isSmall ? 8 : 12),
              _buildBulletPoint('Local storage using encrypted Hive database'),
              _buildBulletPoint(
                'Secure OAuth 2.0 authentication for Google services',
              ),
              _buildBulletPoint(
                'No transmission of personal data to external servers',
              ),
              _buildBulletPoint(
                'Files uploaded to Drive are stored in YOUR account, not ours',
              ),
              _buildBulletPoint(
                'We do not store Google credentials or access tokens',
              ),
              SizedBox(height: isSmall ? 8 : 12),
              Container(
                padding: EdgeInsets.all(isSmall ? 12 : 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Note: While we implement security measures, no method of electronic storage is 100% secure. Please use strong device passwords and keep your device secure.',
                  style: TextStyle(
                    fontSize: isSmall ? 12 : 13,
                    color: const Color(0xFF92400E),
                    height: 1.5,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDataRetentionSection() {
    return _buildSection(
      icon: Icons.timelapse_rounded,
      iconColor: const Color(0xFF10B981),
      iconBgColor: const Color(0xFFD1FAE5),
      title: 'Data Retention',
      content:
          'Your data is stored locally on your device for as long as you keep the app installed. When you delete projects or uninstall the app, all local data is removed. Files uploaded to Google Drive remain in YOUR Drive account and follow Google\'s retention policies. You have full control to delete them at any time from your Google Drive.',
    );
  }

  Widget _buildYourRightsSection() {
    return _buildSection(
      icon: Icons.admin_panel_settings_rounded,
      iconColor: const Color(0xFFEF4444),
      iconBgColor: const Color(0xFFFEE2E2),
      title: 'Your Rights and Choices',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 400;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'You have complete control over your data:',
                style: TextStyle(
                  fontSize: isSmall ? 13 : 14,
                  color: const Color(0xFF475569),
                  height: 1.6,
                ),
              ),
              SizedBox(height: isSmall ? 8 : 12),
              _buildBulletPoint('Access all your projects and data anytime'),
              _buildBulletPoint('Modify or delete your projects at will'),
              _buildBulletPoint('Export your work in various formats'),
              _buildBulletPoint('Clear all app data from Settings'),
              _buildBulletPoint(
                'Revoke Google Drive access from your Google Account settings',
              ),
              _buildBulletPoint('Delete files from Google Drive independently'),
              _buildBulletPoint('Uninstall the app to remove all local data'),
              SizedBox(height: isSmall ? 8 : 12),
              Container(
                padding: EdgeInsets.all(isSmall ? 12 : 14),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'To revoke Google Drive access:',
                      style: TextStyle(
                        fontSize: isSmall ? 12 : 13,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF991B1B),
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '1. Go to your Google Account (myaccount.google.com)\n2. Navigate to Security → Third-party apps\n3. Remove Lamlayers access',
                      style: TextStyle(
                        fontSize: isSmall ? 12 : 13,
                        color: const Color(0xFF991B1B),
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChildrenPrivacySection() {
    return _buildSection(
      icon: Icons.child_care_rounded,
      iconColor: const Color(0xFFEC4899),
      iconBgColor: const Color(0xFFFCE7F3),
      title: 'Children\'s Privacy',
      content:
          'Lamlayers does not knowingly collect personal information from children under 13 years of age. The app stores data locally and does not require registration or personal information. If we become aware that a child under 13 has provided us with personal information, we will take steps to delete such information. If you believe a child has provided personal information to us, please contact us.',
    );
  }

  Widget _buildChangesSection() {
    return _buildSection(
      icon: Icons.update_rounded,
      iconColor: const Color(0xFFF59E0B),
      iconBgColor: const Color(0xFFFEF3C7),
      title: 'Changes to This Privacy Policy',
      content:
          'We may update this privacy policy from time to time to reflect changes in our practices or for legal, operational, or regulatory reasons. When we make changes, we will update the "Last updated" date at the top of this policy. We encourage you to review this policy periodically. Continued use of the app after changes constitutes acceptance of the updated policy.',
    );
  }

  Widget _buildContactSection() {
    return _buildSection(
      icon: Icons.contact_support_rounded,
      iconColor: const Color(0xFF06B6D4),
      iconBgColor: const Color(0xFFCFFAFE),
      title: 'Contact Us',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 400;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'If you have any questions, concerns, or requests regarding this privacy policy or how we handle your data, please contact us:',
                style: TextStyle(
                  fontSize: isSmall ? 13 : 14,
                  color: const Color(0xFF475569),
                  height: 1.6,
                ),
              ),
              SizedBox(height: isSmall ? 12 : 16),
              Container(
                padding: EdgeInsets.all(isSmall ? 12 : 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFCFFAFE).withOpacity(0.5),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF06B6D4).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.email_rounded,
                      color: const Color(0xFF06B6D4),
                      size: isSmall ? 20 : 24,
                    ),
                    SizedBox(width: isSmall ? 12 : 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Email Support',
                            style: TextStyle(
                              fontSize: isSmall ? 12 : 13,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0E7490),
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'zenithsyntax@gmail.com',
                            style: TextStyle(
                              fontSize: isSmall ? 13 : 14,
                              color: const Color(0xFF0E7490),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: isSmall ? 8 : 12),
              Text(
                'We will respond to your inquiries within a reasonable timeframe.',
                style: TextStyle(
                  fontSize: isSmall ? 12 : 13,
                  color: const Color(0xFF64748B),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard(bool isDesktop, bool isTablet, bool isMobile) {
    final iconSize = isDesktop ? 48.0 : (isTablet ? 44.0 : 40.0);
    final titleSize = isDesktop ? 24.0 : (isTablet ? 22.0 : 20.0);
    final subtitleSize = isDesktop ? 16.0 : (isTablet ? 15.0 : 14.0);
    final padding = isDesktop ? 40.0 : (isTablet ? 32.0 : 24.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF10B981).withOpacity(0.1),
            const Color(0xFF06B6D4).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(isMobile ? 16 : 20),
        border: Border.all(
          color: const Color(0xFF10B981).withOpacity(0.3),
          width: isMobile ? 1.5 : 2,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.verified_user_rounded,
            color: const Color(0xFF10B981),
            size: iconSize,
          ),
          SizedBox(height: isMobile ? 12 : 16),
          Text(
            'Your Privacy, Your Control',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your data stays on your device. Google Drive is optional and only used when YOU choose to share. We never access your files without permission.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: subtitleSize,
              color: const Color(0xFF475569),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    String? content,
    Widget? child,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 400;
        final padding = isSmall ? 16.0 : 20.0;
        final iconPadding = isSmall ? 8.0 : 10.0;
        final iconSize = isSmall ? 18.0 : 20.0;
        final titleSize = isSmall ? 15.0 : 16.0;
        final contentSize = isSmall ? 13.0 : 14.0;

        return Container(
          width: double.infinity,
          padding: EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(isSmall ? 12 : 16),
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
                    padding: EdgeInsets.all(iconPadding),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(isSmall ? 10 : 12),
                    ),
                    child: Icon(icon, color: iconColor, size: iconSize),
                  ),
                  SizedBox(width: isSmall ? 10 : 12),
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0F172A),
                        letterSpacing: -0.3,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: isSmall ? 12 : 16),
              if (content != null)
                Text(
                  content,
                  style: TextStyle(
                    fontSize: contentSize,
                    color: const Color(0xFF475569),
                    height: 1.6,
                  ),
                ),
              if (child != null) child,
            ],
          ),
        );
      },
    );
  }

  Widget _buildSubheading(String text) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 400;
        return Padding(
          padding: EdgeInsets.only(bottom: isSmall ? 6 : 8),
          child: Text(
            text,
            style: TextStyle(
              fontSize: isSmall ? 13 : 14,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBulletPoint(String text) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 400;
        return Padding(
          padding: EdgeInsets.only(bottom: isSmall ? 6 : 8, left: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '• ',
                style: TextStyle(
                  fontSize: isSmall ? 13 : 14,
                  color: const Color(0xFF8B5CF6),
                  fontWeight: FontWeight.w700,
                ),
              ),
              Expanded(
                child: Text(
                  text,
                  style: TextStyle(
                    fontSize: isSmall ? 13 : 14,
                    color: const Color(0xFF475569),
                    height: 1.6,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildServiceItem(String name, String description) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 400;
        return Padding(
          padding: EdgeInsets.only(bottom: isSmall ? 8 : 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.check_circle,
                color: const Color(0xFF10B981),
                size: isSmall ? 16 : 18,
              ),
              SizedBox(width: isSmall ? 8 : 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: isSmall ? 13 : 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: isSmall ? 12 : 13,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLink(String text, String url) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmall = constraints.maxWidth < 400;
        return Padding(
          padding: EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            '→ $text',
            style: TextStyle(
              fontSize: isSmall ? 12 : 13,
              color: const Color(0xFF06B6D4),
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline,
            ),
          ),
        );
      },
    );
  }
}
