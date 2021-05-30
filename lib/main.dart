import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MiControladorGlobal extends GetxController {
  final intGlobal = 0.obs;
  static MiControladorGlobal get to => Get.find<MiControladorGlobal>();
}

class Usuario {
  int id;
  String nombre;
  Usuario({this.id = 0, this.nombre = "noname"});
}

class MiControlador extends GetxController {
  final contador = 0.obs;
  final nombre = "".obs;
  final usuario = Usuario().obs;
  incrementar() {
    if (contador.value > 10)
      contador.value = 0;
    else
      contador.value++;
  }
}

Future<String> llamadaApi() async {
  await Future.delayed(Duration(seconds: 3));
  //await 3.delay(); //modo alternativo de espera usando la libreria GetX
  return "datos recibidos";
}

class ApiController extends GetxController with StateMixin<String> {
  ApiController() {
    change("", status: RxStatus.empty());
  }

  void consultar(conError) async {
    try {
      change(null, status: RxStatus.loading());
      String resp = await llamadaApi();
      if (conError)
        change(null, status: RxStatus.error("Error en la identificacion"));
      else
        change(resp, status: RxStatus.success());
    } catch (err) {
      change(null, status: RxStatus.error(err.toString()));
    }
  }
}

void main() {
  // ! usar controlador global
  Get.put(MiControladorGlobal());

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: Pagina(),
  ));
}

class Pagina extends StatelessWidget {
  final controlador = Get.put(MiControlador());
  final apiControlador = Get.put(ApiController());
  final miControladorGlobal = MiControladorGlobal.to;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Getx desde 0'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            // ! ejemplo de uso basico de un elemento observable
            Obx(() => Text(
                  'contador: ${controlador.contador.value}',
                )),
            ElevatedButton(
                onPressed: () => controlador.contador.value++,
                child: Text("aumentar contador")),
            ElevatedButton(
                onPressed: () => controlador.incrementar(),
                child: Text("aumentar contador con función")),
            Divider(), // ! Ejemplo del uso de un objeto
            Obx(() => Text(
                  'Usuario -> id: ${controlador.usuario.value.id} nombre: ${controlador.usuario.value.nombre}',
                )),
            ElevatedButton(
                onPressed: () {
                  controlador.usuario.value.id++;
                  controlador.usuario.refresh();
                },
                child: Text("aumentar id de usuario")),
            ElevatedButton(
                onPressed: () {
                  controlador.usuario.value =
                      Usuario(id: 99, nombre: "nuevo usuario");
                },
                child: Text("Asignar nuevo usuario")),
            Divider(), // ! Ejemplo de una llamada asíncrona
            apiControlador.obx(
              (datos) => Text("Resultado: $datos"),
              onLoading: CircularProgressIndicator(),
              onError: (error) => Text("Error: $error"),
            ),
            ElevatedButton(
                onPressed: () => apiControlador.consultar(false),
                child: Text("Consultar")),
            ElevatedButton(
                onPressed: () => apiControlador.consultar(true),
                child: Text("Llamada Error")),
            Divider(), // ! Ejemplo del controlador global
            Obx(
              () =>
                  Text("Valor global: ${miControladorGlobal.intGlobal.value}"),
            ),
            ElevatedButton(
                onPressed: () => miControladorGlobal.intGlobal.value++,
                child: Text("Aumentar valor global")),
          ],
        ),
      ),
    );
  }
}
