// ignore_for_file: avoid_print, prefer_const_literals_to_create_immutables, prefer_const_constructors, library_private_types_in_public_api, unused_element, empty_constructor_bodies, deprecated_member_use, unused_import, prefer_const_declarations, depend_on_referenced_packages, unused_field, use_key_in_widget_constructors, prefer_final_fields, non_constant_identifier_names

import 'package:flutter/material.dart';// Importamos los materiales necesarios que usa Flutter
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';// Esta clase importada guardara previamente las imagenes que cargaremos en el carrusel
import 'package:carousel_slider/carousel_slider.dart';
import 'dart:convert';
import 'dart:async';

void main() => runApp(MaterialApp(
      home: MainWidget(
        username: 'admin',// Obtenemos por parametro el user 
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

class _MenuDataState extends State<MenuData> with SingleTickerProviderStateMixin {
  double _drawerOffset = -250; // Valor inicial oculto del Drawer
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
      _drawerOffset = -250; // Drawer completamente oculto
      _animationController.reverse();
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double verticalLimit = screenHeight / 2; // Límite vertical para abrir el Drawer

    return WillPopScope(
      onWillPop: () async {
        if (_drawerOffset != -250) {
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
                  _drawerOffset != -250) {
                _isDragging = true;
              }
            },
            onHorizontalDragUpdate: (details) {
              if (_isDragging) {
                setState(() {
                  // Controla el desplazamiento para abrir/cerrar el Drawer
                  _drawerOffset = (_drawerOffset + details.delta.dx).clamp(-245.0, 0.0);
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
                  onHorizontalDragStart: (details) {
                    // Limitar la detección del arrastre solo a la esquina superior izquierda (10x10 píxeles)
                    if (details.localPosition.dx < 10 && details.localPosition.dy < 10) {
                      _isDragging = true;
                    }
                  },
                  onHorizontalDragUpdate: (details) {
                    if (_isDragging) {
                      setState(() {
                        // Controla el desplazamiento para abrir/cerrar el Drawer
                        _drawerOffset = (_drawerOffset + details.delta.dx).clamp(-245.0, 0.0);
                      });
                    }
                  },
                  onHorizontalDragEnd: (details) {
                    if (_isDragging) {
                      // Define si el Drawer debe abrirse o cerrarse
                      if (_drawerOffset > -122.5) {
                        openDrawer();
                      } else {
                        closeDrawer();
                      }
                    }
                    _isDragging = false; // Reinicia la bandera
                  },
                  child: Container(
                    width: 250, // Ancho del Drawer
                    color: const Color.fromARGB(255, 157, 213, 238),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 35),
                        _buildMenuButton('Inicio', Icons.home, isMain: true),
                        _buildMenuButton('Admin', Icons.admin_panel_settings, isAdmin: true),
                        _buildMenuButton('Desconectar', Icons.logout, isDisconnect: true),
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
  Widget _buildMenuButton(String title, IconData icon, {bool isAdmin = false, bool isMain = false, bool isDisconnect = false}) {
    return ElevatedButton(
      onPressed: () {
        // Según el botón que clicamos, se habilita la ruta a la que nos dirigiremos
        if (isAdmin) {
          // Navegamos a la pantalla donde haremos el Login
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const LoginScreen()),
          );
        } else if (isMain) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => MainWidget(username: 'admin')),
          );
        } else if (isDisconnect) {
          // Aquí puedes añadir la lógica para desconectar
          closeDrawer(); // Cierra el Drawer después de seleccionar
          print('$title seleccionado');
        } else {
          closeDrawer(); // Cierra el Drawer para otras selecciones
          print('$title seleccionado');
        }
      },
      style: ElevatedButton.styleFrom(
        foregroundColor: Colors.black, backgroundColor: Colors.transparent, // Color del texto
        elevation: 0, // Sin sombra
        padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0), // Espaciado
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18),
          ),
        ],
      ),
    );
  }
}

class MainWidget extends StatefulWidget {
  final String username;
  final int? tempsEntreAnimacions;
  final String? urlImatges;
  
  const MainWidget({// Obtenemos por parametros las variables que queremos utilizar
    super.key, 
    required this.username, 
    this.tempsEntreAnimacions, 
    this.urlImatges,
  });

  @override
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  // Usamos un encendedor para detectar cuando mostrar o no el carrusel
  bool showCarousel = false;

  @override
  void initState() {
    super.initState();
    // Verificar si los datos están configurados y obtenidos correctamente
    if (widget.tempsEntreAnimacions != null && widget.urlImatges != null) {
      setState(() {
        showCarousel = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Si se cumple la condicion, podemos proceder a mostrar el carrusel
          if (showCarousel) 
            ImageCarousel(), // Mostrar carrusel si los datos están validados
            MenuData(key: GlobalKey<_MenuDataState>()), // Luego el Drawer (capa superior)
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
  int _currentIndex = 0;// Indice para iterar cada imagen de la lista obtenida

  final String baseUrl = 'https://www.assegur.com/img/tauletes/';// Url de las imagenes
  final List<String> imageIds = List.generate(12, (index) => '${index + 1}'.padLeft(2, '0'));// Generamos una lista con las imagenes obtenidas

  @override
  Widget build(BuildContext context) {
    // Las siguientes variables ocuparan todo el rango de la pantalla
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: CarouselSlider.builder(
        // Contar hasta la longitud de la lista con las imagenes obtenidas
        itemCount: imageIds.length,
        itemBuilder: (context, index, realIndex) {
          final imageUrl = '$baseUrl${imageIds[index]}-tauleta.jpg';// Iteramos cada imagen para acceder a cada una
          return SizedBox(
            width: screenWidth,
            height: screenHeight, // Ocupa toda la altura de la pantalla
            child: CachedNetworkImage(// Precargamos las siguientes imagenes
              imageUrl: imageUrl,
              fit: BoxFit.cover, // Asegura que la imagen cubra completamente el espacio
              errorWidget: (context, url, error) => Center(
                // Si la imagen no se puede cargar, muestra un mensaje de error
                child: Text('Error al cargar la imagen'),
              ),
            ),
          );
        },
        options: CarouselOptions(
          height: screenHeight, // Configura la altura para ocupar toda la pantalla
          autoPlay: true,
          autoPlayInterval: Duration(seconds: 5),// Duracion de la animacion por defecto
          autoPlayAnimationDuration: Duration(milliseconds: 800),
          autoPlayCurve: Curves.easeInQuart,
          viewportFraction: 1.0, // Cada imagen ocupa todo el espacio horizontal
          onPageChanged: (index, reason) {
            setState(() {
              _currentIndex = index;
            });
          },
          scrollPhysics: const NeverScrollableScrollPhysics(), // Deshabilita el scroll manual
        ),
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
  late TextEditingController _emailController = TextEditingController();
  late TextEditingController _passwordController = TextEditingController();

  // Configuracion a la que accederemos segun las validaciones requeridas
  final Configuracio configuracio = const Configuracio(
    id: 'Taula09',// Id de la tablet
    email: 'admin',// User para validar el usuario
    password: '1234',// Contraseña para validar el usuario
    temps: '5',// Tiempo por defecto
    urlImatges: 'https://assegur.com/img/tauletes',// Url por defecto
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
    // Inicializar los controladores con los valores iniciales de configuracio que se requieren
    _emailController = TextEditingController(text: configuracio.email);
    _passwordController = TextEditingController(text: configuracio.password);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Login"),
        backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          // Centrar hijo de la columna 
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Inputs del LOGIN
            TextFormField(
              controller: _emailController, // Obtener controlador para escribir en este campo
              decoration: const InputDecoration(
                labelText: 'Usuario',
                border: OutlineInputBorder(),
                suffixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _passwordController, // Obtener controlador para escribir en este campo
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
                final String user = _emailController.text;
                final String password = _passwordController.text;
                if (configuracio.validateCredentials(user, password)) {
                  // Si las credenciales son válidas, navegar a MainWidgetWithLoginSuccess
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (context) => MainWithLoginSuccess(),
                    ),
                  );
                } else {
                  // Mostrar un mensaje de error si es que los datos introducidos no son correctos
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Datos inválidos')),
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
  late TextEditingController tempsEntreConsultesController =
      TextEditingController();
  late TextEditingController urlImatgesController = TextEditingController();
  late TextEditingController _idTablet = TextEditingController();
  late TextEditingController _UrlApi = TextEditingController();
  late TextEditingController _endPoint = TextEditingController();
  late TextEditingController _bearer = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Se inicializan las variables con valores por defecto
    tempsEntreConsultesController = TextEditingController(text: '5');
    urlImatgesController =
        TextEditingController(text: 'https://assegur.com/img/tauletes');
    _idTablet = TextEditingController(text: 'Taula09');
    _UrlApi = TextEditingController(text: 'https://platform.assegur.com/');
    _endPoint = TextEditingController(text: 'api/tablets/{idTablet}/url');
    _bearer = TextEditingController(text: 'Bearer token');  // Añadir un valor predeterminado aquí
  }
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
      isFormValidated = true;
      // Redirigir a MainWidget con los datos guardados
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MainWidget(
            username: 'admin',
            tempsEntreAnimacions: tempsEntreAnimacions!,
            urlImatges: urlImatges!,
          ),
        ),
      );
    });
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        // Si el formulario valida los datos introducidos , el contenido principal
        // será el carrusel con las imagenes obtenidas de la API
        child: isFormValidated
            ? ImageCarousel() // Si el formulario es válido, mostramos el carrusel
            : _buildForm(), // Si no, mostramos el formulario
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
          // Inputs para obtener los datos de configuración
          TextFormField(
            controller: _idTablet,
            decoration: InputDecoration(
              labelText: 'ID Tablet',
              border: OutlineInputBorder(),
            ),
            keyboardType: TextInputType.text,
          ),
          SizedBox(
            height: 16,
          ),
          TextFormField(
            controller: _UrlApi,
            decoration: InputDecoration(
                labelText: 'URl Api', border: OutlineInputBorder()),
            keyboardType: TextInputType.text,
          ),
          SizedBox(
            height: 16,
          ),
          TextFormField(
            controller: _endPoint,
            decoration: InputDecoration(
                labelText: 'Endpoint', border: OutlineInputBorder()),
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: 16),
          TextFormField(
            controller: _bearer,
            decoration: InputDecoration(
                labelText: 'Bearer', border: OutlineInputBorder()),
            keyboardType: TextInputType.text,
          ),
          SizedBox(height: 16),
          // Campo para el tiempo entre consultas
          TextFormField(
            controller: tempsEntreConsultesController,
            decoration: InputDecoration(
                labelText: 'Temps entre animacions (ms)',
                border: OutlineInputBorder()),
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
            decoration: InputDecoration(
                labelText: 'URL de les imatges', border: OutlineInputBorder()),
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
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              )),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
            onPressed: _onDesar,
            child: Text('Desar'),
          ),
          ElevatedButton(
            style: ButtonStyle(
              shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                  RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18.0),
              )),
              backgroundColor: MaterialStateProperty.all<Color>(Colors.black),
              foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
            ),
            onPressed: () {
              // Mostrar un mensaje de error
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Datos actualizados')),
              );
            },
            child: Text('Actualitzar'),
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
  final String urlImatges;
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
