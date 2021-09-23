import 'package:mysql1/mysql1.dart';
import 'dart:io';


Future main() async {
  final conn = await MySqlConnection.connect(ConnectionSettings(
    host: 'localhost',
    port: 3306,
    user: 'root',
    db: 'cpifpe',
    password: 'root000'));
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

  print('----- BEM VINDO AO CENTRO DE PESQUISA -----');

  print('''O que você deseja fazer?
[ 1 ] - Realizar Login
[ 2 ] - Realizar Cadastro (Apenas administradores)
[ 0 ] - Sair do Programa''');
  stdout.write('> ');
  int escolha = int.parse(stdin.readLineSync()!);
  
  //! Cadastro Administrador
  if (escolha == 2) {
    print('-' * 40);

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
    print('Cadastro realizado com sucesso!');
  }

  //! Realizar Login
  else if (escolha == 1) {
    print('''Você deseja realizar login como Administrador ou Professor/Aluno?
[ 1 ] - Administrador
[ 2 ] - Professor/Aluno
[ 0 ] - Voltar''');

    while (true) {
      stdout.write('> ');
      escolha = int.parse(stdin.readLineSync()!);
      if (escolha == 1 || escolha == 2 || escolha == 0)
        break;
      print('Escolha inválida!');
    }

    //? Login:
    stdout.write('Sua matrícula do IFPE: ');
    String matricula = stdin.readLineSync()!.trim();
    stdout.write('Senha: ');
    String senha = stdin.readLineSync()!.trim();

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

    if (quantidade == 0)
      print('Não existe nenhum usuário cadastrado no Centro de Pesquisa com esse login!');
    
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

      if (senhaCadastrada != senha)
        print('Senha incorreta!');
      
      else {
        print('Login realizado com sucesso!');

        //! BATER PONTO
        if (escolha == 2) {
          print('''O que você deseja fazer?
[ 1 ] - Registrar Entrada
[ 2 ] - Registrar Saída
[ 0 ] - Voltar''');
          stdout.write('> ');
          int escolha = int.parse(stdin.readLineSync()!);
          
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
            String segundo = DateTime.now().minute.toString();
            String horario = hora + ':' + minuto + ':' + segundo;
            
            //* Inserindo dados na tabela ponto
            var result = await conn.query(
              'insert into ponto (data, horario, matricula, tipo) values (?, ?, ?, ?)',
              [data, horario, matricula, tipoPonto]);
            print('Inserted row id=${result.insertId}');
          }
        }

        if (escolha == 1) {
          print('''O que você deseja fazer? 
[ 1 ] - Cadastrar Usuário
[ 2 ] - Descadastrar Usuário
[ 3 ] - Visualizar Histórico de Entradas e Saídas
[ 0 ] - Sair da conta''');
        }
        stdout.write('> ');
        escolha = int.parse(stdin.readLineSync()!);

          if (escolha == 1) {
            String login_adm = matricula;
            print('''Você deseja cadastrar um professor ou um aluno?
[ 1 ] - Professor
[ 2 ] - Aluno
[ 0 ] - Voltar''');
            stdout.write('> ');
            escolha = int.parse(stdin.readLineSync()!);

            String tipoUsuario = '';
            if (escolha == 1)
              tipoUsuario = 'PROFESSOR';
            else if (escolha == 2)
              tipoUsuario = 'ALUNO';

              //* Cadastrando Usuário:
              stdout.write('Nome: ');
              String nome = stdin.readLineSync()!.trim();

              stdout.write('Matricula do IFPE: ');
              matricula = stdin.readLineSync()!.trim();

              stdout.write('Senha: ');
              senha = stdin.readLineSync()!.trim();
          
              stdout.write('Sala: ');
              String id_sala = stdin.readLineSync()!.trim();

              await conn.query(
                'insert into usuario (login_adm, nome, matricula, senha, id_sala, tipo) values(?, ?, ?, ?, ?, ?)',
                [login_adm, nome, matricula, senha, id_sala, tipoUsuario]);
              print('Cadastro realizado com sucesso!');
        }

          else if (escolha == 2) {
            stdout.write('Informe a matrícula do usuário: ');
            String matricula = stdin.readLineSync()!;

            //* Verificando se existe algum usuário com a matrícula informada:
            var results = await conn.query(
              'SELECT COUNT(*) FROM usuario WHERE matricula = ?', [matricula]
            );
            for (var row in results)
              quantidade = row[0];

            //* Excluindo dado da tabela:
            await conn.query('DELETE FROM usuario WHERE matricula = ?', [matricula]);
            print('Usuário descadastrado com sucesso!');
          }

          else if (escolha == 3) {
            String space = ' ';
            print('-' * 79);
            print('DATA${space * 8}HORÁRIO${space * 8}NOME${space * 21}MATRÍCULA${space * 11}TIPO${space * 3}');
            print('-' * 79);
            var results = await conn.query('SELECT * FROM ponto ORDER BY tipo');
            print(results);            
          }
      }
      }
    }
  print('PROGRAMA FINALIZADO COM SUCESSO!');
  await conn.close();
  }
