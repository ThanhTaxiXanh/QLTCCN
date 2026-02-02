// lib/domain/entities/category_entity.dart

class CategoryEntity {
  final String id;
  final String name;
  final String type; // 'expense' or 'income'
  final String icon;
  final String color;
  final DateTime createdAt;
  final int transactionCount;

  const CategoryEntity({
    required this.id,
    required this.name,
    required this.type,
    required this.icon,
    required this.color,
    required this.createdAt,
    this.transactionCount = 0,
  });

  bool get isExpense => type == 'expense';
  bool get isIncome => type == 'income';

  CategoryEntity copyWith({
    String? id,
    String? name,
    String? type,
    String? icon,
    String? color,
    DateTime? createdAt,
    int? transactionCount,
  }) {
    return CategoryEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      icon: icon ?? this.icon,
      color: color ?? this.color,
      createdAt: createdAt ?? this.createdAt,
      transactionCount: transactionCount ?? this.transactionCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'icon': icon,
      'color': color,
      'createdAt': createdAt.toIso8601String(),
      'transactionCount': transactionCount,
    };
  }

  factory CategoryEntity.fromJson(Map<String, dynamic> json) {
    return CategoryEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      type: json['type'] as String,
      icon: json['icon'] as String,
      color: json['color'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      transactionCount: (json['transactionCount'] as int?) ?? 0,
    );
  }
}
