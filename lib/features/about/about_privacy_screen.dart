import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../app/routes.dart';
import '../../shared/widgets/brand_logos.dart';

class AboutPrivacyScreen extends StatelessWidget {
  const AboutPrivacyScreen({super.key});

  static const String instagramUrl = 'https://www.instagram.com/emperorsmartsolutions';
  static const String linkedinUrl = 'https://www.linkedin.com/company/emperor-smart-solutions/';
  static const String officeAddress = '202, Shitiratna Complex, Panchvati, Navrangpura, Ahmedabad - 380009, Gujarat, India';
  static const String googleMapsUrl = 'https://maps.google.com/?q=202,+Shitiratna+Complex,+Panchvati,+Navrangpura,+Ahmedabad+-+380009,+Gujarat,+India';

  Future<void> _launchURL(BuildContext context, String urlString) async {
    final Uri uri = Uri.parse(urlString);
    try {
      bool launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched) {
        launched = await launchUrl(uri, mode: LaunchMode.platformDefault);
      }
      if (!launched) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Could not open link. Please check internet connection or browser settings.')),
          );
        }
      }
    } catch (e) {
      try {
        await launchUrl(uri);
      } catch (err) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open link: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final cardBg = isDark ? const Color(0xFF1E293B) : Colors.white;
    final borderColor = isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0);
    final sectionHeaderColor = isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5);

    return Scaffold(
      appBar: AppBar(
        title: const Text('About & Privacy', style: TextStyle(fontWeight: FontWeight.bold)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Description Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Text(
                'A professional, 100% offline daily cashbook app. Record cash in, cash out, track balances, categories, and generate reports without sending data to servers.',
                style: TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: isDark ? Colors.grey[300] : Colors.grey[700],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section 1: LEGAL & GOVERNANCE
            _buildSectionHeader('LEGAL & GOVERNANCE', sectionHeaderColor),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Material(
                color: Colors.transparent,
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  leading: Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF143823) : const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.shield_outlined,
                      color: Color(0xFF2E7D32),
                      size: 24,
                    ),
                  ),
                  title: const Text(
                    'Privacy Policy',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  subtitle: const Text(
                    'Read full data safety practices & privacy policy',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  trailing: const Icon(Icons.chevron_right, color: Colors.grey),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.privacyPolicy);
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Section 2: CONNECT WITH US
            _buildSectionHeader('CONNECT WITH US', sectionHeaderColor),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  // Instagram
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      leading: const InstagramRealLogo(size: 40),
                      title: const Text(
                        'Instagram',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: const Text(
                        'Follow Emperor Smart Solutions',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      trailing: const Icon(Icons.north_east, size: 20, color: Colors.grey),
                      onTap: () => _launchURL(context, instagramUrl),
                    ),
                  ),
                  Divider(height: 1, color: borderColor),

                  // LinkedIn
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                      leading: const LinkedInRealLogo(size: 40),
                      title: const Text(
                        'LinkedIn',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: const Text(
                        'Follow Emperor Smart Solutions',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      trailing: const Icon(Icons.north_east, size: 20, color: Colors.grey),
                      onTap: () => _launchURL(context, linkedinUrl),
                    ),
                  ),
                  Divider(height: 1, color: borderColor),

                  // Contact Us
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF143823) : const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.phone_outlined,
                          color: Color(0xFF10B981),
                          size: 24,
                        ),
                      ),
                      title: const Text(
                        'Contact Us',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: const Text(
                        '+91 63543 51080',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      trailing: const Icon(Icons.north_east, size: 20, color: Color(0xFF10B981)),
                      onTap: () => _launchURL(context, 'tel:+916354351080'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Section 3: DEVELOPER & LOCATION
            _buildSectionHeader('DEVELOPER', sectionHeaderColor),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: cardBg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: borderColor),
              ),
              child: Column(
                children: [
                  // Developer Company Card
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: isDark ? const Color(0xFF1F2445) : const Color(0xFFE8EAF6),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.domain,
                            color: Color(0xFF3F51B5),
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Emperor Smart Solutions',
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Emperor Smart Solutions develops software, mobile applications, digital products, and utility applications.',
                                style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.4),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1, color: borderColor),

                  // Interactive Address & Maps Tile
                  Material(
                    color: Colors.transparent,
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isDark ? const Color(0xFF3D211E) : const Color(0xFFFFEBEE),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.location_on_outlined,
                          color: Color(0xFFE53935),
                          size: 24,
                        ),
                      ),
                      title: const Text(
                        'Office Address',
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                      subtitle: const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text(
                          officeAddress,
                          style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.35),
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.map_outlined, color: sectionHeaderColor, size: 22),
                          const SizedBox(height: 2),
                          Text(
                            'View Map',
                            style: TextStyle(fontSize: 9, color: sectionHeaderColor, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      onTap: () => _launchURL(context, googleMapsUrl),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // Footer Copyright Notice
            Center(
              child: Text(
                '© 2026 Emperor Smart Solutions. All rights reserved.',
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.grey[500] : Colors.grey[600],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: color,
          letterSpacing: 1.1,
        ),
      ),
    );
  }
}
