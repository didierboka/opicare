import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/helpers/debug_logger.dart';
import 'package:opicare/core/widgets/navigation/custom_appbar.dart';
import 'package:opicare/features/hopitaux/data/models/nom_vaccin_model.dart';
import 'package:opicare/features/hopitaux/data/models/type_visite_model.dart';
import 'package:opicare/features/hopitaux/data/repositories/nom_vaccin_repository.dart';
import 'package:opicare/features/hopitaux/data/repositories/type_visite_repository.dart';
import 'package:opicare/features/hopitaux/presentation/bloc/nom_vaccin_bloc.dart';
import 'package:opicare/features/hopitaux/presentation/widgets/nom_vaccin_dropdown.dart';

class ExempleNomVaccinScreen extends StatefulWidget {
  static const path = '/exemple-nom-vaccin';

  const ExempleNomVaccinScreen({super.key});

  @override
  State<ExempleNomVaccinScreen> createState() => _ExempleNomVaccinScreenState();
}

class _ExempleNomVaccinScreenState extends State<ExempleNomVaccinScreen> {
  TypeVisiteModel? _selectedTypeVaccin;
  NomVaccinModel? _selectedNomVaccin;
  List<TypeVisiteModel> _typesVaccins = [];
  bool _isLoadingTypes = false;

  @override
  void initState() {
    super.initState();
    _loadTypesVaccins();
  }

  Future<void> _loadTypesVaccins() async {
    setState(() {
      _isLoadingTypes = true;
    });

    try {
      final repository = TypeVisiteRepositoryImpl();
      final response = await repository.getTypeVisites();
      
      if (response.status && response.data != null) {
        setState(() {
          _typesVaccins = [response.data!];
          _isLoadingTypes = false;
        });
      } else {
        setState(() {
          _isLoadingTypes = false;
        });
        DebugLogger.error('Erreur lors du chargement des types de vaccins: ${response.message}');
      }
    } catch (e) {
      setState(() {
        _isLoadingTypes = false;
      });
      DebugLogger.error('Exception lors du chargement des types de vaccins: $e');
    }
  }

  void _onTypeVaccinChanged(TypeVisiteModel? typeVaccin) {
    setState(() {
      _selectedTypeVaccin = typeVaccin;
      // Réinitialiser le nom de vaccin sélectionné quand le type change
      _selectedNomVaccin = null;
    });
    
    if (typeVaccin != null) {
      DebugLogger.log('Type de vaccin sélectionné: ${typeVaccin.typeVisite} (ID: ${typeVaccin.id})');
    }
  }

  void _onNomVaccinChanged(NomVaccinModel? nomVaccin) {
    setState(() {
      _selectedNomVaccin = nomVaccin;
    });
    
    if (nomVaccin != null) {
      DebugLogger.log('Nom de vaccin sélectionné: ${nomVaccin.nomVac} (ID: ${nomVaccin.idVac})');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Exemple - Sélection de vaccins",
        scaffoldKey: GlobalKey<ScaffoldState>(),
      ),
      body: BlocProvider(
        create: (context) => NomVaccinBloc(
          nomVaccinRepository: NomVaccinRepositoryImpl(),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sélection de vaccins',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 24),
                
                // Dropdown pour le type de vaccin
                Text(
                  'Type de vaccin',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: DropdownButtonFormField<TypeVisiteModel>(
                    value: _selectedTypeVaccin,
                    decoration: const InputDecoration(
                      hintText: 'Sélectionnez un type de vaccin',
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    ),
                    items: _isLoadingTypes
                        ? [
                            const DropdownMenuItem<TypeVisiteModel>(
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
                          ]
                        : _typesVaccins.map((typeVaccin) {
                            return DropdownMenuItem<TypeVisiteModel>(
                              value: typeVaccin,
                              child: Text(typeVaccin.typeVisite),
                            );
                          }).toList(),
                    onChanged: _onTypeVaccinChanged,
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Dropdown pour le nom de vaccin
                NomVaccinDropdown(
                  selectedTypeVaccinId: _selectedTypeVaccin?.id,
                  selectedNomVaccin: _selectedNomVaccin,
                  onNomVaccinChanged: _onNomVaccinChanged,
                  label: 'Nom du vaccin',
                  hint: 'Sélectionnez un nom de vaccin',
                  isRequired: true,
                ),
                
                const SizedBox(height: 32),
                
                // Affichage des informations sélectionnées
                if (_selectedTypeVaccin != null || _selectedNomVaccin != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.blue.shade200),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Informations sélectionnées:',
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (_selectedTypeVaccin != null) ...[
                          Text('Type de vaccin: ${_selectedTypeVaccin!.typeVisite}'),
                          Text('ID du type: ${_selectedTypeVaccin!.id}'),
                          const SizedBox(height: 8),
                        ],
                        if (_selectedNomVaccin != null) ...[
                          Text('Nom du vaccin: ${_selectedNomVaccin!.nomVac}'),
                          Text('ID du vaccin: ${_selectedNomVaccin!.idVac}'),
                          Text('Période: ${_selectedNomVaccin!.periodeVac}'),
                        ],
                      ],
                    ),
                  ),
                ],
                
                const Spacer(),
                
                // Bouton de validation
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _selectedNomVaccin != null
                        ? () {
                            DebugLogger.success('Validation réussie!');
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Sélection validée avec succès!'),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Valider la sélection',
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 