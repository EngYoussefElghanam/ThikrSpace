part of 'beta_gate_cubit.dart';

sealed class BetaGateState {}

class BetaGateInitial extends BetaGateState {}

class BetaGateLoading extends BetaGateState {}

class BetaGateDenied extends BetaGateState {
  final String message;
  BetaGateDenied(this.message);
}

class BetaGateNeedsOnboarding extends BetaGateState {
  final UserProfile profile;
  BetaGateNeedsOnboarding(this.profile);
}

class BetaGateAllowed extends BetaGateState {
  final UserProfile profile;
  BetaGateAllowed(this.profile);
}

class BetaGateError extends BetaGateState {
  final String message;
  BetaGateError(this.message);
}
