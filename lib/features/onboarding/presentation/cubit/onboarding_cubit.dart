import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../profile/domain/entities/user_profile.dart';
import '../../../profile/domain/repositories/user_profile_repository.dart';

part 'onboarding_state.dart';

class OnboardingCubit extends Cubit<OnboardingState> {
  final UserProfileRepository _repository;

  OnboardingCubit(this._repository) : super(OnboardingInitial());

  Future<void> completeOnboarding({
    required String uid,
    required int surahStart,
    required int surahEnd,
    required int dailyNew,
    required int dailyMaxReviews,
    required String timezone,
  }) async {
    emit(OnboardingLoading());
    try {
      final settings = UserSettings(
        surahStart: surahStart,
        surahEnd: surahEnd,
        dailyNew: dailyNew,
        dailyMaxReviews: dailyMaxReviews,
        timezone: timezone,
        // Using safe defaults for the rest
        khalwaDefaultMinutes: 15,
        clarityEnabled: true,
      );

      // This method (built in Prompt 2) automatically saves to Hive first, then Firestore
      await _repository.updateSettings(uid, settings);

      emit(OnboardingSuccess());
    } catch (e) {
      emit(OnboardingError("Failed to save your settings. Please try again."));
    }
  }
}
