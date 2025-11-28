import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DataDeletionScreen extends StatelessWidget {
  const DataDeletionScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Account and Data Deletion',
          style: TextStyle(
            fontSize: _getResponsiveFontSize(
              context,
              mobile: 18,
              tablet: 20,
              desktop: 22,
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
                _buildOverviewSection(context),
                SizedBox(height: _getResponsiveSpacing(context)),
                _buildAccountTypesSection(context),
                SizedBox(height: _getResponsiveSpacing(context)),
                _buildDeleteLocalDataSection(context),
                SizedBox(height: _getResponsiveSpacing(context)),
                _buildRevokeGoogleAccessSection(context),
                SizedBox(height: _getResponsiveSpacing(context)),
                _buildDataDeletedSection(context),
                SizedBox(height: _getResponsiveSpacing(context)),
                _buildDataRetentionSection(context),
                SizedBox(height: _getResponsiveSpacing(context)),
                _buildAdditionalInfoSection(context),
                SizedBox(height: _getResponsiveSpacing(context)),
                _buildContactSection(context),
                SizedBox(height: _getResponsiveSpacing(context)),
                _buildSummaryCard(context),
                SizedBox(height: _getResponsiveSpacing(context) * 1.5),
              ],
            ),
          ),
        ),
      ),
    );
  }

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
    if (_isDesktop(context)) return 24;
    if (_isTablet(context)) return 20;
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

  Widget _buildHeaderCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_getResponsivePadding(context) * 1.5),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFEF4444), Color(0xFFF59E0B)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFEF4444).withOpacity(0.3),
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
              Icons.delete_forever_rounded,
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
            'Account and Data Deletion Guide',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 22,
                tablet: 26,
                desktop: 30,
              ),
              fontWeight: FontWeight.w900,
              color: Colors.white,
              letterSpacing: -0.5,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Lamlayers',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 14,
                tablet: 15,
                desktop: 16,
              ),
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewSection(BuildContext context) {
    return _buildSection(
      context,
      icon: Icons.info_rounded,
      iconColor: const Color(0xFF06B6D4),
      iconBgColor: const Color(0xFFCFFAFE),
      title: 'Overview',
      content:
          'Lamlayers is a design and scrapbook creation app that prioritizes user privacy. This guide explains how to request deletion of your account and associated data.',
    );
  }

  Widget _buildAccountTypesSection(BuildContext context) {
    return _buildSection(
      context,
      icon: Icons.account_circle_rounded,
      iconColor: const Color(0xFF8B5CF6),
      iconBgColor: const Color(0xFFF5F3FF),
      title: 'Important: Accounts Are Optional',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: EdgeInsets.all(_getResponsivePadding(context)),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFF59E0B).withOpacity(0.3),
              ),
            ),
            child: Text(
              'Lamlayers does not require you to create an account to use the app. All core features work without any account registration.',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
                color: const Color(0xFF92400E),
                height: 1.6,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: _getResponsiveSpacing(context)),
          Text(
            'Account Types',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 15,
                tablet: 16,
                desktop: 17,
              ),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'The only account option available is Google Sign-In, which is completely optional and only used for:',
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
            'Sharing your Lambooks (flip books) via Google Drive',
          ),
          _buildBulletPoint(
            context,
            'Uploading files to Google Drive for web viewing',
          ),
          SizedBox(height: 8),
          Container(
            padding: EdgeInsets.all(_getResponsivePadding(context) * 0.75),
            decoration: BoxDecoration(
              color: const Color(0xFFD1FAE5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.check_circle_rounded,
                  color: const Color(0xFF10B981),
                  size: _getResponsiveFontSize(
                    context,
                    mobile: 20,
                    tablet: 22,
                    desktop: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'If you have never used the "Share via Google Drive" feature, you do not have an account with Lamlayers.',
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(
                        context,
                        mobile: 13,
                        tablet: 14,
                        desktop: 15,
                      ),
                      color: const Color(0xFF065F46),
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeleteLocalDataSection(BuildContext context) {
    return _buildSection(
      context,
      icon: Icons.phone_android_rounded,
      iconColor: const Color(0xFF10B981),
      iconBgColor: const Color(0xFFD1FAE5),
      title: 'Option 1: Delete Local Data (No Account Required)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'If you have not signed in with Google, all your data is stored locally on your device:',
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
          SizedBox(height: _getResponsiveSpacing(context)),
          Text(
            '1. Uninstall the app from your device',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 15,
                tablet: 16,
                desktop: 17,
              ),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'This permanently deletes all local data including:',
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
            'Your design projects (.lamlayers files stored in app)',
          ),
          _buildBulletPoint(context, 'Your scrapbooks/lambooks'),
          _buildBulletPoint(context, 'App settings and preferences'),
          _buildBulletPoint(context, 'Favorites and recent items'),
          _buildBulletPoint(context, 'All locally stored images and media'),
          SizedBox(height: _getResponsiveSpacing(context)),
          Text(
            '2. No additional action needed',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 15,
                tablet: 16,
                desktop: 17,
              ),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'All data is stored on your device and will be removed when you uninstall the app.',
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

  Widget _buildRevokeGoogleAccessSection(BuildContext context) {
    return _buildSection(
      context,
      icon: Icons.cloud_rounded,
      iconColor: const Color(0xFF3B82F6),
      iconBgColor: const Color(0xFFDBEAFE),
      title:
          'Option 2: Revoke Google Sign-In Access (If You Used Google Drive Sharing)',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'If you have signed in with Google to share files via Google Drive:',
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
          SizedBox(height: _getResponsiveSpacing(context)),
          Text(
            '1. Revoke Google Account Access:',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 15,
                tablet: 16,
                desktop: 17,
              ),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8),
          _buildBulletPoint(context, 'Go to your Google Account Settings'),
          _buildBulletPoint(
            context,
            'Find "Lamlayers" or "Third-party apps with account access"',
          ),
          _buildBulletPoint(
            context,
            'Click "Remove Access" or "Revoke Access"',
          ),
          _buildBulletPoint(
            context,
            'This removes Lamlayers\' access to your Google account',
          ),
          SizedBox(height: 8),
          _buildLinkButton(
            context,
            'Open Google Account Settings',
            'https://myaccount.google.com/permissions',
            Icons.settings_rounded,
          ),
          SizedBox(height: _getResponsiveSpacing(context)),
          Text(
            '2. Delete Files from Google Drive (if desired):',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 15,
                tablet: 16,
                desktop: 17,
              ),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8),
          _buildBulletPoint(context, 'Go to Google Drive'),
          _buildBulletPoint(
            context,
            'Search for files with .lambook extension that you uploaded',
          ),
          _buildBulletPoint(context, 'Delete any files you want to remove'),
          _buildBulletPoint(
            context,
            'Note: Files uploaded to Google Drive are stored in your Google account, not in Lamlayers\' servers',
          ),
          SizedBox(height: 8),
          _buildLinkButton(
            context,
            'Open Google Drive',
            'https://drive.google.com',
            Icons.folder_rounded,
          ),
          SizedBox(height: _getResponsiveSpacing(context)),
          Text(
            '3. Uninstall the app from your device to remove all local data',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 15,
                tablet: 16,
                desktop: 17,
              ),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataDeletedSection(BuildContext context) {
    return _buildSection(
      context,
      icon: Icons.checklist_rounded,
      iconColor: const Color(0xFF10B981),
      iconBgColor: const Color(0xFFD1FAE5),
      title: 'What Data Is Deleted',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Local Data (Stored on Your Device)',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 15,
                tablet: 16,
                desktop: 17,
              ),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'When you uninstall the app, the following data is permanently deleted:',
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
          _buildBulletPoint(context, 'All design projects and posters'),
          _buildBulletPoint(context, 'All scrapbooks/lambooks'),
          _buildBulletPoint(context, 'App settings and preferences'),
          _buildBulletPoint(context, 'Font favorites and color history'),
          _buildBulletPoint(
            context,
            'Images and media stored in app\'s local database',
          ),
          _buildBulletPoint(context, 'All user-created content'),
          SizedBox(height: _getResponsiveSpacing(context)),
          Text(
            'Google Account Data',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 15,
                tablet: 16,
                desktop: 17,
              ),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'When you revoke Google Sign-In access:',
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
            'Lamlayers\' access to your Google account is removed',
          ),
          _buildBulletPoint(
            context,
            'No data is stored on Lamlayers servers (we don\'t have servers)',
          ),
          Container(
            margin: EdgeInsets.only(top: 8),
            padding: EdgeInsets.all(_getResponsivePadding(context) * 0.75),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF3C7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: const Color(0xFFF59E0B),
                  size: _getResponsiveFontSize(
                    context,
                    mobile: 20,
                    tablet: 22,
                    desktop: 24,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Files you uploaded to Google Drive remain in your Google Drive until you delete them manually',
                    style: TextStyle(
                      fontSize: _getResponsiveFontSize(
                        context,
                        mobile: 13,
                        tablet: 14,
                        desktop: 15,
                      ),
                      color: const Color(0xFF92400E),
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataRetentionSection(BuildContext context) {
    return _buildSection(
      context,
      icon: Icons.timelapse_rounded,
      iconColor: const Color(0xFFF59E0B),
      iconBgColor: const Color(0xFFFEF3C7),
      title: 'Data Retention',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildBulletPoint(
            context,
            'Local Data: Deleted immediately when you uninstall the app',
          ),
          _buildBulletPoint(
            context,
            'Google Sign-In: Access revoked immediately when you remove it from your Google Account settings',
          ),
          _buildBulletPoint(
            context,
            'Google Drive Files: Retained in your Google Drive account until you delete them (these are in your Google account, not Lamlayers)',
          ),
        ],
      ),
    );
  }

  Widget _buildAdditionalInfoSection(BuildContext context) {
    return _buildSection(
      context,
      icon: Icons.storage_rounded,
      iconColor: const Color(0xFF8B5CF6),
      iconBgColor: const Color(0xFFF5F3FF),
      title: 'Additional Information',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'We Don\'t Store Your Data on Our Servers',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 15,
                tablet: 16,
                desktop: 17,
              ),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Lamlayers does not operate any servers that store your personal data. All data is either:',
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
            'Stored locally on your device (Hive database)',
          ),
          _buildBulletPoint(
            context,
            'Stored in your Google Drive account (if you chose to upload files)',
          ),
          SizedBox(height: _getResponsiveSpacing(context)),
          Text(
            'No Account Registration Required',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 15,
                tablet: 16,
                desktop: 17,
              ),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Since there is no account registration system in the app:',
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
            'There is no account to "delete" in the traditional sense',
          ),
          _buildBulletPoint(
            context,
            'Simply uninstalling the app removes all local data',
          ),
          _buildBulletPoint(
            context,
            'Revoking Google Sign-In access removes any account connection',
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection(BuildContext context) {
    return _buildSection(
      context,
      icon: Icons.contact_support_rounded,
      iconColor: const Color(0xFF06B6D4),
      iconBgColor: const Color(0xFFCFFAFE),
      title: 'Contact for Additional Help',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'If you need assistance with data deletion or have questions:',
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
          SizedBox(height: _getResponsiveSpacing(context)),
          Container(
            padding: EdgeInsets.all(_getResponsivePadding(context)),
            decoration: BoxDecoration(
              color: const Color(0xFFCFFAFE).withOpacity(0.5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF06B6D4).withOpacity(0.3),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(
                  context,
                  'Developer:',
                  'ZenithSyntax',
                  Icons.person_rounded,
                ),
                SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  'App Name:',
                  'Lamlayers',
                  Icons.apps_rounded,
                ),
                SizedBox(height: 8),
                _buildInfoRow(
                  context,
                  'Package Name:',
                  'com.zenithsyntax.lamlayers',
                  Icons.code_rounded,
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
          Text(
            'For support, please contact us through the app\'s settings screen or via the Google Play Store listing.',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 13,
                tablet: 14,
                desktop: 15,
              ),
              color: const Color(0xFF64748B),
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: const Color(0xFF06B6D4),
          size: _getResponsiveFontSize(
            context,
            mobile: 18,
            tablet: 20,
            desktop: 22,
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(
                    context,
                    mobile: 12,
                    tablet: 13,
                    desktop: 14,
                  ),
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF0E7490),
                ),
              ),
              SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(
                    context,
                    mobile: 13,
                    tablet: 14,
                    desktop: 15,
                  ),
                  color: const Color(0xFF0E7490),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(_getResponsivePadding(context) * 1.5),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFFEF4444).withOpacity(0.1),
            const Color(0xFFF59E0B).withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.summarize_rounded,
                color: const Color(0xFFEF4444),
                size: _getResponsiveFontSize(
                  context,
                  mobile: 32,
                  tablet: 36,
                  desktop: 40,
                ),
              ),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Summary',
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
              ),
            ],
          ),
          SizedBox(height: _getResponsiveSpacing(context)),
          Text(
            'To delete all your Lamlayers data:',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 15,
                tablet: 16,
                desktop: 17,
              ),
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0F172A),
            ),
          ),
          SizedBox(height: 8),
          Text(
            '1. If you used Google Drive sharing:',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 14,
                tablet: 15,
                desktop: 16,
              ),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
          SizedBox(height: 4),
          Padding(
            padding: EdgeInsets.only(left: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '• Revoke access in Google Account Settings',
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
                Text(
                  '• Delete any uploaded files from Google Drive (optional)',
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
              ],
            ),
          ),
          SizedBox(height: 8),
          Text(
            '2. Uninstall the app from your device',
            style: TextStyle(
              fontSize: _getResponsiveFontSize(
                context,
                mobile: 14,
                tablet: 15,
                desktop: 16,
              ),
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
          SizedBox(height: _getResponsiveSpacing(context)),
          Container(
            padding: EdgeInsets.all(_getResponsivePadding(context) * 0.75),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              'That\'s it! All your local data will be permanently deleted, and any Google account connection will be removed.',
              style: TextStyle(
                fontSize: _getResponsiveFontSize(
                  context,
                  mobile: 13,
                  tablet: 14,
                  desktop: 15,
                ),
                color: const Color(0xFF0F172A),
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(height: _getResponsiveSpacing(context)),
          Row(
            children: [
              Icon(
                Icons.update_rounded,
                color: const Color(0xFF64748B),
                size: _getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Last updated: ${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(
                    context,
                    mobile: 12,
                    tablet: 13,
                    desktop: 14,
                  ),
                  color: const Color(0xFF64748B),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
          SizedBox(height: 4),
          Row(
            children: [
              Icon(
                Icons.tag_rounded,
                color: const Color(0xFF64748B),
                size: _getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
              ),
              SizedBox(width: 8),
              Text(
                'Version: 1.0',
                style: TextStyle(
                  fontSize: _getResponsiveFontSize(
                    context,
                    mobile: 12,
                    tablet: 13,
                    desktop: 14,
                  ),
                  color: const Color(0xFF64748B),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
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
              color: const Color(0xFF8B5CF6),
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

  Widget _buildLinkButton(
    BuildContext context,
    String text,
    String url,
    IconData icon,
  ) {
    return InkWell(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        }
      },
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: _getResponsivePadding(context),
          vertical: 12,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF3B82F6),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: _getResponsiveFontSize(
                context,
                mobile: 18,
                tablet: 20,
                desktop: 22,
              ),
            ),
            SizedBox(width: 8),
            Text(
              text,
              style: TextStyle(
                fontSize: _getResponsiveFontSize(
                  context,
                  mobile: 14,
                  tablet: 15,
                  desktop: 16,
                ),
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(width: 4),
            Icon(
              Icons.open_in_new_rounded,
              color: Colors.white,
              size: _getResponsiveFontSize(
                context,
                mobile: 16,
                tablet: 18,
                desktop: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
