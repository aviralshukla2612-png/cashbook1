import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/account_model.dart';
import '../repositories/account_repository.dart';
import 'database_provider.dart';
import 'settings_provider.dart';

final accountsStreamProvider = StreamProvider<List<AccountModel>>((ref) {
  final repo = ref.watch(accountRepositoryProvider);
  return repo.watchAccounts();
});

class ActiveAccountIdNotifier extends Notifier<String?> {
  static const String _activeAccountKey = 'active_account_id';

  @override
  String? build() {
    _loadActiveAccount();
    return null;
  }

  Future<void> _loadActiveAccount() async {
    final settingsRepo = ref.read(settingsRepositoryProvider);
    final savedId = await settingsRepo.getSetting(_activeAccountKey);
    if (savedId != null && savedId.isNotEmpty) {
      state = savedId;
    } else {
      // Default fallback
      final accountsRepo = ref.read(accountRepositoryProvider);
      final accounts = await accountsRepo.getAllAccounts();
      if (accounts.isNotEmpty) {
        final defaultAcc = accounts.firstWhere((a) => a.isDefault, orElse: () => accounts.first);
        state = defaultAcc.id;
      }
    }
  }

  Future<void> setActiveAccount(String accountId) async {
    state = accountId;
    final settingsRepo = ref.read(settingsRepositoryProvider);
    await settingsRepo.setSetting(_activeAccountKey, accountId);
  }
}

final activeAccountIdProvider = NotifierProvider<ActiveAccountIdNotifier, String?>(ActiveAccountIdNotifier.new);

final activeAccountProvider = Provider<AccountModel?>((ref) {
  final activeId = ref.watch(activeAccountIdProvider);
  final accountsAsync = ref.watch(accountsStreamProvider);

  return accountsAsync.when(
    data: (accounts) {
      if (accounts.isEmpty) return null;
      if (activeId != null) {
        final match = accounts.where((a) => a.id == activeId).toList();
        if (match.isNotEmpty) return match.first;
      }
      // Fallback to default or first
      return accounts.firstWhere((a) => a.isDefault, orElse: () => accounts.first);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});
