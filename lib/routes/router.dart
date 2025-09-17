import 'package:go_router/go_router.dart';
import 'package:trackermobile/services/auth_gate.dart';
import 'package:trackermobile/views/company_authentication/add_employee_view.dart';
import 'package:trackermobile/views/company_authentication/sign_in_view.dart';
import 'package:trackermobile/views/company_authentication/singn_up_view.dart';
import 'package:trackermobile/views/splash.dart';
import 'package:trackermobile/views/emplooyee_view/employee_view.dart';
import 'package:trackermobile/views/home/home.dart';

// Configure routes
final GoRouter router = GoRouter(
  routes: [
    GoRoute(
      path: '/add-employee',
      builder: (context, state) {
        final username = state.extra as String?;
        return AddEmployeeScreen(user: username ?? '');
      },
    ),
    GoRoute(path: '/', builder: (context, state) => SplashScreen()),
    GoRoute(path: '/signup', builder: (context, state) => SignupView()),
    GoRoute(path: '/home', builder: (context, state) => HomeView()),
    GoRoute(path: '/login', builder: (context, state) => SignInView()),
    GoRoute(
      name: 'employee',
      path: '/employee:id',

      builder: (context, state) {
        final employee = state.pathParameters['id'];
        return EmployeeDetailPage(employee: employee!);
      },
    ),
    // GoRoute(
    //   path: '/add-employee',
    //   builder: (context, state) => AddEmployeeScreen(),
    // ),
    GoRoute(path: '/auth_gate', builder: (context, state) => const AuthGate()),
  ],
);
