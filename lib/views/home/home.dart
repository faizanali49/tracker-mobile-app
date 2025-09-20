import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trackermobile/providers/fetch_company_provider.dart';
import 'package:trackermobile/providers/fetch_employee_provider.dart';
import 'package:trackermobile/providers/sign_in_providers.dart';
import 'package:trackermobile/widgets/employee_list_widget.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  String? usernrole;
  String? avatarUrl;
  final _searchController = TextEditingController();
  final String? companyId = FirebaseAuth.instance.currentUser?.email
      ?.toLowerCase();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();

    // Set companyEmailProvider state after widget build
    Future.microtask(() {
      if (companyId != null) {
        ref.read(companyEmailProvider.notifier).state = companyId!;
      }
    });

    // Fetch company data
    ref.read(companyDataProvider.future).then((data) {
      if (data != null) {
        setState(() {
          usernrole = data['company'];
          avatarUrl = data['avatarUrl'];
        });
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (companyId == null) {
      return const Scaffold(body: Center(child: Text('User not logged in')));
    }

    final employeesAsyncValue = ref.watch(employeesStreamProvider(companyId!));

    return Container(
      // Add decoration with background image
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg-2.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        // Make the scaffold background transparent to show the image
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.white.withValues(alpha: 0.6),
          elevation: 0,
          toolbarHeight: 80,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                        ? NetworkImage(avatarUrl!)
                        : const AssetImage('assets/images/boss.jpg')
                              as ImageProvider,
                  ),
                  const SizedBox(width: 16),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usernrole ?? 'Company',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                      ),
                      const Text(
                        "Admin",
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      context.push('/add-employee');
                    },
                    icon: const Icon(
                      Icons.person_add_alt_1,
                      color: Colors.blueAccent,
                      size: 28,
                    ),
                    tooltip: 'Add Employee',
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(
                      Icons.refresh,
                      color: Colors.blue,
                      size: 28,
                    ),
                    onPressed: () {
                      ref.invalidate(employeesStreamProvider(companyId!));
                    },
                    tooltip: 'Refresh',
                  ),
                  const SizedBox(width: 4),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.red, size: 28),
                    onPressed: () async {
                      try {
                        await FirebaseAuth.instance.signOut();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error signing out: $e')),
                        );
                      }
                    },
                    tooltip: 'Logout',
                  ),
                ],
              ),
            ],
          ),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 18,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Colors.grey,
                    size: 24,
                  ),
                  hintText: "Search employee...",
                  hintStyle: TextStyle(fontSize: 16, color: Colors.grey[500]),
                  border: InputBorder.none,
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Colors.blueAccent,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
              child: Text(
                'Employees',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ),
            Expanded(
              child: employeesAsyncValue.when(
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) => Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error, color: Colors.red, size: 60),
                      const SizedBox(height: 20),
                      Text(
                        'Error: $error',
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          // Optional retry logic here
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Retry'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          backgroundColor: Colors.blueAccent,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                data: (employees) {
                  final filteredEmployees = _searchQuery.isEmpty
                      ? employees
                      : employees
                            .where(
                              (e) => e.name.toLowerCase().contains(
                                _searchQuery.toLowerCase(),
                              ),
                            )
                            .toList();

                  return RefreshIndicator(
                    onRefresh: () async {
                      // Invalidate both providers to refresh all data
                      ref.invalidate(employeesStreamProvider(companyId!));
                      ref.invalidate(companyDataProvider);
                    },
                    child: filteredEmployees.isEmpty
                        ? ListView(
                            // Add ListView to make RefreshIndicator work with empty state
                            children: const [
                              SizedBox(height: 100),
                              Center(
                                child: Text(
                                  'No employees found',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.black54,
                                  ),
                                ),
                              ),
                            ],
                          )
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            itemCount: filteredEmployees.length,
                            itemBuilder: (context, index) {
                              final employee = filteredEmployees[index];
                              final asyncStatus = ref.watch(
                                employeeCurrentStatus((
                                  companyId!,
                                  employee.email,
                                )),
                              );

                              return asyncStatus.when(
                                loading: () => EmployeeListWidget(
                                  context,
                                  employee,
                                  Colors.grey[200]!,
                                  Colors.grey[400]!,
                                  false,
                                ),
                                error: (error, stack) =>
                                    Center(child: Text('Error: $error')),
                                data: (status) {
                                  Color borderColor = Colors.grey[400]!;
                                  Color dotColor = Colors.grey[400]!;
                                  bool hasStatus = false;

                                  if (status.isNotEmpty) {
                                    hasStatus = true;
                                    switch (status.first.status.toLowerCase()) {
                                      case 'online':
                                        borderColor = Colors.greenAccent;
                                        dotColor = Colors.green;
                                        break;
                                      case 'offline':
                                        borderColor = Colors.redAccent;
                                        dotColor = Colors.red;
                                        break;
                                      case 'paused':
                                        borderColor = Colors.orangeAccent;
                                        dotColor = Colors.orange;
                                        break;
                                    }
                                  }

                                  return EmployeeListWidget(
                                    context,
                                    employee,
                                    borderColor,
                                    dotColor,
                                    hasStatus,
                                  );
                                },
                              );
                            },
                          ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Removing the old buildStatusCard as it's no longer needed for the new design
