import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/completed_project.dart';
import '../services/firestore_service.dart';

class CommunityScreen extends StatefulWidget {
  const CommunityScreen({super.key});

  @override
  State<CommunityScreen> createState() => _CommunityScreenState();
}

class _CommunityScreenState extends State<CommunityScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  late Future<double> _totalCO2Future;
  final double _targetCO2 = 1000.0; // Target is 1,000 kg

  @override
  void initState() {
    super.initState();
    _totalCO2Future = _firestoreService.getTotalCO2Saved();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Bar
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search Projects',
                    prefixIcon: const Icon(Icons.search, color: Colors.grey),
                    suffixIcon: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.tune, color: Colors.grey),
                        SizedBox(
                          height: 24,
                          child: VerticalDivider(
                            color: Colors.grey.withOpacity(0.5),
                            thickness: 1,
                          ),
                        ),
                        const Icon(Icons.sort, color: Colors.grey),
                      ],
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 14.0,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _searchQuery = value;
                    });
                  },
                ),
              ),
            ),

            // Monthly Challenge Card
            Container(
              margin:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                image: const DecorationImage(
                  image: NetworkImage('https://picsum.photos/800/300?blur=2'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.7),
                    ],
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.recycling,
                            color: Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'Monthly Challenge',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        '"Turn Plastic Bottles Into Planters!"',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),
                      FutureBuilder<double>(
                        future: _totalCO2Future,
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const LinearProgressIndicator(
                              backgroundColor: Colors.white24,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            );
                          }

                          final totalCO2 = snapshot.data ?? 0.0;
                          // Calculate percentage (capped at 100%)
                          final percentage =
                              (totalCO2 / _targetCO2).clamp(0.0, 1.0);
                          final percentDisplay = (percentage * 100).toInt();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(10),
                                child: LinearProgressIndicator(
                                  value: percentage,
                                  minHeight: 8,
                                  backgroundColor:
                                      Colors.white.withOpacity(0.3),
                                  valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                ),
                              ),
                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.public,
                                        color: Colors.white,
                                        size: 16,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'Global Progress: $percentDisplay%',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () {
                                      // Handle join challenge
                                    },
                                    icon: const Icon(Icons.add),
                                    label: const Text('Join Challenge'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: const Color(0xFF377047),
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 12),
                                      textStyle: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Project Feed Label
            const Padding(
              padding: EdgeInsets.only(left: 16.0, top: 16.0, bottom: 8.0),
              child: Text(
                'Project Feed',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),

            // Project Feed List
            _buildProjectFeed(),
          ],
        ),
      ),
    );
  }

  Widget _buildProjectFeed() {
    return StreamBuilder<List<CompletedProject>>(
      stream: _searchQuery.isEmpty
          ? _firestoreService.getAllCompletedProjects()
          : _firestoreService.searchCompletedProjects(_searchQuery),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        final projects = snapshot.data ?? [];

        if (projects.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                children: [
                  const Icon(
                    Icons.search_off,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _searchQuery.isEmpty
                        ? 'No projects found'
                        : 'No projects matching "$_searchQuery"',
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            return _buildProjectCard(project);
          },
        );
      },
    );
  }

  Widget _buildProjectCard(CompletedProject project) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFF377047),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Project Image
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  bottomLeft: Radius.circular(16),
                ),
                child: Image.network(
                  project.mainImageUrl,
                  width: 100,
                  height: 100,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      width: 100,
                      height: 100,
                      color: Colors.grey[300],
                      child: const Icon(Icons.image_not_supported,
                          color: Colors.white70),
                    );
                  },
                ),
              ),

              // Project details
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // User handle
                      const Text(
                        '@eco_maker23',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Project title
                      Text(
                        project.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Project description
                      Text(
                        'Made from ${_getMaterialsDescription(project.materialsUsed)}. Super easy!',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Engagement buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
            child: Row(
              children: [
                _buildEngagementButton(Icons.favorite_border, '25'),
                _buildEngagementButton(Icons.comment_outlined, '3'),
                _buildEngagementButton(Icons.share_outlined, '10'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEngagementButton(IconData icon, String count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 16,
          ),
          const SizedBox(width: 4),
          Text(
            count,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  String _getMaterialsDescription(Map<String, int> materials) {
    // Find the materials that were used (value > 0)
    final usedMaterials =
        materials.entries.where((entry) => entry.value > 0).toList();

    if (usedMaterials.isEmpty) {
      return 'recycled materials';
    }

    // Format the first material with count
    final firstMaterial = usedMaterials.first;
    final formattedMaterial =
        '${firstMaterial.value} used ${_formatMaterialName(firstMaterial.key)}';

    if (usedMaterials.length == 1) {
      return formattedMaterial;
    } else {
      return '$formattedMaterial and cardboard';
    }
  }

  String _formatMaterialName(String key) {
    // Convert snake_case to display format (e.g., 'plastic_bottle' -> 'bottles')
    if (key == 'plastic_bottle') return 'bottles';
    if (key == 'tin_can') return 'cans';
    if (key == 'bottle_cap') return 'bottle caps';

    // Default case: just remove underscore and return
    return key.replaceAll('_', ' ');
  }
}
