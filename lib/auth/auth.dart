import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:products/auth/service.dart';

import '../displaydata.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final AuthService _authService = AuthService();

  bool _isLogin = true; // Toggle between login and registration

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isLogin ? 'Login' : 'Register')),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [

            Text("Welcome back!",
              textAlign: TextAlign.start,
              style: GoogleFonts.beVietnamPro(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.black
              ),
            ),
            SizedBox(height: 30,),
            if (!_isLogin)

            SizedBox(
              height: 50,
              width: 400,
              child: TextField(
                controller: _usernameController,
                style:GoogleFonts.beVietnamPro(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.person, color: Colors.black54,),
                  hintText: "Username",
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            SizedBox(
              height: 50,
              width: 400,
              child: TextField(
                controller: _emailController,
                style:GoogleFonts.beVietnamPro(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.email_outlined, color: Colors.black54,),
                  hintText: "Email",
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 50,
              width: 400,
              child: TextField(
                obscureText: true,
                controller: _passwordController,
                style:GoogleFonts.beVietnamPro(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black
                ),
                decoration: InputDecoration(
                  prefixIcon: Icon(Icons.lock, color: Colors.black54,),
                  hintText: "Password",
                  filled: true,
                  fillColor: Colors.black.withOpacity(0.2),
                  border: OutlineInputBorder(
                    borderSide: BorderSide.none,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ),

            SizedBox(height: 20),

            SizedBox(
              height: 50,
              width: 400,
              child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent
                  ),
                  onPressed: () async {

                    if (_isLogin) {
                      // Login
                      var user = await _authService.login(
                        _emailController.text,
                        _passwordController.text,
                      );
                      if (user != null) {
                        Navigator.push(context, MaterialPageRoute(builder: (context) => ProductsList()));
                        print("Login successful");
                      } else {
                        print("Login failed");
                      }
                    } else {
                      // Register
                      var user = await _authService.register(
                        _usernameController.text,
                        _emailController.text,
                        _passwordController.text,

                      );
                      if (user != null) {
                        _usernameController.clear();
                        _emailController.clear();
                        _passwordController.clear();

                        print("Registration successful");
                      } else {
                        print("Registration failed");
                      }
                    }
                  },
                  child: Text(_isLogin ? 'Login' : 'Register',
                    style: GoogleFonts.beVietnamPro(fontSize: 18,
                        fontWeight: FontWeight.w600, color: Colors.white),)),
            ),

            SizedBox(height: 20,),
            TextButton(
              onPressed: () {
                setState(() {
                  _isLogin = !_isLogin;
                });
              },
              child: Text(_isLogin ? 'Create an account' : 'Already have an account? Login',
                  style: GoogleFonts.beVietnamPro(fontSize: 16,
                  fontWeight: FontWeight.w600, color: Colors.black54)),
            ),
          ],
        ),
      ),
    );
  }
}
