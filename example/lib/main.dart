import 'package:flutter/material.dart';
import 'package:meiro_sdk/meiro_sdk.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await MeiroSdk.init(
    configuration: MeiroConfiguration(
      endpoint: Uri.parse('https://me.staging.meiro.tech/'),
      appId: 'example-app-id',
      firebaseProjectId: 'example-project-id',
      debugMode: true,
    ),
  );

  await MeiroSdk.trackCustomEvent({'name': 'App opened'});

  runApp(const ExampleApp());
}

/// Example application.
class ExampleApp extends StatelessWidget {
  /// Creates the example application.
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorObservers: [MeiroNavigatorObserver()],
      routes: {
        '/': (_) => const FirstScreen(),
        '/second': (_) => const SecondScreen(),
      },
    );
  }
}

/// First example screen.
class FirstScreen extends StatelessWidget {
  /// Creates the first example screen.
  const FirstScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('First screen')),
      body: Center(
        child: FilledButton(
          onPressed: () => Navigator.of(context).pushNamed('/second'),
          child: const Text('Go to second screen'),
        ),
      ),
    );
  }
}

/// Second example screen.
class SecondScreen extends StatelessWidget {
  /// Creates the second example screen.
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Second screen')),
    );
  }
}
