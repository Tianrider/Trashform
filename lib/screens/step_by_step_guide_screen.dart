import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/recommendation.dart';
import '../services/firestore_service.dart';

class StepByStepGuideScreen extends StatefulWidget {
  final Recommendation recommendation;

  const StepByStepGuideScreen({
    super.key,
    required this.recommendation,
  });

  @override
  State<StepByStepGuideScreen> createState() => _StepByStepGuideScreenState();
}

class _StepByStepGuideScreenState extends State<StepByStepGuideScreen> {
  int _currentStep = 0;
  final FirestoreService _firestoreService = FirestoreService();
  bool _isCompleting = false;
  final ImagePicker _picker = ImagePicker();
  File? _projectImage;
  List<File> _additionalImages = [];
  final TextEditingController _priceController = TextEditingController();
  String _projectId = '';
  bool _isListingOnMarketplace = false;

  @override
  void dispose() {
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.black),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        title: const Text(
          'Scan',
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project title and info
            Container(
              color: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.recommendation.name,
                    style: const TextStyle(
                      color: Color(0xFF377047),
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    'Recommended by AI based on your scanned items',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Materials and CO2 info
                  Row(
                    children: [
                      _buildMaterialChip(Icons.water_drop_outlined, 2),
                      const SizedBox(width: 8),
                      _buildMaterialChip(Icons.inventory_2_outlined, 2),
                      const SizedBox(width: 8),
                      _buildMaterialChip(Icons.lens_outlined, 2),
                      const Spacer(),
                      Row(
                        children: [
                          const Icon(
                            Icons.eco_outlined,
                            color: Color(0xFF377047),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'CO2 Saved: ${widget.recommendation.co2Saved}',
                            style: const TextStyle(
                              color: Color(0xFF377047),
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Step by step guide with image
            Container(
              color: const Color(0xFF377047),
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Step number and description
                  Text(
                    'Step ${_currentStep + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    _currentStep < widget.recommendation.stepByStep.length
                        ? widget.recommendation.stepByStep[_currentStep]
                        : 'Cut the plastic bottle in half.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Step image with navigation arrows
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          color: Colors.white,
                          height: 200,
                          width: double.infinity,
                          child: Image.network(
                            'https://picsum.photos/400/200',
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Center(
                                child: Icon(Icons.image_not_supported,
                                    size: 50, color: Colors.grey),
                              );
                            },
                          ),
                        ),
                      ),

                      // Navigation arrows
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // Previous step button
                          if (_currentStep > 0)
                            CircleAvatar(
                              backgroundColor: Colors.white.withOpacity(0.8),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_back_ios,
                                    color: Colors.black),
                                onPressed: () {
                                  setState(() {
                                    _currentStep--;
                                  });
                                },
                              ),
                            )
                          else
                            const SizedBox(width: 40),

                          // Next step button
                          if (_currentStep <
                              widget.recommendation.stepByStep.length - 1)
                            CircleAvatar(
                              backgroundColor: Colors.white.withOpacity(0.8),
                              child: IconButton(
                                icon: const Icon(Icons.arrow_forward_ios,
                                    color: Colors.black),
                                onPressed: () {
                                  setState(() {
                                    _currentStep++;
                                  });
                                },
                              ),
                            )
                          else
                            const SizedBox(width: 40),
                        ],
                      ),
                    ],
                  ),

                  // Step progress indicator
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.photo_library_outlined,
                            color: Colors.white, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          'Page ${_currentStep + 1} of ${widget.recommendation.stepByStep.length}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Watch similar projects section
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'Watch Similar Projects on YouTube',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // YouTube videos horizontal list
            SizedBox(
              height: 90,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: 3,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  return Container(
                    width: 150,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: Colors.grey[200],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Video thumbnail
                        ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(8),
                            topRight: Radius.circular(8),
                          ),
                          child: Image.network(
                            'https://picsum.photos/150/70?random=$index',
                            height: 70,
                            width: 150,
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Video title
                        const Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: 8.0, vertical: 4.0),
                          child: Text(
                            'DIY Hanging Planter Tutorial',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Mark as completed button
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: ElevatedButton.icon(
                onPressed: _isCompleting ? null : _completeProject,
                icon: _isCompleting
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.check),
                label: Text(_isCompleting ? 'Saving...' : 'Mark as Completed'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF377047),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Save completed project to Firestore and show completion dialog
  void _completeProject() async {
    setState(() {
      _isCompleting = true;
    });

    try {
      // Extract CO2 value from string (e.g., "3.2 kg" -> 3.2)
      double co2Value = double.tryParse(widget.recommendation.co2Saved
              .replaceAll(RegExp(r'[^0-9.]'), '')) ??
          0.0;

      // Save to Firestore
      _projectId = await _firestoreService.saveCompletedProject(
        widget.recommendation,
        co2Value, // CO2 saved value
        26, // XP earned (dummy value)
      );

      // Show completion dialog
      if (mounted) {
        _showCompletionDialog();
      }
    } catch (e) {
      print('Error completing project: $e');
      // Show error snackbar
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save project. Please try again.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isCompleting = false;
        });
      }
    }
  }

  // Show completion dialog
  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Success icon
                Container(
                  width: 80,
                  height: 80,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFF377047),
                  ),
                  child: const Icon(
                    Icons.check,
                    color: Colors.white,
                    size: 48,
                  ),
                ),
                const SizedBox(height: 16),

                // Completion title
                const Text(
                  'Project Completed!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),

                // Badge progress
                const Text(
                  'Badge Progress Updated:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),

                // CO2 saved
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '+4.2 kg CO',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      '2',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                    Text(
                      ' saved',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),

                // XP earned
                Text(
                  '+26 XP earned',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black.withOpacity(0.8),
                  ),
                ),
                const SizedBox(height: 16),

                // New badge
                const Text(
                  'New Badge Unlocked:',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  'Eco Explorer',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black.withOpacity(0.8),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),

                // Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Sell on Marketplace button
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        _showMarketplaceDialog();
                      },
                      icon: const Icon(Icons.shopping_bag, size: 18),
                      label: const Text('Sell on Marketplace'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF377047),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),

                    // Close button
                    OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Return to previous screen
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.grey),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 32, vertical: 8),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Close',
                        style: TextStyle(
                          color: Colors.black54,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Show marketplace listing dialog
  void _showMarketplaceDialog() {
    _priceController.text = '25.00'; // Default price

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: Container(
              padding: const EdgeInsets.all(24),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'List on Marketplace',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Project name (non-editable)
                    Text(
                      widget.recommendation.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Price input
                    TextField(
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Price (\$)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: const Icon(Icons.attach_money),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Project photo
                    const Text(
                      'Project Photo:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () async {
                        final XFile? image = await _picker.pickImage(
                          source: ImageSource.camera,
                          maxWidth: 800,
                          maxHeight: 800,
                          imageQuality: 90,
                        );
                        if (image != null) {
                          setState(() {
                            _projectImage = File(image.path);
                          });
                        }
                      },
                      child: Container(
                        height: 150,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey),
                        ),
                        child: _projectImage == null
                            ? const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_a_photo,
                                    color: Colors.grey,
                                    size: 48,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Take a photo of your project',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ],
                              )
                            : ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _projectImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                  height: double.infinity,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Additional photos
                    const Text(
                      'Additional Photos (Optional):',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          // Image tiles
                          ..._additionalImages.map((image) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Stack(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(
                                        image,
                                        width: 80,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: InkWell(
                                        onTap: () {
                                          setState(() {
                                            _additionalImages.remove(image);
                                          });
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(2),
                                          decoration: const BoxDecoration(
                                            color: Colors.red,
                                            shape: BoxShape.circle,
                                          ),
                                          child: const Icon(
                                            Icons.close,
                                            color: Colors.white,
                                            size: 14,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )),

                          // Add button
                          if (_additionalImages.length < 3)
                            InkWell(
                              onTap: () async {
                                final XFile? image = await _picker.pickImage(
                                  source: ImageSource.camera,
                                  maxWidth: 800,
                                  maxHeight: 800,
                                  imageQuality: 80,
                                );
                                if (image != null) {
                                  setState(() {
                                    _additionalImages.add(File(image.path));
                                  });
                                }
                              },
                              child: Container(
                                width: 80,
                                height: 80,
                                decoration: BoxDecoration(
                                  color: Colors.grey[200],
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: const Icon(
                                  Icons.add_photo_alternate,
                                  color: Colors.grey,
                                  size: 32,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        // List button
                        ElevatedButton(
                          onPressed: _projectImage == null ||
                                  _isListingOnMarketplace
                              ? null
                              : () {
                                  print("DEBUG: List for Sale button pressed");
                                  print("DEBUG: Project ID: $_projectId");
                                  print(
                                      "DEBUG: Project image path: ${_projectImage?.path}");
                                  print(
                                      "DEBUG: Project price: ${_priceController.text}");
                                  _listOnMarketplace();
                                  Navigator.pop(context); // Close the dialog
                                },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF377047),
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: _isListingOnMarketplace
                              ? const Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                    SizedBox(width: 12),
                                    Text('Listing...'),
                                  ],
                                )
                              : const Text('List for Sale'),
                        ),

                        // Cancel button
                        OutlinedButton(
                          onPressed: () {
                            Navigator.pop(context);
                            Navigator.pop(context); // Return to previous screen
                          },
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: Colors.grey),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 32, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Cancel',
                            style: TextStyle(
                              color: Colors.black54,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          );
        });
      },
    );
  }

  // List project on marketplace
  void _listOnMarketplace() async {
    // Set loading state
    setState(() {
      _isListingOnMarketplace = true;
    });

    try {
      print("DEBUG: Starting _listOnMarketplace method");
      if (_projectImage == null) {
        // Show error if no image
        print("DEBUG: Error - No project image");
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please take a photo of your project.'),
            backgroundColor: Colors.red,
          ),
        );
        setState(() {
          _isListingOnMarketplace = false;
        });
        return;
      }

      // Parse price
      print("DEBUG: Parsing price from text: ${_priceController.text}");
      final double price = double.tryParse(_priceController.text) ?? 25.00;
      print("DEBUG: Parsed price: $price");

      // Get category
      final String category =
          _getCategoryFromMaterials(widget.recommendation.materials);
      print("DEBUG: Category: $category");

      print("DEBUG: Starting Firebase upload with:");
      print("DEBUG: Project ID: $_projectId");
      print("DEBUG: Name: ${widget.recommendation.name}");
      print(
          "DEBUG: Description length: ${widget.recommendation.description.length}");
      print("DEBUG: Image file exists: ${_projectImage?.existsSync()}");
      print("DEBUG: Additional images count: ${_additionalImages.length}");

      // List on marketplace
      final String result = await _firestoreService.addMarketplaceListing(
        projectId: _projectId,
        name: widget.recommendation.name,
        description: widget.recommendation.description,
        price: price,
        imageFile: _projectImage!,
        additionalImageFiles: _additionalImages,
        category: category,
      );

      print("DEBUG: Firebase result: $result");

      // Show success message and navigate back to home
      if (mounted) {
        setState(() {
          _isListingOnMarketplace = false;
        });

        if (result.isNotEmpty) {
          print("DEBUG: Successfully listed item with ID: $result");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Project successfully listed on marketplace!'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate all the way back to the main screen
          Navigator.popUntil(context, (route) => route.isFirst);
        } else {
          print("DEBUG: Error - Empty result ID returned");
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to list project: Empty ID returned'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('DEBUG: Error listing on marketplace: $e');
      if (mounted) {
        setState(() {
          _isListingOnMarketplace = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to list project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Determine category based on materials used
  String _getCategoryFromMaterials(Map<String, int> materials) {
    if (materials['plastic_bottle'] != null &&
        materials['plastic_bottle']! > 0) {
      return 'Plastic';
    } else if (materials['tin_can'] != null && materials['tin_can']! > 0) {
      return 'Metal';
    } else if (materials['glass_bottle'] != null &&
        materials['glass_bottle']! > 0) {
      return 'Glass';
    } else if (materials['paper'] != null && materials['paper']! > 0 ||
        materials['newspaper'] != null && materials['newspaper']! > 0 ||
        materials['cardboard'] != null && materials['cardboard']! > 0) {
      return 'Paper';
    }
    return 'Other';
  }

  Widget _buildMaterialChip(IconData icon, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: Colors.black54,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            'x$count',
            style: const TextStyle(
              color: Colors.black54,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
