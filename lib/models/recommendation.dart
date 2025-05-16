class Recommendation {
  final String co2Saved;
  final String description;
  final String imagePrompt;
  final Map<String, int> materials;
  final String name;
  final List<String> stepByStep;

  Recommendation({
    required this.co2Saved,
    required this.description,
    required this.imagePrompt,
    required this.materials,
    required this.name,
    required this.stepByStep,
  });

  factory Recommendation.fromJson(Map<String, dynamic> json) {
    return Recommendation(
      co2Saved: json['co2_saved'],
      description: json['description'],
      imagePrompt: json['image_prompt'],
      materials: Map<String, int>.from(json['materials']),
      name: json['name'],
      stepByStep: List<String>.from(json['step_by_step']),
    );
  }
}
