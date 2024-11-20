// ignore_for_file: avoid_print, prefer_const_literals_to_create_immutables, prefer_const_constructors, library_private_types_in_public_api, unused_element, empty_constructor_bodies, deprecated_member_use, unused_import, prefer_const_declarations, depend_on_referenced_packages, unused_field, use_key_in_widget_constructors, prefer_final_fields, non_constant_identifier_names, sort_child_properties_last, use_build_context_synchronously, unnecessary_brace_in_string_interps
import 'package:flutter/material.dart';
import 'package:flutter_caroussel/configuracio.dart';
import 'package:flutter_caroussel/controller/fetchController.dart';
import 'package:flutter_caroussel/errorFounWebView.dart';
import 'package:flutter_caroussel/imageCarousel.dart';
import 'package:flutter_caroussel/url_model.dart';
import 'package:flutter_caroussel/webViewContainer.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'loginScreen.dart';
import 'screenLoginSuccess.dart';

void main() {
  // Configuracion general del widget principal
  const configuracio = Configuracio(
    user: 'admin',
    password: '1234',
    temps: '5',
    urlImatges: 'https://www.assegur.com/img/tauletes/',
    isValid: true,
    agentsSignatureEndPoint: '',
    agentsSignaturebearer: '',
    agentsSignatureIdTablet: 'Taula09',
    loggedInWithMicrosoftAccount: false,
  );
  runApp(
    // Rutas de la aplicacion para moverse a distintos widgets
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UrlModel()),
        ChangeNotifierProvider(
            create: (context) => FetchController()), // Agrega FetchController
      ],
      child: MaterialApp(
        home: MainWidget(
          username: configuracio.user,
          id: configuracio.id,
          tempsEntreAnimacions: int.tryParse(configuracio.temps),
          urlImatges: configuracio.urlImatges,
          urlApi: '',
          endpoint: configuracio.agentsSignatureEndPoint,
          bearer: configuracio.agentsSignatureEndPoint,
        ),
        debugShowCheckedModeBanner: false,
        routes: {
          // Rutas de la App , pantalla Login y Pantalla Carrusel
          '/LoginScreen': (context) => LoginScreen(
                id: configuracio.agentsSignatureIdTablet,
                bearer: configuracio.agentsSignaturebearer,
                endpoint: configuracio.agentsSignatureEndPoint,
              ),
          '/MainWidget': (context) => MainWidget(
                username: configuracio.user,
                id: configuracio.id,
                tempsEntreAnimacions: int.tryParse(configuracio.temps),
                urlImatges: configuracio.urlImatges,
                urlApi: '',
                endpoint: configuracio.agentsSignatureEndPoint,
                bearer: configuracio.agentsSignaturebearer,
              ),
        },
      ),
    ),
  );
}

class MainWidget extends StatefulWidget {
  final String username;
  final int? tempsEntreAnimacions;
  final String urlImatges;
  final String id;
  final String bearer;
  final String endpoint;
  final String urlApi;

  const MainWidget({
    super.key,
    required this.username,
    required this.id,
    this.tempsEntreAnimacions,
    required this.urlImatges,
    required this.bearer,
    required this.endpoint,
    required this.urlApi,
  });

  @override
  MainWidgetState createState() => MainWidgetState();
}

class MainWidgetState extends State<MainWidget> {
  Timer? _timer;
  String? currentUrl;
  String? apiUrl;
  String? bearerToken;
  String? idTablet;
  String? url;
  String? endpoint;
  bool showWebView = false;
  bool isFetching = false;

  @override
  void initState() {
    super.initState();
    _loadConfig().then((_) {
      _startFetchingData();
    });
  }
  // Funcion para cargar los datos de configuracion desde ScreenLoginSuccess
  Future<void> _loadConfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apiUrl = prefs.getString('urlApi') ?? widget.urlApi;
      bearerToken = prefs.getString('bearer') ?? widget.bearer;
      idTablet = prefs.getString('idTablet') ?? widget.id;
      endpoint = prefs.getString('finalEndPoint') ?? widget.endpoint;

      // Debugging: Verificar valores cargados
      print('Carregat desde SharedPreferences:');
      print('apiUrl: $apiUrl');
      print('bearerToken: $bearerToken');
      print('idTablet: $idTablet');
      print('endpoint: $endpoint');
    });
  }
  // Se comienza a hacer peticiones
  void _startFetchingData() {
    if (isFetching) {
      print('Petició en curs. No es possible iniciar una nova.');
      return; // Evitar múltiples instancias
    }
    isFetching = true;
    print('Començant peticions...');
    attemptFetchData();
  }
  // Se detienen las peticiones para evitar duplicados de estas y se vuelven a hacer peticiones 
  Future<void> attemptFetchData() async {
    final String apiUrlWithEndpoint = '$apiUrl$endpoint';

    final fetchController =
        Provider.of<FetchController>(context, listen: false);
    fetchController.startFetching();

    // Se verifica si existe o estan bien escritos los datos que utilizaremos para las peticiones en la configuracion
    if (apiUrl != null &&
        apiUrl!.isNotEmpty &&
        endpoint != null &&
        endpoint!.isNotEmpty) {
      while (isFetching) {
        isFetching = fetchController.isFetching;

        print("IS FETCHING: $isFetching ");
        try {
          final success = await _fetchData(apiUrlWithEndpoint);
          if (success) {
            isFetching = false; // Finaliza el ciclo si es exitoso
            print('Petició exitosa. Finalitzant intents.');
          } else {
            print('Resposta no exitosa. Probant de nou en 1 segon...');
          }
        } catch (e) {
          print('Excepció a la solicitut: $e. Probant de nou en 10 segon...');
        }

        // Siempre espera 10 segundos entre intentos

        await Future.delayed(const Duration(seconds: 1));
      }
    }
    print('Petició finalitzada.');
    await Future.delayed(const Duration(seconds: 5));
    attemptFetchData();
  }
  // Funcion para ejecutar las peticiones a una Api
  Future<bool> _fetchData(String apiUrlWithEndpoint) async {
    try {
      print('Obtenint dades de -> $apiUrlWithEndpoint');
      final response = await http.get(
        Uri.parse(apiUrlWithEndpoint),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $bearerToken',
        },
      );

      if (response.statusCode == 200) {
        print('Dades rebudes.');
        final Map<String, dynamic> responseBody = jsonDecode(response.body);
        final String url = responseBody['url'];
        final String urlTablet = responseBody['id'];
        final String urlDate = responseBody['creationDate'];
        // En caso de recibir los datos de una firma, se mostraran en un webView
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => WebViewContainer(
              url: url,
              urlDate: urlDate,
              urlTablet: urlTablet,
            ),
          ),
        );
        return true; // Indica que se recibió una respuesta exitosa
      } else {
        print('Error HTTP rebut: ${response.statusCode}');
        return false; // Continua el bucle
      }
    } catch (e) {
      print('Excepció a la solicitut: $e');
      return false; // Continua el bucle ante excepciones
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 69, 65, 65),
      body: Stack(
        alignment: Alignment.center,
        children: [
          if (!showWebView)
            // El carrusel se muestra siempre hasta que `showWebView` sea verdadero
            ImageCarousel(
              animationInterval: widget.tempsEntreAnimacions ?? 5,
              urlimatges: widget.urlImatges,
            ),
          MenuData(
              key: GlobalKey<_MenuDataState>()), // Muestra un drawer oculto en la pantalla
        ],
      ),
    );
  }
}

class MenuData extends StatefulWidget {
  const MenuData({super.key});
  static _MenuDataState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MenuDataState>();
  }

  @override
  _MenuDataState createState() => _MenuDataState();
}

class _MenuDataState extends State<MenuData>
    with SingleTickerProviderStateMixin {
  double _drawerOffset = -250; // Valor inicial del drawer
  late AnimationController _animationController;
  bool _isDragging = false; // Flag para el gesto 'Drag'
  // Variable para mantener el botón seleccionado
  String _selectedMenu = 'Inici'; // Botón inicial seleccionado
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 100),
    );
  }

  // Método para abrir el Drawer
  void openDrawer() {
    setState(() {
      _drawerOffset = 0;
      _animationController.forward();
    });
  }

  // Método para cerrar el Drawer
  void closeDrawer() {
    setState(() {
      _drawerOffset = -250;
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double verticalLimit = screenHeight / 2; // Límite para abrir el drawer
    return WillPopScope(
      onWillPop: () async {
        if (_drawerOffset != -250) {
          closeDrawer(); // Cierra el drawer si está abierto
          return false;
        }
        return true; // Permite retroceder si el drawer está cerrado
      },
      child: Stack(
        children: [
          GestureDetector(
            onHorizontalDragStart: (details) {
              if (details.localPosition.dy <= verticalLimit ||
                  _drawerOffset != -250) {
                _isDragging = true;
              }
            },
            onHorizontalDragUpdate: (details) {
              if (_isDragging) {
                setState(() {
                  _drawerOffset =
                      (_drawerOffset + details.delta.dx).clamp(-245.0, 0.0);
                });
              }
            },
            onHorizontalDragEnd: (details) {
              if (_isDragging) {
                if (_drawerOffset > -122.5) {
                  openDrawer(); // Abrir el drawer
                } else {
                  closeDrawer(); // Cerrar el drawer
                }
              }
              _isDragging = false;
            },
          ),
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_drawerOffset, 0),
                child: GestureDetector(
                  onHorizontalDragStart: (details) {
                    if (details.localPosition.dx < 10 &&
                        details.localPosition.dy < 10) {
                      _isDragging = true;
                    }
                  },
                  onHorizontalDragUpdate: (details) {
                    if (_isDragging) {
                      setState(() {
                        _drawerOffset = (_drawerOffset + details.delta.dx)
                            .clamp(-245.0, 0.0);
                      });
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    if (_isDragging) {
                      if (_drawerOffset > -122.5) {
                        openDrawer(); // Abrir el drawer
                      } else {
                        closeDrawer(); // Cerrar el drawer
                      }
                    }
                    _isDragging = false;
                  },
                  child: Container(
                    width: 250,
                    decoration: BoxDecoration(
                      color: const Color.fromARGB(205, 255, 255, 255),
                      borderRadius: const BorderRadius.only(
                        topRight: Radius.circular(
                            15), // Borde superior derecho redondeado
                        bottomRight: Radius.circular(
                            15), // Borde inferior derecho redondeado
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 35),
                        _buildMenuButton('Inici', Icons.home, isMain: true),
                        _buildMenuButton('Admin', Icons.admin_panel_settings,
                            isAdmin: true),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // Método para construir los botones del Drawer
  Widget _buildMenuButton(String title, IconData icon,
      {bool isAdmin = false, bool isMain = false}) {
    bool isSelected =
        _selectedMenu == title; // Verificar si este botón está seleccionado
    return InkWell(
        child: ElevatedButton(
      onPressed: () async {
        // Cambiar el estado cuando se presiona el botón
        setState(() {
          _selectedMenu = title;
        });
        // Verificamos si es el botón de Admin
        if (isAdmin) {
          // Navegar a la pantalla de login
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const LoginScreen(
                id: '',
                bearer: '',
                endpoint: '',
              ),
            ),
          );
        } else if (isMain) {
          // Navegar a la pantalla principal (MainWidget)
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => MainWidget(
                username: 'admin',
                id: 'Taula09',
                urlApi: '',
                bearer: '',
                endpoint: '',
                urlImatges:
                    'https://www.assegur.com/img/tauletes/', // Verifica este valor
              ),
            ),
          );
        }
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: isSelected ? Colors.white : Colors.black,
        backgroundColor: isSelected ? Colors.black : Colors.transparent,
        elevation: 0,
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18),
          ),
          const SizedBox(width: 20),
          Icon(icon)
        ],
      ),
    ));
  }
}
