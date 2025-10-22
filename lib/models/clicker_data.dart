class ClickerData {
  final String id;
  final int counter;
  final String backgroundColor;
  final DateTime lastUpdated;
  final String deviceId;

  ClickerData({
    required this.id,
    required this.counter,
    required this.backgroundColor,
    required this.lastUpdated,
    required this.deviceId,
  });

  // Convert to JSON for AWS DynamoDB
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'counter': counter,
      'backgroundColor': backgroundColor,
      'lastUpdated': lastUpdated.toIso8601String(),
      'deviceId': deviceId,
    };
  }

  // Create from JSON
  factory ClickerData.fromJson(Map<String, dynamic> json) {
    return ClickerData(
      id: json['id'] as String,
      counter: json['counter'] as int,
      backgroundColor: json['backgroundColor'] as String,
      lastUpdated: DateTime.parse(json['lastUpdated'] as String),
      deviceId: json['deviceId'] as String,
    );
  }

  // Create a copy with updated values
  ClickerData copyWith({
    String? id,
    int? counter,
    String? backgroundColor,
    DateTime? lastUpdated,
    String? deviceId,
  }) {
    return ClickerData(
      id: id ?? this.id,
      counter: counter ?? this.counter,
      backgroundColor: backgroundColor ?? this.backgroundColor,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      deviceId: deviceId ?? this.deviceId,
    );
  }
}
