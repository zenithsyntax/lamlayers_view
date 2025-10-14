import 'package:flutter/material.dart';

// Minimal metadata for a .lambook to drive the read-only UI
class LambookMeta {
  final String id;
  final String name;
  final double pageWidth;
  final double pageHeight;
  final Color scaffoldBgColor;
  final String? scaffoldBgImagePath;
  final Color leftCoverColor;
  final String? leftCoverImagePath;
  final Color rightCoverColor;
  final String? rightCoverImagePath;

  LambookMeta({
    required this.id,
    required this.name,
    required this.pageWidth,
    required this.pageHeight,
    required this.scaffoldBgColor,
    this.scaffoldBgImagePath,
    required this.leftCoverColor,
    this.leftCoverImagePath,
    required this.rightCoverColor,
    this.rightCoverImagePath,
  });
}

// In-memory parsed .lambook content
class LambookData {
  final LambookMeta meta;
  final List<LambookPage> pages;

  LambookData({required this.meta, required this.pages});
}

// Simplified page data for viewer
class LambookPage {
  final String id;
  final String name;
  final Color backgroundColor;
  final String? thumbnailPath;
  final String? backgroundImagePath;

  LambookPage({
    required this.id,
    required this.name,
    required this.backgroundColor,
    this.thumbnailPath,
    this.backgroundImagePath,
  });
}
