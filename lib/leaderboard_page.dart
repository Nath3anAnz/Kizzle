import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firebase

class LeaderboardPage extends StatefulWidget {
  final String kategori;
  const LeaderboardPage({super.key, required this.kategori});

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
              _buildLeaderboardStream("1"), // Easy
              _buildLeaderboardStream("2"), // Medium
              _buildLeaderboardStream("3"), // Hard
            ],
          ),
        ),
      ),
    );
  }

  // --- FUNGSI BARU: NAMPILIN DATA REAL-TIME DARI FIREBASE ---
  Widget _buildLeaderboardStream(String levelFilter) {
    return StreamBuilder<QuerySnapshot>(
      // Kita query datanya: Filter berdasarkan kategori & level, lalu urutkan bintang terbanyak, baru waktu tercepat
      stream: FirebaseFirestore.instance
          .collection('leaderboard')
          .where('kategori', isEqualTo: widget.kategori)
          .where('level', isEqualTo: levelFilter)
          .orderBy('stars', descending: true) // Bintang paling banyak di atas
          .orderBy(
            'waktu',
            descending: false,
          ) // Waktu paling sedikit (cepet) di atas
          .snapshots(),
      builder: (context, snapshot) {
        // Kalau lagi loading ngambil data
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: Colors.orange),
          );
        }

        // Kalau ada error (termasuk error butuh bikin Index di Firebase)
        if (snapshot.hasError) {
          debugPrint("Leaderboard Error: ${snapshot.error}");
          return const Center(
            child: Text(
              "Data belum siap.\nCek console buat bikin Index!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'PalanquinDark',
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
          );
        }

        // Kalau datanya kosong / belum ada yang main
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text(
              "Belum ada rekor nih!",
              style: TextStyle(
                fontFamily: 'PalanquinDark',
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.blue,
              ),
            ),
          );
        }

        // Kalau datanya ada, kita ekstrak dan tampilkan ke ListView
        final docs = snapshot.data!.docs;

        return ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            var data = docs[index].data() as Map<String, dynamic>;

            // Amankan tipe datanya biar nggak crash
            String nama = data['nama'] ?? 'Tanpa Nama';
            int waktu = data['waktu'] is int
                ? data['waktu']
                : int.tryParse(data['waktu'].toString()) ?? 0;
            int stars = data['stars'] is int
                ? data['stars']
                : int.tryParse(data['stars'].toString()) ?? 0;

            return _buildPlayerCard(nama, waktu, stars, index + 1);
          },
        );
      },
    );
  }

  // Widget desain kartunya tetap sama persis seperti yang lu buat!
  Widget _buildPlayerCard(String name, int waktu, int stars, int rank) {
    Color medalColor;
    IconData medalIcon = Icons.military_tech;
    Border? cardBorder;

    if (rank == 1) {
      medalColor = Colors.amber; // Emas
      cardBorder = Border.all(
        color: Colors.amber,
        width: 2,
      ); // Bingkai emas buat juara 1
    } else if (rank == 2) {
      medalColor = Colors.grey.shade400; // Perak
    } else if (rank == 3) {
      medalColor = Colors.brown.shade400; // Perunggu
    } else {
      medalColor = Colors.transparent;
      medalIcon = Icons.circle; // Polos buat rank 4 ke atas
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: cardBorder,
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 5, offset: Offset(0, 3)),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: rank <= 3
                ? Icon(medalIcon, color: medalColor, size: 35)
                : Text(
                    "#$rank",
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'PalanquinDark',
                      fontSize: 20,
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
                  style: TextStyle(
                    fontFamily: 'PalanquinDark',
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: rank == 1 ? Colors.blueAccent : Colors.black,
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
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              "${waktu}s",
              style: const TextStyle(
                fontFamily: 'PalanquinDark',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
