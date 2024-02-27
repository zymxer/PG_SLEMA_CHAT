import 'package:pg_slema/features/dish/logic/entity/dish.dart';
import 'package:pg_slema/features/meal/logic/entity/meal_time.dart';

class Meal {
  static const String mealListSharedPrefKey = 'meals';
  final String id;
  final String title;
  final Set<Dish> ingredients;
  final DateTime mealDate;
  final MealTime mealTime;

  Meal(this.id, this.title, this.ingredients, this.mealDate, this.mealTime);
}
