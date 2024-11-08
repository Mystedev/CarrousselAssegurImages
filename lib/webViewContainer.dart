// ignore_for_file: prefer_const_literals_to_create_immutables, prefer_const_constructors, avoid_print, library_private_types_in_public_api, file_names, use_function_type_syntax_for_parameters, use_build_context_synchronously

/*
  WebViewContainer:
    Crea un widget que muestra un WebView con la información del clima o del contenido
    Especificado de la API donde haremos las peticiones
*/
import 'package:flutter/material.dart';
import 'package:flutter_caroussel/main.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebViewContainer extends StatefulWidget {
  final String url;

  const WebViewContainer({super.key, required this.url});

  @override
  _WebViewContainerState createState() => _WebViewContainerState();
}

class _WebViewContainerState extends State<WebViewContainer> {
  bool _isLoading = false; // Variable para controlar el estado de carga
  late final WebViewController _controller;
  @override
  void initState() {
    super.initState();

    // Inicialización del WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted) // Permitir JavaScript
      ..loadRequest(Uri.parse(widget.url)); // Cargar la URL solicitada
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: const Color.fromARGB(214, 255, 255, 255),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 5,
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
                child: WebViewWidget(controller: _controller),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(248, 65, 157, 238),
                foregroundColor: const Color.fromARGB(255, 255, 255, 255),
                textStyle: const TextStyle(
                  fontSize: 35,
                  fontWeight: FontWeight.w600,
                ),
                minimumSize: const Size(220, 80),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(40),
                ),
                elevation: 5,
                shadowColor: const Color.fromARGB(255, 119, 164, 183)
                    .withOpacity(0.5),
              ),
              onPressed: _isLoading
                  ? null // Desactivar el botón cuando está cargando
                  : () async {
                      setState(() {
                        _isLoading = true; // Activar el estado de carga
                      });

                      // Simulación de una operación que tarda
                      await Future.delayed(Duration(seconds: 1));
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) =>
                              MainWidget(
                                username: 'admin', 
                                id: 'Taula09', 
                                urlApi: '',
                                endpoint: '',
                                bearer: '',
                                ),
                        ),
                      );
                      setState(() {
                        _isLoading = false; // Desactivar el estado de carga
                      });
                    },
              child: _isLoading
                  ? CircularProgressIndicator(
                      color: Colors.white, // Indicador de carga blanco
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text('Signar '),
                        SizedBox(width: 20),
                        Icon(Icons.draw_outlined, size: 25),
                      ],
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
// API PRODUCCIO REAL
//final String baseUrl = 'https://signaturit.assegur.com/AgentsSignature/api/tablets/';