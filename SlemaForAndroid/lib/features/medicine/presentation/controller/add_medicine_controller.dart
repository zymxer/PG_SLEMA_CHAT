import 'package:flutter/material.dart';
import 'package:pg_slema/features/medicine/application/service/medicine_service.dart';
import 'package:pg_slema/features/medicine/data/repository/shared_preferences_medicine_repository.dart';
import 'package:pg_slema/features/medicine/domain/medicine.dart';
import 'package:pg_slema/features/notification/application/service/notification_service.dart';
import 'package:pg_slema/features/notification/data/repository/shared_preferences_notification_repository.dart';
import 'package:pg_slema/features/medicine/domain/converter/medicine_to_dto_converter.dart';
import 'package:pg_slema/features/notification/domain/get_notification.dart';
import 'package:pg_slema/features/notification/domain/notification.dart' as nt;
import 'package:pg_slema/features/notification/presentation/controller/manage_notifications_controller.dart';
import 'package:pg_slema/utils/frequency/frequency.dart';
import 'package:pg_slema/utils/id/integer_id_generator.dart';
import 'package:pg_slema/utils/log/logger_mixin.dart';
import 'package:pg_slema/utils/time_of_day/time_of_day_comparing_extension.dart';
import 'package:uuid/uuid.dart';

class AddMedicineController extends ChangeNotifier
    with Logger, ManageNotificationsController {
  final String medicineId = const Uuid().v4();
  late final NotificationService _notificationService;
  late final MedicineService _medicineService;
  String typedMedicineName = "";
  String typedIntakeType = "";
  DateTime endIntakeDate = DateTime.now();
  Frequency frequency = Frequency.singular;
  bool canDateBePicked = false;
  @override
  List<GetNotification> notifications = List<GetNotification>.from([
    GetNotification(const Uuid().v4(), TimeOfDay.now()),
    GetNotification(const Uuid().v4(), TimeOfDay.now())
  ]);
  //List<GetNotification>.empty(growable: true);

  AddMedicineController() : super() {
    final notificationRepository = SharedPreferencesNotificationRepository();
    _notificationService = NotificationService(notificationRepository);
    final converter = MedicineToDtoConverter(_notificationService);
    final medicineRepository = SharedPreferencesMedicineRepository(converter);
    _medicineService =
        MedicineService(medicineRepository, _notificationService);
  }

  Future saveMedicine() async {
    var lastMedicineDate = _getLastNotificationDateTime();

    var medicineNotifications =
        await _createNotificationsForMedicine(lastMedicineDate);

    Medicine medicine = Medicine(medicineId, typedMedicineName, typedIntakeType,
        DateTime.now(), lastMedicineDate, frequency, medicineNotifications);

    logger.debug(medicine);

    await _medicineService.addMedicine(medicine);
    await Future.forEach(
        medicineNotifications, _notificationService.addNotification);
  }

  @override
  void onNotificationDeleted(GetNotification notification) {
    logger.debug("notification deleted: ${notification.id}");
    notifications.removeWhere((el) => el.id == notification.id);
  }

  @override
  void onNotificationCreated(GetNotification notification) {
    logger.debug("notification created: ${notification.id}");
    notifications.add(notification);
  }

  @override
  void onNotificationChanged(GetNotification notification) {
    logger.debug("notification changed: ${notification.id}");
    notifications[notifications
        .indexWhere((element) => element.id == notification.id)] = notification;
  }

  DateTime _getLastNotificationDateTime() {
    if (frequency == Frequency.singular) {
      return _getDateTimeForSingularIntakeMedicine();
    } else {
      return endIntakeDate;
    }
  }

  DateTime _getDateTimeForSingularIntakeMedicine() {
    var currentTime = TimeOfDay.now();
    return notifications
            .where((notification) =>
                !notification.notificationTime.isHigher(currentTime))
            .isNotEmpty
        ? DateTime.now().add(const Duration(days: 1))
        : DateTime.now();
  }

  Future<List<nt.Notification>> _createNotificationsForMedicine(
      DateTime lastNotificationDate) async {
    var forbiddenIds = await _notificationService.getAllNotifications().then(
        (notifications) => notifications.map((e) => e.scheduledId).toList());
    var idsToSchedule =
        IntegerIdGenerator.generateRandomIdsWhichAreNotForbidden(
            forbiddenIds, notifications.length);
    return notifications
        .map((notification) => nt.Notification(
            notification.id,
            medicineId,
            'Przypomnienie',
            'Trzeba przyjąć $typedIntakeType',
            notification.notificationTime,
            DateTime.now(),
            lastNotificationDate,
            frequency,
            idsToSchedule.removeLast()))
        .toList(growable: true);
  }
}
