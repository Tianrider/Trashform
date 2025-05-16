import 'package:flutter/material.dart';
import '../models/detected_item.dart';
import '../models/recommendation.dart';
import 'step_by_step_guide_screen.dart';

class DetectionResultsScreen extends StatelessWidget {
  const DetectionResultsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Dummy data for detected items as provided
    final List<DetectedItem> detectedItems = [
      DetectedItem(
        count: 30,
        item: "Botol Plastik",
        recyclable: true,
      ),
      DetectedItem(
        count: 37,
        item: "Kaleng Aluminium",
        recyclable: true,
      ),
      DetectedItem(
        count: 14,
        item: "Tutup Plastik",
        recyclable: true,
      ),
      DetectedItem(
        count: 4,
        item: "Benda Plastik Kecil",
        recyclable: false,
        note:
            "Umumnya tidak dapat didaur ulang karena ukurannya yang kecil, terbuat dari material campuran, atau jenis plastiknya tidak diketahui.",
      ),
    ];

    // Dummy data for recommendations as provided
    final List<Recommendation> recommendations = [
      Recommendation(
        co2Saved: "3.2 kg",
        description:
            "Sebuah karya seni dinding abstrak yang dibuat dengan menggabungkan botol plastik yang dipotong dan dibentuk, kaleng aluminium yang dipipihkan dan dihias, dan tutup plastik yang disusun dalam pola yang menarik. Benda plastik kecil dapat digunakan sebagai elemen dekoratif tambahan.",
        imagePrompt:
            "Foto close-up dari karya seni dinding abstrak yang terbuat dari botol plastik yang dipotong dan diwarnai cerah, kaleng aluminium yang dipipihkan dan dihias, dan tutup plastik yang disusun dalam pola geometris. Karya seni tersebut dipasang di dinding putih. Pencahayaan yang artistik.",
        materials: {
          "aluminum_foil": 0,
          "bottle_cap": 14,
          "can": 0,
          "cardboard": 0,
          "cd_disc": 0,
          "egg_carton": 0,
          "fabric_scrap": 0,
          "glass_bottle": 0,
          "ice_cream_stick": 0,
          "jar_lid": 0,
          "metal_spoon": 0,
          "newspaper": 0,
          "old_button": 0,
          "old_magazine": 0,
          "paper": 0,
          "plastic_bag": 0,
          "plastic_bottle": 10,
          "popsicle_stick": 0,
          "rope": 0,
          "rubber_band": 0,
          "shoebox": 0,
          "straw": 0,
          "tin_can": 5,
          "toilet_paper_roll": 0,
          "wire": 0,
          "wood_scrap": 0,
          "yarn": 0,
        },
        name: "Karya Seni Dinding Abstrak dari Botol, Kaleng, dan Tutup",
        stepByStep: [
          "Potong dan bentuk botol plastik menjadi berbagai bentuk dan ukuran.",
          "Pipihkan kaleng aluminium dan hiasi dengan cat atau stiker.",
          "Susun tutup plastik dalam pola yang menarik di atas kanvas atau papan.",
          "Tempelkan potongan botol plastik dan kaleng aluminium ke kanvas.",
          "Tambahkan benda plastik kecil sebagai detail dekoratif.",
          "Gantung karya seni di dinding.",
        ],
      ),
      // Duplicate recommendations for UI demonstration
      Recommendation(
        co2Saved: "3.2 kg",
        description:
            "Sebuah karya seni dinding abstrak yang dibuat dengan menggabungkan botol plastik yang dipotong dan dibentuk, kaleng aluminium yang dipipihkan dan dihias, dan tutup plastik yang disusun dalam pola yang menarik. Benda plastik kecil dapat digunakan sebagai elemen dekoratif tambahan.",
        imagePrompt:
            "Foto close-up dari karya seni dinding abstrak yang terbuat dari botol plastik yang dipotong dan diwarnai cerah, kaleng aluminium yang dipipihkan dan dihias, dan tutup plastik yang disusun dalam pola geometris. Karya seni tersebut dipasang di dinding putih. Pencahayaan yang artistik.",
        materials: {
          "aluminum_foil": 0,
          "bottle_cap": 14,
          "can": 0,
          "cardboard": 0,
          "cd_disc": 0,
          "egg_carton": 0,
          "fabric_scrap": 0,
          "glass_bottle": 0,
          "ice_cream_stick": 0,
          "jar_lid": 0,
          "metal_spoon": 0,
          "newspaper": 0,
          "old_button": 0,
          "old_magazine": 0,
          "paper": 0,
          "plastic_bag": 0,
          "plastic_bottle": 10,
          "popsicle_stick": 0,
          "rope": 0,
          "rubber_band": 0,
          "shoebox": 0,
          "straw": 0,
          "tin_can": 5,
          "toilet_paper_roll": 0,
          "wire": 0,
          "wood_scrap": 0,
          "yarn": 0,
        },
        name: "Bottle Desk Organizer",
        stepByStep: [
          "Potong dan bentuk botol plastik menjadi berbagai bentuk dan ukuran.",
          "Pipihkan kaleng aluminium dan hiasi dengan cat atau stiker.",
          "Susun tutup plastik dalam pola yang menarik di atas kanvas atau papan.",
          "Tempelkan potongan botol plastik dan kaleng aluminium ke kanvas.",
          "Tambahkan benda plastik kecil sebagai detail dekoratif.",
          "Gantung karya seni di dinding.",
        ],
      ),
      Recommendation(
        co2Saved: "3.2 kg",
        description:
            "Sebuah karya seni dinding abstrak yang dibuat dengan menggabungkan botol plastik yang dipotong dan dibentuk, kaleng aluminium yang dipipihkan dan dihias, dan tutup plastik yang disusun dalam pola yang menarik. Benda plastik kecil dapat digunakan sebagai elemen dekoratif tambahan.",
        imagePrompt:
            "Foto close-up dari karya seni dinding abstrak yang terbuat dari botol plastik yang dipotong dan diwarnai cerah, kaleng aluminium yang dipipihkan dan dihias, dan tutup plastik yang disusun dalam pola geometris. Karya seni tersebut dipasang di dinding putih. Pencahayaan yang artistik.",
        materials: {
          "aluminum_foil": 0,
          "bottle_cap": 14,
          "can": 0,
          "cardboard": 0,
          "cd_disc": 0,
          "egg_carton": 0,
          "fabric_scrap": 0,
          "glass_bottle": 0,
          "ice_cream_stick": 0,
          "jar_lid": 0,
          "metal_spoon": 0,
          "newspaper": 0,
          "old_button": 0,
          "old_magazine": 0,
          "paper": 0,
          "plastic_bag": 0,
          "plastic_bottle": 10,
          "popsicle_stick": 0,
          "rope": 0,
          "rubber_band": 0,
          "shoebox": 0,
          "straw": 0,
          "tin_can": 5,
          "toilet_paper_roll": 0,
          "wire": 0,
          "wood_scrap": 0,
          "yarn": 0,
        },
        name: "Bottle Desk Organizer",
        stepByStep: [
          "Potong dan bentuk botol plastik menjadi berbagai bentuk dan ukuran.",
          "Pipihkan kaleng aluminium dan hiasi dengan cat atau stiker.",
          "Susun tutup plastik dalam pola yang menarik di atas kanvas atau papan.",
          "Tempelkan potongan botol plastik dan kaleng aluminium ke kanvas.",
          "Tambahkan benda plastik kecil sebagai detail dekoratif.",
          "Gantung karya seni di dinding.",
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF377047),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Detected Items',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Detected Items section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: detectedItems.length,
                  itemBuilder: (context, index) {
                    final item = detectedItems[index];
                    return _buildDetectedItemCard(item);
                  },
                ),
              ),
            ),

            // Recommendations section
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
              child: Text(
                'Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            ListView.builder(
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
              itemCount: recommendations.length,
              itemBuilder: (context, index) {
                return _buildRecommendationCard(
                    context, recommendations[index]);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetectedItemCard(DetectedItem item) {
    // Map item names to appropriate icons
    IconData getIconForItem(String itemName) {
      if (itemName.contains('Botol')) {
        return Icons.water_drop_outlined;
      } else if (itemName.contains('Kaleng')) {
        return Icons.inventory_2_outlined;
      } else if (itemName.contains('Tutup')) {
        return Icons.lens_outlined;
      } else {
        return Icons.widgets_outlined;
      }
    }

    return Container(
      width: 120,
      margin: const EdgeInsets.only(right: 10),
      child: Card(
        elevation: 0,
        color: const Color(0xFFF5F5F5),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Item icon based on type
              Icon(
                getIconForItem(item.item),
                size: 48,
              ),
              const SizedBox(height: 10),

              // Item name
              Text(
                item.item,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),

              // Count
              Text(
                'x${item.count}',
                style: const TextStyle(
                  color: Colors.grey,
                ),
              ),

              // Recyclable status
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: item.recyclable
                      ? Colors.green.withOpacity(0.1)
                      : Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle,
                      color: item.recyclable ? Colors.green : Colors.red,
                      size: 12,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      item.recyclable ? 'Recyclable' : 'Non-recyclable',
                      style: TextStyle(
                        color: item.recyclable ? Colors.green : Colors.red,
                        fontSize: 12,
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

  Widget _buildRecommendationCard(
      BuildContext context, Recommendation recommendation) {
    // Get the main materials used (those with quantity > 0)
    Map<String, int> mainMaterials = {};
    recommendation.materials.forEach((key, value) {
      if (value > 0) {
        mainMaterials[key] = value;
      }
    });

    // Map material types to appropriate icons
    IconData getIconForMaterial(String materialType) {
      switch (materialType) {
        case 'plastic_bottle':
          return Icons.water_drop_outlined;
        case 'tin_can':
          return Icons.inventory_2_outlined;
        case 'bottle_cap':
          return Icons.lens_outlined;
        default:
          return Icons.widgets_outlined;
      }
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                StepByStepGuideScreen(recommendation: recommendation),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: const Color(0xFF377047),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            // Left image - using a placeholder for now
            // Later this can be generated from the imagePrompt using Gemini API
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                bottomLeft: Radius.circular(16),
              ),
              child: Image.network(
                'https://picsum.photos/100/100', // Placeholder image
                width: 100,
                height: 100,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey,
                    child: const Icon(Icons.image_not_supported,
                        color: Colors.white),
                  );
                },
              ),
            ),

            // Right content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    Text(
                      recommendation.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),

                    // CO2 saved
                    Row(
                      children: [
                        const Icon(
                          Icons.eco_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'CO2 Saved: ${recommendation.co2Saved}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Materials needed - show the top 3 materials
                    Row(
                      children: mainMaterials.entries.take(3).map((entry) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: _buildMaterialChip(
                            getIconForMaterial(entry.key),
                            entry.value,
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMaterialChip(IconData icon, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            'x$count',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
