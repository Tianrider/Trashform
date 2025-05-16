class DetectedItem {
  final int count;
  final String item;
  final bool recyclable;
  final String? note;

  DetectedItem({
    required this.count,
    required this.item,
    required this.recyclable,
    this.note,
  });

  factory DetectedItem.fromJson(Map<String, dynamic> json) {
    return DetectedItem(
      count: json['count'],
      item: json['item'],
      recyclable: json['recyclable'],
      note: json['note'],
    );
  }
}
