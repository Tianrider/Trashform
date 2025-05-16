import 'package:flutter/material.dart';
import '../models/recommendation.dart';

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
                onPressed: () {
                  // Show project completed dialog
                  _showCompletionDialog();
                },
                icon: const Icon(Icons.check),
                label: const Text('Mark as Completed'),
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
                    // View badges button
                    ElevatedButton.icon(
                      onPressed: () {
                        // Handle view badges
                        Navigator.pop(context); // Close dialog
                        Navigator.pop(context); // Return to previous screen
                      },
                      icon: const Icon(Icons.recycling, size: 18),
                      label: const Text('View Badges'),
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
}
