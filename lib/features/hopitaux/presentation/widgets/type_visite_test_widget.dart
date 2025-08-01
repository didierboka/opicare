import 'package:flutter/material.dart';
import 'package:opicare/core/di.dart';
import 'package:opicare/features/hopitaux/data/repositories/type_visite_repository.dart';

class TypeVisiteTestWidget extends StatefulWidget {
  const TypeVisiteTestWidget({Key? key}) : super(key: key);

  @override
  State<TypeVisiteTestWidget> createState() => _TypeVisiteTestWidgetState();
}

class _TypeVisiteTestWidgetState extends State<TypeVisiteTestWidget> {
  bool isLoading = false;
  String result = '';
  String error = '';

  Future<void> testTypeVisiteApi() async {
    setState(() {
      isLoading = true;
      result = '';
      error = '';
    });

    try {
      final repository = Di.get<TypeVisiteRepository>();
      final response = await repository.getTypeVisites();

      if (response.status) {
        setState(() {
          result = 'Succès!\n\nTypes de visite récupérés:\n';
          if (response.datas != null) {
            for (var typeVisite in response.datas!) {
              result += '- ${typeVisite.typeVisite} (ID: ${typeVisite.id})\n';
            }
          }
        });
      } else {
        setState(() {
          error = 'Erreur: ${response.message}';
        });
      }
    } catch (e) {
      setState(() {
        error = 'Exception: $e';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Test API TypeVisite'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: isLoading ? null : testTypeVisiteApi,
              child: isLoading
                  ? const CircularProgressIndicator()
                  : const Text('Tester l\'API TypeVisite'),
            ),
            const SizedBox(height: 20),
            if (result.isNotEmpty) ...[
              const Text(
                'Résultat:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Text(
                  result,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
            if (error.isNotEmpty) ...[
              const SizedBox(height: 20),
              const Text(
                'Erreur:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.red),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Text(
                  error,
                  style: const TextStyle(fontSize: 14, color: Colors.red),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
} 