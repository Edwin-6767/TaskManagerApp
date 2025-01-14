import 'package:flutter/material.dart';
import 'package:task_manager_app/Screens/Addtaskscreen/Addtask.dart';
import 'package:task_manager_app/Screens/DashBoardScreen/dashboard.dart';
import 'package:task_manager_app/Screens/LoginScreen/login.dart';
import 'package:task_manager_app/Screens/Registration/Registration.dart';
import 'package:task_manager_app/Screens/TaskDetailsScreen/TaskDetails.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a purple toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: LoginScreen(),
      routes: {
        '/LoginScreen': (context) => LoginScreen(), 
        '/RegistrationScreen': (context) => RegisterScreen(),
        '/DashboardScreen':(context)=> DashboardScreen(),
       '/taskDetails': (context) {
      final taskId = ModalRoute.of(context)!.settings.arguments as int;
      return TaskDetailsScreen(taskId: taskId);},
        '/AddTaskScreen':(context)=> AddTaskScreen(),


      },
    );
  }
}


