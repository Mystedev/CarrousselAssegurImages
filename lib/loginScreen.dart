// Pantalla de Login
// ignore_for_file: use_build_context_synchronously, library_private_types_in_public_api, file_names, unused_element, avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_caroussel/configuracio.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screenLoginSuccess.dart';

class LoginScreen extends StatefulWidget {
  final String id;
  final String bearer;
  final String endpoint;

  const LoginScreen(
      {super.key,
      required this.id,
      required this.bearer,
      required this.endpoint});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late TextEditingController _emailController = TextEditingController();
  late TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  final Configuracio configuracio = const Configuracio(
    id: 'Taula09',
    user: 'admin',
    password: '1234',
    temps: '5',
    urlImatges: 'https://assegur.com/img/tauletes',
    isValid: true,
    agentsSignatureApiUrl: '',
    agentsSignatureEndPoint: '',
    agentsSignaturebearer: '',
    agentsSignatureIdTablet: '',
    loggedInWithMicrosoftAccount: false,
  );
  @override
  void initState() {
    super.initState();
    _checkLoginStatus();
    _emailController = TextEditingController(text: configuracio.user);
    _passwordController = TextEditingController(text: configuracio.password);
  }

  // Verificar si ya está logueado
  void _checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (isLoggedIn) {
      // Si ya está logueado, redirigir automáticamente
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) => MainWithLoginSuccess(),
        ),
      );
    }
  }

  // Guardar estado de login exitoso
  /*void _loginSuccessful() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('isLoggedIn', true); // Guardar que el usuario está logueado
  }*/

  void _handleLogin() async {
    setState(() {
      _isLoading = true;
    });

    final String user = _emailController.text;
    final String password = _passwordController.text;

    await Future.delayed(
        const Duration(seconds: 2)); // Simulación de validación de login

    if (configuracio.validateCredentials(user, password)) {
      //_loginSuccessful(); // Guardar la sesion
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) =>
              MainWithLoginSuccess(), // Redirigir a la configuracion
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dades valides!'),
          backgroundColor: Color.fromARGB(255, 2, 180, 133),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dades incorrectes'),
          backgroundColor: Color.fromARGB(255, 186, 36, 54),
          showCloseIcon: true,
          closeIconColor: Color.fromARGB(255, 0, 0, 0),
        ),
      );
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login screen"),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'User',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  border: OutlineInputBorder(),
                  suffixIcon: Icon(Icons.password),
                ),
                obscureText: true,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleLogin,
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.black,
                ),
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Login'),
              ),
            ]),
      ),
    );
  }
}
