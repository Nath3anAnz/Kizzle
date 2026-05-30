import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LeaderboardPage extends StatefulWidget {
  final String kategori;

  const LeaderboardPage({
    super.key,
    required this.kategori,
  });

  @override
  State<LeaderboardPage> createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            "Leaderboard: ${widget.kategori}",
            style: const TextStyle(
              fontFamily: 'Jua',
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          backgroundColor: Colors.orange,
          iconTheme: const IconThemeData(color: Colors.white),
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            indicatorWeight: 4,
            tabs: [
              Tab(text: "Easy"),
              Tab(text: "Medium"),
              Tab(text: "Hard"),
            ],
          ),
        ),
        body: Container(
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage('assets/images/background_level.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: TabBarView(
            children: [
              _buildLeaderboardStream("1"),
              _buildLeaderboardStream("2"),
              _buildLeaderboardStream("3"),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLeaderboardStream(String levelFilter) {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('leaderboard')
          .where('kategori', isEqualTo: widget.kategori)
          .where('level', isEqualTo: levelFilter)
          .orderBy('stars', descending: true)
          .orderBy('waktu', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          );
        }

        if (snapshot.hasError) {
          debugPrint("Leaderboard Error: ${snapshot.error}");

          return Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                "Data leaderboard belum siap.\nCek Firebase Index jika diperlukan.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PalanquinDark',
                  color: Colors.redAccent,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        if (docs.isEmpty) {
          return Center(
            child: Container(
              margin: const EdgeInsets.all(24),
              padding: const EdgeInsets.all(22),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.92),
                borderRadius: BorderRadius.circular(24),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: const Text(
                "Belum ada rekor nih!",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'PalanquinDark',
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueAccent,
                ),
              ),
            ),
          );
        }

        return SafeArea(
          child: Column(
            children: [
              _buildLeaderboardInfo(docs.length),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                  physics: const AlwaysScrollableScrollPhysics(),
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    final data = docs[index].data();

                    final String nama = _readString(data['nama'], 'Tanpa Nama');
                    final int waktu = _readInt(data['waktu']);
                    final int stars = _readInt(data['stars']).clamp(0, 3);

                    return _buildPlayerCard(
                      name: nama,
                      waktu: waktu,
                      stars: stars,
                      rank: index + 1,
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLeaderboardInfo(int totalPlayers) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.92),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.8),
          width: 1.5,
        ),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.leaderboard_rounded,
            color: Colors.orange,
            size: 22,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              "Menampilkan $totalPlayers pemain",
              style: const TextStyle(
                fontFamily: 'PalanquinDark',
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),
          const Text(
            "Scroll ↓",
            style: TextStyle(
              fontFamily: 'PalanquinDark',
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.blueAccent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlayerCard({
    required String name,
    required int waktu,
    required int stars,
    required int rank,
  }) {
    final bool isTopRank = rank <= 3;

    Color medalColor;
    IconData medalIcon = Icons.military_tech;
    Border? cardBorder;

    if (rank == 1) {
      medalColor = Colors.amber;
      cardBorder = Border.all(color: Colors.amber, width: 2);
    } else if (rank == 2) {
      medalColor = Colors.grey.shade400;
    } else if (rank == 3) {
      medalColor = Colors.brown.shade400;
    } else {
      medalColor = Colors.black54;
      medalIcon = Icons.circle;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.96),
        borderRadius: BorderRadius.circular(20),
        border: cardBorder,
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 5,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: isTopRank
                ? Icon(
                    medalIcon,
                    color: medalColor,
                    size: 34,
                  )
                : Text(
                    "#$rank",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'PalanquinDark',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'PalanquinDark',
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: rank == 1 ? Colors.blueAccent : Colors.black87,
                  ),
                ),
                const SizedBox(height: 5),
                Row(
                  children: List.generate(
                    3,
                    (index) => Icon(
                      index < stars ? Icons.star : Icons.star_border,
                      color: Colors.orange,
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              "${waktu}s",
              style: const TextStyle(
                fontFamily: 'PalanquinDark',
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _readString(dynamic value, String fallback) {
    if (value == null) return fallback;

    final text = value.toString().trim();

    if (text.isEmpty) return fallback;

    return text;
  }

  int _readInt(dynamic value) {
    if (value == null) return 0;

    if (value is int) return value;

    if (value is double) return value.round();

    return int.tryParse(value.toString()) ?? 0;
  }
}