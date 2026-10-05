import 'package:flutter/material.dart';
import '../features/transactions/add_transaction_screen.dart';
import '../features/transactions/transaction_detail_screen.dart';
import '../features/categories/category_screen.dart';
import '../features/backup/backup_screen.dart';
import '../features/backup/restore_screen.dart';
import '../features/auth/pin_screen.dart';
import '../features/about/about_privacy_screen.dart';
import '../features/about/privacy_policy_screen.dart';
import '../features/accounts/accounts_screen.dart';
import '../models/transaction_model.dart';
import '../core/enums/transaction_type.dart';

class AppRoutes {
  static const String home = '/';
  static const String addTransaction = '/add_transaction';
  static const String transactionDetail = '/transaction_detail';
  static const String categories = '/categories';
  static const String accounts = '/accounts';
  static const String backup = '/backup';
  static const String restore = '/restore';
  static const String pin = '/pin';
  static const String about = '/about';
  static const String privacyPolicy = '/privacy_policy';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case addTransaction:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => AddTransactionScreen(
            existingTransaction: args?['transaction'] as TransactionModel?,
            initialType: args?['initialType'] as TransactionType?,
          ),
        );

      case transactionDetail:
        final transaction = settings.arguments as TransactionModel;
        return MaterialPageRoute(
          builder: (_) => TransactionDetailScreen(transaction: transaction),
        );

      case categories:
        return MaterialPageRoute(builder: (_) => const CategoryScreen());

      case accounts:
        return MaterialPageRoute(builder: (_) => const AccountsScreen());

      case backup:
        return MaterialPageRoute(builder: (_) => const BackupScreen());

      case restore:
        return MaterialPageRoute(builder: (_) => const RestoreScreen());

      case pin:
        final args = settings.arguments as Map<String, dynamic>?;
        return MaterialPageRoute(
          builder: (_) => PinScreen(
            isSettingPin: args?['isSettingPin'] ?? false,
          ),
        );

      case about:
        return MaterialPageRoute(builder: (_) => const AboutPrivacyScreen());

      case privacyPolicy:
        return MaterialPageRoute(builder: (_) => const PrivacyPolicyScreen());

      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(child: Text('No route defined for ${settings.name}')),
          ),
        );
    }
  }
}
