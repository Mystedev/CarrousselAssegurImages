// ignore_for_file: file_names

import 'package:flutter/material.dart';

class ErrorFound extends StatelessWidget {
  final String errorMessage;

  final int? errorException; // Parametres opcionals
  final String errorUrl; // Parametres opcionals


  const ErrorFound(
      {super.key,
      required this.errorMessage,
      this.errorException,
      required this.errorUrl,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error en la petició'),
      ),
      body: Center(
        child: Container(
          padding: const EdgeInsets.all(16.0),
          child: Text(
              '''  
                Error exception-> $errorException
                Url -> $errorUrl
              ''',
            style: const TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
