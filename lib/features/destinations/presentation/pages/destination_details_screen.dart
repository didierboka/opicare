import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/helpers/debug_logger.dart';
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
          }

          if (state is DestinationDetailsLoaded) {
            final destination = state.details;

            DebugLogger.log("Destination: $destination");

            // return Container();
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  Text(
                    "$destination",
                  ),
                ],
              ),
            );
          }

          if (state is DestinationError) {
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
