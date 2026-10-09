import '../model/results.dart';

/// "Résultats" of a pupil, or of a parent's child ([studentId] required for a parent).
abstract interface class ResultsRepository {
  Future<MyResults> mine({String? studentId});

  /// One of the teacher's pupils, for the Fiche élève: the same numbers.
  Future<MyResults> forStudent(String studentId);
}
