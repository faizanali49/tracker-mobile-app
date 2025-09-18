import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trackermobile/providers/sign_in_providers.dart';
import 'package:trackermobile/themes/colors.dart';
import 'package:trackermobile/models/fetch_employee_model.dart';
import 'package:trackermobile/providers/fetch_employee_provider.dart';
import 'package:trackermobile/services/auth/sign_out_global_auth.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  static String? usernrole;
  bool _isRefreshing = false;
  String? avatarUrl;
  final _searchController = TextEditingController();
  List<Employee> _filteredEmployees = [];

  @override
  void initState() {
    super.initState();

    // Load company data
    ref.read(companyDataProvider.future).then((data) {
      if (data != null) {
        setState(() {
          usernrole = data['username'];
          ref.read(usernameProvider.notifier).state = usernrole;
          avatarUrl = data['avatarUrl'];
        });
      }
    });

    setState(() => _isRefreshing = true);
    try {
      ref.read(employeesProvider.notifier).fetchEmployees();
    } catch (e) {
      // Optionally handle error
    } finally {
      if (mounted) setState(() => _isRefreshing = false);
    }

    // ref.invalidate(employeesProvider);

    // _searchController.addListener(() {
    //   final employees = ref.read(employeesProvider).value ?? [];
    // });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final employeesAsync = ref.watch(employeesProvider);

    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            image: DecorationImage(
              image: AssetImage('assets/images/home-bg1.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 26,
                        backgroundImage:
                            avatarUrl != null && avatarUrl!.isNotEmpty
                            ? NetworkImage(avatarUrl!)
                            : const AssetImage('assets/images/boss.jpg')
                                  as ImageProvider,
                      ),
                      const SizedBox(width: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            usernrole ?? 'Raza',
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            "Admin",
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        context.push('/add-employee', extra: usernrole);
                      },
                      icon: const Icon(Icons.add, color: Colors.blueAccent),
                    ),
                  ),
                  Row(
                    children: [
                      // Add refresh button
                      IconButton(
                        icon: const Icon(Icons.refresh, color: Colors.blue),
                        onPressed: _isRefreshing
                            ? null
                            : () async {
                                setState(() => _isRefreshing = true);
                                try {
                                  await ref
                                      .read(employeesProvider.notifier)
                                      .fetchEmployees();
                                } catch (e) {
                                  // Optionally handle error
                                } finally {
                                  if (mounted)
                                    setState(() => _isRefreshing = false);
                                }
                              },
                      ),

                      // Replace the sign out button's onPressed method with this:
                      IconButton(
                        icon: const Icon(Icons.logout, color: Colors.red),
                        onPressed: () async {
                          try {
                            await performGlobalSignOut(ref);
                            if (context.mounted) {
                              context.go('/login');
                            }
                          } catch (e) {
                            // ignore: use_build_context_synchronously
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error signing out: $e')),
                            );
                          }
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ),

            body: Column(
              children: [
                /// Search bar
                Container(
                  margin: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                      prefixIcon: const Icon(Icons.search, color: Colors.grey),
                      hintText: "Search employee...",
                      hintStyle: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[500],
                      ),
                      border: InputBorder.none,
                    ),
                  ),
                ),

                /// Employee List
                Expanded(
                  child: employeesAsync.when(
                    loading: () =>
                        const Center(child: CircularProgressIndicator()),
                    error: (error, stack) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.error, color: Colors.red, size: 48),
                          const SizedBox(height: 16),
                          Text('Error: $error'),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              ref.invalidate(employeesProvider);
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                    data: (employees) {
                      // Initialize filtered list if empty
                      if (_filteredEmployees.isEmpty &&
                          _searchController.text.isEmpty) {
                        _filteredEmployees = employees;
                      }

                      if (_filteredEmployees.isEmpty) {
                        return const Center(child: Text("No employees found"));
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          setState(() => _isRefreshing = true);
                          try {
                            await ref
                                .read(employeesProvider.notifier)
                                .fetchEmployees();
                          } catch (e) {
                            // Optionally handle error
                          } finally {
                            if (mounted) setState(() => _isRefreshing = false);
                          }
                        },

                        child: ListView.builder(
                          itemCount: _filteredEmployees.length,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemBuilder: (context, index) {
                            final employee = _filteredEmployees[index];
                            return InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () {
                                context.pushNamed(
                                  'employee',
                                  pathParameters: {'id': employee.id},
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  color: Colors.white,
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black.withValues(
                                        alpha: 0.05,
                                      ),
                                      blurRadius: 6,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                  border: Border.all(
                                    color: employee.status == 'online'
                                        ? onlineColor
                                        : employee.status == 'offline'
                                        ? offlineColor
                                        : pauseColor,
                                    width: 1.2,
                                  ),
                                ),
                                child: ListTile(
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  leading: employee.avatar.startsWith('assets/')
                                      ? CircleAvatar(
                                          backgroundImage: AssetImage(
                                            employee.avatar,
                                          ),
                                          radius: 26,
                                        )
                                      : CircleAvatar(
                                          backgroundImage: NetworkImage(
                                            employee.avatar,
                                          ),
                                          radius: 26,
                                          onBackgroundImageError: (e, s) {
                                            // Fallback for image loading errors
                                          },
                                          child: employee.avatar.isEmpty
                                              ? Text(
                                                  employee.name[0]
                                                      .toUpperCase(),
                                                )
                                              : null,
                                        ),
                                  title: Text(
                                    employee.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Last active: ${employee.lastActive}",
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      Text(
                                        employee.role,
                                        style: TextStyle(
                                          fontSize: 11,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: Icon(
                                    Icons.circle,
                                    color: employee.status == 'online'
                                        ? onlineColor
                                        : employee.status == 'offline'
                                        ? offlineColor
                                        : pauseColor,
                                    size: 12,
                                  ),
                                ),
                              ),
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
        ),
      ],
    );
  }
}
