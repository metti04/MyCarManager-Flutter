class Utente {
  final String username;
  final String password;
  final String email;
  final String nome;
  final String cognome;
  final DateTime dataDiNascita;

  const Utente({
    required this.username,
    required this.password,
    required this.email,
    required this.nome,
    required this.cognome,
    required this.dataDiNascita,
  });

  factory Utente.fromJson(Map<String, dynamic> json) {
    return Utente(
      username: json['username'] as String,
      password: json['password'] as String,
      email: json['email'] as String,
      nome: json['nome'] as String,
      cognome: json['cognome'] as String,
      dataDiNascita: DateTime.parse(json['dataDiNascita'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'email': email,
      'nome': nome,
      'cognome': cognome,
      'dataDiNascita': dataDiNascita.toIso8601String().split('T').first,
    };
  }
}
