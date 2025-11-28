import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/helpers/debug_logger.dart';
import 'package:opicare/features/hopitaux/data/models/nom_vaccin_model.dart';
import 'package:opicare/features/hopitaux/presentation/bloc/nom_vaccin_bloc.dart';
import 'package:opicare/features/hopitaux/presentation/bloc/nom_vaccin_event.dart';
import 'package:opicare/features/hopitaux/presentation/bloc/nom_vaccin_state.dart';

class NomVaccinDropdown extends StatefulWidget {
  final String? selectedTypeVaccinId;
  final NomVaccinModel? selectedNomVaccin;
  final Function(NomVaccinModel?) onNomVaccinChanged;
  final String? label;
  final String? hint;
  final bool isRequired;

  const NomVaccinDropdown({
    Key? key,
    this.selectedTypeVaccinId,
    this.selectedNomVaccin,
    required this.onNomVaccinChanged,
    this.label,
    this.hint,
    this.isRequired = false,
  }) : super(key: key);

  @override
  State<NomVaccinDropdown> createState() => _NomVaccinDropdownState();
}

class _NomVaccinDropdownState extends State<NomVaccinDropdown> {
  NomVaccinModel? _selectedNomVaccin;

  @override
  void initState() {
    super.initState();
    _selectedNomVaccin = widget.selectedNomVaccin;
    _loadNomsVaccins();
  }

  @override
  void didUpdateWidget(NomVaccinDropdown oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Si le type de vaccin a changé, recharger les noms de vaccins
    if (oldWidget.selectedTypeVaccinId != widget.selectedTypeVaccinId) {
      _loadNomsVaccins();
      _selectedNomVaccin = null;
      widget.onNomVaccinChanged(null);
    }
    
    // Si le nom de vaccin sélectionné a changé depuis l'extérieur
    if (oldWidget.selectedNomVaccin != widget.selectedNomVaccin) {
      _selectedNomVaccin = widget.selectedNomVaccin;
    }
  }

  void _loadNomsVaccins() {
    if (widget.selectedTypeVaccinId != null && widget.selectedTypeVaccinId!.isNotEmpty) {
      DebugLogger.log('Chargement des noms de vaccins pour le type: ${widget.selectedTypeVaccinId}');
      context.read<NomVaccinBloc>().add(LoadNomsVaccins(widget.selectedTypeVaccinId!));
    } else {
      // Si aucun type de vaccin sélectionné, vider la liste
      context.read<NomVaccinBloc>().add(ClearNomsVaccins());
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NomVaccinBloc, NomVaccinState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (widget.label != null) ...[
              Text(
                widget.label!,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
            ],
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonFormField<NomVaccinModel>(
                value: _selectedNomVaccin,
                decoration: InputDecoration(
                  hintText: widget.hint ?? 'Sélectionnez une visite',
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                ),
                items: _buildDropdownItems(state),
                onChanged: (NomVaccinModel? value) {
                  setState(() {
                    _selectedNomVaccin = value;
                  });
                  widget.onNomVaccinChanged(value);
                },
                validator: widget.isRequired
                    ? (value) {
                        if (value == null) {
                          return 'Veuillez sélectionner une visite';
                        }
                        return null;
                      }
                    : null,
              ),
            ),
            if (state is NomVaccinFailure) ...[
              const SizedBox(height: 8),
              Text(
                state.message,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ],
          ],
        );
      },
    );
  }

  List<DropdownMenuItem<NomVaccinModel>> _buildDropdownItems(NomVaccinState state) {
    if (state is NomVaccinLoading) {
      return [
        const DropdownMenuItem<NomVaccinModel>(
          value: null,
          child: Row(
            children: [
              SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8),
              Text('Chargement...'),
            ],
          ),
        ),
      ];
    }

    if (state is NomVaccinLoaded) {
      if (state.nomsVaccins.isEmpty) {
        return [
          const DropdownMenuItem<NomVaccinModel>(
            value: null,
            child: Text('Aucun nom de vaccin disponible'),
          ),
        ];
      }

      return state.nomsVaccins.map((nomVaccin) {
        return DropdownMenuItem<NomVaccinModel>(
          value: nomVaccin,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                nomVaccin.nomVac,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              if (nomVaccin.periodeVac.isNotEmpty)
                Text(
                  'Période: ${nomVaccin.periodeVac}',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
            ],
          ),
        );
      }).toList();
    }

    // État initial ou en cas d'erreur
    return [
      const DropdownMenuItem<NomVaccinModel>(
        value: null,
        child: Text('Sélectionnez un type de vaccin d\'abord'),
      ),
    ];
  }
} 