import 'package:flutter/material.dart';
import 'package:pg_slema/features/medicine/logic/entity/medicine.dart';
import 'package:pg_slema/features/medicine/presentation/widget/single_medicine_label.dart';
import 'package:pg_slema/features/medicine/presentation/widget/popup_menu_edit_delete_button.dart';

class SingleMedicineWidget extends StatelessWidget {
  final ValueChanged<Medicine> onMedicineDeleted;
  final ValueChanged<Medicine> onMedicineEdited;
  final Medicine medicine;

  const SingleMedicineWidget(
      {super.key,
      required this.medicine,
      required this.onMedicineDeleted,
      required this.onMedicineEdited});

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.0),
          color: Theme.of(context).colorScheme.primaryContainer,
          boxShadow: [
            BoxShadow(
              color: Theme.of(context).colorScheme.shadow,
              offset: const Offset(0.0, 4.0),
              blurRadius: 4.0,
            ),
          ],
          border: Border.all(
            color: Theme.of(context).colorScheme.outline,
            width: 3.0,
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0, right: 8.0),
                child: Icon(
                  Icons.medication_outlined,
                  color: Theme.of(context).primaryColor,
                  size: 32,
                ),
              ),
              Expanded(
                child: Text(
                  medicine.name,
                  style: Theme.of(context).textTheme.headlineLarge,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              PopupMenuEditDeleteButton(
                  onMedicineChanged: onMedicineEdited,
                  medicineProvider: () => medicine,
                  onDeletePressed: () => onMedicineDeleted(medicine)),
            ],
          ),
          SingleMedicineLabel(label: medicine.intakeType),
        ]));
  }
}
