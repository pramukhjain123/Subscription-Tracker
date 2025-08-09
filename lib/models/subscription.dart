class Subscription {
  final String? id;
  final String userId;
  final String name;
  final double price;
  final DateTime dueDate;
  final double usageHours;
  final bool isAutoPay;
  final DateTime? lastUsed;

  Subscription({
    this.id,
    required this.userId,
    required this.name,
    required this.price,
    required this.dueDate,
    this.usageHours = 0.0,
    this.isAutoPay = false,
    this.lastUsed,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value, [double defaultValue = 0.0]) {
      if (value == null) return defaultValue;
      if (value is double) return value;
      if (value is int) return value.toDouble();
      if (value is String) return double.tryParse(value) ?? defaultValue;
      return defaultValue;
    }
    return Subscription(
      id: json['_id'],
      userId: json['userId'] ?? '',
      name: json['name'] ?? '',
      price: parseDouble(json['price']),
      dueDate: DateTime.parse(json['dueDate']),
      usageHours: parseDouble(json['usageHours']),
      isAutoPay: json['isAutoPay'] ?? false,
      lastUsed: json['lastUsed'] != null ? DateTime.parse(json['lastUsed']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'name': name,
      'price': price,
      'dueDate': dueDate.toIso8601String(),
      'usageHours': usageHours,
      'isAutoPay': isAutoPay,
      'lastUsed': lastUsed?.toIso8601String(),
    };
  }

  Subscription copyWith({
    String? id,
    String? userId,
    String? name,
    double? price,
    DateTime? dueDate,
    double? usageHours,
    bool? isAutoPay,
    DateTime? lastUsed,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      price: price ?? this.price,
      dueDate: dueDate ?? this.dueDate,
      usageHours: usageHours ?? this.usageHours,
      isAutoPay: isAutoPay ?? this.isAutoPay,
      lastUsed: lastUsed ?? this.lastUsed,
    );
  }

  double get hourlyRate => usageHours > 0 ? price / usageHours : 0;
  int get daysUntilDue => dueDate.difference(DateTime.now()).inDays;
  bool get isOverdue => dueDate.isBefore(DateTime.now());
  bool get isDueSoon => daysUntilDue <= 7 && daysUntilDue >= 0;
} 