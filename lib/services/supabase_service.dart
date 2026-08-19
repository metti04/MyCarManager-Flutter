import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  SupabaseService._();

  static const String url = 'https://zvaddmvzsgakkkwyvocm.supabase.co';
  static const String anonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp2YWRkbXZ6c2dha2trd3l2b2NtIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODQ3MDM1MTAsImV4cCI6MjEwMDI3OTUxMH0.OleeaV0tF90PgOUUf1Tt8ui9sMP8SjhVtFAyIvmm6XM';

  static Future<void> init() async {
    await Supabase.initialize(url: url, anonKey: anonKey);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
