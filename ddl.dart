import 'package:mysql1/mysql1.dart';
import 'package:ansicolor/ansicolor.dart';
import 'dart:io';


Future main() async {
  final conn = await MySqlConnection.connect(ConnectionSettings(
    host: 'localhost',
    port: 3306,
    user: 'root',
    db: 'cpifpe',
    password: 'root#012345'));
    await Future.delayed(Duration(seconds: 1));

//* Criação de tabelas:
/*await conn.query('''CREATE TABLE administrador (
  nome varchar(40) NOT NULL,
  login varchar(15),
  senha varchar(12) NOT NULL,
  primary key (login)
) default charset = utf8mb4 default collate = utf8mb4_general_ci;''');

await conn.query('''CREATE TABLE usuario (
  login_adm varchar(15),
  nome varchar(40) NOT NULL,
  matricula varchar(15),
  senha varchar(12) NOT NULL,
  id_sala varchar(5) NOT NULL,
  tipo enum('ALUNO', 'PROFESSOR') NOT NULL,
  primary key (matricula),
  foreign key (login_adm) references administrador (login)
) default charset = utf8mb4 default collate = utf8mb4_general_ci;''');

await conn.query('''CREATE TABLE ponto (
  data date NOT NULL,
  horario time NOT NULL,
  matricula varchar(15) NOT NULL,
  tipo enum('ENTRADA', 'SAÍDA'),
  foreign key (matricula) references usuario (matricula)
) default charset = utf8mb4 default collate = utf8mb4_general_ci;''');*/

  AnsiPen pen = new AnsiPen()..xterm(029);
  print(pen('----- CENTRO DE PESQUISA IFPE -----'));
  while (true) {
  sleep(Duration(seconds: 1));
  print('''O que você deseja fazer?
[ 1 ] - Realizar Login
[ 2 ] - Realizar Cadastro (Apenas administradores)
[ 0 ] - Sair do Programa''');

  int escolha = 0;
  while (true) {
  stdout.write('Escolha: ');
  escolha = int.parse(stdin.readLineSync()!);
  if (escolha == 1 || escolha == 2 || escolha == 0)
    break;
  AnsiPen pen = new AnsiPen()..red();
  print(pen('Escolha inválida!'));
  }
  print('-' * 40);
  sleep(Duration(seconds: 1));

  //? Sair do programa
  if (escolha == 0)
    break;
  
  //! Cadastro Administrador
  if (escolha == 2) {
    stdout.write('Nome: ');
    String nome = stdin.readLineSync()!.trim();

    stdout.write('Login do IFPE: ');
    String login = stdin.readLineSync()!;

    stdout.write('Senha (max: 12 caracteres): ');
    String senha = stdin.readLineSync()!;

    // Inserindo dados na tabela
    await conn.query(
      'insert into administrador(nome, login, senha) values(?, ?, ?)',
      [nome, login, senha]);
    AnsiPen pen = new AnsiPen()..green();
    sleep(Duration(seconds: 1));
    print(pen('Cadastro realizado com sucesso!'));
  }

  //! Realizar Login
  while(true) {
    print('''Você deseja realizar login como Administrador ou Professor/Aluno?
[ 1 ] - Administrador
[ 2 ] - Professor/Aluno
[ 0 ] - Voltar''');
    int escolha = 0;
    while (true) {
      stdout.write('Escolha: ');
      escolha = int.parse(stdin.readLineSync()!);
      if (escolha == 1 || escolha == 2 || escolha == 0)
        break;
      AnsiPen pen = new AnsiPen()..red();
      print(pen('Escolha inválida!'));
    }

    print('-' * 40);

    if (escolha == 0)
      break;
      
    sleep(Duration(seconds: 1));

    //? Login:
    stdout.write('Sua matrícula do IFPE: ');
    String matricula = stdin.readLineSync()!.trim();
    stdout.write('Senha: ');
    String senha = stdin.readLineSync()!.trim();

    sleep(Duration(seconds: 1));

    //* Verificando se existe alguém com a matrícula informada:
    int quantidade = 0;
    dynamic results = 0;
    String senhaCadastrada = '';

    if (escolha == 1)
      results = await conn.query('SELECT COUNT(*) FROM administrador WHERE login = ?', [matricula]);

    else if (escolha == 2)
      results = await conn.query('SELECT COUNT(*) FROM usuario WHERE matricula = ?', [matricula]);

    for (var row in results)
      quantidade = row[0];

    if (quantidade == 0) {
      AnsiPen pen = new AnsiPen()..red();
      print(pen('Matrícula incorreta!'));
      print('-' * 40);
      sleep(Duration(seconds: 1));
    }
    
    else {
      //* Verificando se a senha está correta
      if (escolha == 1) {
        results = await conn.query('SELECT senha FROM administrador WHERE login = ?', [matricula]);
        for (var row in results)
          senhaCadastrada = row[0];
      }
      else if (escolha == 2) {
        results = await conn.query('SELECT senha FROM usuario WHERE matricula = ?', [matricula]);
        for (var row in results)
          senhaCadastrada = row[0];
      }

      if (senhaCadastrada != senha) {
        AnsiPen pen = new AnsiPen()..red();
        print(pen('Senha incorreta!'));
        print('-' * 40);
        sleep(Duration(seconds: 1));
      }
      
      else {
        AnsiPen pen = new AnsiPen()..green();
        print(pen('Login realizado com sucesso!'));
        print('-' * 40);

        //? BATER PONTO
        if (escolha == 2) {
          sleep(Duration(seconds: 1));
          print('''O que você deseja fazer?
[ 1 ] - Registrar Entrada
[ 2 ] - Registrar Saída
[ 0 ] - Voltar''');
          int escolha = 0;
          while (true) {
            stdout.write('Escolha: ');
            escolha = int.parse(stdin.readLineSync()!);
            if (escolha == 1 || escolha == 2 || escolha == 0)
              break;
            AnsiPen pen = new AnsiPen()..red();
            print(pen('Escolha inválida!'));
          }

          print('-' * 40);
          sleep(Duration(seconds: 1));

          if (escolha == 0)
            break;

          
          String tipoPonto = '';
          if (escolha == 1)
            tipoPonto = 'ENTRADA';
          else if (escolha == 2)
            tipoPonto = 'SAÍDA';

          if (escolha == 1 || escolha == 2) {
            //* Buscando data
            String dia = (DateTime.now().day).toString();
            String mes = (DateTime.now().month).toString();
            String ano = (DateTime.now().year).toString();
            String data = ano + '-0' + mes + '-' + dia;

            //* Buscando hora
            String hora = DateTime.now().hour.toString();
            String minuto = DateTime.now().minute.toString();
            String segundo = DateTime.now().second.toString();
            String horario = hora + ':' + minuto + ':' + segundo;
            
            //* Inserindo dados na tabela ponto
            await conn.query(
              'insert into ponto (data, horario, matricula, tipo) values (?, ?, ?, ?)',
              [data, horario, matricula, tipoPonto]);
            if (escolha == 1) {
              AnsiPen pen = new AnsiPen()..green();
              print(pen('Entrada realizada com sucesso. Seja bem vindo!'));
            }
            else if (escolha == 2) {
              AnsiPen pen = new AnsiPen()..green();
              print(pen('Saída realizada com sucesso. Até a próxima!'));
            }              
          }
        }

        if (escolha == 1) {
          while (true) {
            sleep(Duration(seconds: 1));
            print('''O que você deseja fazer? 
[ 1 ] - Cadastrar Usuário
[ 2 ] - Descadastrar Usuário
[ 3 ] - Visualizar Histórico de Entradas e Saídas
[ 0 ] - Sair da conta''');
            int escolha = 0;
            while (true) {
            stdout.write('Escolha: ');
            escolha = int.parse(stdin.readLineSync()!);
            if (escolha == 1 || escolha == 2 || escolha == 3 || escolha == 0)
              break;
            AnsiPen pen = new AnsiPen()..red();
            print(pen('Escolha inválida!'));
            }

            if (escolha == 0) {
              print('-' * 40);
              sleep(Duration(seconds: 1));
              break;
            }

            if (escolha == 1) {
                String login_adm = matricula;
              while (true) {
                print('-' * 40);
                sleep(Duration(seconds: 1));
                print('''Você deseja cadastrar um professor ou um aluno?
[ 1 ] - Professor
[ 2 ] - Aluno
[ 0 ] - Voltar''');
                int escolha = 0;
                while (true) {
                  stdout.write('Escolha: ');
                  escolha = int.parse(stdin.readLineSync()!);
                  if (escolha == 1 || escolha == 2 || escolha == 0)
                    break;
                  AnsiPen pen = new AnsiPen()..red();
                  print(pen('Escolha inválida!'));
                }

                print('-' * 40);

                if (escolha == 0)
                  break;

                sleep(Duration(seconds: 1));
                
                String tipoUsuario = '';
                if (escolha == 1)
                  tipoUsuario = 'PROFESSOR';
                else if (escolha == 2)
                  tipoUsuario = 'ALUNO';

                  //* Cadastrando Usuário:
                  stdout.write('Nome: ');
                  String nome = stdin.readLineSync()!.trim();

                  stdout.write('Matricula do IFPE: ');
                  String matricula = stdin.readLineSync()!.trim();

                  stdout.write('Senha: ');
                  String senha = stdin.readLineSync()!.trim();
              
                  stdout.write('Sala: ');
                  String id_sala = stdin.readLineSync()!.trim();

                  await conn.query(
                    'insert into usuario (login_adm, nome, matricula, senha, id_sala, tipo) values(?, ?, ?, ?, ?, ?)',
                    [login_adm, nome, matricula, senha, id_sala, tipoUsuario]);
                  sleep(Duration(seconds: 1));
                  AnsiPen pen = new AnsiPen()..green();
                  print(pen('Cadastro realizado com sucesso!'));
              }
            }

            else if (escolha == 2) {
              print('-' * 40);
              sleep(Duration(seconds: 1));
              stdout.write('Informe a matrícula do usuário: ');
              String matricula = stdin.readLineSync()!;

              //* Verificando se existe algum usuário com a matrícula informada:
              var results = await conn.query(
                'SELECT COUNT(*) FROM usuario WHERE matricula = ?', [matricula]
              );
              for (var row in results)
                quantidade = row[0];
              if (quantidade == 0) {
                AnsiPen pen = new AnsiPen()..red();
                print(pen('Não existe nenhum usuário cadastrado com essa matrícula!'));
                print('-' * 40);
              }
              else {
                //* Exclundio dados desse usuário na tabela ponto:
                await conn.query('DELETE FROM ponto WHERE matricula = ?', [matricula]);
                //* Excluindo dado da tabela:
                await conn.query('DELETE FROM usuario WHERE matricula = ?', [matricula]);
                sleep(Duration(seconds: 1));
                AnsiPen pen = new AnsiPen()..green();
                print(pen('Usuário descadastrado com sucesso!'));
                print('-' * 40);
              }
            }

            else if (escolha == 3) {
              sleep(Duration(seconds: 1));
              String space = ' ';
              AnsiPen pen = new AnsiPen()..xterm(004);
              print(pen('-' * 82));
              pen = new AnsiPen()..xterm(004);
              print(pen('DATA${space * 11}HORÁRIO${space * 8}NOME${space * 21}MATRÍCULA${space * 11}TIPO${space * 3}'));
              pen = new AnsiPen()..xterm(004);
              print(pen('-' * 82));
              var results = await conn.query('''select ponto.data, ponto.horario, usuario.nome, ponto.matricula, ponto.tipo
  FROM ponto INNER JOIN usuario on ponto.matricula = usuario.matricula ORDER BY ponto.data, nome, horario;''');
              for (dynamic row in results) {
                List data = ((row[0].toString().split(' '))[0]).split('-');
                String dataFormatada = data[2] + '/' + data[1] + '/' + data[0];
                String horario = (row[1].toString().split('.'))[0];
                String nome = row[2].toString();
                String matricula = row[3].toString();
                String tipo = row[4].toString();

                stdout.write('$dataFormatada${space * (15 - dataFormatada.length)}$horario${space * (15 - horario.length)}');
                print('$nome${space * (25 - nome.length)}$matricula${space * (20 - matricula.length)}$tipo${space * (7 - tipo.length)}');
              }
              pen = new AnsiPen()..xterm(004);
              print(pen('-' * 82));
            }
          }
        }
      }
      }
  }
  }
  pen = new AnsiPen()..green();
  print(pen('PROGRAMA FINALIZADO COM SUCESSO!'));
  await conn.close();
  }
