import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mutex/mutex.dart';
import 'package:pg_slema/features/well_being/logic/entity/assessment.dart';
import 'package:pg_slema/features/well_being/logic/repository/assessments_repository.dart';
import 'package:pg_slema/utils/change_notifier_impl.dart';
import 'package:pg_slema/utils/connector/shared_preferences_connector.dart';
import 'package:pg_slema/utils/log/logger_mixin.dart';

class SharedPreferencesAssessmentsRepository
    with Logger
    implements AssessmentsRepository {
  static const String _assessmentsSharedPreferencesKey = 'assessments';

  final assessmentsRwLock = ReadWriteMutex();
  final List<Assessment> loadedAssessments = List.empty(growable: true);
  final sharedPreferencesConnector = SharedPreferencesConnector();
  final ChangeNotifierImpl assessmentChangeNotifier = ChangeNotifierImpl();

  @override
  Future<List<Assessment>> getAll() {
    return assessmentsRwLock.protectRead(() async {
      return List.from(loadedAssessments, growable: false);
    });
  }

  @override
  Future save(Assessment assessment) async {
    await assessmentsRwLock.protectWrite(() async {
      int indexToInsertAt = 0;
      for (int i = 0; i < loadedAssessments.length; i++) {
        if (assessment.isOlderThan(loadedAssessments[i])) {
          break;
        }
      }

      loadedAssessments.insert(indexToInsertAt, assessment);
    });

    // Need to update data in order to keep loadedAssessments up to date.
    await _saveToSharedPreferences();
  }

  @override
  Future delete(int id) async {
    await assessmentsRwLock.protectWrite(() async {
      loadedAssessments.removeWhere((element) => element.id == id);
    });

    // Need to update data in order to keep loadedAssessments up to date.
    await _saveToSharedPreferences();
  }

  @override
  ChangeNotifier getAssessmentChangeNotifier() {
    return assessmentChangeNotifier;
  }

  /// Creates a new instance of [SharedPreferencesAssessmentsRepository]. Serves as a workaround for dart not allowing async ctors.
  static Future<SharedPreferencesAssessmentsRepository> create() async {
    final self = SharedPreferencesAssessmentsRepository();
    await self._loadFromSharedPreferences();
    return self;
  }

  Future _loadFromSharedPreferences() async {
    final entries = await sharedPreferencesConnector
        .getList(_assessmentsSharedPreferencesKey);

    final assessments = entries
        .map((json) => jsonDecode(json))
        .map((map) => Assessment.fromJsonObject(map))
        .where((element) => element != null)
        .map((e) => e!)
        .toList();

    await assessmentsRwLock.protectWrite(() async {
      loadedAssessments.clear();
      loadedAssessments.addAll(assessments);
    });

    logger.debug("Loaded assessments from shared preferences.");
  }

  Future _saveToSharedPreferences() async {
    List<Assessment>? assessmentsBefore;
    await assessmentsRwLock.protectRead(() async {
      assessmentsBefore = List.from(loadedAssessments, growable: false);
    });
    List<Assessment> assessments = assessmentsBefore!;

    List<String> json = assessments
        .map((e) => e.toJsonObject())
        .map((e) => jsonEncode(e))
        .toList();

    await sharedPreferencesConnector.updateList(
        json, _assessmentsSharedPreferencesKey);

    logger.debug("Saved assessments to shared preferences.");
    assessmentChangeNotifier.notifyListeners();
  }
}
