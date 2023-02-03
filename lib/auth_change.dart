import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mentor_me/features/auth/onboarding/onboarding_screen.dart';
import 'package:mentor_me/features/home/screens/home_screen.dart';
import 'package:mentor_me/modals/mentor_user.dart';

import 'features/auth/controller/auth_controller.dart';

class AuthChange extends ConsumerStatefulWidget {
  final User data;
  const AuthChange({Key? key, required this.data}) : super(key: key);

  @override
  ConsumerState<AuthChange> createState() => _AuthChangeState();
}

class _AuthChangeState extends ConsumerState<AuthChange> {
  // This widget is the root of your application.
  bool isLoading = false;

  getData(WidgetRef ref) async {
    setState(() {
      isLoading = true;
    });
    await ref.watch(authControllerProvider.notifier).getCurrentUserData(
        uid: widget.data.uid,
        context: context,
        callback: () {
          setState(() {
            isLoading = false;
          });
        });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    getData(ref);
  }

  @override
  Widget build(BuildContext context) {
    MentorMeUser? meUser = ref.watch(userProvider);
    return Scaffold(
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : meUser == null
              ? const OnboardingComponent()
              : const HomeScreen(),
    );
  }
}
