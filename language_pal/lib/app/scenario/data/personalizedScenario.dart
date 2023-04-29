import 'package:poly_app/common/data/scenario_model.dart';

class PersonaliedScenario {
  ScenarioModel scenario;
  int? bestScore;
  bool inProgress;
  bool useCaseRecommended;

  get done => bestScore != null && bestScore! >= 8;

  PersonaliedScenario({
    required this.scenario,
    this.bestScore,
    this.inProgress = false,
    this.useCaseRecommended = false,
  });

  // comparator function
  int compareTo(PersonaliedScenario other) {
    if (inProgress && !other.inProgress) {
      return -1;
    } else if (!inProgress && other.inProgress) {
      return 1;
    } else {
      if (done && !other.done) {
        return 1;
      } else if (!done && other.done) {
        return -1;
      } else {
        if (useCaseRecommended && !other.useCaseRecommended) {
          return -1;
        } else if (!useCaseRecommended && other.useCaseRecommended) {
          return 1;
        } else {
          return 0;
        }
      }
    }
  }
}
