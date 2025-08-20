import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  _HistoryPageState createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    if (_currentUser == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.person_off,
              color: Colors.grey[600],
              size: 64,
            ),
            SizedBox(height: 20),
            Text(
              'Please log in to see your history.',
              style: GoogleFonts.cinzel(
                color: Colors.grey[400],
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(_currentUser!.uid)
          .collection('historyOfSpells')
          .orderBy('castedAt', descending: true)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  color: Colors.red[600],
                  strokeWidth: 3,
                ),
                SizedBox(height: 20),
                Text(
                  'Conjuring your grimoire...',
                  style: GoogleFonts.cinzel(
                    color: Colors.grey[500],
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red[400],
                  size: 64,
                ),
                SizedBox(height: 20),
                Text(
                  'Failed to conjure your history.',
                  style: GoogleFonts.cinzel(
                    color: Colors.red[300],
                    fontSize: 16,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'The spirits are restless...',
                  style: GoogleFonts.metamorphous(
                    color: Colors.grey[500],
                    fontSize: 12,
                  ),
                ),
                SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    setState(() {}); // Rebuild to retry
                  },
                  icon: Icon(Icons.refresh, color: Colors.white),
                  label: Text(
                    'Retry Ritual',
                    style: GoogleFonts.metamorphous(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red[900],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.auto_stories,
                  color: Colors.grey[600],
                  size: 64,
                ),
                SizedBox(height: 20),
                Text(
                  'Your Grimoire is Empty',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.cinzel(
                    color: Colors.grey[400],
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'No spells have been cast yet.\nBegin your dark journey...',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.metamorphous(
                    color: Colors.grey[500],
                    fontSize: 14,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          );
        }

        var spellDocs = snapshot.data!.docs;

        return Column(
          children: [
            // Header with spell count
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    Icons.auto_stories,
                    color: Colors.red[400],
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Spell Archives',
                    style: GoogleFonts.cinzel(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.red[900]?.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.red[600]!.withOpacity(0.5)),
                    ),
                    child: Text(
                      '${spellDocs.length} Spells',
                      style: GoogleFonts.metamorphous(
                        color: Colors.red[300],
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Spells list
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.fromLTRB(12.0, 0, 12.0, 12.0),
                itemCount: spellDocs.length,
                itemBuilder: (context, index) {
                  var spellData = spellDocs[index].data() as Map<String, dynamic>;
                  return _buildSpellCard(spellData, index);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSpellCard(Map<String, dynamic> spellData, int index) {
    // Safely get data with fallbacks
    final String enemyName = spellData['enemyName'] ?? 'Unknown Target';
    final double intensity = (spellData['intensity'] ?? 1.0).toDouble();
    final Timestamp? castedAtTimestamp = spellData['castedAt'];
    final String spellName = spellData['spellName'] ?? 'Koodothram';
    final String? nakshathram = spellData['nakshathram'];
    final String? enemyEmail = spellData['enemyEmail'];

    // Format the date
    String formattedDate = 'Unknown Time';
    if (castedAtTimestamp != null) {
      formattedDate = DateFormat('MMMM d, yyyy \'at\' h:mm a').format(castedAtTimestamp.toDate());
    }

    // Get intensity color
    Color intensityColor = _getIntensityColor(intensity);
    String intensityText = _getIntensityText(intensity);
    String intensityEmoji = _getIntensityEmoji(intensity);

    return Card(
      color: Colors.grey[900]?.withOpacity(0.8),
      margin: const EdgeInsets.only(bottom: 16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: intensityColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[900]!.withOpacity(0.9),
              Colors.black.withOpacity(0.8),
            ],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with spell name and index
              Row(
                children: [
                  Expanded(
                    child: Text(
                      spellName,
                      style: GoogleFonts.creepster(
                        color: Colors.white,
                        fontSize: 20,
                        letterSpacing: 1.5,
                        shadows: [
                          Shadow(
                            color: intensityColor.withOpacity(0.5),
                            blurRadius: 8,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.grey[800]?.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '#${index + 1}',
                      style: GoogleFonts.metamorphous(
                        color: Colors.grey[400],
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 12),

              // Target info
              Row(
                children: [
                  Icon(
                    Icons.person,
                    color: Colors.grey[400],
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Target: ',
                    style: GoogleFonts.cinzel(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      enemyName,
                      style: GoogleFonts.cinzel(
                        color: Colors.grey[300],
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),

              // Show email if available
              if (enemyEmail != null && enemyEmail.isNotEmpty) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.email,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        enemyEmail,
                        style: GoogleFonts.metamorphous(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ],

              // Show nakshathram if available
              if (nakshathram != null && nakshathram.isNotEmpty) ...[
                SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      Icons.star,
                      color: Colors.grey[400],
                      size: 16,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Nakshathram: ',
                      style: GoogleFonts.cinzel(
                        color: Colors.grey[400],
                        fontSize: 14,
                      ),
                    ),
                    Text(
                      nakshathram,
                      style: GoogleFonts.metamorphous(
                        color: Colors.grey[300],
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ],

              SizedBox(height: 12),

              // Intensity row
              Row(
                children: [
                  Icon(
                    Icons.whatshot,
                    color: intensityColor,
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Intensity: ',
                    style: GoogleFonts.cinzel(
                      color: Colors.grey[400],
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${intensity.toInt()}/10',
                    style: GoogleFonts.metalMania(
                      color: intensityColor,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    intensityEmoji,
                    style: TextStyle(fontSize: 16),
                  ),
                  SizedBox(width: 8),
                  Text(
                    intensityText,
                    style: GoogleFonts.metamorphous(
                      color: intensityColor.withOpacity(0.8),
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 16),

              // Date footer
              Container(
                padding: EdgeInsets.symmetric(vertical: 8),
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(
                      color: Colors.grey[700]!.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Colors.grey[500],
                      size: 14,
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Sealed on: $formattedDate',
                      style: GoogleFonts.cinzel(
                        color: Colors.grey[500],
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper methods for intensity styling
  Color _getIntensityColor(double intensity) {
    if (intensity <= 2) return Color(0xFFFF6B35); // Orange
    if (intensity <= 4) return Color(0xFFDC143C); // Crimson
    if (intensity <= 6) return Color(0xFFFF1493); // Deep Pink
    if (intensity <= 8) return Color(0xFF8B008B); // Dark Magenta
    return Color(0xFF4B0082); // Indigo
  }

  String _getIntensityText(double intensity) {
    if (intensity <= 2) return 'Mild Curse';
    if (intensity <= 4) return 'Dark Wish';
    if (intensity <= 6) return 'Deadly Curse';
    if (intensity <= 8) return 'Ancient Hex';
    return 'Ultimate Doom';
  }

  String _getIntensityEmoji(double intensity) {
    if (intensity <= 2) return '😈';
    if (intensity <= 4) return '👹';
    if (intensity <= 6) return '💀';
    if (intensity <= 8) return '⚰️';
    return '☠️';
  }
}