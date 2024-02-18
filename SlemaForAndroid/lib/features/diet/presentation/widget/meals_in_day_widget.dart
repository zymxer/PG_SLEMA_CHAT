import 'package:flutter/cupertino.dart';
import 'package:pg_slema/features/diet/presentation/controller/diet_screen_controller.dart';
import 'package:pg_slema/features/diet/presentation/widget/meals_in_meal_time_widget.dart';

class MealsInDayWidget extends StatefulWidget {
  final Stream<DateTime> stream;

  const MealsInDayWidget({super.key, required this.stream});

  @override
  State<StatefulWidget> createState() => _MealsInDayWidgetState();
}

class _MealsInDayWidgetState extends State<MealsInDayWidget> {
  late DietScreenController controller;

  @override
  void initState() {
    super.initState();
    controller = DietScreenController(_onMealsChanged);
    controller.initializeMeals();
    widget.stream.listen((date) {
      controller.onDateChanged(date);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext context) {
        return CustomScrollView(
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (BuildContext context, int index) {
                  return MealsInMealTimeWidget(
                          mealTime:
                              controller.meals.entries.elementAt(index).key,
                          meals:
                              controller.meals.entries.elementAt(index).value)
                      .build(context);
                },
                childCount: controller.meals.entries.length,
              ),
            ),
          ],
        );
      },
    );
  }

  void _onMealsChanged() {
    setState(() {});
  }
}
