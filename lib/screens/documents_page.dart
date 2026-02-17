import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/app_constants.dart';
import '../widgets/glass_card.dart';

class DocumentsPage extends StatefulWidget {
  const DocumentsPage({super.key});

  @override
  State<DocumentsPage> createState() => _DocumentsPageState();
}

class _DocumentsPageState extends State<DocumentsPage> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  final List<DocumentItem> mockDocuments = [
    DocumentItem(
      name: 'Field Report - Q1 2024',
      type: 'PDF',
      size: '2.4 MB',
      date: 'Mar 15, 2024',
      icon: Icons.picture_as_pdf,
      color: Colors.red,
    ),
    DocumentItem(
      name: 'Harvest Analysis',
      type: 'Excel',
      size: '1.8 MB',
      date: 'Mar 10, 2024',
      icon: Icons.table_chart,
      color: Colors.green,
    ),
    DocumentItem(
      name: 'Soil Test Results',
      type: 'PDF',
      size: '3.2 MB',
      date: 'Feb 28, 2024',
      icon: Icons.picture_as_pdf,
      color: Colors.red,
    ),
    DocumentItem(
      name: 'Equipment Maintenance Log',
      type: 'Word',
      size: '890 KB',
      date: 'Feb 20, 2024',
      icon: Icons.description,
      color: Colors.blue,
    ),
    DocumentItem(
      name: 'Annual Budget Report',
      type: 'PDF',
      size: '5.1 MB',
      date: 'Jan 30, 2024',
      icon: Icons.picture_as_pdf,
      color: Colors.red,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth < 600 ? 1 : screenWidth < 1200 ? 2 : 3;

    return SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 110),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            // Header
            Row(
              children: [
                Icon(Icons.description_outlined, color: AppConstants.limeGreen, size: 32),
                const SizedBox(width: 12),
                Text(
                  'Documents',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Access and manage farm documents',
              style: GoogleFonts.spaceGrotesk(
                fontSize: 14,
                color: isDark ? Colors.white70 : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            // Storage Summary
            GlassCard(
              intensity: GlassIntensity.medium,
              padding: const EdgeInsets.all(24),
              child: Row(
                children: [
                  Icon(Icons.folder_outlined, color: AppConstants.limeGreen, size: 48),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Storage Used',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 14,
                            color: isDark ? Colors.white70 : Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '13.4 GB / 50 GB',
                          style: GoogleFonts.spaceGrotesk(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: 0.268,
                            minHeight: 8,
                            backgroundColor: isDark ? Colors.white24 : Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(AppConstants.limeGreen),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
            // Documents Grid
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.5,
              ),
              itemCount: mockDocuments.length,
              itemBuilder: (context, index) {
                final doc = mockDocuments[index];
                return GlassCard(
                  intensity: GlassIntensity.medium,
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(doc.icon, color: doc.color, size: 32),
                          const Spacer(),
                          Icon(Icons.more_vert, color: isDark ? Colors.white70 : Colors.grey[600]),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        doc.name,
                        style: GoogleFonts.spaceGrotesk(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            doc.size,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.grey[600],
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '•',
                            style: TextStyle(color: isDark ? Colors.white60 : Colors.grey[600]),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            doc.date,
                            style: GoogleFonts.spaceGrotesk(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      );
  }
}

class DocumentItem {
  final String name;
  final String type;
  final String size;
  final String date;
  final IconData icon;
  final Color color;

  DocumentItem({
    required this.name,
    required this.type,
    required this.size,
    required this.date,
    required this.icon,
    required this.color,
  });
}
