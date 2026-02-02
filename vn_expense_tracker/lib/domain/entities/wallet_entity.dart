// lib/domain/entities/wallet_entity.dart

class WalletEntity {
  final String id;
  final String name;
  final String currency;
  final double initialBalance;
  final DateTime createdAt;
  final DateTime updatedAt;
  final double currentBalance;

  const WalletEntity({
    required this.id,
    required this.name,
    required this.currency,
    required this.initialBalance,
    required this.createdAt,
    required this.updatedAt,
    this.currentBalance = 0,
  });

  WalletEntity copyWith({
    String? id,
    String? name,
    String? currency,
    double? initialBalance,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? currentBalance,
  }) {
    return WalletEntity(
      id: id ?? this.id,
      name: name ?? this.name,
      currency: currency ?? this.currency,
      initialBalance: initialBalance ?? this.initialBalance,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      currentBalance: currentBalance ?? this.currentBalance,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'currency': currency,
      'initialBalance': initialBalance,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'currentBalance': currentBalance,
    };
  }

  factory WalletEntity.fromJson(Map<String, dynamic> json) {
    return WalletEntity(
      id: json['id'] as String,
      name: json['name'] as String,
      currency: json['currency'] as String,
      initialBalance: (json['initialBalance'] as num).toDouble(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      currentBalance: (json['currentBalance'] as num?)?.toDouble() ?? 0,
    );
  }
}
