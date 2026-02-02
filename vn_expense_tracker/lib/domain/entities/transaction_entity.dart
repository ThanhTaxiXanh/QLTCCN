// lib/domain/entities/transaction_entity.dart

class TransactionEntity {
  final String id;
  final String? title;
  final double amount;
  final String type; // 'expense' or 'income'
  final DateTime date;
  final String walletId;
  final String categoryId;
  final String? note;
  final Map<String, dynamic>? metadata;
  final DateTime createdAt;
  final DateTime updatedAt;
  
  // Related entities (loaded separately)
  final String? categoryName;
  final String? categoryIcon;
  final String? categoryColor;
  final String? walletName;

  const TransactionEntity({
    required this.id,
    this.title,
    required this.amount,
    required this.type,
    required this.date,
    required this.walletId,
    required this.categoryId,
    this.note,
    this.metadata,
    required this.createdAt,
    required this.updatedAt,
    this.categoryName,
    this.categoryIcon,
    this.categoryColor,
    this.walletName,
  });

  bool get isExpense => type == 'expense';
  bool get isIncome => type == 'income';
  
  String get displayTitle => title ?? categoryName ?? 'Giao dịch';

  TransactionEntity copyWith({
    String? id,
    String? title,
    double? amount,
    String? type,
    DateTime? date,
    String? walletId,
    String? categoryId,
    String? note,
    Map<String, dynamic>? metadata,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? categoryName,
    String? categoryIcon,
    String? categoryColor,
    String? walletName,
  }) {
    return TransactionEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      amount: amount ?? this.amount,
      type: type ?? this.type,
      date: date ?? this.date,
      walletId: walletId ?? this.walletId,
      categoryId: categoryId ?? this.categoryId,
      note: note ?? this.note,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      categoryName: categoryName ?? this.categoryName,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      categoryColor: categoryColor ?? this.categoryColor,
      walletName: walletName ?? this.walletName,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'amount': amount,
      'type': type,
      'date': date.toIso8601String(),
      'walletId': walletId,
      'categoryId': categoryId,
      'note': note,
      'metadata': metadata,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'categoryName': categoryName,
      'categoryIcon': categoryIcon,
      'categoryColor': categoryColor,
      'walletName': walletName,
    };
  }

  factory TransactionEntity.fromJson(Map<String, dynamic> json) {
    return TransactionEntity(
      id: json['id'] as String,
      title: json['title'] as String?,
      amount: (json['amount'] as num).toDouble(),
      type: json['type'] as String,
      date: DateTime.parse(json['date'] as String),
      walletId: json['walletId'] as String,
      categoryId: json['categoryId'] as String,
      note: json['note'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      categoryName: json['categoryName'] as String?,
      categoryIcon: json['categoryIcon'] as String?,
      categoryColor: json['categoryColor'] as String?,
      walletName: json['walletName'] as String?,
    );
  }
}

// Transaction summary for statistics
class TransactionSummary {
  final double totalIncome;
  final double totalExpense;
  final double netBalance;
  final int transactionCount;

  const TransactionSummary({
    required this.totalIncome,
    required this.totalExpense,
    required this.netBalance,
    required this.transactionCount,
  });

  double get savingsRate => totalIncome > 0 
      ? ((totalIncome - totalExpense) / totalIncome) * 100 
      : 0;
}

// Category breakdown item
class CategoryBreakdownItem {
  final String categoryId;
  final String categoryName;
  final String categoryIcon;
  final String categoryColor;
  final double amount;
  final int transactionCount;
  final double percentage;

  const CategoryBreakdownItem({
    required this.categoryId,
    required this.categoryName,
    required this.categoryIcon,
    required this.categoryColor,
    required this.amount,
    required this.transactionCount,
    required this.percentage,
  });
}
