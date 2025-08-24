import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/features/destinations/presentation/bloc/destination_bloc.dart';
import 'package:opicare/features/destinations/presentation/bloc/destination_event.dart';
import 'package:opicare/features/destinations/presentation/bloc/destination_state.dart';
import 'package:opicare/features/destinations/presentation/widgets/destination_card.dart';

class DestinationsScreen extends StatefulWidget {
  static const String routeName = '/destinations';

  const DestinationsScreen({Key? key}) : super(key: key);

  @override
  _DestinationsScreenState createState() => _DestinationsScreenState();
}

class _DestinationsScreenState extends State<DestinationsScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les destinations au démarrage
    context.read<DestinationBloc>().add(LoadDestinationsEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Destinations'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocConsumer<DestinationBloc, DestinationState>(
        listener: (context, state) {
          if (state is DestinationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is DestinationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DestinationsLoaded) {
            return ListView.builder(
              itemCount: state.destinations.length,
              itemBuilder: (context, index) {
                final destination = state.destinations[index];
                return DestinationCard(destination: destination);
              },
            );
          } else if (state is DestinationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement des destinations',
                  ),
                  const SizedBox(height: 8),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<DestinationBloc>().add(LoadDestinationsEvent());
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Aucune destination disponible'));
        },
      ),
    );
  }
}
