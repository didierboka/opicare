import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:opicare/core/res/styles/colours.dart';
import 'package:opicare/features/api_test/presentation/bloc/api_test_bloc.dart';
import 'package:opicare/features/api_test/presentation/widgets/api_request_form.dart';
import 'package:opicare/features/api_test/presentation/widgets/api_response_viewer.dart';

class ApiTestPage extends StatelessWidget {
  static const String path = '/api-test';

  const ApiTestPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ApiTestBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'Test APIs',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          backgroundColor: Colours.primaryBlue,
          elevation: 0,
          centerTitle: true,
        ),
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colours.primaryBlue,
                Colors.white,
              ],
              stops: const [0.0, 0.3],
            ),
          ),
          child: SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  const ApiRequestForm(),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: MediaQuery.of(context).size.height * 0.5,
                    child: const ApiResponseViewer(),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
} 