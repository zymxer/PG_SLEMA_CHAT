import 'package:flutter/material.dart';
import 'package:pg_slema/features/well_being/presentation/widget/assessment_app_bar.dart';
import 'package:pg_slema/features/well_being/presentation/widget/forms/sleep/assessment_sleep_form.dart';
import 'package:pg_slema/utils/widgets/default_container/default_container.dart';
import 'package:pg_slema/features/well_being/presentation/widget/forms/symptoms/assessment_symptoms_form.dart';
import 'package:pg_slema/features/well_being/presentation/widget/forms/well_being/assessment_well_being_form.dart';
import 'package:pg_slema/utils/date/date.dart';
import 'package:pg_slema/utils/log/logger_mixin.dart';

class AssessmentScreen extends StatefulWidget {
  const AssessmentScreen({super.key});

  @override
  State<AssessmentScreen> createState() => _AssessmentScreenState();
}

class _AssessmentScreenState extends State<AssessmentScreen> with Logger {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final currentDateString = DateTime.now().toDateString();
    return CustomScrollView(
      slivers: <Widget>[
        const AssessmentAppBar(),
        SliverToBoxAdapter(
          child: Form(
            key: _formKey,
            child: const Column(
              children: [
                DefaultContainer(
                  padding: EdgeInsets.all(15),
                  child: AssessmentWellBeingForm(),
                ),
                DefaultContainer(
                  padding: EdgeInsets.all(15),
                  child: AssessmentSymptomsFormWidget(),
                ),
                DefaultContainer(
                  padding: EdgeInsets.all(15),
                  child: AssessmentSleepForm(),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
