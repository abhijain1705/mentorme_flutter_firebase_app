import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mentor_me/auth_change.dart';
import 'package:mentor_me/features/auth/controller/auth_controller.dart';
import 'package:mentor_me/features/auth/onboarding/onboarding_screen.dart';
import 'package:mentor_me/utils/error.dart';
import 'package:mentor_me/utils/loading.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    const ProviderScope(child: MyApp()),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> {


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mentor Me',
      debugShowCheckedModeBanner: false,
      home: ref.watch(authStateChangeProvider).when(
          data: (data) {
            if (data != null) {
              return AuthChange(data: data);
            } else {
              return const OnboardingComponent();
            }
          },
          error: (error, stackTrace) => ErrorText(error: error.toString()),
          loading: () => const Loading()),
    );
  }
}
