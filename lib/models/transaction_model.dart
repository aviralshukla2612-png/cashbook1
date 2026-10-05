import 'package:flutter/material.dart';
import '../core/enums/transaction_type.dart';
import '../core/utils/currency_formatter.dart';

class TransactionModel {
  final String id;
  final TransactionType type;
  final int amountPaisa;
  final String? partyName;
  final String categoryId;
  final String? categoryName;
  final Color? categoryColor;
  final IconData? categoryIcon;
  final String? description;
  final DateTime transactionDate;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TransactionModel({
    required this.id,
    required this.type,
    required this.amountPaisa,
    this.partyName,
    required this.categoryId,
    this.categoryName,
    this.categoryColor,
    this.categoryIcon,
    this.description,
    required this.transactionDate,
    required this.createdAt,
    required this.updatedAt,
  });

  double get amountRupees => CurrencyFormatter.paisaToRupees(amountPaisa);

  String get formattedAmount => CurrencyFormatter.formatPaisa(amountPaisa);

  bool get isCashIn => type == TransactionType.cashIn;
  bool get isCashOut => type == TransactionType.cashOut;

  TransactionModel copyWith({
    String? id,
    TransactionType? type,
    int? amountPaisa,
    String? partyName,
    String? categoryId,
    String? categoryName,
    Color? categoryColor,
    IconData? categoryIcon,
    String? description,
    DateTime? transactionDate,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TransactionModel(
      id: id ?? this.id,
      type: type ?? this.type,
      amountPaisa: amountPaisa ?? this.amountPaisa,
      partyName: partyName ?? this.partyName,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      categoryColor: categoryColor ?? this.categoryColor,
      categoryIcon: categoryIcon ?? this.categoryIcon,
      description: description ?? this.description,
      transactionDate: transactionDate ?? this.transactionDate,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
