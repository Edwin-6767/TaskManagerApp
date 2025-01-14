import 'dart:convert';  // To parse the response

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal, 
        title: Text('Login', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.teal.shade200, Colors.teal.shade600],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome Back!',
                    style: TextStyle(fontSize: 30, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                  SizedBox(height: 30),
                  // Username TextField
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  // Password TextField
                  TextField(
                    controller: passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Password',
                      labelStyle: TextStyle(color: Colors.black),
                      filled: true,
                      fillColor: Colors.white.withOpacity(0.8),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  SizedBox(height: 30),
                  // Login Button
                  ElevatedButton(
                    onPressed: () => _loginUser(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal.shade600,
                      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    child: Text(
                      'Login',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black38),
                    ),
                  ),
                  SizedBox(height: 15),
                  // Register TextButton
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.of(context).pushNamed('/RegistrationScreen');
                      },
                      child: Text(
                        'Don’t have an account? Register',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

Future<void> _loginUser(BuildContext context) async {
  String username = usernameController.text.trim();
  String password = passwordController.text.trim();

  // Ensure fields are filled
  if (username.isEmpty || password.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Please fill in both fields')),
    );
    return;
  }

  // API URL for login
  String url = 'https://localhost:7082/api/auth/login?username=$username&password=$password';

  try {
    // Send POST request
    final response = await http.post(
      Uri.parse(url),
      headers: {'Content-Type': 'application/json'},
    );

    // Print the raw response body for debugging
    print('Response body: ${response.body}');

    // Only proceed if the response body is not empty and contains expected fields
    if (response.body.isNotEmpty) {
      try {
        Map<String, dynamic> responseData = json.decode(response.body);

        // Log the parsed response to check
        print('Parsed response data: $responseData');

        // Check if the response contains the required fields
        String token = responseData['token'] ?? '';
        int userId = responseData['userId'] ?? 0;
        String username = responseData['username'] ?? '';

        if (token.isEmpty || userId == 0 || username.isEmpty) {
          // Log the actual response data for debugging
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Invalid response data: $response.body')),
          );
          return;
        }

        // Successful login, save data to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', token); // Save JWT token
        await prefs.setInt('user_id', userId); // Save UserId
        await prefs.setString('username', username); // Save Username

        // Show login success
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Login successful!')),
        );

        // Navigate to Dashboard
        Navigator.pushReplacementNamed(context, '/DashboardScreen');
      } catch (e) {
        // Handle JSON parsing errors
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error parsing response: $e')),
        );
        print('Error parsing response: $e');
      }
    } else {
      // If response body is empty, show an error
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Empty response from the server')),
      );
    }
  } catch (e) {
    // Handle network errors
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
    print('Error: $e');
  }
}
}