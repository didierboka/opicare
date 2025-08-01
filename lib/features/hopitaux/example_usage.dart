// Exemple d'utilisation de l'API typevisite
// 
// Ce fichier montre comment utiliser l'API typevisite dans votre code Flutter

import 'package:opicare/core/di.dart';
import 'package:opicare/features/hopitaux/data/repositories/type_visite_repository.dart';

class TypeVisiteExample {
  
  /// Exemple d'utilisation de l'API typevisite
  static Future<void> getTypeVisites() async {
    try {
      // Récupérer le repository depuis l'injection de dépendances
      final repository = Di.get<TypeVisiteRepository>();
      
      // Appeler l'API
      final response = await repository.getTypeVisites();
      
      if (response.status) {
        print('✅ API typevisite appelée avec succès!');
        
        // Afficher les types de visite récupérés
        if (response.datas != null) {
          print('📋 Types de visite disponibles:');
          for (var typeVisite in response.datas!) {
            print('  - ${typeVisite.typeVisite} (ID: ${typeVisite.id})');
          }
        }
      } else {
        print('❌ Erreur lors de l\'appel API: ${response.message}');
      }
    } catch (e) {
      print('💥 Exception lors de l\'appel API: $e');
    }
  }
  
  /// Exemple d'utilisation dans un widget
  static Future<List<String>> getTypeVisiteNames() async {
    try {
      final repository = Di.get<TypeVisiteRepository>();
      final response = await repository.getTypeVisites();
      
      if (response.status && response.datas != null) {
        // Retourner seulement les noms des types de visite
        return response.datas!.map((tv) => tv.typeVisite).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Erreur: $e');
      return [];
    }
  }
}

/*
// Utilisation dans un widget:

class MyWidget extends StatefulWidget {
  @override
  _MyWidgetState createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  List<String> typeVisites = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    loadTypeVisites();
  }

  Future<void> loadTypeVisites() async {
    setState(() {
      isLoading = true;
    });

    final types = await TypeVisiteExample.getTypeVisiteNames();
    
    setState(() {
      typeVisites = types;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Types de Visite')),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: typeVisites.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(typeVisites[index]),
                );
              },
            ),
    );
  }
}
*/ 