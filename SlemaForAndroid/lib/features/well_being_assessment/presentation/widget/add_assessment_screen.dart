import 'package:flutter/material.dart';
import 'package:pg_slema/features/well_being_assessment/presentation/widget/add_assessment_app_bar.dart';
import 'package:pg_slema/utils/date/date.dart';
import 'package:pg_slema/utils/log/logger_mixin.dart';

class AddAssessmentScreen extends StatefulWidget {
  const AddAssessmentScreen({super.key});

  @override
  State<AddAssessmentScreen> createState() => _AddAssessmentScreenState();
}

class _AddAssessmentScreenState extends State<AddAssessmentScreen> with Logger {
  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final currentDateString = DateTime.now().toDateString();
    return Scaffold(
      appBar: AddAssessmentAppBar(currentDateString),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Form(
            key: _formKey,
            child: const Column(
              children: [],
            ),
          ),
        ),
      ),
    );
  }
}
