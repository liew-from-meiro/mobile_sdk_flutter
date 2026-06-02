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

class ExampleApp extends StatelessWidget {
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

class FirstScreen extends StatelessWidget {
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

class SecondScreen extends StatelessWidget {
  const SecondScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: Text('Second screen')),
    );
  }
}

