import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:task_manager_app/Screens/EditScreen/EditScreen.dart';

class TaskDetailsScreen extends StatefulWidget {
  final int taskId;

  const TaskDetailsScreen({super.key, required this.taskId});

  @override
  _TaskDetailsScreenState createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  Map<String, dynamic>? task;
  int? taskId;
  bool isLoading = true;
  bool hasError = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal,
        title: const Text(
          'Task Details',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade300, Colors.teal.shade600],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: isLoading
            ? Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation(Colors.white),
                ),
              )
            : hasError
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.error_outline, size: 50, color: Colors.red),
                        const SizedBox(height: 10),
                        const Text(
                          'Failed to load task details.',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton.icon(
                          onPressed: () => _fetchTaskDetails(taskId!),
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal.shade700,
                          ),
                        ),
                      ],
                    ),
                  )
                : task == null
                    ? const Center(
                        child: Text(
                          'Task details not available',
                          style: TextStyle(fontSize: 18, color: Colors.white),
                        ),
                      )
                    : Center(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              _buildDetailCard(
                                title: task!['title'] ?? 'No Title',
                                status: task!['status'],
                                priority: task!['priority'],
                                deadline: task!['deadline'],
                                description: task!['description'] ?? 'No description available',
                              ),
                              const SizedBox(height: 30),
                              ElevatedButton(
                                onPressed: () {
                                  if (task != null && taskId != null) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditTaskScreen(
                                          taskId: taskId!,
                                          title: task!['title'] ?? 'No Title',
                                          status: task!['status'] ?? 'Unknown',
                                          priority: task!['priority'] ?? 'Low',
                                          deadline: task!['deadline'] ?? 'No Deadline',
                                          description: task!['description'] ?? 'No description available',
                                        ),
                                      ),
                                    ).then((_) {
                                      _fetchTaskDetails(taskId!);
                                    });
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(content: Text('Task ID is missing or invalid')),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.teal.shade600,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 5,
                                ),
                                child: const Text(
                                  'Edit Task',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black38,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 15),
                              ElevatedButton(
                                onPressed: () {
                                  _deleteTask(taskId!);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.red.shade600,
                                  padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  elevation: 5,
                                ),
                                child: const Text(
                                  'Delete Task',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black38,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    taskId = widget.taskId;
    if (taskId == null || taskId! <= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid Task ID')),
        );
        Navigator.of(context).pop();
      });
    } else {
      _fetchTaskDetails(taskId!);
    }
  }

  Widget _buildDetailCard({
    required String title,
    required String status,
    required String priority,
    required String deadline,
    required String description,
  }) {
    return Card(
      elevation: 8,
      shadowColor: Colors.teal,
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDetailRow(Icons.title, 'Title', title, Colors.black),
            const SizedBox(height: 10),
            _buildDetailRow(Icons.assignment_turned_in, 'Status', status, _getStatusColor(status)),
            const SizedBox(height: 10),
            _buildDetailRow(Icons.priority_high, 'Priority', priority, Colors.black),
            const SizedBox(height: 10),
            _buildDetailRow(Icons.calendar_today, 'Deadline', deadline, Colors.black),
            const SizedBox(height: 20),
            Text(
              'Description:',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.teal.shade100,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              description,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, Color valueColor) {
    return Row(
      children: [
        Icon(icon, color: Colors.teal.shade800, size: 24),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              fontSize: 18,
              color: valueColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _deleteTask(int taskId) async {
    String url = 'https://localhost:7082/api/tasks/DeleteTask?id=$taskId';

    setState(() {
      isLoading = true;
    });

    try {
      final response = await http.delete(Uri.parse(url));

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Task deleted successfully')),
        );
        Navigator.of(context).pop(true);
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete task')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _fetchTaskDetails(int taskId) async {
    String url = 'https://localhost:7082/api/tasks/GetTaskbyID?id=$taskId';

    setState(() {
      isLoading = true;
      hasError = false;
    });

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        setState(() {
          task = json.decode(response.body);
          if (task != null && task!['id'] != null) {
            task!['id'] = task!['id'] is int
                ? task!['id']
                : int.tryParse(task!['id'].toString()) ?? 0;
          }
          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
          hasError = true;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to load task details.')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        hasError = true;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

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
}
