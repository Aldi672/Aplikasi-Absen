import 'package:flutter/material.dart';

class GetLoginScreen extends StatelessWidget {
  const GetLoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: Center(
              child: SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.all(20),

                  child: Column(
                    mainAxisSize: MainAxisSize.min,

                    children: [
                      // Logo
                      Image.asset("asset/images/foto/logo.png", height: 80),
                      SizedBox(height: 10),
                      Row(
                        children: [
                          SizedBox(width: 40),
                          Image.asset("asset/images/foto/daun.png", height: 80),
                          Text(
                            "Welcome back!",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 20),

                      // Username
                      TextField(
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.person_outline),
                          hintText: "Username",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),
                      SizedBox(height: 15),

                      // Password
                      TextField(
                        obscureText: true,
                        decoration: InputDecoration(
                          prefixIcon: Icon(Icons.lock_outline),
                          hintText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                      ),

                      // Forgot password
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {},
                          child: Text(
                            "Forgot Password?",
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            backgroundColor: Color(0xFF2C8DE0),
                            foregroundColor: Colors.white,
                            elevation: 5,
                          ),
                          onPressed: () {
                            // Aksi login
                          },
                          child: Text(
                            "LOG IN",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(height: 20),

                      Text(
                        "Or sign up using",
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),

                      SizedBox(height: 15),

                      // Social login
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // IconButton(
                          //   icon: Image.network(
                          //     "https://cdn-icons-png.flaticon.com/512/124/124010.png",
                          //   ),
                          //   iconSize: 40,
                          //   onPressed: () {},
                          // ),
                          SizedBox(width: 15),
                          // IconButton(
                          //   icon: Image.network(
                          //     "https://cdn-icons-png.flaticon.com/512/300/300221.png",
                          //   ),
                          //   iconSize: 40,
                          //   onPressed: () {},
                          // ),
                          SizedBox(width: 15),
                          // IconButton(
                          //   icon: Image.network(
                          //     "https://cdn-icons-png.flaticon.com/512/179/179309.png",
                          //   ),
                          //   iconSize: 40,
                          //   onPressed: () {},
                          // ),
                        ],
                      ),

                      SizedBox(height: 20),

                      // Signup
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text("Don't have an account? "),
                          Text(
                            "Sign Up",
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF2C8DE0),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
