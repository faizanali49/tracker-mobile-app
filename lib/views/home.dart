import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:trackermobile/models/api.dart';
import 'package:trackermobile/themes/colors.dart';
import 'package:trackermobile/views/company_authentication/provider/login_auth.dart';

class HomeView extends ConsumerStatefulWidget {
  const HomeView({super.key});

  @override
  ConsumerState<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends ConsumerState<HomeView> {
  static String? usernrole;
  Uint8List? avatarBytes;
  String? avatarUrl; // Add this field to your state

  Future<void> _loadUserData() async {
    try {
      final uid = FirebaseAuth.instance.currentUser!.uid;
      final doc = await FirebaseFirestore.instance
          .collection('companies')
          .doc(uid)
          .get();

      if (doc.exists) {
        setState(() {
          usernrole = doc['username'];
          ref.read(usernameProvider.notifier).state = usernrole;

          // The avatar is now a URL, not Base64
          avatarUrl = doc['avatarUrl']; // Add this field to your state
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
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
                    backgroundImage: avatarUrl != null && avatarUrl!.isNotEmpty
                        ? NetworkImage(avatarUrl!) // Use NetworkImage for URLs
                        : const AssetImage('assets/images/boss.jpg')
                              as ImageProvider,
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "${usernrole ?? 'Company'}",
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Text(
                        "Admin",
                        style: TextStyle(fontSize: 13, color: Colors.black54),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  onPressed: () {
                    context.push('/add-employee', extra: usernrole);
                  },
                  icon: const Icon(Icons.add, color: Colors.blueAccent),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.logout, color: Colors.red),
                onPressed: () async {
                  try {
                    await FirebaseAuth.instance.signOut();
                    if (context.mounted) {
                      context.go(
                        '/login',
                      ); // navigate back to login after sign out
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error signing out: $e')),
                    );
                  }
                },
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
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: TextField(
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 14,
                  ),
                  prefixIcon: const Icon(Icons.search, color: Colors.grey),
                  hintText: "Search employee...",
                  hintStyle: TextStyle(fontSize: 14, color: Colors.grey[500]),
                  border: InputBorder.none,
                ),
              ),
            ),

            /// Employee List
            Expanded(
              child: ListView.builder(
                itemCount: employees.length,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemBuilder: (context, index) {
                  final employee = employees[index];
                  return InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      context.pushNamed(
                        'employee',
                        pathParameters: {'id': employee.name},
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
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
                        leading: CircleAvatar(
                          backgroundImage: AssetImage(employee.avatar),
                          radius: 26,
                        ),
                        title: Text(
                          employee.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Colors.black87,
                          ),
                        ),
                        subtitle: Text(
                          "Last active: ${employee.lastActive}",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
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
            ),
          ],
        ),
      ),
    );
  }
}
