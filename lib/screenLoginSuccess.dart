// ignore_for_file: use_build_context_synchronously, non_constant_identifier_names, avoid_print, unused_element, use_key_in_widget_constructors, library_private_types_in_public_api, camel_case_types, use_super_parameters, unused_import, prefer_final_fields, prefer_const_declarations, no_leading_underscores_for_local_identifiers, override_on_non_overriding_member, deprecated_member_use

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
import 'package:url_launcher/url_launcher.dart';
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
  bool isLoading = false;
  String downloadProgress = "";
  bool _isDownloading = false;
  final String urlUpdate = 'https://drive.google.com/uc?export=download&id=1ti8hGWg7immsGLEVbaZBXyPh7L5TDPkE';

  @override
  void initState() {
    super.initState();
    tempsEntreConsultesController = TextEditingController(text: '5');
    urlImatgesController =
        TextEditingController(text: 'https://assegur.com/img/tauletes');
    _idTablet = TextEditingController(text: 'Taula09');
    _UrlApi = TextEditingController(
        text: 'https://signaturit.assegur.com/AgentsSignature/');
    _endPoint = TextEditingController(text: 'api/tablets/{idTablet}/url');
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

  Future<void> _fetchData() async {
    // Reemplazar {idTablet} en el endpoint con el valor de _idTablet.text
    final String apiUrl =
        'https://platformpre.assegur.com/api/tablets/${_idTablet.text}/url';

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

        // Mostrar la URL obtenida en el WebViewContainer paraa renderizar el contenido
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const WebViewContainer(
              url: 'https://platformpre.assegur.com/api/tablets/_idTablet/url',
            ),
          ),
        );
      } else {
        print('Error HTTP rebut: ${response.statusCode}');
        print(response.body);

        // Navegar a ErrorFound con el mensaje de excepción y el estado de la respuesta
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ErrorFound(
                errorMessage: response.body,
                errorException: response.statusCode),
          ),
        );
      }
    } catch (e) {
      print('Excepció: $e');

      // En caso de excepción, mostrar el mensaje de error en ErrorFound
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ErrorFound(
            errorMessage: e.toString(),
          ),
        ),
      );
    }

    // Retardo antes de intentar la petición de nuevo
    await Future.delayed(const Duration(seconds: 5));
  }

  // Funcion para guardar los datos introducidos en la configuracion del carrusel
  void _onDesar() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isLoading = true;
      });

      await Future.delayed(const Duration(seconds: 2));

      setState(() {
        tempsEntreAnimacions = int.parse(tempsEntreConsultesController.text);
        urlImatges = urlImatgesController.text;
        isFormValidated = true;
        isLoading = false;
      });

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('idTablet', _idTablet.text);
      await prefs.setString('urlApi', _UrlApi.text);
      await prefs.setString('endPoint', _endPoint.text);
      await prefs.setString('bearer', _bearer.text);
      await prefs.setInt('tempsEntreAnimacions', tempsEntreAnimacions!);
      await prefs.setString('urlImatges', urlImatges!);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Dades desades correctament!',
            style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
          ),
          backgroundColor: Color.fromARGB(255, 138, 231, 206),
        ),
      );

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainWidget(
            username: 'admin',
            id: _idTablet.text,
            urlApi: _UrlApi.text,
            tempsEntreAnimacions: tempsEntreAnimacions!,
            urlImatges: urlImatges!,
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

  // Funcion para descargar e instalar el APK de GoogleDrive
  /*Future<void> _downloadAndInstallApk() async {
    final String apkUrl =
        'https://drive.google.com/file/d/1ti8hGWg7immsGLEVbaZBXyPh7L5TDPkE/view'; // Ensure this is a direct download link

    try {
      // Permiso para guardar el apk en la ruta
      final status = await Permission.storage.request();
      if (!status.isGranted) {
        print("Storage permission denied");
        return;
      }

      setState(() {
        _isDownloading = true;
        downloadProgress = "0%";
      });

      // Usar el directorio predeterminado de descargas 'Download'
      Directory? downloadsDirectory;
      if (Platform.isAndroid) {
        downloadsDirectory = await getExternalStorageDirectory();
      }
      // No se pudo obtener el directorio
      if (downloadsDirectory == null) {
        throw Exception("Failed to get the Downloads directory.");
      }

      final String filePath = '${downloadsDirectory.path}/update.apk';

      // Metodo asincrono para obtener el APK y descargarlo
      final response = await http.Client().send(
        http.Request('GET', Uri.parse(apkUrl)),
      );

      if (response.statusCode == 200) {
        final file = File(filePath);
        final fileSink = file.openWrite();
        print('Filesink : $fileSink');
        int downloaded = 0;
        final contentLength = response.contentLength ?? 0;

        response.stream.listen(
          (chunk) {
            fileSink.add(chunk);
            downloaded += chunk.length;
            setState(() {
              downloadProgress =
                  "${((downloaded / contentLength) * 100).toStringAsFixed(0)}%";
              print('Lentgh : $contentLength');
            });
          },
          onDone: () async {
            await fileSink.close();

            // Verify the file size
            if (await file.length() == 0) {
              print("Error: The file is empty.");
              setState(() {
                _isDownloading = false;
              });
              return;
            }

            setState(() {
              _isDownloading = false;
            });

            // Open the APK to initiate installation
            final result = await OpenFile.open(filePath);
            if (result.type == ResultType.error) {
              print('Error opening file: ${result.message}');
            }
          },
          onError: (e) {
            setState(() {
              _isDownloading = false;
            });
            print("Error downloading file: $e");
          },
          cancelOnError: true,
        );
      } else {
        print("Error downloading: ${response.statusCode}");
        setState(() {
          _isDownloading = false;
        });
      }
    } catch (e) {
      print("Exception: $e");
      setState(() {
        _isDownloading = false;
      });
    }
  }*/

  void _loadSavedData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _idTablet.text = prefs.getString('idTablet') ?? 'Taula09';
      _UrlApi.text =
          prefs.getString('urlApi') ?? 'https://platform.assegur.com/';
      _endPoint.text =
          prefs.getString('endPoint') ?? 'api/tablets/${_idTablet.text}/url';
      _bearer.text = prefs.getString('bearer') ??
          'eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJEaWdpdGFsIFNpZ25hdHVyZSIsImlhdCI6MTY1MjE4OTAzNiwiZXhwIjoxOTA0NjQ5ODQ5LCJhdWQiOiJhc2FwcHAwMyIsInN1YiI6InRhYmxldHNAYXNzZWd1ci5jb20ifQ.J8YkIZJW2a_n9rSvS-SPOuLsZ6KpTipQUc0n4xU-2sI';
      tempsEntreConsultesController.text =
          (prefs.getInt('tempsEntreAnimacions') ?? 5).toString();
      urlImatgesController.text =
          prefs.getString('urlImatges') ?? 'https://assegur.com/img/tauletes';
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
                bearer: '',
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
                        // Usamos launchUrlString en lugar de launchUrl
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
                // Boton hacer peticion
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: const ButtonStyle(
                        backgroundColor: WidgetStatePropertyAll(
                            Color.fromARGB(255, 113, 192, 229)),
                        foregroundColor: WidgetStatePropertyAll(Colors.black)),
                    onPressed: _fetchData,
                    child: const Text('Fer petició'),
                  ),
                )
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

  const ErrorFound({Key? key, required this.errorMessage, this.errorException})
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
            '''Error en la petició -> $errorMessage  
              Error -> $errorException
            ''',
            style: const TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
