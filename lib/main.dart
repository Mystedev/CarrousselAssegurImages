// ignore_for_file: avoid_print, prefer_const_literals_to_create_immutables, prefer_const_constructors, library_private_types_in_public_api, unused_element, empty_constructor_bodies, deprecated_member_use, unused_import, prefer_const_declarations, depend_on_referenced_packages, unused_field, use_key_in_widget_constructors, prefer_final_fields, non_constant_identifier_names, sort_child_properties_last, use_build_context_synchronously, unnecessary_brace_in_string_interps
import 'package:flutter/material.dart';
import 'package:flutter_caroussel/configuracio.dart';
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

// ******************************************************************
/*
    Aplicación princiapl:
    Esta se compone de un carrusel de imagenes solicitadas desde una API
    y un widget para mostrar la información del clima , tambien obtenido de una API.
    La seccion de inicio permanece vacia mientras no se defina una configuracion ni 
    se haya hecho LOGIN del usuario del dispositivo.
  */
void main() {
  // Configuracion general del widget principal
  const configuracio = Configuracio(
    user: 'admin',
    password: '1234',
    temps: '5',
    urlImatges: 'https://www.assegur.com/img/tauletes/',
    isValid: true,
    agentsSignatureEndPoint: '/api/tablets/',
    agentsSignaturebearer: 'af18a463fd6a3226d28c4f71722983bc',
    agentsSignatureIdTablet: 'Taula09',
    loggedInWithMicrosoftAccount: false,
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => UrlModel(),
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
  bool showWebView = false;

  @override
  void initState() {
    super.initState();
    _loadConfig();
    //startPolling(); -> Activa peticiones automaticas en el main widget
  }

  Future<void> _loadConfig() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      apiUrl = prefs.getString('urlApi') ?? widget.urlApi;
      bearerToken = prefs.getString('bearer') ?? widget.bearer;
      idTablet = prefs.getString('idTablet') ?? widget.id;
    });
  }

  // Método para iniciar las peticiones automáticas
  /*void startPolling() {
    _timer ??= Timer.periodic(Duration(seconds: 1), (timer) async {
      await _fetchData();
    });
  }*/

  /*void stopPolling() {
    _timer?.cancel();
    _timer = null;
  }*/

  Future<void> _fetchData() async {
    // Funcion que hace las peticiones automáticas
    if (apiUrl == null || bearerToken == null || idTablet == null) return;

    final String? fullUrl = apiUrl;
    try {
      final response = await http.get(
        Uri.parse(fullUrl!),
        headers: {
          'Content-Type': 'aplication/json',
          'Authorization': 'Bearer $bearerToken',
        },
      );
      if (response.statusCode == 200) {
        print('Petició exitosa amb id ${idTablet}');
        final data = json.decode(response.body);
        final url = data['url'];

        if (url != null && url != currentUrl) {
          setState(() {
            currentUrl = url;
            showWebView = true; // Mostrar WebView si la URL es válida
          });
        }
      } else {
        print('Error HTTP: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception in _fetchData: $e');
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
          if (showWebView && currentUrl != null)
            WebViewContainer(
                //urlDate: '',
                urlTablet: '',
                url: currentUrl!), // Muestra el WebView si la URL es válida
          MenuData(key: GlobalKey<_MenuDataState>()),
        ],
      ),
    );
  }
}

/*
    Clase MenuData:
    Esta clase se encarga de gestionar el menu de la aplicación.
    Esta se refiere a una barra lateral oculta que solo se muestra cuando hacemos drag
    y la movemos del borde
  */
class MenuData extends StatefulWidget {
  const MenuData({super.key});
  static _MenuDataState? of(BuildContext context) {
    return context.findAncestorStateOfType<_MenuDataState>();
  }

  @override
  _MenuDataState createState() => _MenuDataState();
}

/*
    Clase _MenuDataState:
    Esta clase se encarga de gestionar el comportamiento del menu.
    Asi como la animacion ,tiempo,duracion,tamaño del menu
  */
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

  /*
      Clase build:
      Esta clase se encarga de construir el widget de la barra lateral oculta.
      La seccion de inicio permanece vacia mientras no se defina una configuracion.
      Aqui encontraremos botones para acceder a otros widgets asi como :
      Seccion de inicio de sesion
      Seccion de inicio de la App
      Seccion de desconectar la sesión
    */
  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;
    double verticalLimit = screenHeight / 2; // Límite vertical
    double horizontalLimit =
        screenWidth / 2; // Solo entre mitad izquierda y borde izquierdo

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
              // Verificar que el toque inicie en la mitad izquierda de la pantalla
              if (details.localPosition.dx <= horizontalLimit &&
                  details.localPosition.dy <= verticalLimit) {
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
                        topRight: Radius.circular(15),
                        bottomRight: Radius.circular(15),
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
                        _buildMenuButton(
                          'Desconnectar',
                          Icons.logout,
                        ),
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

  /*
      Clase _buildMenuButton:
      Esta clase se encarga de construir los botones del Drawer , los cuales nos daran
      Acceso al resto de widgets y estados de la aplicacion
    */
  // Método para construir los botones del Drawer
  Widget _buildMenuButton(String title, IconData icon,
      {bool isAdmin = false, bool isMain = false}) {
    bool isSelected =
        _selectedMenu == title; // Verificar si este botón está seleccionado
    return ElevatedButton(
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
                urlImatges: '',
              ),
            ),
          );
        } /*else if (isDisconnect) {
            // Obtener las preferencias para verificar si hay una sesión activa
            SharedPreferences prefs = await SharedPreferences.getInstance();
            bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

            if (isLoggedIn) {
              // Mostrar la alerta de confirmación si hay sesión activa
              print('Asking to logout the session');
              _showLogoutConfirmationDialog(context);
            } else {
              // Informar al usuario si no hay ninguna sesión activa
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('No hi ha cap sessió activa'),
                  backgroundColor: Colors.redAccent,
                ),
              );
            }
          }*/
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
          Icon(icon),
        ],
      ),
    );
  }

  /* void _showLogoutConfirmationDialog(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Confirmar Desconnexió'),
            content: const Text('¿Estás segur de que vols tancar la sessió?'),
            actions: <Widget>[
              TextButton(
                child: const Text('Cancelar'),
                onPressed: () {
                  // Cerrar el cuadro de diálogo sin desconectar
                  Navigator.of(context).pop();
                },
              ),
              TextButton(
                child: const Text('Tancar sessió'),
                onPressed: () async {
                  // Proceder a cerrar la sesión
                  SharedPreferences prefs = await SharedPreferences.getInstance();
                  // Eliminar el estado de sesión
                  await prefs.remove('isLoggedIn');
                  // Redirigir al login
                  Navigator.of(context).pushAndRemoveUntil(
                    MaterialPageRoute(
                        builder: (context) => MainWidget(
                              username: 'admin',
                              id: 'Taula09',
                              urlApi: '',
                            )),
                    (Route<dynamic> route) =>
                        false, // Eliminar todas las rutas anteriores
                  );
                },
              ),
            ],
          );
        },
      );
    }
  }
  */
}
