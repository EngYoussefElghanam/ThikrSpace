import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../profile/domain/repositories/user_profile_repository.dart';
import '../../../profile/domain/entities/user_profile.dart';

part 'access_gate_state.dart';

class AccessGateCubit extends Cubit<AccessGateState> {
  final UserProfileRepository _profileRepository;

  AccessGateCubit(this._profileRepository) : super(AccessGateInitial());

  Future<void> evaluateAccess(String uid) async {
    emit(AccessGateLoading());
    try {
      final profile = await _profileRepository.getUserProfile(uid);

      if (!profile.settings.isOnboarded) {
        emit(AccessGateNeedsOnboarding(profile));
        return;
      }

      emit(AccessGateAllowed(profile));
    } catch (e, stackTrace) {
      debugPrint('AccessGate Error: $e\n$stackTrace');
      emit(AccessGateError(
          "Could not load profile. Please check your connection."));
    }
  }
}
