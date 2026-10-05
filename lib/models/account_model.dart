import '../core/utils/currency_formatter.dart';

class AccountModel {
  final String id;
  final String name;
  final String? phone;
  final String? email;
  final int initialBalancePaisa;
  final String? notes;
  final bool isDefault;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AccountModel({
    required this.id,
    required this.name,
    this.phone,
    this.email,
    this.initialBalancePaisa = 0,
    this.notes,
    this.isDefault = false,
    required this.createdAt,
    required this.updatedAt,
  });

  double get initialBalanceRupees => CurrencyFormatter.paisaToRupees(initialBalancePaisa);
  String get formattedInitialBalance => CurrencyFormatter.formatPaisa(initialBalancePaisa);

  AccountModel copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    int? initialBalancePaisa,
    String? notes,
    bool? isDefault,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AccountModel(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      initialBalancePaisa: initialBalancePaisa ?? this.initialBalancePaisa,
      notes: notes ?? this.notes,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
