import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:task_manager_app/Screens/Addtaskscreen/Addtask.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Map<String, dynamic>> tasks = [];
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.teal, Colors.teal],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ListView.builder(
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    Color statusColor =
                        _getStatusColor(tasks[index]['status']!);

                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                      elevation: 5,
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(16.0),
                        title: Text(
                          tasks[index]['title']!,
                          style: const TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        subtitle: Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8.0, vertical: 4.0),
                              decoration: BoxDecoration(
                                color: statusColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                tasks[index]['status']!,
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                        onTap: () async {
                          // Navigate to TaskDetailsScreen and await the result
                       Navigator.pushNamed(
                            context,
                            '/taskDetails',
                            arguments: tasks[index]['id'],
                          ).then((_) {
    // **Re-fetch tasks after returning from TaskDetailsScreen**
                            _loadUserIdAndFetchTasks();
  });
                        },
                      ),
                    );
                  },
                ),
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to AddTaskScreen and await the result
          bool? taskAdded = await Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => AddTaskScreen()));

          if (taskAdded != null && taskAdded) {
            // If a new task was added, refresh the task list
            _loadUserIdAndFetchTasks();
          }
        },
        backgroundColor: Colors.teal.shade600,
        child: const Icon(Icons.add, size: 30),
      ),
    );
  }

  Future<void> fetchTasks(int userId) async {
    String url = 'https://localhost:7082/api/tasks/GetTasks?userId=$userId';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        try {
          List<dynamic> data = json.decode(response.body);

          setState(() {
            tasks = data.map((task) {
              return {
                'id': task['taskId'] ?? 0,
                'title': task['title']?.toString() ?? '',
                'status': task['status']?.toString() ?? '',
              };
            }).toList();
            isLoading = false;
          });
        } catch (e) {
          setState(() {
            isLoading = false;
          });
          print('Error parsing response: $e');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error parsing response: $e')),
          );
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print('Failed to load tasks, Status Code: ${response.statusCode}');
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load tasks')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error during API call: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    _loadUserIdAndFetchTasks();
  }

  // Helper function to determine status color
  Color _getStatusColor(String status) {
    switch (status) {
      case 'To Do':
        return Colors.red;
      case 'In Progress':
        return Colors.yellow;
      case 'Pending':
        return Colors.orange;
      case 'Completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> _loadUserIdAndFetchTasks() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    int userId = prefs.getInt('user_id') ?? 0;

    if (userId == 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User ID not found')),
      );
      return;
    }

    await fetchTasks(userId);
  }
}
