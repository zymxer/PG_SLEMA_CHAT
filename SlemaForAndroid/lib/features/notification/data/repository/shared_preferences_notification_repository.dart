import 'package:pg_slema/features/notification/data/converter/notification_dto_to_json_converter.dart';
import 'package:pg_slema/features/notification/data/notification_dto.dart';
import 'package:pg_slema/features/notification/data/repository/notification_repository.dart';
import 'package:pg_slema/features/notification/domain/converter/notification_to_dto_converter.dart';
import 'package:pg_slema/features/notification/domain/notification.dart';
import 'package:pg_slema/utils/data/shared_preferences_crud_repository.dart';

class SharedPreferencesNotificationRepository
    extends SharedPreferencesCrudRepository<NotificationDto>
    with NotificationRepository {
  SharedPreferencesNotificationRepository()
      : super(NotificationDtoToJsonConverter(),
            Notification.notificationListSharedPrefKey);

  @override
  Future<List<Notification>> getAllNotificationsByMedicine(
      String medicineId) async {
    var jsonNotificationsList = await getAllDto();
    return jsonNotificationsList
        .where((element) => element.ownerId == medicineId)
        .map(NotificationToDtoConverter.fromDto)
        .toList(growable: true);
  }

  @override
  Future deleteNotification(Notification notification) async {
    var dto = NotificationToDtoConverter.toDto(notification);
    await deleteDto(dto);
  }

  @override
  Future addNotification(Notification notification) async {
    final dto = NotificationToDtoConverter.toDto(notification);
    await addDto(dto);
  }

  @override
  Future updateNotification(Notification notification) async {
    var dto = NotificationToDtoConverter.toDto(notification);
    await updateDto(dto);
  }

  @override
  Future<List<Notification>> getAllNotifications() async {
    var dto = await getAllDto();
    return dto.map(NotificationToDtoConverter.fromDto).toList(growable: true);
  }

  @override
  Future deleteAll(List<Notification> notifications) async {
    var dto = notifications
        .map(NotificationToDtoConverter.toDto)
        .toList(growable: true);
    await deleteAllFrom(dto);
  }
}
