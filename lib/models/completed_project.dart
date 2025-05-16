import 'package:cloud_firestore/cloud_firestore.dart';

class CompletedProject {
  final String id;
  final String name;
  final String description;
  final String mainImageUrl;
  final List<String> stepImages;
  final List<String> steps;
  final double co2Saved;
  final int xpEarned;
  final String userId;
  final DateTime completedDate;
  final Map<String, int> materialsUsed;

  CompletedProject({
    required this.id,
    required this.name,
    required this.description,
    required this.mainImageUrl,
    required this.stepImages,
    required this.steps,
    required this.co2Saved,
    required this.xpEarned,
    required this.userId,
    required this.completedDate,
    required this.materialsUsed,
  });

  // Convert Firestore document to CompletedProject
  factory CompletedProject.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

    return CompletedProject(
      id: doc.id,
      name: data['name'] ?? '',
      description: data['description'] ?? '',
      mainImageUrl: data['mainImageUrl'] ?? '',
      stepImages: List<String>.from(data['stepImages'] ?? []),
      steps: List<String>.from(data['steps'] ?? []),
      co2Saved: (data['co2Saved'] ?? 0.0).toDouble(),
      xpEarned: data['xpEarned'] ?? 0,
      userId: data['userId'] ?? '',
      completedDate:
          (data['completedDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
      materialsUsed: Map<String, int>.from(data['materialsUsed'] ?? {}),
    );
  }

  // Convert CompletedProject to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'description': description,
      'mainImageUrl': mainImageUrl,
      'stepImages': stepImages,
      'steps': steps,
      'co2Saved': co2Saved,
      'xpEarned': xpEarned,
      'userId': userId,
      'completedDate': Timestamp.fromDate(completedDate),
      'materialsUsed': materialsUsed,
    };
  }
}
