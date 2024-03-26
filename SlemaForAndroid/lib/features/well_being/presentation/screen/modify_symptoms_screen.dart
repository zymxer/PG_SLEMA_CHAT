import 'package:flutter/material.dart';
import 'package:pg_slema/features/well_being/logic/entity/assessment.dart';
import 'package:pg_slema/utils/log/logger_mixin.dart';
import 'package:pg_slema/utils/widgets/default_appbar/default_appbar.dart';
import 'package:pg_slema/utils/widgets/default_body/default_body.dart';

class ModifySymptomsScreen extends StatefulWidget {
  final Assessment assessment;
  final void Function(Assessment Function(Assessment)) onDataChanged;

  const ModifySymptomsScreen({
    super.key,
    required this.assessment,
    required this.onDataChanged,
  });

  @override
  State<ModifySymptomsScreen> createState() => ModifySymptomsScreenState();
}

class ModifySymptomsScreenState extends State<ModifySymptomsScreen>
    with Logger {
  Assessment? assessment;

  @override
  void initState() {
    super.initState();

    assessment = widget.assessment;
  }

  @override
  Widget build(BuildContext context) {
    // TODO: Fix styling
    return Scaffold(
      body: Column(
        children: [
          const DefaultAppBar(title: "Symptomy"),
          DefaultBody(
            child: ListView.builder(
              itemCount: assessment!.symptomEntries.symptomEntries.length,
              itemBuilder: (context, index) {
                return Row(
                  children: [
                    IconButton(
                      onPressed: () {
                        onDeletePressed(index);
                      },
                      icon: const Icon(Icons.remove),
                    ),
                    Expanded(
                      child: Text(
                        assessment!.symptomEntries.symptomEntries[index].name,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        onMoveUpPressed(index);
                      },
                      icon: const Icon(Icons.arrow_upward),
                    ),
                    IconButton(
                      onPressed: () {
                        onMoveDownPressed(index);
                      },
                      icon: const Icon(Icons.arrow_downward),
                    ),
                  ],
                );
              },
            ),
          ),
          SymptomsBottomBar(
            onSymptomAddPressed: onSymptomAddPressed,
          ),
        ],
      ),
    );
  }

  void onDeletePressed(int index) {
    logger.debug("Symptom remove: $index");

    final symptomEntries =
        assessment!.symptomEntries.copyWithRemovedEntry(index);
    updateSymptomEntries(symptomEntries);
  }

  void onMoveUpPressed(int index) {
    logger.debug("Symptom move up: $index");

    if (index == 0) {
      logger.warning("Cannot move up an item at index 0.");
      return;
    }

    final symptomEntries =
        assessment!.symptomEntries.copyWithSwappedIndexes(index - 1, index);
    updateSymptomEntries(symptomEntries);
  }

  void onMoveDownPressed(int index) {
    logger.debug("Symptom move down: $index");

    if (index == assessment!.symptomEntries.symptomEntries.length - 1) {
      logger.warning("Cannot move up an item at max index.");
      return;
    }

    final symptomEntries =
        assessment!.symptomEntries.copyWithSwappedIndexes(index, index + 1);
    updateSymptomEntries(symptomEntries);
  }

  void onSymptomAddPressed(String value) {
    logger.debug("Symptom add: $value");

    // TODO: Validate input

    final symptomEntries =
        assessment!.symptomEntries.copyWithAdditionalEntry(value);
    updateSymptomEntries(symptomEntries);
  }

  void updateSymptomEntries(SymptomEntries symptomEntries) {
    final newAssessment = assessment!.copyWith(symptomEntries: symptomEntries);
    setState(() {
      assessment = newAssessment;
    });

    widget.onDataChanged((assessment) {
      return newAssessment;
    });
  }
}

class SymptomsBottomBar extends StatefulWidget {
  final void Function(String) onSymptomAddPressed;

  const SymptomsBottomBar({
    super.key,
    required this.onSymptomAddPressed,
  });

  @override
  State<SymptomsBottomBar> createState() => SymptomsBottomBarState();
}

class SymptomsBottomBarState extends State<SymptomsBottomBar> with Logger {
  final double labelFontSize = 48.0;

  String value = "";

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 64.0,
        maxHeight: 64.0,
      ),
      color: Theme.of(context).primaryColor,
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            IconButton(
              onPressed: onPressed,
              icon: const Icon(Icons.add),
            ),
            Expanded(
              // TODO: This settings seem to make no difference. Fix displaying the text.
              child: TextFormField(
                onChanged: onChanged,
                decoration: InputDecoration(
                  labelStyle: TextStyle(
                    fontSize: labelFontSize,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  void onChanged(String newValue) {
    value = newValue;
  }

  void onPressed() {
    logger.debug("Pressed add button.");
    widget.onSymptomAddPressed(value);
  }
}
