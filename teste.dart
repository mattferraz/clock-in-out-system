import 'package:ansicolor/ansicolor.dart';


main() {
String dia = (DateTime.now().day).toString();
String mes = (DateTime.now().month).toString();
String ano = (DateTime.now().year).toString();

String hora = DateTime.now().hour.toString();
String minuto = DateTime.now().minute.toString();
String segundo = DateTime.now().second.toString();

String horaFormatada = hora + ':' + minuto + ':' + segundo;
print(horaFormatada);

String dataFormatada = ano + '-0' + mes + '-' + dia;
print(dataFormatada);

print(DateTime.now());

AnsiPen pen = new AnsiPen()..blue();
print(pen("White foreground with a peach background"));

}