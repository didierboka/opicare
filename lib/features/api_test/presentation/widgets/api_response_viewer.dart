import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/features/api_test/presentation/bloc/api_test_bloc.dart';
import 'package:opicare/features/api_test/presentation/bloc/api_test_event.dart';
import 'package:opicare/features/api_test/presentation/bloc/api_test_state.dart';

class ApiResponseViewer extends StatelessWidget {
  const ApiResponseViewer({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ApiTestBloc, ApiTestState>(
      builder: (context, state) {
        return Card(
          elevation: 8,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Réponse API',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colours.primaryBlue,
                      ),
                    ),
                    if (state is ApiTestLoaded)
                      IconButton(
                        onPressed: () {
                          context.read<ApiTestBloc>().add(const ClearResponse());
                        },
                        icon: const Icon(Icons.clear),
                        tooltip: 'Effacer',
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                
                Flexible(
                  child: _buildResponseContent(context, state),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildResponseContent(BuildContext context, ApiTestState state) {
    if (state is ApiTestInitial) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.api,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'Aucune requête effectuée',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Lancez une requête pour voir la réponse ici',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (state is ApiTestLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Requête en cours...',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ),
      );
    }

    if (state is ApiTestError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            const SizedBox(height: 16),
            Text(
              'Erreur',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.message,
              style: const TextStyle(fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (state is ApiTestLoaded) {

      // Liste des données
      var datas = state.response.datas;

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Informations de la requête
            Card(
              color: Colours.inputBackground,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informations de la requête',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _buildInfoRow('Méthode', state.requestType),
                    _buildInfoRow('Endpoint', state.endpoint),
                    if (state.requestData != null)
                      _buildInfoRow('Données', _formatJson(state.requestData!)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Statut de la réponse
            Card(
              color: state.response.status ? Colors.green.shade50 : Colors.red.shade50,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Row(
                  children: [
                    Icon(
                      state.response.status ? Icons.check_circle : Icons.error,
                      color: state.response.status ? Colors.green : Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Statut: ${state.response.status ? "Succès" : "Erreur"}',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: state.response.status ? Colors.green : Colors.red,
                            ),
                          ),
                          if (state.response.message.toString().isNotEmpty)
                            Text(
                              'Message: ${state.response.message}',
                              style: const TextStyle(fontSize: 12),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            
            // Données de la réponse
            if (state.response.response != null) ...[
              Text(
                'Réponse complète',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: SelectableText(
                  _formatJson(state.response.response!),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Données parsées
            if (state.response.data != null) ...[
              Text(
                'Données parsées',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: SelectableText(
                  _formatJson(state.response.data!),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 16),

            if (datas != null && datas.isNotEmpty) ...[
              Text(
                'Liste des données (${datas.length} éléments)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange.shade200),
                ),
                child: SelectableText(
                  _formatJson(datas),
                  style: const TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ],
        ),
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  String _formatJson(dynamic data) {
    try {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    } catch (e) {
      return data.toString();
    }
  }
} 