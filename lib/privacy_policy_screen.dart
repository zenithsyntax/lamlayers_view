import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
            'Your Privacy Matters',
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
            'Last updated: October 16, 2025',
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
      _buildDataUsageSection(),
      _buildDataSharingSection(),
      _buildThirdPartySection(),
      _buildDataSecuritySection(),
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
            ..removeLast(), // Remove last spacing
    );
  }

  Widget _buildIntroSection() {
    return _buildSection(
      icon: Icons.description_rounded,
      iconColor: const Color(0xFF8B5CF6),
      iconBgColor: const Color(0xFFF5F3FF),
      title: 'Introduction',
      content:
          'Welcome to Lamlayers! We respect your privacy and are committed to protecting your personal data. This privacy policy explains how we handle your information when you use our app.',
    );
  }

  Widget _buildDataCollectionSection() {
    return _buildSection(
      icon: Icons.storage_rounded,
      iconColor: const Color(0xFF06B6D4),
      iconBgColor: const Color(0xFFCFFAFE),
      title: 'Data We Collect',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 400;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lamlayers stores data locally on your device:',
                style: TextStyle(
                  fontSize: isSmall ? 13 : 14,
                  color: const Color(0xFF475569),
                  height: 1.6,
                ),
              ),
              SizedBox(height: isSmall ? 8 : 12),
              _buildBulletPoint('Your design projects and lambooks'),
              _buildBulletPoint('App settings and preferences'),
              _buildBulletPoint('Images and media you add to projects'),
              _buildBulletPoint('Font favorites and recent colors'),
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
                  'All data is stored locally using Hive database. We do not collect or transmit your personal information to external servers.',
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

  Widget _buildDataUsageSection() {
    return _buildSection(
      icon: Icons.security_rounded,
      iconColor: const Color(0xFF10B981),
      iconBgColor: const Color(0xFFD1FAE5),
      title: 'How We Use Your Data',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 400;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBulletPoint('To save and manage your creative projects'),
              _buildBulletPoint(
                'To remember your app preferences and settings',
              ),
              _buildBulletPoint('To provide auto-save functionality'),
              _buildBulletPoint('To enhance your creative experience'),
              SizedBox(height: isSmall ? 8 : 12),
              Container(
                padding: EdgeInsets.all(isSmall ? 12 : 16),
                decoration: BoxDecoration(
                  color: const Color(0xFFD1FAE5),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: const Color(0xFF10B981),
                      size: isSmall ? 18 : 20,
                    ),
                    SizedBox(width: isSmall ? 8 : 12),
                    Expanded(
                      child: Text(
                        'Your data never leaves your device',
                        style: TextStyle(
                          fontSize: isSmall ? 12 : 13,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF065F46),
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
      title: 'Data Sharing',
      content:
          'We do NOT share, sell, or transmit your data to third parties. All your projects, images, and settings remain private and stored only on your device. When you export your work, you have complete control over where and how you share it.',
    );
  }

  Widget _buildThirdPartySection() {
    return _buildSection(
      icon: Icons.extension_rounded,
      iconColor: const Color(0xFFF59E0B),
      iconBgColor: const Color(0xFFFEF3C7),
      title: 'Third-Party Services',
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmall = constraints.maxWidth < 400;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Lamlayers may use the following third-party services:',
                style: TextStyle(
                  fontSize: isSmall ? 13 : 14,
                  color: const Color(0xFF475569),
                  height: 1.6,
                ),
              ),
              SizedBox(height: isSmall ? 8 : 12),
              _buildServiceItem(
                'Google Fonts',
                'For providing beautiful typography',
              ),
              _buildServiceItem(
                'Google Mobile Ads',
                'For displaying ads (if applicable)',
              ),
              SizedBox(height: isSmall ? 8 : 12),
              Text(
                'These services may have their own privacy policies. We recommend reviewing them separately.',
                style: TextStyle(
                  fontSize: isSmall ? 12 : 13,
                  color: const Color(0xFF64748B),
                  height: 1.5,
                  fontStyle: FontStyle.italic,
                ),
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
      iconColor: const Color(0xFF8B5CF6),
      iconBgColor: const Color(0xFFF5F3FF),
      title: 'Data Security',
      content:
          'We implement appropriate security measures to protect your data. All information is stored locally using encrypted Hive database. However, please note that no method of electronic storage is 100% secure.',
    );
  }

  Widget _buildYourRightsSection() {
    return _buildSection(
      icon: Icons.admin_panel_settings_rounded,
      iconColor: const Color(0xFFEF4444),
      iconBgColor: const Color(0xFFFEE2E2),
      title: 'Your Rights',
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
              _buildBulletPoint('Modify or delete your projects'),
              _buildBulletPoint('Export your work in various formats'),
              _buildBulletPoint('Clear all app data from Settings'),
              _buildBulletPoint('Uninstall the app to remove all data'),
            ],
          );
        },
      ),
    );
  }

  Widget _buildChildrenPrivacySection() {
    return _buildSection(
      icon: Icons.child_care_rounded,
      iconColor: const Color(0xFF06B6D4),
      iconBgColor: const Color(0xFFCFFAFE),
      title: 'Children\'s Privacy',
      content:
          'Lamlayers does not knowingly collect personal information from children under 13. The app is designed to store data locally without requiring personal information.',
    );
  }

  Widget _buildChangesSection() {
    return _buildSection(
      icon: Icons.update_rounded,
      iconColor: const Color(0xFFF59E0B),
      iconBgColor: const Color(0xFFFEF3C7),
      title: 'Changes to This Policy',
      content:
          'We may update this privacy policy from time to time. Any changes will be reflected with an updated "Last updated" date at the top of this policy. We encourage you to review this policy periodically.',
    );
  }

  Widget _buildContactSection() {
    return _buildSection(
      icon: Icons.contact_support_rounded,
      iconColor: const Color(0xFFEC4899),
      iconBgColor: const Color(0xFFFCE7F3),
      title: 'Contact Us',
      content:
          'If you have any questions or concerns about this privacy policy or how we handle your data, please contact us at:\n\nEmail: zenithsyntax@gmail.com',
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
            'Privacy First',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Your creativity is yours. Your data stays on your device. Always.',
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
}
