-- ============================================================
-- MatchPoint — Complete Database Schema
-- Run this in Supabase SQL Editor (https://supabase.com/dashboard)
-- ============================================================

-- ────────────────────────────────────────────────────────────
-- 1. EXTENSIONS
-- ────────────────────────────────────────────────────────────

CREATE EXTENSION IF NOT EXISTS postgis;

-- ────────────────────────────────────────────────────────────
-- 2. TABLES
-- ────────────────────────────────────────────────────────────

-- Profiles (extends Supabase auth.users)
CREATE TABLE profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  username TEXT UNIQUE NOT NULL,
  avatar_url TEXT,
  location_text TEXT,
  latitude DOUBLE PRECISION,
  longitude DOUBLE PRECISION,
  geog GEOGRAPHY(POINT, 4326),
  sports TEXT[] DEFAULT '{}',
  available_now BOOLEAN DEFAULT false,
  respect_score INTEGER DEFAULT 50,
  hide_from_map BOOLEAN DEFAULT false,
  notifications_enabled BOOLEAN DEFAULT true,
  gps_enabled BOOLEAN DEFAULT true,
  last_active TIMESTAMPTZ DEFAULT NOW(),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Per-sport ELO ratings
CREATE TABLE sport_ratings (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  sport TEXT NOT NULL,
  rating INTEGER DEFAULT 1200,
  trend TEXT DEFAULT 'stable',
  UNIQUE(user_id, sport)
);

-- Geographic player clusters
CREATE TABLE play_zones (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  geog GEOGRAPHY(POINT, 4326),
  created_by UUID REFERENCES profiles(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Many-to-many: players ↔ zones
CREATE TABLE player_zones (
  player_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  zone_id UUID REFERENCES play_zones(id) ON DELETE CASCADE,
  is_home_zone BOOLEAN DEFAULT false,
  PRIMARY KEY (player_id, zone_id)
);

-- Playing venues/courts
CREATE TABLE courts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  name TEXT NOT NULL,
  sports TEXT[] DEFAULT '{}',
  location_name TEXT,
  image_url TEXT,
  latitude DOUBLE PRECISION NOT NULL,
  longitude DOUBLE PRECISION NOT NULL,
  geog GEOGRAPHY(POINT, 4326),
  zone_id UUID REFERENCES play_zones(id),
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Match lifecycle
CREATE TABLE matches (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  challenger_id UUID REFERENCES profiles(id) NOT NULL,
  opponent_id UUID REFERENCES profiles(id) NOT NULL,
  sport TEXT NOT NULL,
  court_id UUID REFERENCES courts(id),
  status TEXT NOT NULL DEFAULT 'pending',
  challenger_accepted BOOLEAN DEFAULT true,
  opponent_accepted BOOLEAN DEFAULT false,
  court_changed BOOLEAN DEFAULT false,
  score TEXT,
  result_for_challenger TEXT,
  logged_by UUID REFERENCES profiles(id),
  verified BOOLEAN DEFAULT false,
  disputed BOOLEAN DEFAULT false,
  dispute_reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Social feed posts
CREATE TABLE posts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  author_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  sport TEXT NOT NULL,
  content TEXT NOT NULL,
  image_url TEXT,
  tag TEXT DEFAULT 'general',
  likes_count INTEGER DEFAULT 0,
  comments_count INTEGER DEFAULT 0,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Post likes
CREATE TABLE post_likes (
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (user_id, post_id)
);

-- Post comments
CREATE TABLE post_comments (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  post_id UUID REFERENCES posts(id) ON DELETE CASCADE,
  author_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Chat threads (auto-created on match acceptance)
CREATE TABLE chat_threads (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  match_id UUID REFERENCES matches(id) ON DELETE CASCADE,
  player1_id UUID REFERENCES profiles(id) NOT NULL,
  player2_id UUID REFERENCES profiles(id) NOT NULL,
  last_message_text TEXT,
  last_message_time TIMESTAMPTZ,
  expires_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(match_id)
);

-- Chat messages (real-time via Supabase Realtime)
CREATE TABLE messages (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  thread_id UUID REFERENCES chat_threads(id) ON DELETE CASCADE,
  sender_id UUID REFERENCES profiles(id) NOT NULL,
  content TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Player following
CREATE TABLE follows (
  follower_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  following_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (follower_id, following_id)
);

-- User reports
CREATE TABLE reports (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  reporter_id UUID REFERENCES profiles(id),
  reported_id UUID REFERENCES profiles(id),
  reason TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- User blocks
CREATE TABLE blocks (
  blocker_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  blocked_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (blocker_id, blocked_id)
);

-- Thread read tracking (for unread dots)
CREATE TABLE thread_reads (
  thread_id UUID REFERENCES chat_threads(id) ON DELETE CASCADE,
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  last_read_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (thread_id, user_id)
);

-- ────────────────────────────────────────────────────────────
-- 3. INDEXES (performance)
-- ────────────────────────────────────────────────────────────

CREATE INDEX idx_profiles_geog ON profiles USING GIST (geog);
CREATE INDEX idx_profiles_available ON profiles (available_now) WHERE available_now = true;
CREATE INDEX idx_profiles_sports ON profiles USING GIN (sports);
CREATE INDEX idx_courts_geog ON courts USING GIST (geog);
CREATE INDEX idx_courts_sports ON courts USING GIN (sports);
CREATE INDEX idx_matches_challenger ON matches (challenger_id);
CREATE INDEX idx_matches_opponent ON matches (opponent_id);
CREATE INDEX idx_matches_status ON matches (status);
CREATE INDEX idx_posts_sport ON posts (sport);
CREATE INDEX idx_posts_created ON posts (created_at DESC);
CREATE INDEX idx_messages_thread ON messages (thread_id, created_at);
CREATE INDEX idx_chat_threads_players ON chat_threads (player1_id, player2_id);

-- ────────────────────────────────────────────────────────────
-- 4. ROW LEVEL SECURITY (RLS)
-- ────────────────────────────────────────────────────────────

-- Profiles: anyone can read, only owner can update/insert
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public profiles are viewable by everyone"
  ON profiles FOR SELECT USING (true);
CREATE POLICY "Users can insert their own profile"
  ON profiles FOR INSERT WITH CHECK (auth.uid() = id);
CREATE POLICY "Users can update own profile"
  ON profiles FOR UPDATE USING (auth.uid() = id);

-- Sport Ratings: public read, owner write
ALTER TABLE sport_ratings ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public ratings"
  ON sport_ratings FOR SELECT USING (true);
CREATE POLICY "Users can insert own ratings"
  ON sport_ratings FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update own ratings"
  ON sport_ratings FOR UPDATE USING (auth.uid() = user_id);

-- Play Zones: public read
ALTER TABLE play_zones ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public zones"
  ON play_zones FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create zones"
  ON play_zones FOR INSERT WITH CHECK (auth.uid() = created_by);

-- Player Zones: public read, own write
ALTER TABLE player_zones ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public player zones"
  ON player_zones FOR SELECT USING (true);
CREATE POLICY "Users can join zones"
  ON player_zones FOR INSERT WITH CHECK (auth.uid() = player_id);
CREATE POLICY "Users can leave zones"
  ON player_zones FOR DELETE USING (auth.uid() = player_id);

-- Courts: public read
ALTER TABLE courts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public courts"
  ON courts FOR SELECT USING (true);
CREATE POLICY "Authenticated users can add courts"
  ON courts FOR INSERT WITH CHECK (auth.uid() IS NOT NULL);

-- Matches: only participants can see/modify
ALTER TABLE matches ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Match participants can view"
  ON matches FOR SELECT
  USING (auth.uid() IN (challenger_id, opponent_id));
CREATE POLICY "Authenticated users can create matches"
  ON matches FOR INSERT
  WITH CHECK (auth.uid() = challenger_id);
CREATE POLICY "Match participants can update"
  ON matches FOR UPDATE
  USING (auth.uid() IN (challenger_id, opponent_id));

-- Posts: public read, own write/delete
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public posts"
  ON posts FOR SELECT USING (true);
CREATE POLICY "Authenticated users can create posts"
  ON posts FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Users can update own posts"
  ON posts FOR UPDATE USING (auth.uid() = author_id);
CREATE POLICY "Users can delete own posts"
  ON posts FOR DELETE USING (auth.uid() = author_id);

-- Post Likes: public read, own write
ALTER TABLE post_likes ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public likes"
  ON post_likes FOR SELECT USING (true);
CREATE POLICY "Users can like posts"
  ON post_likes FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can unlike posts"
  ON post_likes FOR DELETE USING (auth.uid() = user_id);

-- Post Comments: public read, own write
ALTER TABLE post_comments ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public comments"
  ON post_comments FOR SELECT USING (true);
CREATE POLICY "Authenticated users can comment"
  ON post_comments FOR INSERT WITH CHECK (auth.uid() = author_id);
CREATE POLICY "Users can delete own comments"
  ON post_comments FOR DELETE USING (auth.uid() = author_id);

-- Chat Threads: only participants
ALTER TABLE chat_threads ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Thread participants can view"
  ON chat_threads FOR SELECT
  USING (auth.uid() IN (player1_id, player2_id));
CREATE POLICY "System can create threads"
  ON chat_threads FOR INSERT
  WITH CHECK (auth.uid() IN (player1_id, player2_id));

-- Messages: only thread participants
ALTER TABLE messages ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Thread participants can view messages"
  ON messages FOR SELECT
  USING (EXISTS (
    SELECT 1 FROM chat_threads
    WHERE chat_threads.id = messages.thread_id
    AND auth.uid() IN (chat_threads.player1_id, chat_threads.player2_id)
  ));
CREATE POLICY "Thread participants can send messages"
  ON messages FOR INSERT
  WITH CHECK (
    auth.uid() = sender_id
    AND EXISTS (
      SELECT 1 FROM chat_threads
      WHERE chat_threads.id = thread_id
      AND auth.uid() IN (chat_threads.player1_id, chat_threads.player2_id)
    )
  );

-- Follows: public read, own write
ALTER TABLE follows ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Public follows"
  ON follows FOR SELECT USING (true);
CREATE POLICY "Users can follow"
  ON follows FOR INSERT WITH CHECK (auth.uid() = follower_id);
CREATE POLICY "Users can unfollow"
  ON follows FOR DELETE USING (auth.uid() = follower_id);

-- Reports: only reporter can see own, anyone can create
ALTER TABLE reports ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own reports"
  ON reports FOR SELECT USING (auth.uid() = reporter_id);
CREATE POLICY "Authenticated users can report"
  ON reports FOR INSERT WITH CHECK (auth.uid() = reporter_id);

-- Blocks: only blocker can see/manage
ALTER TABLE blocks ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own blocks"
  ON blocks FOR SELECT USING (auth.uid() = blocker_id);
CREATE POLICY "Users can block"
  ON blocks FOR INSERT WITH CHECK (auth.uid() = blocker_id);
CREATE POLICY "Users can unblock"
  ON blocks FOR DELETE USING (auth.uid() = blocker_id);

-- Thread Reads: own read tracking
ALTER TABLE thread_reads ENABLE ROW LEVEL SECURITY;
CREATE POLICY "Users can view own reads"
  ON thread_reads FOR SELECT USING (auth.uid() = user_id);
CREATE POLICY "Users can mark read"
  ON thread_reads FOR INSERT WITH CHECK (auth.uid() = user_id);
CREATE POLICY "Users can update read time"
  ON thread_reads FOR UPDATE USING (auth.uid() = user_id);

-- ────────────────────────────────────────────────────────────
-- 5. FUNCTIONS
-- ────────────────────────────────────────────────────────────

-- Find players within X km of a point (uses PostGIS)
CREATE OR REPLACE FUNCTION nearby_players(
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  radius_km INTEGER DEFAULT 50
)
RETURNS SETOF profiles AS $$
  SELECT * FROM profiles
  WHERE hide_from_map = false
    AND geog IS NOT NULL
    AND ST_DWithin(
      geog,
      ST_MakePoint(lng, lat)::geography,
      radius_km * 1000
    )
  ORDER BY geog <-> ST_MakePoint(lng, lat)::geography;
$$ LANGUAGE sql SECURITY DEFINER;

-- Find courts within X km of a point
CREATE OR REPLACE FUNCTION nearby_courts(
  lat DOUBLE PRECISION,
  lng DOUBLE PRECISION,
  radius_km INTEGER DEFAULT 50
)
RETURNS SETOF courts AS $$
  SELECT * FROM courts
  WHERE geog IS NOT NULL
    AND ST_DWithin(
      geog,
      ST_MakePoint(lng, lat)::geography,
      radius_km * 1000
    )
  ORDER BY geog <-> ST_MakePoint(lng, lat)::geography;
$$ LANGUAGE sql SECURITY DEFINER;

-- Auto-update geog column when lat/lng changes on profiles
CREATE OR REPLACE FUNCTION update_profile_geog()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.latitude IS NOT NULL AND NEW.longitude IS NOT NULL THEN
    NEW.geog := ST_MakePoint(NEW.longitude, NEW.latitude)::geography;
  END IF;
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_profile_geog
  BEFORE INSERT OR UPDATE OF latitude, longitude ON profiles
  FOR EACH ROW
  EXECUTE FUNCTION update_profile_geog();

-- Auto-update geog on courts
CREATE OR REPLACE FUNCTION update_court_geog()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.latitude IS NOT NULL AND NEW.longitude IS NOT NULL THEN
    NEW.geog := ST_MakePoint(NEW.longitude, NEW.latitude)::geography;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_court_geog
  BEFORE INSERT OR UPDATE OF latitude, longitude ON courts
  FOR EACH ROW
  EXECUTE FUNCTION update_court_geog();

-- Auto-update geog on play_zones
CREATE OR REPLACE FUNCTION update_zone_geog()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.latitude IS NOT NULL AND NEW.longitude IS NOT NULL THEN
    NEW.geog := ST_MakePoint(NEW.longitude, NEW.latitude)::geography;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_update_zone_geog
  BEFORE INSERT OR UPDATE OF latitude, longitude ON play_zones
  FOR EACH ROW
  EXECUTE FUNCTION update_zone_geog();

-- ────────────────────────────────────────────────────────────
-- 6. MATCH LIFECYCLE TRIGGERS
-- ────────────────────────────────────────────────────────────

-- Auto-create chat thread when both players accept a match
CREATE OR REPLACE FUNCTION create_chat_on_match_accept()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.opponent_accepted = true AND NEW.challenger_accepted = true THEN
    INSERT INTO chat_threads (match_id, player1_id, player2_id)
    VALUES (NEW.id, NEW.challenger_id, NEW.opponent_id)
    ON CONFLICT (match_id) DO NOTHING;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_match_accepted
  AFTER UPDATE ON matches
  FOR EACH ROW
  WHEN (NEW.opponent_accepted = true AND NEW.challenger_accepted = true)
  EXECUTE FUNCTION create_chat_on_match_accept();

-- Auto-expire chat 24h after match verification
CREATE OR REPLACE FUNCTION set_chat_expiry()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.verified = true AND (OLD.verified = false OR OLD.verified IS NULL) THEN
    UPDATE chat_threads
    SET expires_at = NOW() + INTERVAL '24 hours'
    WHERE match_id = NEW.id;
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_match_verified_expiry
  AFTER UPDATE ON matches
  FOR EACH ROW
  WHEN (NEW.verified = true)
  EXECUTE FUNCTION set_chat_expiry();

-- ELO rating update on match verification
CREATE OR REPLACE FUNCTION update_ratings_on_verify()
RETURNS TRIGGER AS $$
DECLARE
  k_factor INTEGER := 32;
  winner_rating INTEGER;
  loser_rating INTEGER;
  expected_winner DOUBLE PRECISION;
  winner_id UUID;
  loser_id UUID;
BEGIN
  IF NEW.verified = true AND (OLD.verified = false OR OLD.verified IS NULL) THEN
    -- Determine winner/loser
    IF NEW.result_for_challenger = 'win' THEN
      winner_id := NEW.challenger_id;
      loser_id := NEW.opponent_id;
    ELSE
      winner_id := NEW.opponent_id;
      loser_id := NEW.challenger_id;
    END IF;

    -- Get current ratings (default 1200 if not found)
    SELECT COALESCE(rating, 1200) INTO winner_rating FROM sport_ratings
      WHERE user_id = winner_id AND sport = NEW.sport;
    IF NOT FOUND THEN winner_rating := 1200; END IF;

    SELECT COALESCE(rating, 1200) INTO loser_rating FROM sport_ratings
      WHERE user_id = loser_id AND sport = NEW.sport;
    IF NOT FOUND THEN loser_rating := 1200; END IF;

    -- ELO calculation
    expected_winner := 1.0 / (1.0 + POWER(10, (loser_rating - winner_rating)::DOUBLE PRECISION / 400));

    -- Upsert winner rating
    INSERT INTO sport_ratings (user_id, sport, rating, trend)
    VALUES (winner_id, NEW.sport, 1200 + (k_factor * (1 - expected_winner))::INTEGER, 'up')
    ON CONFLICT (user_id, sport) DO UPDATE
    SET rating = sport_ratings.rating + (k_factor * (1 - expected_winner))::INTEGER,
        trend = 'up';

    -- Upsert loser rating
    INSERT INTO sport_ratings (user_id, sport, rating, trend)
    VALUES (loser_id, NEW.sport, 1200 - (k_factor * expected_winner)::INTEGER, 'down')
    ON CONFLICT (user_id, sport) DO UPDATE
    SET rating = sport_ratings.rating - (k_factor * expected_winner)::INTEGER,
        trend = 'down';
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_verify_rating_update
  AFTER UPDATE ON matches
  FOR EACH ROW
  WHEN (NEW.verified = true)
  EXECUTE FUNCTION update_ratings_on_verify();

-- Update last_message on chat_threads when a new message is sent
CREATE OR REPLACE FUNCTION update_thread_last_message()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE chat_threads
  SET last_message_text = NEW.content,
      last_message_time = NEW.created_at
  WHERE id = NEW.thread_id;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER trigger_update_thread_last_message
  AFTER INSERT ON messages
  FOR EACH ROW
  EXECUTE FUNCTION update_thread_last_message();

-- Update match timestamps on any change
CREATE OR REPLACE FUNCTION update_match_timestamp()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trigger_match_updated
  BEFORE UPDATE ON matches
  FOR EACH ROW
  EXECUTE FUNCTION update_match_timestamp();

-- ────────────────────────────────────────────────────────────
-- 7. AUTO-CREATE PROFILE ON SIGNUP
-- ────────────────────────────────────────────────────────────

-- This function is called by a Supabase Auth trigger
-- when a new user signs up. It creates a profile row.
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, username, avatar_url)
  VALUES (
    NEW.id,
    COALESCE(NEW.raw_user_meta_data->>'username', 'user_' || LEFT(NEW.id::TEXT, 8)),
    NEW.raw_user_meta_data->>'avatar_url'
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW
  EXECUTE FUNCTION handle_new_user();

-- ────────────────────────────────────────────────────────────
-- 8. STORAGE BUCKETS
-- ────────────────────────────────────────────────────────────

-- Create storage buckets for user uploads
INSERT INTO storage.buckets (id, name, public)
VALUES ('avatars', 'avatars', true);

INSERT INTO storage.buckets (id, name, public)
VALUES ('post-images', 'post-images', true);

-- Storage policies: authenticated users can upload, public can view
CREATE POLICY "Public avatar access"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'avatars');

CREATE POLICY "Users can upload avatars"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'avatars' AND auth.uid() IS NOT NULL);

CREATE POLICY "Users can update own avatar"
  ON storage.objects FOR UPDATE
  USING (bucket_id = 'avatars' AND auth.uid()::text = (storage.foldername(name))[1]);

CREATE POLICY "Public post image access"
  ON storage.objects FOR SELECT
  USING (bucket_id = 'post-images');

CREATE POLICY "Users can upload post images"
  ON storage.objects FOR INSERT
  WITH CHECK (bucket_id = 'post-images' AND auth.uid() IS NOT NULL);

-- ────────────────────────────────────────────────────────────
-- 9. ENABLE REALTIME
-- ────────────────────────────────────────────────────────────

-- Enable realtime on tables that need live updates
ALTER PUBLICATION supabase_realtime ADD TABLE messages;
ALTER PUBLICATION supabase_realtime ADD TABLE matches;
ALTER PUBLICATION supabase_realtime ADD TABLE profiles;
