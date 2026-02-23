part of 'access_gate_cubit.dart';

sealed class AccessGateState {}

final class AccessGateInitial extends AccessGateState {}

final class AccessGateLoading extends AccessGateState {}

final class AccessGateNeedsOnboarding extends AccessGateState {
  final UserProfile profile;
  AccessGateNeedsOnboarding(this.profile);
}

final class AccessGateAllowed extends AccessGateState {
  final UserProfile profile;
  AccessGateAllowed(this.profile);
}

final class AccessGateError extends AccessGateState {
  final String message;
  AccessGateError(this.message);
}
