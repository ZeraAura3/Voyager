// lib/config/supabase_config.dart

/// Supabase Configuration
///
/// SETUP REQUIRED:
/// 1. Go to https://supabase.com and create a new project
/// 2. Get your project URL and anon key from Project Settings > API
/// 3. Replace the placeholder values below with your actual credentials
/// 4. Create the following tables in Supabase SQL Editor:
///
/// CREATE TABLE users_history (
///   id BIGSERIAL PRIMARY KEY,
///   user_id TEXT NOT NULL,
///   username TEXT,
///   email TEXT,
///   phone_number TEXT,
///   created_at TIMESTAMPTZ DEFAULT NOW()
/// );
///
/// CREATE TABLE tickets_history (
///   id BIGSERIAL PRIMARY KEY,
///   ticket_id TEXT NOT NULL,
///   user_id TEXT NOT NULL,
///   username TEXT,
///   phone_number TEXT,
///   trade_type TEXT,
///   status TEXT,
///   from_location TEXT,
///   to_location TEXT,
///   date TIMESTAMPTZ,
///   time TEXT,
///   price NUMERIC,
///   description TEXT,
///   ticket_image_url TEXT,
///   created_at TIMESTAMPTZ DEFAULT NOW(),
///   updated_at TIMESTAMPTZ,
///   completed_at TIMESTAMPTZ DEFAULT NOW()
/// );
///
/// -- Add indexes for better performance
/// CREATE INDEX idx_tickets_history_user_id ON tickets_history(user_id);
/// CREATE INDEX idx_tickets_history_ticket_id ON tickets_history(ticket_id);
/// CREATE INDEX idx_tickets_history_status ON tickets_history(status);

class SupabaseConfig {
  // TODO: Replace with your Supabase project URL
  static const String supabaseUrl = 'https://moiqelvqayexwabjazsx.supabase.co';

  // TODO: Replace with your Supabase anon/public key
  static const String supabaseAnonKey =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im1vaXFlbHZxYXlleHdhYmphenN4Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3Njk2MTU1NDUsImV4cCI6MjA4NTE5MTU0NX0.2AaGh8wCXtixZwy48WbCxy7udGDghNyVh40TZVJkzl0';

  /// Check if Supabase is properly configured
  static bool get isConfigured {
    return supabaseUrl != 'YOUR_SUPABASE_URL_HERE' &&
        supabaseAnonKey != 'YOUR_SUPABASE_ANON_KEY_HERE' &&
        supabaseUrl.isNotEmpty &&
        supabaseAnonKey.isNotEmpty;
  }
}
