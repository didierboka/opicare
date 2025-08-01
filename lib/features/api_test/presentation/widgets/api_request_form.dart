import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/features/api_test/presentation/bloc/api_test_bloc.dart';
import 'package:opicare/features/api_test/presentation/bloc/api_test_event.dart';

class ApiRequestForm extends StatefulWidget {
  const ApiRequestForm({Key? key}) : super(key: key);

  @override
  State<ApiRequestForm> createState() => _ApiRequestFormState();
}

class _ApiRequestFormState extends State<ApiRequestForm> {
  final _formKey = GlobalKey<FormState>();
  final _endpointController = TextEditingController();
  final _dataController = TextEditingController();
  final _headersController = TextEditingController();
  
  String _selectedMethod = 'GET';
  bool _useFormData = true;
  bool _likeAgent = false;
  bool _likeOrange = false;

  @override
  void initState() {
    super.initState();
    // Endpoint par défaut pour tester
    _endpointController.text = '/vaccin/vaccinsInfos';
    _dataController.text = '{"d": "PROD"}';
  }

  @override
  void dispose() {
    _endpointController.dispose();
    _dataController.dispose();
    _headersController.dispose();
    super.dispose();
  }

  void _submitRequest() {
    if (!_formKey.currentState!.validate()) return;

    final bloc = context.read<ApiTestBloc>();
    
    if (_selectedMethod == 'GET') {
      bloc.add(TestGetRequest(endpoint: _endpointController.text.trim()));
    } else {
      Map<String, dynamic> data = {};
      try {
        data = Map<String, dynamic>.from(
          _dataController.text.isNotEmpty 
            ? Map<String, dynamic>.from(
                _parseJson(_dataController.text)
              )
            : {}
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur JSON: $e')),
        );
        return;
      }

      Map<String, String>? headers;
      if (_headersController.text.isNotEmpty) {
        try {
          headers = Map<String, String>.from(
            _parseJson(_headersController.text)
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur headers JSON: $e')),
          );
          return;
        }
      }

      bloc.add(TestPostRequest(
        endpoint: _endpointController.text.trim(),
        data: data,
        headers: headers,
        useFormData: _useFormData,
        likeAgent: _likeAgent,
        likeOrange: _likeOrange,
      ));
    }
  }

  Map<String, dynamic> _parseJson(String jsonString) {
    // Simple JSON parsing - en production, utilisez jsonDecode
    if (jsonString.trim().isEmpty) return {};
    
    // Supprimer les accolades et parser manuellement
    String clean = jsonString.trim();
    if (clean.startsWith('{') && clean.endsWith('}')) {
      clean = clean.substring(1, clean.length - 1);
    }
    
    Map<String, dynamic> result = {};
    List<String> pairs = clean.split(',');
    
    for (String pair in pairs) {
      if (pair.trim().isEmpty) continue;
      List<String> keyValue = pair.split(':');
      if (keyValue.length == 2) {
        String key = keyValue[0].trim().replaceAll('"', '');
        String value = keyValue[1].trim().replaceAll('"', '');
        result[key] = value;
      }
    }
    
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Test API',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colours.primaryBlue,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              
              // Méthode HTTP
              Row(
                children: [
                  const Text('Méthode: ', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(width: 10),
                  DropdownButton<String>(
                    value: _selectedMethod,
                    items: ['GET', 'POST'].map((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedMethod = newValue!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Endpoint
              TextFormField(
                controller: _endpointController,
                decoration: const InputDecoration(
                  labelText: 'Endpoint',
                  hintText: '/api/endpoint',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.link),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Veuillez entrer un endpoint';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              
              // Données (pour POST)
              if (_selectedMethod == 'POST') ...[
                TextFormField(
                  controller: _dataController,
                  decoration: const InputDecoration(
                    labelText: 'Données (JSON)',
                    hintText: '{"key": "value"}',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.data_object),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                
                // Headers (optionnel)
                TextFormField(
                  controller: _headersController,
                  decoration: const InputDecoration(
                    labelText: 'Headers (JSON optionnel)',
                    hintText: '{"Content-Type": "application/json"}',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.http),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 16),
                
                // Options POST
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Options POST:',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        CheckboxListTile(
                          title: const Text('Utiliser Form Data'),
                          value: _useFormData,
                          onChanged: (bool? value) {
                            setState(() {
                              _useFormData = value ?? true;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        CheckboxListTile(
                          title: const Text('Comme Agent'),
                          value: _likeAgent,
                          onChanged: (bool? value) {
                            setState(() {
                              _likeAgent = value ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                        CheckboxListTile(
                          title: const Text('Comme Orange'),
                          value: _likeOrange,
                          onChanged: (bool? value) {
                            setState(() {
                              _likeOrange = value ?? false;
                            });
                          },
                          controlAffinity: ListTileControlAffinity.leading,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
              ],
              
              // Bouton de soumission
              ElevatedButton.icon(
                onPressed: _submitRequest,
                icon: const Icon(Icons.send),
                label: const Text('Lancer la requête'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colours.primaryBlue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 