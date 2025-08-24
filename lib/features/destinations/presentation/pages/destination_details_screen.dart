import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/features/destinations/domain/entities/destination_entity.dart';
import 'package:opicare/features/destinations/presentation/bloc/destination_bloc.dart';
import 'package:opicare/features/destinations/presentation/bloc/destination_event.dart';
import 'package:opicare/features/destinations/presentation/bloc/destination_state.dart';

class DestinationDetailsScreen extends StatefulWidget {
  static const String routeName = '/destination-details';
  final String destinationId;

  const DestinationDetailsScreen({
    Key? key,
    required this.destinationId,
  }) : super(key: key);

  @override
  _DestinationDetailsScreenState createState() => _DestinationDetailsScreenState();
}

class _DestinationDetailsScreenState extends State<DestinationDetailsScreen> {
  late DestinationBloc _destinationBloc;

  @override
  void initState() {
    super.initState();
    _destinationBloc = context.read<DestinationBloc>();
    _destinationBloc.add(LoadDestinationDetailsEvent(widget.destinationId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la destination'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<DestinationBloc, DestinationState>(
        bloc: _destinationBloc,
        builder: (context, state) {
          if (state is DestinationLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is DestinationDetailsLoaded) {
            final destination = state.destination;
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (destination.imageUrl != null)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: Image.network(
                        destination.imageUrl!,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          height: 200,
                          color: Colors.grey[300],
                          child: const Icon(Icons.image_not_supported),
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  Text(
                    destination.name,
                  ),
                  const SizedBox(height: 8),
                  if (destination.shortDescription != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(
                        destination.shortDescription!,
                      ),
                    ),
                  if (destination.fullDescription != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Text(destination.fullDescription!),
                    ),
                  if (destination.images?.isNotEmpty ?? false) ...[
                    const Text(
                      'Galerie d\'images',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    SizedBox(
                      height: 150,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: destination.images!.length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(right: 8.0),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.network(
                                destination.images![index],
                                width: 200,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) => Container(
                                  width: 200,
                                  color: Colors.grey[300],
                                  child: const Icon(Icons.broken_image),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ],
              ),
            );
          } else if (state is DestinationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 16),
                  Text(
                    'Erreur de chargement des détails',
                  ),
                  const SizedBox(height: 8),
                  Text(state.message),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      _destinationBloc.add(LoadDestinationDetailsEvent(widget.destinationId));
                    },
                    child: const Text('Réessayer'),
                  ),
                ],
              ),
            );
          }
          return const Center(child: Text('Aucune information disponible'));
        },
      ),
    );
  }
}
