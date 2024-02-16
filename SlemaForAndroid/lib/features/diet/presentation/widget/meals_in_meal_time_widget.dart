import 'package:flutter/cupertino.dart';
import 'package:pg_slema/features/meal/logic/entity/meal.dart';
import 'package:pg_slema/features/meal/logic/entity/meal_time.dart';

class MealsInMealTimeWidget extends StatelessWidget {
  final MealTime mealTime;
  final List<Meal> meals;

  const MealsInMealTimeWidget(
      {super.key, required this.mealTime, required this.meals});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          mealTime.name,
        ),
        Builder(
          builder: (BuildContext context) {
            return CustomScrollView(
              shrinkWrap: true,
              slivers: [
                SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                      return Text(meals.elementAt(index).dish.name)
                          .build(context);
                    },
                    childCount: meals.length,
                  ),
                ),
              ],
            );
          },
        )
      ],
    );
  }
}
