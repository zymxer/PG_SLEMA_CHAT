import 'package:pg_slema/features/exercises/logic/entity/exercise.dart';
import 'package:pg_slema/features/exercises/logic/repository/exercise_repository.dart';
import 'package:pg_slema/utils/date/date.dart';

class ExerciseService {
  final ExerciseRepository repository;

  ExerciseService(this.repository);

  Future<List<Exercise>> getAllExercises() async {
    return repository.getAllExercises().then((exercises) {
      exercises.sort((a, b) {
        int dateComparison = b.exerciseDate.compareDates(a.exerciseDate);

        if (dateComparison == 0) {
          return b.exerciseTime.compareTo(a.exerciseTime);
        }

        return dateComparison;
      });
      return exercises;
    });
  }

  Future<Exercise> getExercise(String id) async {
    return repository.getExercise(id);
  }

  Future addExercise(Exercise exercise) async {
    await repository.addExercise(exercise);
  }

  Future updateExercise(Exercise exercise) async {
    await repository.updateExercise(exercise);
  }

  Future deleteExercise(String id) async {
    await repository.deleteExercise(id);
  }

  Future deleteAllExercises() {
    return repository.deleteAllExercises();
  }
}
