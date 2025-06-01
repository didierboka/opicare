import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/enums/app_enums.dart';
import 'package:opicare/core/helpers/ui_helpers.dart';
import 'package:opicare/core/widgets/form_widgets/custom_select_field.dart';
import 'package:opicare/features/souscribtion/data/models/formule.dart';
import 'package:opicare/features/souscribtion/presentation/bloc/formule/formule_bloc.dart';

// class FormuleSelect extends StatelessWidget {
//   FormuleSelect({super.key});
//
//   List<FormuleModel> list = [];
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocConsumer<FormuleBloc, FormuleState>(
//         listener: (context, state) {
//       showLoader(context, state is FormuleLoading);
//
//       if (state is FormuleSuccess) {
//         list = state.list;
//       }
//
//       if (state is FormuleFailure) {
//         showSnackbar(context,
//           message: state.message,
//           type: MessageType.error,
//         );
//       }
//     },
//     builder: (context, state){
//     return    CustomSelectField(
//       label: 'Type d\'abonnements',
//       selectedValue: selectedAbonnement,
//       hint: 'Choisir un abonnement',
//       options: for(item in)
//
//       [
//         {'libelle': 'Premium', 'valeur': 'Premium'},
//         {'libelle': 'Standard', 'valeur': 'Standard'},
//         {'libelle': 'Business', 'valeur': 'Business'},
//         {'libelle': 'Serenity', 'valeur': 'Serenity'},
//       ],
//       onSelected: (val) => setState(() => selectedAbonnement = val),
//       defaultValidator: true,
//     );
//         }
//
//     );
//   }
// }
