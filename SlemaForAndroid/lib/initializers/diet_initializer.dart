import 'package:pg_slema/features/dish/logic/entity/dish.dart';
import 'package:pg_slema/features/dish/logic/service/dish_service.dart';
import 'package:pg_slema/features/dish_category/logic/converter/dish_category_to_dto.dart';
import 'package:pg_slema/features/dish_category/logic/entity/dish_category.dart';
import 'package:pg_slema/features/dish_category/logic/repository/shared_preferences_dish_category_repository.dart';
import 'package:pg_slema/features/dish_category/logic/service/dish_category_service.dart';
import 'package:pg_slema/features/dish_category/logic/service/exception/dish_category_name_exception.dart';
import 'package:pg_slema/features/meal/logic/converter/meal_to_dto_converter.dart';
import 'package:pg_slema/features/meal/logic/entity/meal.dart';
import 'package:pg_slema/features/meal/logic/repository/shared_preferences_meal_repository.dart';
import 'package:pg_slema/features/meal/logic/service/meal_service.dart';
import 'package:pg_slema/initializers/initializer.dart';
import 'package:pg_slema/features/meal/logic/entity/meal_time.dart';
import 'package:uuid/uuid.dart';

class DietInitializer with Initializer {
  final DishCategoryService dishCategoryService;
  final DishService dishService;
  final Uuid idGenerator;

  DietInitializer(this.dishService)
      : idGenerator = const Uuid(),
        dishCategoryService = DishCategoryService(
            SharedPreferencesDishCategoryRepository(
                DishCategoryToDtoConverter()),
            dishService);

  @override
  Future initialize() async {
    await initializeDishesForCategory(
        'Owoce', ['Jagoda', 'Banan', 'Malina', 'Pomarańcza', 'Mandarynka']);
    await initializeDishesForCategory(
        'Warzywa', ['Ogórek', 'Brokuł', 'Kalafior', 'Marchew', 'Burak']);
    await initializeDishesForCategory(
        'Nabiał', ['Twaróg', 'Ser żółty', 'Mleko']);
    await initializeDishesForCategory('Mięso', [
      'Wieprzowina',
      'Wołowina',
      'Kurczak',
      'Indyk',
      'Cielęcina',
      'Baranina'
    ]);
    await initializeMeals(false);
  }

  Future initializeDishesForCategory(
      String categoryName, List<String> names) async {
    DishCategory dishCategory = await getCategoryByName(categoryName);
    var dish = generateDishes(names, dishCategory.id);
    var currentDishes = await dishService
        .getAllDishesByDishCategory(dishCategory.id)
        .then((value) => value.map((e) => e.name));
    var dishToAdd = dish
        .where((e) => !currentDishes.contains(e.name))
        .toList(growable: true);
    await dishService.addAllDishesFrom(dishToAdd);
  }

  Future<DishCategory> getCategoryByName(String name) async {
    try {
      var category = DishCategory(idGenerator.v4(), name);
      await dishCategoryService.addDishCategory(category);
      return category;
    } on DishCategoryNameException {
      return dishCategoryService.getDishCategoryByName(name);
    }
  }

  List<Dish> generateDishes(List<String> names, String categoryId) {
    return names
        .map((e) => Dish(idGenerator.v4(), e, categoryId))
        .toList(growable: true);
  }

  Future initializeMeals(bool initialize) async {
    if (initialize) {
      var dishes = await dishService.getAllDishes();
      var mealService = MealService(
          SharedPreferencesMealRepository(MealToDtoConverter(dishService)));
      var meals = await mealService.getAllMeals();
      if (meals.isEmpty) {
        await mealService.addMeal(Meal(
            idGenerator.v4(), dishes[0], DateTime.now(), MealTime.firstMeal));
        await mealService.addMeal(Meal(
            idGenerator.v4(), dishes[1], DateTime.now(), MealTime.secondMeal));
        await mealService.addMeal(Meal(
            idGenerator.v4(), dishes[1], DateTime.now(), MealTime.secondMeal));
        await mealService.addMeal(Meal(
            idGenerator.v4(),
            dishes[2],
            DateTime.now().subtract(const Duration(days: 1)),
            MealTime.thirdMeal));
        await mealService.addMeal(Meal(
            idGenerator.v4(),
            dishes[3],
            DateTime.now().subtract(const Duration(days: 1)),
            MealTime.fourthMeal));
        await mealService.addMeal(Meal(
            idGenerator.v4(),
            dishes[4],
            DateTime.now().subtract(const Duration(days: 1)),
            MealTime.fourthMeal));
      }
    }
  }
}
