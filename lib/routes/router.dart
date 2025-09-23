import 'package:go_router/go_router.dart';
import 'package:trackermobile/services/auth/sign_in_auth_gate.dart';
import 'package:trackermobile/views/company_authentication/sign_in_view.dart';
import 'package:trackermobile/views/company_authentication/singn_up_view.dart';
import 'package:trackermobile/views/home/add_employee.dart';
import 'package:trackermobile/views/splash.dart';
import 'package:trackermobile/views/home/home.dart';

// Configure routes
final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/add-employee',
      builder: (context, state) => const AddEmployeeScreen(),
    ),
    // GoRoute(path: '/counter', builder: (context, state) => CounterScreen()),
    // In your router configuration file
    GoRoute(path: '/', builder: (context, state) => SplashScreen()),
    GoRoute(path: '/signup', builder: (context, state) => SignupView()),
    GoRoute(path: '/home', builder: (context, state) => HomeView()),
    GoRoute(path: '/login', builder: (context, state) => SignInView()),
    // GoRoute(
    //   name: 'employee',
    //   path: '/employee/:id', // Add slash between path and parameter

    //   builder: (context, state) {
    //     final employee = state.pathParameters['id'];
    //     return EmployeeDetailPage(employee: employee!);
    //   },
    // ),
    GoRoute(path: '/auth_gate', builder: (context, state) => const AuthGate()),
  ],
);
