import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../models/account_model.dart';
import '../../providers/account_provider.dart';
import '../../providers/database_provider.dart';
import '../../shared/widgets/empty_state.dart';
import 'add_edit_account_dialog.dart';

class AccountsScreen extends ConsumerStatefulWidget {
  const AccountsScreen({super.key});

  @override
  ConsumerState<AccountsScreen> createState() => _AccountsScreenState();
}

class _AccountsScreenState extends ConsumerState<AccountsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _confirmDelete(BuildContext context, AccountModel account) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: const [
            Icon(Icons.warning_amber_rounded, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete Customer Account?'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete "${account.name}"?\n\n'
          'This will permanently delete this customer account and all associated transactions for this customer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final repo = ref.read(accountRepositoryProvider);
                await repo.deleteAccount(account.id);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Customer "${account.name}" deleted.')),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to delete account: $e')),
                  );
                }
              }
            },
            child: const Text('Delete Customer'),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.trim().isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.trim().substring(0, name.trim().length >= 2 ? 2 : 1).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accountsAsync = ref.watch(accountsStreamProvider);
    final activeId = ref.watch(activeAccountIdProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Customer Accounts'),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => AddEditAccountDialog.show(context),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Customer Account'),
      ),
      body: accountsAsync.when(
        data: (accounts) {
          if (accounts.isEmpty) {
            return EmptyState(
              title: 'No Customer Accounts Found',
              description: 'Create your first customer account to start managing entries.',
              buttonLabel: 'Add Customer',
              onButtonPressed: () => AddEditAccountDialog.show(context),
            );
          }

          final filtered = accounts.where((acc) {
            if (_searchQuery.trim().isEmpty) return true;
            final q = _searchQuery.toLowerCase();
            return acc.name.toLowerCase().contains(q) ||
                (acc.phone ?? '').toLowerCase().contains(q) ||
                (acc.email ?? '').toLowerCase().contains(q) ||
                (acc.notes ?? '').toLowerCase().contains(q);
          }).toList();

          final activeAcc = accounts.firstWhere(
            (a) => a.id == activeId,
            orElse: () => accounts.first,
          );

          return Column(
            children: [
              // Search & Quick Stats Bar
              Container(
                color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF8FAFC),
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Search Input
                    TextField(
                      controller: _searchController,
                      onChanged: (val) => setState(() => _searchQuery = val),
                      decoration: InputDecoration(
                        hintText: 'Search customer account by name, phone, or email...',
                        prefixIcon: const Icon(Icons.search),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: isDark ? const Color(0xFF0F172A) : Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Active Account Summary Card
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2563EB), Color(0xFF1D4ED8)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.account_balance_wallet, color: Colors.white, size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Currently Active Customer',
                                  style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  activeAcc.name,
                                  style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${accounts.length} ${accounts.length == 1 ? 'Customer' : 'Customers'}',
                              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Accounts List
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Text(
                          'No customer matching "$_searchQuery"',
                          style: const TextStyle(color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: filtered.length,
                        itemBuilder: (context, index) {
                          final acc = filtered[index];
                          final isActive = acc.id == activeId;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isActive ? AppColors.primary : Colors.transparent,
                                width: isActive ? 2 : 0,
                              ),
                            ),
                            elevation: isActive ? 3 : 1,
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      // Initials Avatar
                                      CircleAvatar(
                                        radius: 22,
                                        backgroundColor: isActive
                                            ? AppColors.primary
                                            : (isDark ? Colors.blueGrey.shade800 : Colors.blue.shade50),
                                        child: Text(
                                          _getInitials(acc.name),
                                          style: TextStyle(
                                            color: isActive ? Colors.white : AppColors.primary,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 14),

                                      // Name & Phone/Email details
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              children: [
                                                Flexible(
                                                  child: Text(
                                                    acc.name,
                                                    style: theme.textTheme.titleMedium?.copyWith(
                                                      fontWeight: FontWeight.bold,
                                                    ),
                                                    overflow: TextOverflow.ellipsis,
                                                  ),
                                                ),
                                                if (isActive) ...[
                                                  const SizedBox(width: 8),
                                                  Container(
                                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                                    decoration: BoxDecoration(
                                                      color: Colors.green.withOpacity(0.15),
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(color: Colors.green, width: 1),
                                                    ),
                                                    child: const Text(
                                                      'ACTIVE',
                                                      style: TextStyle(
                                                        color: Colors.green,
                                                        fontSize: 10,
                                                        fontWeight: FontWeight.bold,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ],
                                            ),
                                            if (acc.phone != null && acc.phone!.isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  const Icon(Icons.phone, size: 13, color: Colors.grey),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    acc.phone!,
                                                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                            ],
                                            if (acc.email != null && acc.email!.isNotEmpty) ...[
                                              const SizedBox(height: 2),
                                              Row(
                                                children: [
                                                  const Icon(Icons.email, size: 13, color: Colors.grey),
                                                  const SizedBox(width: 4),
                                                  Text(
                                                    acc.email!,
                                                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ],
                                        ),
                                      ),

                                      // Edit and Delete Buttons
                                      IconButton(
                                        icon: const Icon(Icons.edit_outlined, color: Colors.blue),
                                        tooltip: 'Edit Details',
                                        onPressed: () => AddEditAccountDialog.show(context, account: acc),
                                      ),
                                      if (accounts.length > 1 && !acc.isDefault)
                                        IconButton(
                                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                                          tooltip: 'Delete Customer',
                                          onPressed: () => _confirmDelete(context, acc),
                                        ),
                                    ],
                                  ),

                                  if (acc.notes != null && acc.notes!.isNotEmpty) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      width: double.infinity,
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        acc.notes!,
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontStyle: FontStyle.italic,
                                          color: isDark ? Colors.grey.shade400 : Colors.grey.shade700,
                                        ),
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 12),
                                  const Divider(height: 1),
                                  const SizedBox(height: 10),

                                  // Initial Balance & Switch Active Account row
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          const Text(
                                            'Initial Balance',
                                            style: TextStyle(fontSize: 11, color: Colors.grey),
                                          ),
                                          Text(
                                            acc.formattedInitialBalance,
                                            style: const TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                      if (!isActive)
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            ref.read(activeAccountIdProvider.notifier).setActiveAccount(acc.id);
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(
                                                content: Text('Switched active customer to "${acc.name}"'),
                                                duration: const Duration(seconds: 2),
                                              ),
                                            );
                                          },
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppColors.primary,
                                            foregroundColor: Colors.white,
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          icon: const Icon(Icons.swap_horiz, size: 16),
                                          label: const Text('Switch Customer', style: TextStyle(fontSize: 13)),
                                        )
                                      else
                                        OutlinedButton.icon(
                                          onPressed: null,
                                          style: OutlinedButton.styleFrom(
                                            side: const BorderSide(color: Colors.green),
                                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            ),
                                          ),
                                          icon: const Icon(Icons.check_circle, size: 16, color: Colors.green),
                                          label: const Text(
                                            'Active Customer',
                                            style: TextStyle(fontSize: 13, color: Colors.green, fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading accounts: $err')),
      ),
    );
  }
}
