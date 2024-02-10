class HttpHeaders {
  final String apiKey;

  HttpHeaders({required this.apiKey});

  Map<String, String> get defaultHeaders => {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      };
}
