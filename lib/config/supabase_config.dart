// lib/config/supabase_config.dart

/// Supabase Configuration
///
/// SETUP REQUIRED:
/// 1. Go to https://supabase.com and create a new project
/// 2. Get your project URL and anon key from Project Settings > API
/// 3. Replace the placeholder values below with your actual credentials
/// 4. Run the SQL migration in Supabase SQL Editor:
///    - Open supabase_migration.sql from the project root
///    - Copy the entire contents
///    - Paste into Supabase Dashboard → SQL Editor → New query → Run
///
/// Tables created by the migration:
///   - users (user_id, firebase_uid, email, full_name, roll_no, gender)
///   - tickets (ticket_id, user_id, trade_type, status, locations, date, time, price, etc.)
///   - swap_requests (request_id, ticket_id, ticket_owner_id, requested_by, status, message)
///   - tickets_history (history_id, ticket_id, user_id, trade_type, status, locations, etc.)
///   - rides (ride_id, posted_by, locations, date, time, available_seats, price_per_seat, gender_preference, status)
///   - bookings (booking_id, ride_id, rider_id, seats_booked, total_price, status)

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
