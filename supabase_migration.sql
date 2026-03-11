-- ============================================================
-- Voyager App - Complete Supabase Schema Migration
-- Run this ENTIRE script in the Supabase SQL Editor
-- (Dashboard → SQL Editor → New query → Paste → Run)
-- ============================================================

-- ─── STEP 0: DROP ALL EXISTING RLS POLICIES ─────────────────
-- Must happen BEFORE any column type changes, because PostgreSQL
-- refuses to alter a column type if a policy references it.
DO $$
DECLARE
  r RECORD;
BEGIN
  FOR r IN (
    SELECT schemaname, tablename, policyname
    FROM pg_policies
    WHERE schemaname = 'public'
      AND tablename IN ('users','tickets','swap_requests','tickets_history','rides','bookings')
  ) LOOP
  ON %I.%I', r.policyname, r.schemaname, r.tablename);
  END LOOP;
END $$;

-- ─── USERS TABLE ────────────────────────────────────────────
CREATE TABLE IF NOT EXISTS users (
  user_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  firebase_uid TEXT UNIQUE NOT NULL,
  email TEXT,
  full_name TEXT,
  roll_no TEXT,
  gender TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_users_firebase_uid ON users(firebase_uid);

-- FIX: Convert any enum-typed gender column in users to TEXT
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'users' AND column_name = 'gender'
      AND data_type = 'USER-DEFINED'
  ) THEN
    ALTER TABLE users ALTER COLUMN gender SET DATA TYPE TEXT USING gender::TEXT;
  END IF;
END $$;

DROP TYPE IF EXISTS gender_type CASCADE;

-- ─── TICKETS TABLE ──────────────────────────────────────────
CREATE TABLE IF NOT EXISTS tickets (
  ticket_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(user_id),
  trade_type TEXT NOT NULL, -- 'buy', 'sell', 'swap'
  status TEXT DEFAULT 'active', -- 'active', 'completed', 'cancelled'
  from_location TEXT,
  to_location TEXT,
  ride_date DATE,
  ride_time TEXT,
  price NUMERIC DEFAULT 0,
  description TEXT,
  ticket_image_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_tickets_user_id ON tickets(user_id);
CREATE INDEX IF NOT EXISTS idx_tickets_status ON tickets(status);

-- FIX: Convert any enum-typed status/trade_type columns in tickets to TEXT
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'tickets' AND column_name = 'status'
      AND data_type = 'USER-DEFINED'
  ) THEN
    ALTER TABLE tickets ALTER COLUMN status SET DATA TYPE TEXT USING status::TEXT;
    ALTER TABLE tickets ALTER COLUMN status SET DEFAULT 'active';
  END IF;
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'tickets' AND column_name = 'trade_type'
      AND data_type = 'USER-DEFINED'
  ) THEN
    ALTER TABLE tickets ALTER COLUMN trade_type SET DATA TYPE TEXT USING trade_type::TEXT;
  END IF;
END $$;

-- ─── SWAP REQUESTS TABLE ────────────────────────────────────
CREATE TABLE IF NOT EXISTS swap_requests (
  request_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ticket_id UUID REFERENCES tickets(ticket_id),
  ticket_owner_id UUID REFERENCES users(user_id),
  requested_by UUID REFERENCES users(user_id),
  status TEXT DEFAULT 'pending', -- 'pending', 'accepted', 'rejected'
  message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  responded_at TIMESTAMPTZ
);

CREATE INDEX IF NOT EXISTS idx_swap_requests_ticket_id ON swap_requests(ticket_id);
CREATE INDEX IF NOT EXISTS idx_swap_requests_owner ON swap_requests(ticket_owner_id);
CREATE INDEX IF NOT EXISTS idx_swap_requests_requester ON swap_requests(requested_by);

-- FIX: Convert any enum-typed status column in swap_requests to TEXT
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_name = 'swap_requests' AND column_name = 'status'
      AND data_type = 'USER-DEFINED'
  ) THEN
    ALTER TABLE swap_requests ALTER COLUMN status SET DATA TYPE TEXT USING status::TEXT;
    ALTER TABLE swap_requests ALTER COLUMN status SET DEFAULT 'pending';
  END IF;
END $$;

-- ─── TICKETS HISTORY TABLE ──────────────────────────────────
CREATE TABLE IF NOT EXISTS tickets_history (
  history_id BIGSERIAL PRIMARY KEY,
  ticket_id UUID,
  user_id UUID,
  trade_type TEXT,
  status TEXT,
  from_location TEXT,
  to_location TEXT,
  ride_date TEXT,
  ride_time TEXT,
  price NUMERIC,
  description TEXT,
  ticket_image_url TEXT,
  completed_by UUID,
  completed_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_tickets_history_user_id ON tickets_history(user_id);
CREATE INDEX IF NOT EXISTS idx_tickets_history_ticket_id ON tickets_history(ticket_id);

-- ─── RIDES TABLE (ride-sharing / carpool) ───────────────────
-- The original rides table was created with a different schema
-- (source_name, destination_name, ride_status enum, etc.)
-- that doesn't match the app's code. Drop and recreate cleanly.

-- First remove bookings (depends on rides via FK)
DROP TABLE IF EXISTS bookings CASCADE;
DROP TABLE IF EXISTS rides CASCADE;

CREATE TABLE rides (
  ride_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  posted_by UUID REFERENCES users(user_id),
  from_location TEXT NOT NULL,
  to_location TEXT NOT NULL,
  ride_date DATE NOT NULL,
  ride_time TEXT NOT NULL,
  available_seats INTEGER DEFAULT 1,
  price_per_seat NUMERIC DEFAULT 0,
  gender_preference TEXT DEFAULT 'any',
  status TEXT DEFAULT 'active', -- 'active', 'full', 'cancelled', 'completed'
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_rides_posted_by ON rides(posted_by);
CREATE INDEX IF NOT EXISTS idx_rides_status ON rides(status);

-- ─── BOOKINGS TABLE (ride booking requests) ─────────────────
-- Already dropped above (CASCADE from rides FK), recreate cleanly.
CREATE TABLE bookings (
  booking_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  ride_id UUID REFERENCES rides(ride_id) ON DELETE CASCADE,
  rider_id UUID REFERENCES users(user_id),
  seats_booked INTEGER DEFAULT 1,
  total_price NUMERIC DEFAULT 0,
  status TEXT DEFAULT 'pending', -- 'pending', 'confirmed', 'rejected', 'cancelled'
  created_at TIMESTAMPTZ DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_bookings_ride_id ON bookings(ride_id);
CREATE INDEX IF NOT EXISTS idx_bookings_rider_id ON bookings(rider_id);

-- ─── BOOKING APPROVALS TABLE (multi-party approval) ─────────
-- When someone requests to join a ride, ALL existing passengers
-- (including the poster) must approve before the booking is confirmed.
CREATE TABLE IF NOT EXISTS booking_approvals (
  approval_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  booking_id UUID REFERENCES bookings(booking_id) ON DELETE CASCADE,
  approver_id UUID REFERENCES users(user_id),
  status TEXT DEFAULT 'pending', -- 'pending', 'approved', 'rejected'
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ,
  UNIQUE(booking_id, approver_id)
);

CREATE INDEX IF NOT EXISTS idx_booking_approvals_booking_id ON booking_approvals(booking_id);
CREATE INDEX IF NOT EXISTS idx_booking_approvals_approver_id ON booking_approvals(approver_id);
CREATE INDEX IF NOT EXISTS idx_booking_approvals_status ON booking_approvals(status);

-- ─── ROW LEVEL SECURITY (RLS) ──────────────────────────────
-- Enable RLS on all tables but allow anon key full access
-- (since auth is handled by Firebase, not Supabase Auth)

ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE swap_requests ENABLE ROW LEVEL SECURITY;
ALTER TABLE tickets_history ENABLE ROW LEVEL SECURITY;
ALTER TABLE rides ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookings ENABLE ROW LEVEL SECURITY;
ALTER TABLE booking_approvals ENABLE ROW LEVEL SECURITY;

-- Allow full access for anon role (Firebase handles auth)
DO $$
DECLARE
  tbl TEXT;
BEGIN
  FOREACH tbl IN ARRAY ARRAY['users','tickets','swap_requests','tickets_history','rides','bookings','booking_approvals']
  LOOP
    -- Drop existing policy if any, then create fresh
    EXECUTE format('DROP POLICY IF EXISTS "Allow full access for anon" ON %I', tbl);
    EXECUTE format('
      CREATE POLICY "Allow full access for anon" ON %I
        FOR ALL
        TO anon
        USING (true)
        WITH CHECK (true);
    ', tbl);
  END LOOP;
END $$;

-- ─── ENABLE REALTIME ────────────────────────────────────────
-- Needed for Supabase .stream() to work
DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE rides;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE bookings;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE tickets;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE swap_requests;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

DO $$
BEGIN
  ALTER PUBLICATION supabase_realtime ADD TABLE tickets_history;
EXCEPTION WHEN duplicate_object THEN NULL;
END $$;

-- ─── CLEANUP: Drop stale enum types left from old schema ────
DROP TYPE IF EXISTS ride_status CASCADE;
DROP TYPE IF EXISTS booking_status CASCADE;
DROP TYPE IF EXISTS ticket_status CASCADE;
DROP TYPE IF EXISTS trade_type CASCADE;
DROP TYPE IF EXISTS swap_status CASCADE;
DROP TYPE IF EXISTS gender_preference CASCADE;

-- ============================================================
-- DONE! All tables are ready for the Voyager app.
-- ============================================================
