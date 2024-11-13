// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, avoid_print, unused_element, use_key_in_widget_constructors, library_private_types_in_public_api, camel_case_types, use_super_parameters, unused_import, prefer_final_fields, prefer_const_declarations, no_leading_underscores_for_local_identifiers, override_on_non_overriding_member, deprecated_member_use

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/material.dart';
import 'package:flutter_caroussel/main.dart';
import 'package:flutter_caroussel/webViewContainer.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import 'package:drive_direct_download/drive_direct_download.dart';

import 'package:url_launcher/url_launcher_string.dart';

class MainWithLoginSuccess extends StatefulWidget {
  @override
  _MainWithLoginSuccessState createState() => _MainWithLoginSuccessState();
}

class _MainWithLoginSuccessState extends State<MainWithLoginSuccess> {
  late TextEditingController tempsEntreConsultesController;
  late TextEditingController urlImatgesController;
  late TextEditingController _idTablet;
  late TextEditingController _UrlApi;
  late TextEditingController _endPoint;
  late TextEditingController _bearer;
  String url = '';
  bool isLoading = false;
  final GlobalKey<MainWidgetState> _mainWidgetKey =
      GlobalKey<MainWidgetState>();
  bool isAutoFetching = false;
  Timer? _timer; // Timer para manejar las peticiones automáticas
  String downloadProgress = "";
  bool _isDownloading = false;
  final String urlUpdate =
      'https://drive.google.com/uc?export=download&id=1IA74y4QkyXs_DJ9hVzj1YBvxbXJ4IPgi';

  @override
  void initState() {
    super.initState();
    tempsEntreConsultesController = TextEditingController(text: '5');
    urlImatgesController =
        TextEditingController(text: 'https://assegur.com/img/tauletes/');
    _idTablet = TextEditingController(text: 'Taula20');
    _UrlApi = TextEditingController(text: 'https://platform.assegur.com/');
    var text = 'api/tablet/$_idTablet/url';
    _endPoint = TextEditingController(text: text);
    _bearer = TextEditingController(
        text:
            'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJEaWdpdGFsIFNpZ25hdHVyZSIsImlhdCI6MTY1MjE4OTAzNiwiZXhwIjoxOTA0NjQ5ODQ5LCJhdWQiOiJhc2FwcHAwMyIsInN1YiI6InRhYmxldHNAYXNzZWd1ci5jb20ifQ.J8YkIZJW2a_n9rSvS-SPOuLsZ6KpTipQUc0n4xU-2sI');
    _loadSavedData();
  }

  final _formKey = GlobalKey<FormState>();
  int? tempsEntreAnimacions;
  String? urlImatges;
  bool isFormValidated = false;

  String? _downloadLink;

  // Funcion para guardar los datos introducidos en la configuracion del carrusel
  void _onDesar() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        tempsEntreAnimacions = int.parse(tempsEntreConsultesController.text);
        urlImatges =
            urlImatgesController.text; // Obtén el valor de urlImatges aquí
        isFormValidated = true;
        isLoading = false;
      });

      // Guardar los datos en SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();

      await prefs.setString('idTablet', _idTablet.text);
      await prefs.setString('urlApi', _UrlApi.text);
      await prefs.setString('endPoint', _endPoint.text);
      await prefs.setString('bearer', _bearer.text);
      await prefs.setInt('tempsEntreAnimacions', tempsEntreAnimacions!);
      await prefs.setString('urlImatges', urlImatges!); // Guardar urlImatges

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Dades desades correctament!',
            style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          ),
          backgroundColor: Color.fromARGB(255, 138, 231, 206),
        ),
      );

      // Navegar a MainWidget, pasando la URL de las imágenes
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainWidget(
            username: 'admin',
            id: _idTablet.text,
            urlApi: _UrlApi.text,
            tempsEntreAnimacions: tempsEntreConsultesController.text.isNotEmpty
                ? int.parse(tempsEntreConsultesController.text)
                : 5,
            urlImatges: urlImatges!, // Pasando el valor de urlImatges
            bearer: _bearer.text,
            endpoint: _endPoint.text,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dades invalides'),
        ),
      );
    }
  }

  // Llamada al callback para iniciar/detener polling en MainWidget
  /*void toggleAutoFetch(bool value) {
    setState(() {
      isAutoFetching = value;
    });
    _mainWidgetKey.currentState?.widget.onTogglePolling(value);
  }*/

  Future<void> _fetchData() async {
    // Reemplazar {idTablet} en el endpoint con el valor de _idTablet.text
    final String apiUrl = '${_UrlApi.text}${_endPoint.text}';
    print('${_UrlApi.text}${_endPoint.text}}');
    // https://platformpre.assegur.com/api/tablets/tablet-test-01/url
    url =
        apiUrl; // Esta variable solo esta tomando el valor de la API cuando se ejecuta la función ❌
    try {
      // Hacer la petición GET a la API con el header de autorización Bearer
      final response = await http.get(
        Uri.parse(apiUrl),
        // El encabezado de la peticion es necesario para recibir la autorization 'Bearer token'
        headers: {
          'Content-Type': 'aplication/json',
          'Authorization': 'Bearer ${_bearer.text}',
        },
      );
      // Si el estado de la respuesta es '200' , esta es correcta y se ha recibido correctamente
      if (response.statusCode == 200) {
        print('Petició exitosa amb id ${_idTablet.text}');

        // Decodifica la respuesta JSON y extrae la URL
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final String url = responseBody['url'];

        // Mostrar la URL obtenida en el WebViewContainer para renderizar el contenido
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewContainer(
              url: apiUrl,
            ),
          ),
        );
      } else {
        print(apiUrl);
        print('Error HTTP rebut: ${response.statusCode}');
        print(response.body);

        // Navegar a ErrorFound con el mensaje de excepción y el estado de la respuesta
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ErrorFound(
                errorMessage: response.body,
                errorException: response.statusCode,
                errorUrl: apiUrl,
              ),
            ));
      }
    } catch (e) {
      print(apiUrl);
      print('Excepció: $e');

      // En caso de excepción, mostrar el mensaje de error en ErrorFound
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ErrorFound(
            errorMessage: e.toString(),
            errorUrl: '',
          ),
        ),
      );
    }

    // Retardo antes de intentar la petición de nuevo
    await Future.delayed(const Duration(seconds: 5));
  }

  // Método para controlar el inicio o detención de las peticiones

  void _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Borrar los datos guardados en SharedPreferences
    await prefs.remove('ideTablet');
    await prefs.remove('urlApi');
    await prefs.remove('endPoint');
    await prefs.remove('bearer');
    await prefs.remove('token');
    await prefs.remove('tempsEntreAnimacinons');
    await prefs.remove('urlImatges');

    // Método para controlar el inicio y añadir los elementos
    setState(() {
      _idTablet.text = prefs.getString('idTablet') ?? _idTablet.text;
      _UrlApi.text =
          prefs.getString('urlApi') ?? _UrlApi.text; // Cambia 'test' a 'urlApi'
      _endPoint.text =
          prefs.getString('endPoint') ?? 'api/tablets/${_idTablet.text}/url';
      _bearer.text = prefs.getString('bearer') ??
          'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJEaWdpdGFsIFNpZ25hdHVyZSIsImlhdCI6MTY1MjE4OTAzNiwiZXhwIjoxOTA0NjQ5ODQ5LCJhdWQiOiJhc2FwcHAwMyIsInN1YiI6InRhYmxldHNAYXNzZWd1ci5jb20ifQ.J8YkIZJW2a_n9rSvS-SPOuLsZ6KpTipQUc0n4xU-2sI';
      tempsEntreConsultesController.text =
          (prefs.getInt('tempsEntreAnimacions') ?? 5).toString();
      urlImatgesController.text =
          prefs.getString('urlImatges') ?? 'https://assegur.com/img/tauletes/';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: isFormValidated
            ? const MainWidget(
                username: 'admin',
                id: 'Taula09',
                urlApi: '',
                tempsEntreAnimacions: 5,
                urlImatges: 'https://www.assegur.com/img/tauletes/',
                bearer: 'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJEaWdpdGFsIFNpZ25hdHVyZSIsImlhdCI6MTY1MjE4OTAzNiwiZXhwIjoxOTA0NjQ5ODQ5LCJhdWQiOiJhc2FwcHAwMyIsInN1YiI6InRhYmxldHNAYXNzZWd1ci5jb20ifQ.J8YkIZJW2a_n9rSvS-SPOuLsZ6KpTipQUc0n4xU-2sI',
                endpoint: '',
              )
            : _buildForm(),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Center(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 16),
                // Inputs para obtener los datos de configuración
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _idTablet,
                    decoration: const InputDecoration(
                      labelText: 'ID Tablet',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _UrlApi,
                    decoration: const InputDecoration(
                      labelText: 'URl Api',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _endPoint,
                    decoration: const InputDecoration(
                      labelText: 'Endpoint',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: _bearer,
                    decoration: const InputDecoration(
                      labelText: 'Bearer',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.text,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: tempsEntreConsultesController,
                    decoration: const InputDecoration(
                      labelText: 'Temps entre animacions (ms)',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Aquest camp és obligatori';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Introdueix un número vàlid';
                      }
                      return null;
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: TextFormField(
                    controller: urlImatgesController,
                    decoration: const InputDecoration(
                      labelText: 'URL de les imatges',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Aquest camp és obligatori';
                      }
                      if (!Uri.tryParse(value)!.isAbsolute) {
                        return 'Introdueix una URL vàlida';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 32),
                // Botón para guardar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(Colors.black),
                        foregroundColor: WidgetStatePropertyAll(Colors.white)),
                    onPressed: isLoading ? null : _onDesar,
                    child: isLoading
                        ? const CircularProgressIndicator()
                        : const Text('Desar'),
                  ),
                ),
                const SizedBox(height: 16),
                // Botón Actualitzar
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                            Color.fromARGB(255, 134, 231, 171)),
                        foregroundColor: WidgetStatePropertyAll(Colors.black)),
                    onPressed: () async {
                      try {
                        // Usamos launchUrlString en lugar de launchUrl para obtener el enlace directo
                        bool launched = await launchUrlString(
                          urlUpdate,
                          mode: LaunchMode.externalApplication,
                        );
                        if (!launched) {
                          print('No se pudo abrir la URL de descarga');
                        }
                      } catch (e) {
                        print('Error al intentar lanzar la URL: $e');
                      }
                    },
                    child: const Text('Actualitzar'),
                  ),
                ),
                const SizedBox(height: 16),
                // Botón para hacer petición a la Api
                SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                        style: const ButtonStyle(
                            backgroundColor: WidgetStatePropertyAll(
                                Color.fromARGB(255, 137, 199, 241)),
                            foregroundColor:
                                WidgetStatePropertyAll(Colors.black)),
                        onPressed: _fetchData,
                        child: const Text('Fer petició'))),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class ErrorFound extends StatelessWidget {
  final String errorMessage;

  final int? errorException; // Parametres opcionals
  final String errorUrl; // Parametres opcionals

  const ErrorFound(
      {Key? key,
      required this.errorMessage,
      this.errorException,
      required this.errorUrl})
      : super(key: key);

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
            ''' Error en la petició -> $errorMessage  
                Error -> $errorException
                A la url -> $errorUrl
              ''',
            style: const TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
