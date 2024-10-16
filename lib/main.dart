// ignore_for_file: avoid_print, prefer_const_literals_to_create_immutables, prefer_const_constructors, library_private_types_in_public_api, unused_element, empty_constructor_bodies, deprecated_member_use, unused_import, prefer_const_declarations, depend_on_referenced_packages, unused_field, use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:html/parser.dart' as html_parser;
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:convert';
import 'dart:async';

void main() => runApp(MaterialApp(
      home: MainWidget(
        username: 'admin',
      ),
    ));

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
  double _drawerOffset = -249; // Valor inicial oculto del Drawer
  late AnimationController _animationController;
  bool _isDragging = false; // Bandera para controlar el gesto
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
      _drawerOffset = 0; // Drawer completamente visible
      _animationController.forward();
    });
  }

  // Método para cerrar el Drawer
  void closeDrawer() {
    setState(() {
      _drawerOffset = -245; // Drawer completamente oculto
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double verticalLimit =
        screenHeight / 2; // Límite vertical para abrir el Drawer

    return WillPopScope(
      onWillPop: () async {
        if (_drawerOffset != -245) {
          closeDrawer(); // Cierra el Drawer si está abierto
          return false; // Evita salir de la app
        }
        return true; // Permite retroceder si el Drawer está cerrado
      },
      child: Stack(
        children: [
          // Contenido principal
          GestureDetector(
            onHorizontalDragStart: (details) {
              // Permitir arrastre para abrir o cerrar el Drawer desde cualquier parte
              if (details.localPosition.dy <= verticalLimit ||
                  _drawerOffset != -245) {
                _isDragging = true;
              }
            },
            onHorizontalDragUpdate: (details) {
              if (_isDragging) {
                setState(() {
                  // Controla el desplazamiento para abrir/cerrar el Drawer
                  _drawerOffset =
                      (_drawerOffset + details.delta.dx).clamp(-245.0, 0.0);
                });
              }
            },
            onHorizontalDragEnd: (details) {
              if (_isDragging) {
                // Define si el Drawer debe abrirse completamente o cerrarse
                if (_drawerOffset > -122.5) {
                  openDrawer();
                } else {
                  closeDrawer();
                }
              }
              _isDragging = false; // Reinicia la bandera
            },
          ),
          // Drawer personalizado
          AnimatedBuilder(
            animation: _animationController,
            builder: (context, child) {
              return Transform.translate(
                offset: Offset(_drawerOffset, 0),
                child: GestureDetector(
                  onHorizontalDragUpdate: (details) {
                    setState(() {
                      // Permitir mover el Drawer incluso cuando está visible
                      _drawerOffset =
                          (_drawerOffset + details.delta.dx).clamp(-245.0, 0.0);
                    });
                  },
                  onHorizontalDragEnd: (details) {
                    // Define si el Drawer debe abrirse o cerrarse después del arrastre
                    if (_drawerOffset > -122.5) {
                      openDrawer();
                    } else {
                      closeDrawer();
                    }
                  },
                  child: Container(
                    width: 250, // Ancho del Drawer
                    color: const Color.fromARGB(255, 203, 247, 244),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 30),
                        _buildMenuButton('Inicio', Icons.home, isMain: true),
                        _buildMenuButton('Admin', Icons.admin_panel_settings,
                            isAdmin: true),
                        _buildMenuButton('Desconectar', Icons.logout),
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

  // Método para construir botones del Drawer
  Widget _buildMenuButton(String title, IconData icon,
      {bool isAdmin = false, bool isMain = false}) {
    //bool isDisconnect = title == 'Desconectar';
    return GestureDetector(
      onTap: () {
        // Segun el boton que cliquemos , se enciende un log 'boolean' que habilita la ruta a la que nos dirigiremos
        if (isAdmin) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } /*else if (isDisconnect) {
          Navigator.of(context).push(MaterialPageRoute(
           builder: (context) => const DisconnectScreen()));
        }*/
        else if (isMain) {
          Navigator.of(context).push(
            MaterialPageRoute(
                builder: (context) => MainWidget(username: 'admin')),
          );
        } else {
          closeDrawer(); // Cierra el Drawer después de seleccionar
          print('$title seleccionado');
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
        child: Row(
          children: [
            Icon(icon, color: Colors.black),
            const SizedBox(width: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MainWidget extends StatefulWidget {
  final String username;
  final GlobalKey<_MenuDataState> _menuKey = GlobalKey<_MenuDataState>();

  MainWidget({super.key, required this.username});

  @override
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          MenuData(key: widget._menuKey), // El menú
          // Cambiado de Positioned.fill a un Container
          // Seccion del carrusel, esta comentado para poder continuar trabajando en entornos de
          // pruebas , de esta forma no se ve afectado el funcionamiento sobreposicionado del menu
          // lateral, DISCOMMENT TO USE THIS PART
        ],
      ),
    );
  }
}

// El carrusel ya implementado por ti
class ImageCarousel extends StatefulWidget {
  const ImageCarousel({super.key});

  @override
  _ImageCarouselState createState() => _ImageCarouselState();
}

class _ImageCarouselState extends State<ImageCarousel> {
  int _currentIndex = 0;

  final String baseUrl = 'https://www.assegur.com/img/tauletes/';
  final List<String> imageIds =
      List.generate(12, (index) => '${index + 1}'.padLeft(2, '0'));

  @override
  Widget build(BuildContext context) {
    return CarouselSlider.builder(
      itemCount: imageIds.length,
      itemBuilder: (context, index, realIndex) {
        final imageUrl = '$baseUrl${imageIds[index]}-tauleta.jpg';
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.cover,
            placeholder: (context, url) => Center(
              child: CircularProgressIndicator(), // Placeholder mientras carga
            ),
            errorWidget: (context, url, error) => Center(
              child: Text('Error al cargar la imagen'),
            ),
          ),
        );
      },
      options: CarouselOptions(
        height: MediaQuery.of(context).size.height,
        autoPlay: true,
        autoPlayInterval: Duration(seconds: 5),
        autoPlayAnimationDuration: Duration(milliseconds: 800),
        autoPlayCurve: Curves.easeInExpo,
        viewportFraction: 1.0,
        onPageChanged: (index, reason) {
          setState(() {
            _currentIndex = index;
          });
        },
        scrollPhysics: const NeverScrollableScrollPhysics(),
      ),
    );
  }
}

// Pantalla de Login
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Ejemplo de configuración (deberías cambiarlo según tu lógica)
  final Configuracio configuracio = const Configuracio(
    id: '1',
    email: 'admin',
    password: '1234',
    temps: '',
    urlImatges: '',
    isValid: true,
    agentsSignatureApiUrl: '',
    agentsSignatureEndPoint: '',
    agentsSignaturebearer: '',
    agentsSignatureIdTablet: '',
    loggedInWithMicrosoftAccount: false,
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: const Color.fromARGB(255, 165, 242, 252),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Usuario',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Contraseña',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.password),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Validar credenciales al iniciar sesión
                final String email = _emailController.text;
                final String password = _passwordController.text;

                if (configuracio.validateCredentials(email, password)) {
                  // Si las credenciales son válidas, navegar a MainWidgetWithLoginSuccess
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => MainWithLoginSuccess(),
                    ),
                  );
                } else {
                  // Mostrar un mensaje de error
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Credenciales inválidas')),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white, backgroundColor: Colors.black),
              child: const Text('LOGIN'),
            ),
          ],
        ),
      ),
    );
  }
}

// MainWidget con imagen de inicio de sesión exitosa
// Pantalla principal con mensaje de éxito
class MainWithLoginSuccess extends StatefulWidget {
  @override
  _MainWithLoginSuccessState createState() => _MainWithLoginSuccessState();
}

class _MainWithLoginSuccessState extends State<MainWithLoginSuccess> {
  // Controladores para los campos de texto
  final TextEditingController tempsEntreConsultesController = TextEditingController();
  final TextEditingController urlImatgesController = TextEditingController();

  // Clave global para el formulario
  final _formKey = GlobalKey<FormState>();

  // Variable para guardar el tiempo entre animaciones y URL de imágenes
  int? tempsEntreAnimacions;
  String? urlImatges;

  // Booleano para determinar si el formulario fue validado correctamente
  bool isFormValidated = false;

  // Función para validar y desar el formulario
  void _onDesar() {
    if (_formKey.currentState!.validate()) {
      setState(() {
        // Si el formulario es válido, guardamos los valores
        tempsEntreAnimacions = int.parse(tempsEntreConsultesController.text);
        urlImatges = urlImatgesController.text;

        // Marcamos que el formulario fue validado
        isFormValidated = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isFormValidated
            ? ImageCarousel() // Si el formulario es válido, mostramos el carrusel
            : _buildForm(),    // Si no, mostramos el formulario
      ),
    );
  }

  // Widget que construye el formulario
  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(labelText: 'ID Tablet'),
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: 16,),
          TextFormField(
            decoration: InputDecoration(labelText:'URl Api' ),
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: 16,),
          TextFormField(
            decoration: InputDecoration(labelText: 'Endpoint'),
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: 16),
          TextFormField(
            decoration: InputDecoration(labelText: 'Bearer'),
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: 16),
          // Campo para el tiempo entre consultas
          TextFormField(
            controller: tempsEntreConsultesController,
            decoration: InputDecoration(labelText: 'Temps entre animacions (ms)'),
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
          SizedBox(height: 16),

          // Campo para la URL de imágenes
          TextFormField(
            controller: urlImatgesController,
            decoration: InputDecoration(labelText: 'URL de les imatges'),
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
          SizedBox(height: 32),

          // Botón para desar
          ElevatedButton(
            onPressed: _onDesar,
            child: Text('Desar'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    tempsEntreConsultesController.dispose();
    urlImatgesController.dispose();
    super.dispose();
  }
}

class Configuracio {
  final String id = 'Taula09';
  final String email;
  final String password;
  final String temps;
  final String urlImatges; //= 'https://www.assegur.com/img/tauletes';
  final bool isValid;
  final String agentsSignatureApiUrl = 'https://www.assegur.com/img/tauletes/';
  final String agentsSignatureEndPoint;
  final String agentsSignaturebearer;
  final String agentsSignatureIdTablet;
  final bool loggedInWithMicrosoftAccount;

  const Configuracio({
    required id,
    required this.email,
    required this.password,
    required this.temps,
    required this.urlImatges,
    required this.isValid,
    required agentsSignatureApiUrl,
    required this.agentsSignatureEndPoint,
    required this.agentsSignaturebearer,
    required this.agentsSignatureIdTablet,
    required this.loggedInWithMicrosoftAccount,
  });
  // Método para validar el inicio de sesión
  bool validateCredentials(String inputEmail, String inputPassword) {
    return inputEmail == email && inputPassword == password;
  }
}
