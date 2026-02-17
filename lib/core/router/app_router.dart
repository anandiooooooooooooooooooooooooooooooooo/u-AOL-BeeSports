import 'package:beesports/core/di/injection_container.dart';
import 'package:beesports/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:beesports/features/auth/presentation/screens/login_screen.dart';
import 'package:beesports/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:beesports/features/auth/presentation/screens/otp_screen.dart';
import 'package:beesports/features/auth/presentation/screens/register_screen.dart';
import 'package:beesports/features/home/presentation/screens/home_screen.dart';
import 'package:beesports/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:beesports/features/profile/presentation/screens/profile_edit_screen.dart';
import 'package:beesports/features/profile/presentation/screens/profile_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

/// App router configuration using GoRouter.
class AppRouter {
  final AuthBloc authBloc;

  AppRouter(this.authBloc);

  late final GoRouter router = GoRouter(
    initialLocation: '/login',
    refreshListenable: _AuthNotifier(authBloc),
    redirect: (context, state) {
      final authState = authBloc.state;
      final isOnAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/register' ||
          state.matchedLocation == '/otp';

      // If unauthenticated or error, go to login
      if (authState is Unauthenticated || authState is AuthError) {
        return isOnAuthRoute ? null : '/login';
      }

      // If needs OTP verification
      if (authState is NeedsOtpVerification) {
        return '/otp';
      }

      // If needs onboarding
      if (authState is NeedsOnboarding) {
        return state.matchedLocation == '/onboarding' ? null : '/onboarding';
      }

      // If authenticated, don't stay on auth screens
      if (authState is Authenticated && isOnAuthRoute) {
        return '/home';
      }

      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => LoginScreen(
          onNavigateToRegister: () => context.go('/register'),
        ),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => RegisterScreen(
          onNavigateToLogin: () => context.go('/login'),
        ),
      ),
      GoRoute(
        path: '/otp',
        builder: (context, state) {
          final authState = authBloc.state;
          final email =
              authState is NeedsOtpVerification ? authState.email : '';
          return OtpScreen(email: email);
        },
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) {
          final authState = authBloc.state;
          if (authState is NeedsOnboarding) {
            return OnboardingScreen(user: authState.user);
          }
          return const SizedBox.shrink();
        },
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/profile',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<ProfileBloc>(),
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/profile/edit',
        builder: (context, state) => BlocProvider(
          create: (_) => sl<ProfileBloc>(),
          child: const ProfileEditScreen(),
        ),
      ),
    ],
  );
}

/// Converts BLoC stream to ChangeNotifier for GoRouter refresh.
class _AuthNotifier extends ChangeNotifier {
  _AuthNotifier(AuthBloc bloc) {
    bloc.stream.listen((_) => notifyListeners());
  }
}
