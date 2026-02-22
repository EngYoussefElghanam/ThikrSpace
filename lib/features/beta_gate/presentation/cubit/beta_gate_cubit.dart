import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../profile/domain/repositories/user_profile_repository.dart';
import '../../../profile/domain/entities/user_profile.dart';

part 'beta_gate_state.dart';

class BetaGateCubit extends Cubit<BetaGateState> {
  final UserProfileRepository _profileRepository;

  BetaGateCubit(this._profileRepository) : super(BetaGateInitial());

  Future<void> evaluateAccess(String uid) async {
    emit(BetaGateLoading());

    try {
      // 1. Fetch the profile (Offline-first repo handles Hive vs Firestore)
      final profile = await _profileRepository.getUserProfile(uid);

      // 2. The Gating Rule: Must have betaAccess OR pro flag
      if (!profile.flags.betaAccess && !profile.flags.pro) {
        emit(BetaGateDenied("You are not on the ThikrSpace beta list yet."));
        return;
      }

      // 3. The Onboarding Rule: Check if they have set their range and pace
      if (!profile.settings.isOnboarded) {
        emit(BetaGateNeedsOnboarding(profile));
        return;
      }

      // 4. Fully Allowed
      emit(BetaGateAllowed(profile));
    } catch (e) {
      emit(BetaGateError(
          "Could not load profile. Please check your connection."));
    }
  }
}
