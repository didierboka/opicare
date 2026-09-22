import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/core/res/styles/text_style.dart';
import 'package:opicare/core/widgets/form_widgets/custom_button.dart';
import 'package:opicare/features/administration/domain/entities/patient_search_entity.dart';
import 'package:opicare/features/administration/presentation/bloc/patient_search_cubit.dart';

class AdministrationScreen extends StatefulWidget {
  static const path = '/administration';

  const AdministrationScreen({super.key});

  @override
  State<AdministrationScreen> createState() => _AdministrationScreenState();
}

class _AdministrationScreenState extends State<AdministrationScreen> {
  final _loginController = TextEditingController();

  static const _actions = <_AdminAction>[
    _AdminAction(
      icon: Icons.person_off_outlined,
      title: 'Accès du compte',
      subtitle: 'Désactiver ou activer un utilisateur',
    ),
    _AdminAction(
      icon: Icons.vaccines_outlined,
      title: 'Vaccin',
      subtitle: 'Ajouter ou programmer un vaccin',
    ),
    _AdminAction(
      icon: Icons.card_membership_outlined,
      title: 'Abonnement',
      subtitle: 'Consulter la formule, prolonger ou payer un pass',
    ),
    _AdminAction(
      icon: Icons.edit_outlined,
      title: 'Identité',
      subtitle: 'Modifier le nom, les prénoms et la date de naissance',
    ),
  ];

  @override
  void dispose() {
    _loginController.dispose();
    super.dispose();
  }

  void _search() {
    FocusScope.of(context).unfocus();
    context.read<PatientSearchCubit>().search(_loginController.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colours.background,
      appBar: AppBar(
        backgroundColor: Colours.background,
        elevation: 0,
        leading: BackButton(onPressed: () => context.pop()),
        title: Text('Administration', style: TextStyles.titleMedium),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          Text(
            'Recherche exacte sur le login d’un patient actif, avec un abonnement.',
            style: TextStyles.bodyRegular.copyWith(color: Colours.secondaryText),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _loginController,
            textInputAction: TextInputAction.search,
            autocorrect: false,
            decoration: InputDecoration(
              labelText: 'Login patient',
              filled: true,
              fillColor: Colours.background,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onSubmitted: (_) => _search(),
          ),
          const SizedBox(height: 12),
          BlocBuilder<PatientSearchCubit, PatientSearchState>(
            builder: (context, state) {
              if (state is PatientSearchLoading) {
                return const Center(child: CircularProgressIndicator());
              }
              return CustomButton(text: 'Rechercher', onPressed: _search);
            },
          ),
          const SizedBox(height: 16),
          BlocBuilder<PatientSearchCubit, PatientSearchState>(
            builder: (context, state) => _SearchResult(state: state),
          ),
          const SizedBox(height: 8),
          Text(
            'Les actions ci-dessous restent en attente de leurs API.',
            style: TextStyles.bodyRegular.copyWith(color: Colours.secondaryText),
          ),
          const SizedBox(height: 12),
          for (final action in _actions) ...[
            _AdminActionTile(action: action),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

class _SearchResult extends StatelessWidget {
  final PatientSearchState state;

  const _SearchResult({required this.state});

  @override
  Widget build(BuildContext context) {
    final current = state;
    if (current is PatientSearchFailure) {
      return _Message(text: current.message, isError: true);
    }
    if (current is! PatientSearchReady) return const SizedBox.shrink();

    final envelope = current.envelope;
    if (!envelope.success || envelope.patients.isEmpty) {
      final text = envelope.message.isEmpty ? 'Aucun resultat trouve' : envelope.message;
      return _Message(text: text, isError: false);
    }

    return Column(
      children: [
        for (final patient in envelope.patients) ...[
          _PatientCard(patient: patient),
          const SizedBox(height: 12),
        ],
      ],
    );
  }
}

class _Message extends StatelessWidget {
  final String text;
  final bool isError;

  const _Message({required this.text, required this.isError});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: TextStyles.bodyRegular.copyWith(
        color: isError ? Colors.red.shade700 : Colours.secondaryText,
      ),
    );
  }
}

class _PatientCard extends StatelessWidget {
  final PatientSearchEntity patient;

  const _PatientCard({required this.patient});

  @override
  Widget build(BuildContext context) {
    final rows = <MapEntry<String, String>>[
      MapEntry('Login', patient.lPat),
      MapEntry('Nom', patient.nPat),
      MapEntry('Téléphone', patient.tPat),
      MapEntry('Email', patient.ePat),
      MapEntry('Sexe', patient.sPat),
      MapEntry('Naissance', patient.dtPat),
      MapEntry('ID patient', patient.idPat),
      MapEntry('Formule', patient.abonLabel),
      MapEntry('Type', patient.abonType),
      MapEntry('Expiration', patient.expAbn),
      MapEntry('Langue', patient.lang),
      MapEntry('Grossesse', patient.preg),
      MapEntry('Âge de grossesse', patient.agePreg),
      MapEntry('Début de grossesse', patient.debutPreg),
      MapEntry('Fin de grossesse', patient.datePregEnd),
      MapEntry('Statut FJ', patient.stFJ),
      MapEntry('Date FJ', patient.dtFJ),
      MapEntry('Libellé FJ', patient.ltFJ),
      MapEntry('plgId', patient.plgId),
      MapEntry('fm', patient.fm),
    ].where((row) => row.value.trim().isNotEmpty).toList();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colours.homeCardSecondaryBlue.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final row in rows)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Text('${row.key} : ${row.value}', style: TextStyles.bodyRegular),
            ),
        ],
      ),
    );
  }
}

class _AdminAction {
  final IconData icon;
  final String title;
  final String subtitle;

  const _AdminAction({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _AdminActionTile extends StatelessWidget {
  final _AdminAction action;

  const _AdminActionTile({required this.action});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: 0.55,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colours.background,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(action.icon, color: Colours.homeCardSecondaryBlue),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(action.title, style: TextStyles.bodyBold),
                  const SizedBox(height: 4),
                  Text(
                    action.subtitle,
                    style: TextStyles.bodyRegular.copyWith(
                      color: Colours.secondaryText,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
