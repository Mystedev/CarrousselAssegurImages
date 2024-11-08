// Clase configuracion para definir los datos que se validaran a traves de los widgets
class Configuracio {
  // Id de la tablet
  final String id;
  // Usuario de la tablet
  final String user;
  // Password del usuario
  final String password;
  // Tiempo entre animacions
  final String temps;
  // Url de las imagenes para el carrusel
  final String urlImatges;
  // Encendedor para la validacion de datos
  final bool isValid;
  // Configuracion mediante la API
  final String agentsSignatureApiUrl;
  final String agentsSignatureEndPoint;
  final String agentsSignaturebearer;
  final String agentsSignatureIdTablet;
  final bool loggedInWithMicrosoftAccount;

  const Configuracio({
    this.id = 'Taula09', // Valor predeterminado del id
    required this.user,
    required this.password,
    required this.temps,
    required this.urlImatges,
    required this.isValid,
    this.agentsSignatureApiUrl = 'https://www.assegur.com/img/tauletes/',// Direccion predeterminada de la url de las imagenes
    required this.agentsSignatureEndPoint,
    required this.agentsSignaturebearer,
    required this.agentsSignatureIdTablet,
    required this.loggedInWithMicrosoftAccount,
  });

  bool validateCredentials(String inputEmail, String inputPassword) {
    return inputEmail == user && inputPassword == password;
  }
}