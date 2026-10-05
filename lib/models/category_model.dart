import 'package:flutter/material.dart';

class CategoryModel {
  final String id;
  final String name;
  final String type; // CASH_IN, CASH_OUT, BOTH
  final String iconName;
  final String colorHex;
  final bool isDefault;
  final DateTime createdAt;

  const CategoryModel({
    required this.id,
    required this.name,
    required this.type,
    required this.iconName,
    required this.colorHex,
    this.isDefault = false,
    required this.createdAt,
  });

  Color get color {
    try {
      final value = int.parse(colorHex);
      return Color(value);
    } catch (_) {
      return Colors.blue;
    }
  }

  IconData get iconData {
    return getIconByName(iconName);
  }

  static IconData getIconByName(String name) {
    switch (name) {
      case 'shopping_bag':
        return Icons.shopping_bag_outlined;
      case 'payments':
        return Icons.payments_outlined;
      case 'account_balance':
        return Icons.account_balance_outlined;
      case 'show_chart':
        return Icons.show_chart_outlined;
      case 'add_card':
        return Icons.add_card_outlined;
      case 'shopping_cart':
        return Icons.shopping_cart_outlined;
      case 'badge':
        return Icons.badge_outlined;
      case 'directions_bus':
        return Icons.directions_bus_outlined;
      case 'restaurant':
        return Icons.restaurant_outlined;
      case 'bolt':
        return Icons.bolt_outlined;
      case 'home':
        return Icons.home_outlined;
      case 'work':
        return Icons.work_outline;
      case 'receipt_long':
        return Icons.receipt_long_outlined;
      case 'phone_android':
        return Icons.phone_android_outlined;
      case 'local_hospital':
        return Icons.local_hospital_outlined;
      case 'school':
        return Icons.school_outlined;
      case 'flight':
        return Icons.flight_outlined;
      case 'build':
        return Icons.build_outlined;
      default:
        return Icons.category_outlined;
    }
  }
}
