import 'package:flutter_riverpod/flutter_riverpod.dart';

class AuthState {
  final bool isUnlocked;
  final bool isLoading;

  const AuthState({
    this.isUnlocked = false,
    this.isLoading = false,
  });

  AuthState copyWith({
    bool? isUnlocked,
    bool? isLoading,
  }) {
    return AuthState(
      isUnlocked: isUnlocked ?? this.isUnlocked,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class AuthNotifier extends Notifier<AuthState> {
  @override
  AuthState build() => const AuthState();

  void unlock() {
    state = state.copyWith(isUnlocked: true);
  }

  void lock() {
    state = state.copyWith(isUnlocked: false);
  }
}

final authStateProvider = NotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);
