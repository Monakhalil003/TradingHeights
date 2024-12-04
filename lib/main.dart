import 'package:clientapp/NotificationPage.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'AddUserPage.dart';
import 'package:provider/provider.dart';
import 'userViewModel.dart';
import 'db_helper.dart';
import 'package:permission_handler/permission_handler.dart';
import 'UserDetailsScreen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Check and request storage permissions
  checkPermissions();
  await DatabaseHelper().initializeNotifications();
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserViewModel(),
      child: const MyApp(),
    ),
  );
}

// Function to check and request storage permissions
Future<bool> _requestStoragePermission() async {
  var status = await Permission.storage.status;
  if (status.isDenied) {
    // Request the permission
    status = await Permission.storage.request();
  }
  return status.isGranted;
}

// Example usage
void checkPermissions() async {
  bool isGranted = await _requestStoragePermission();
  if (isGranted) {
    print("Storage permission granted!");
  } else {
    print("Storage permission denied.");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'My App',
      theme: ThemeData(
        primaryColor: const Color(0xFF273562),
        scaffoldBackgroundColor: const Color(0xFF273562),
      ),
      home: const SplashScreen(),
    );
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeBackPage()),
      );
    });

    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 254, 254, 254),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Flexible(
              child: Text(
                'Trading Heights!',
                style: GoogleFonts.montserrat(
                  fontSize: 28,
                  color: const Color(0xFFFFA600),
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      color: const Color(0xFFFFA600).withOpacity(0.5),
                      blurRadius: 2.0,
                      offset: const Offset(2.0, 2.0),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              height: 150,
              width: 150,
            ),
            const SizedBox(width: 20),
          ],
        ),
      ),
    );
  }
}

class WelcomeBackPage extends StatefulWidget {
  const WelcomeBackPage({super.key});

  @override
  State<WelcomeBackPage> createState() => _WelcomeBackPageState();
}

class _WelcomeBackPageState extends State<WelcomeBackPage> {
  final TextEditingController _searchController = TextEditingController();
  bool _isAscending = true;

  @override
  void initState() {
    super.initState();
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    userViewModel.loadUsers();
  }

  void _filterSearch(String query) {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    userViewModel.filterUsers(query);
  }

  void _sortData() {
    final userViewModel = Provider.of<UserViewModel>(context, listen: false);
    userViewModel.sortUsers(_isAscending);
    setState(() {
      _isAscending = !_isAscending;
    });
  }
void _viewDetails(int id) {
  final userViewModel = Provider.of<UserViewModel>(context, listen: false);
  final member = userViewModel.filteredUsers.firstWhere(
    (element) => element['id'] == id,
    orElse: () => {},
  );

  if (member.isNotEmpty) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UserDetailsScreen(member: member),
      ),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Member not found.')),
    );
  }
}
    
  

  void _refreshData() async {
    final allUsers = await DatabaseHelper().getUsers();
    setState(() {
      // Update the UI with the latest data
    });
  }

  void _deleteMember(int id) async {
    await DatabaseHelper().deleteUser (id);
    _refreshData();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Member Deleted')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = Provider.of<UserViewModel>(context);
    final memberCount = userViewModel.users.length;
    final String formattedDate = DateFormat('dd MMM, yyyy').format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF273562),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome Back!',
                    style: TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 241, 238, 94),
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    'Mr. Ibrahim',
                    style: TextStyle(
                      fontSize: 30,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'TRADING HEIGHTS',
                    style: GoogleFonts.montserrat(
                      fontSize: 30,
                      color: const Color(0xFFFFA600),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Stack(
                alignment: Alignment.topRight,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.notifications,
                      color: Colors.white,
                    ),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) =>  NotificationPage()),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 241, 238, 94),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.calendar_today,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Date',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            formattedDate,
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color.fromARGB(255, 241, 238, 94),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.people,
                          color: Colors.white,
                          size: 25,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Members',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.black,
                            ),
                          ),
                          Text(
                            '$memberCount members',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height:  20),
              TextField(
                controller: _searchController,
                onChanged: _filterSearch,
                decoration: InputDecoration(
                  hintText: 'Search Name or ID',
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 241, 238, 94),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(25),
                    borderSide: const BorderSide(
                      color: Color.fromARGB(255, 241, 238, 94),
                    ),
                  ),
                  suffixIcon: const Icon(Icons.search, color: Colors.white),
                ),
                style: const TextStyle(color: Colors.white),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      'Members Subscription Details',
                      style: GoogleFonts.montserrat(
                        fontSize: 20,
                        color: const Color(0xFFFFA600),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      _isAscending ? Icons.arrow_upward : Icons.arrow_downward,
                      color: Colors.white,
                    ),
                    onPressed: _sortData,
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Consumer<UserViewModel>(
                builder: (context, userViewModel, child) {
                  final users = userViewModel.filteredUsers;
                  return SingleChildScrollView(
                    child: DataTable(
                      columns: const [
                        DataColumn(label: Text('ID', style: TextStyle(color: Colors.white))),
                        DataColumn(label: Text('Name', style: TextStyle(color: Colors.white))),
                        DataColumn(label: Text('Time Left', style: TextStyle(color: Colors.white))),
                        DataColumn(label: Text('Actions', style: TextStyle(color: Colors.white))),
                      ],
                      rows: users.map((member) {
                        return DataRow(cells: [
                          DataCell(Text(member['id']?.toString() ?? 'N/A', style: const TextStyle(color: Colors.white))),
                          DataCell(Text(member['name'] ?? 'Unknown', style: const TextStyle(color: Colors.white))),
                          DataCell(Text(member['timeLeft'] ?? 'No Data', style: const TextStyle(color: Colors.white))),
                          DataCell(
                            PopupMenuButton<String>(
                              color: Colors.white,
                              icon: const Icon(Icons.more_vert, color: Colors.white),
                              onSelected: (String value) {
                                if (value == 'view') {
                                  _viewDetails(member['id']);
                                } else if (value == 'delete') {
                                  _deleteMember(member['id']);
                                }
                              },
                              itemBuilder: (BuildContext context) => [
                                const PopupMenuItem<String>(
                                  value: 'view',
                                  child: Text('View Details', style: TextStyle(color: Colors.black)),
                                ),
                                const PopupMenuItem<String>(
                                  value: 'delete',
                                  child: Text('Delete', style: TextStyle(color: Colors.black)),
                                ),
                              ],
                            ),
                          ),
                        ]);
                      }).toList(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddUserPage()),
          );
        },
        backgroundColor: const Color(0xFFFFA600),
        child: const Icon(Icons.add),
      ),
    );
  }
}