import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  void _sharePrivacyPolicy(BuildContext context) {
    Share.share(
      'Privacy Policy - Emperor Smart Solutions\n'
      'Our utility applications operate 100% locally on your device. Your data remains strictly stored on your device and is never uploaded to external servers.',
      subject: 'Daily Cashbook - Privacy Policy',
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final accentBlue = isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7);
    final subtextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.open_in_new),
            tooltip: 'Share Privacy Policy',
            onPressed: () => _sharePrivacyPolicy(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          children: [
            // Top Policy Title Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF1E3A5F) : const Color(0xFFE0F2FE),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.shield_outlined,
                          color: Color(0xFF0284C7),
                          size: 28,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Privacy Policy',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Emperor Smart Solutions',
                              style: TextStyle(fontSize: 13, color: subtextColor),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: borderColor),
                  const SizedBox(height: 12),
                  Wrap(
                    alignment: WrapAlignment.spaceBetween,
                    spacing: 12,
                    runSpacing: 4,
                    children: [
                      Text(
                        'Effective Date: September 21, 2026',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: accentBlue),
                      ),
                      Text(
                        'Last Updated: September 21, 2026',
                        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: accentBlue),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Policy Content Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildPolicySection(
                    title: '1. Overview',
                    content:
                        'Emperor Smart Solutions ("we", "us", "our", or "Company") develops and publishes mobile applications, including utility and productivity tools available through Google Play and other supported platforms. This Privacy Policy explains how we handle information in our mobile applications.\n\n'
                        'This Privacy Policy applies to all our applications that link to this policy, including utility apps such as frame generators, calculators, converters, productivity tools, and document utilities. By using one of our applications, you acknowledge the practices described in this Privacy Policy.',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                  _buildPolicySection(
                    title: '2. Information We Collect',
                    content:
                        'The information handled by an application depends on the specific features and services used in that application.',
                    isDark: isDark,
                    bulletPoints: const [
                      MapEntry(
                        'Information You Provide: ',
                        'Our basic utility applications generally do not require account creation, registration, or submission of personal information such as your name, email address, or phone number. Any data entered into local tools remains processed on your device.',
                      ),
                      MapEntry(
                        'Device and Technical Data: ',
                        'Limited non-identifying technical data may be processed automatically, such as device model, OS version, language preference, system performance metrics, and app stability reports.',
                      ),
                      MapEntry(
                        'Storage and Media Access: ',
                        'For applications that handle images, files, or custom exports, access to local device storage is requested solely with your explicit permission to perform requested user actions.',
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  _buildPolicySection(
                    title: '3. How We Use Information',
                    content:
                        'We process data strictly to provide, operate, maintain, and improve application functionality, fulfill user requests, diagnose technical issues, and enforce security standards.',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                  _buildPolicySection(
                    title: '4. Local Processing & Data Privacy',
                    content:
                        'Our utility applications operate 100% locally on your device. Your images, edits, calculations, and custom content remain strictly stored on your device and are never uploaded, transmitted, or stored on external servers.',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 20),
                  _buildPolicySection(
                    title: '5. Advertising & Analytics',
                    content:
                        'Applications may incorporate standard third-party services (such as Google AdMob, Firebase Analytics, or Google Play Services) to deliver in-app ads or track general performance metrics. These services may collect device identifiers in accordance with their privacy policies.',
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildPolicySection({
    required String title,
    required String content,
    required bool isDark,
    List<MapEntry<String, String>>? bulletPoints,
  }) {
    final textColor = isDark ? Colors.grey[300] : Colors.grey[800];
    final titleColor = isDark ? Colors.white : Colors.black;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: titleColor,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            fontSize: 13,
            height: 1.55,
            color: textColor,
          ),
        ),
        if (bulletPoints != null) ...[
          const SizedBox(height: 10),
          ...bulletPoints.map((bp) => Padding(
                padding: const EdgeInsets.only(bottom: 10, left: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: isDark ? const Color(0xFF38BDF8) : const Color(0xFF0284C7),
                      ),
                    ),
                    Expanded(
                      child: RichText(
                        text: TextSpan(
                          style: TextStyle(fontSize: 13, height: 1.5, color: textColor),
                          children: [
                            TextSpan(
                              text: bp.key,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            TextSpan(text: bp.value),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ],
    );
  }
}
