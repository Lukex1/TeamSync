-- Location: supabase/migrations/20250916183625_teamsync_complete_system.sql
-- Schema Analysis: Fresh project - no existing schema
-- Integration Type: Complete new system
-- Module: Team and Event Management System

-- 1. Types and Enums
CREATE TYPE public.user_role AS ENUM ('admin', 'manager', 'member');
CREATE TYPE public.event_status AS ENUM ('draft', 'published', 'cancelled', 'completed');
CREATE TYPE public.attendance_status AS ENUM ('pending', 'going', 'maybe', 'not_going');
CREATE TYPE public.invitation_status AS ENUM ('pending', 'accepted', 'declined');

CREATE TABLE public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id),
    email TEXT NOT NULL UNIQUE,
    full_name TEXT NOT NULL,
    role public.user_role DEFAULT 'member'::public.user_role,
    avatar_url TEXT,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Teams table
CREATE TABLE public.teams (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name TEXT NOT NULL,
    description TEXT,
    invitation_code TEXT NOT NULL UNIQUE,
    owner_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    is_active BOOLEAN DEFAULT true,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- Team memberships junction table
CREATE TABLE public.team_members (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    role public.user_role DEFAULT 'member'::public.user_role,
    invitation_status public.invitation_status DEFAULT 'accepted'::public.invitation_status,
    joined_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(team_id, user_id)
);

-- Events table
CREATE TABLE public.events (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    title TEXT NOT NULL,
    description TEXT,
    location TEXT,
    event_date TIMESTAMPTZ NOT NULL,
    duration_minutes INTEGER DEFAULT 60,
    event_status public.event_status DEFAULT 'draft'::public.event_status,
    creator_id UUID REFERENCES public.user_profiles(id) ON DELETE SET NULL,
    team_id UUID REFERENCES public.teams(id) ON DELETE CASCADE,
    max_participants INTEGER,
    is_recurring BOOLEAN DEFAULT false,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    event_color bigint,
    reminder_time text
);

-- Event attendance tracking
CREATE TABLE public.event_attendees (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES public.events(id) ON DELETE CASCADE,
    user_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    attendance_status public.attendance_status DEFAULT 'pending'::public.attendance_status,
    response_date TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    notes TEXT,
    UNIQUE(event_id, user_id)
);

-- Event comments
CREATE TABLE public.event_comments (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    event_id UUID REFERENCES public.events(id) ON DELETE CASCADE,
    author_id UUID REFERENCES public.user_profiles(id) ON DELETE CASCADE,
    content TEXT NOT NULL,
    created_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMPTZ DEFAULT CURRENT_TIMESTAMP
);

-- 3. Essential Indexes
CREATE INDEX idx_user_profiles_email ON public.user_profiles(email);
CREATE INDEX idx_teams_invitation_code ON public.teams(invitation_code);
CREATE INDEX idx_teams_owner_id ON public.teams(owner_id);
CREATE INDEX idx_team_members_team_id ON public.team_members(team_id);
CREATE INDEX idx_team_members_user_id ON public.team_members(user_id);
CREATE INDEX idx_events_team_id ON public.events(team_id);
CREATE INDEX idx_events_creator_id ON public.events(creator_id);
CREATE INDEX idx_events_event_date ON public.events(event_date);
CREATE INDEX idx_event_attendees_event_id ON public.event_attendees(event_id);
CREATE INDEX idx_event_attendees_user_id ON public.event_attendees(user_id);
CREATE INDEX idx_event_comments_event_id ON public.event_comments(event_id);
CREATE INDEX idx_event_comments_author_id ON public.event_comments(author_id);

-- 4. Functions (MUST BE BEFORE RLS POLICIES)
-- Function to generate unique invitation codes
CREATE OR REPLACE FUNCTION public.generate_invitation_code()
RETURNS TEXT
LANGUAGE plpgsql
SECURITY DEFINER
AS $func$
DECLARE
    code TEXT;
BEGIN
    LOOP
        code := LPAD(FLOOR(RANDOM() * 100000000)::TEXT, 8, '0');
        IF NOT EXISTS (SELECT 1 FROM public.teams WHERE invitation_code = code) THEN
            RETURN code;
        END IF;
    END LOOP;
END;
$func$;

-- Function to check team membership
CREATE OR REPLACE FUNCTION public.is_team_member(team_uuid UUID)
RETURNS BOOLEAN
LANGUAGE sql
STABLE
SECURITY DEFINER
AS $func$
SELECT EXISTS (
    SELECT 1 FROM public.team_members tm
    WHERE tm.team_id = team_uuid 
    AND tm.user_id = auth.uid()
    AND tm.invitation_status = 'accepted'::public.invitation_status
)
$func$;

-- Function to handle new user creation
CREATE OR REPLACE FUNCTION public.handle_new_user()
RETURNS TRIGGER
SECURITY DEFINER
LANGUAGE plpgsql
AS $func$
BEGIN
  INSERT INTO public.user_profiles (id, email, full_name, role)
  VALUES (
    NEW.id, 
    NEW.email, 
    COALESCE(NEW.raw_user_meta_data->>'full_name', split_part(NEW.email, '@', 1)),
    COALESCE(NEW.raw_user_meta_data->>'role', 'member')::public.user_role
  );
  RETURN NEW;
END;
$func$;

-- 5. Enable RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.teams ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.team_members ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.events ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_attendees ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.event_comments ENABLE ROW LEVEL SECURITY;

-- 6. RLS Policies (Functions are now created above)
-- Pattern 1: Core user table - Simple ownership only
CREATE POLICY "users_manage_own_user_profiles"
ON public.user_profiles
FOR ALL
TO authenticated
USING (id = auth.uid())
WITH CHECK (id = auth.uid());

-- Pattern 2: Simple user ownership for teams
CREATE POLICY "users_manage_own_teams"
ON public.teams
FOR ALL
TO authenticated
USING (owner_id = auth.uid())
WITH CHECK (owner_id = auth.uid());

-- Pattern 2: Team members - users can see members of their teams
CREATE POLICY "team_members_visibility"
ON public.team_members
FOR SELECT
TO authenticated
USING (public.is_team_member(team_id) OR user_id = auth.uid());

CREATE POLICY "team_members_manage_own"
ON public.team_members
FOR INSERT
TO authenticated
WITH CHECK (user_id = auth.uid());

CREATE POLICY "team_members_update_own"
ON public.team_members
FOR UPDATE
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

CREATE POLICY "team_owners_manage_members"
ON public.team_members
FOR ALL
TO authenticated
USING (
    EXISTS (
        SELECT 1 FROM public.teams t
        WHERE t.id = team_id AND t.owner_id = auth.uid()
    )
);

-- Events policies - team members can see team events
CREATE POLICY "team_events_visibility"
ON public.events
FOR SELECT
TO authenticated
USING (public.is_team_member(team_id));

CREATE POLICY "users_manage_own_events"
ON public.events
FOR ALL
TO authenticated
USING (creator_id = auth.uid())
WITH CHECK (creator_id = auth.uid());

-- Event attendees policies
CREATE POLICY "attendees_visibility"
ON public.event_attendees
FOR SELECT
TO authenticated
USING (
    public.is_team_member((SELECT team_id FROM public.events WHERE id = event_id))
);

CREATE POLICY "users_manage_own_attendance"
ON public.event_attendees
FOR ALL
TO authenticated
USING (user_id = auth.uid())
WITH CHECK (user_id = auth.uid());

-- Event comments policies
CREATE POLICY "comments_visibility"
ON public.event_comments
FOR SELECT
TO authenticated
USING (
    public.is_team_member((SELECT team_id FROM public.events WHERE id = event_id))
);

CREATE POLICY "users_manage_own_comments"
ON public.event_comments
FOR ALL
TO authenticated
USING (author_id = auth.uid())
WITH CHECK (author_id = auth.uid());

-- 7. Triggers
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Trigger to auto-generate invitation codes
CREATE OR REPLACE FUNCTION public.set_invitation_code()
RETURNS TRIGGER
LANGUAGE plpgsql
AS $func$
BEGIN
    IF NEW.invitation_code IS NULL OR NEW.invitation_code = '' THEN
        NEW.invitation_code := public.generate_invitation_code();
    END IF;
    RETURN NEW;
END;
$func$;

CREATE TRIGGER set_team_invitation_code
  BEFORE INSERT ON public.teams
  FOR EACH ROW EXECUTE FUNCTION public.set_invitation_code();

-- 8. Mock Data with Complete Auth Users
DO $$
DECLARE
    admin_uuid UUID := gen_random_uuid();
    manager_uuid UUID := gen_random_uuid();
    member_uuid UUID := gen_random_uuid();
    team1_uuid UUID := gen_random_uuid();
    team2_uuid UUID := gen_random_uuid();
    event1_uuid UUID := gen_random_uuid();
    event2_uuid UUID := gen_random_uuid();
BEGIN
    -- Create complete auth users with all required fields
    INSERT INTO auth.users (
        id, instance_id, aud, role, email, encrypted_password, email_confirmed_at,
        created_at, updated_at, raw_user_meta_data, raw_app_meta_data,
        is_sso_user, is_anonymous, confirmation_token, confirmation_sent_at,
        recovery_token, recovery_sent_at, email_change_token_new, email_change,
        email_change_sent_at, email_change_token_current, email_change_confirm_status,
        reauthentication_token, reauthentication_sent_at, phone, phone_change,
        phone_change_token, phone_change_sent_at
    ) VALUES
        (admin_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'admin@teamsync.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Sarah Admin", "role": "admin"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (manager_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'manager@teamsync.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "John Manager", "role": "manager"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null),
        (member_uuid, '00000000-0000-0000-0000-000000000000', 'authenticated', 'authenticated',
         'member@teamsync.com', crypt('password123', gen_salt('bf', 10)), now(), now(), now(),
         '{"full_name": "Alice Member", "role": "member"}'::jsonb, '{"provider": "email", "providers": ["email"]}'::jsonb,
         false, false, '', null, '', null, '', '', null, '', 0, '', null, null, '', '', null);

    -- Create teams
    INSERT INTO public.teams (id, name, description, invitation_code, owner_id) VALUES
        (team1_uuid, 'Development Team', 'Frontend and backend development coordination', '12345678', admin_uuid),
        (team2_uuid, 'Marketing Team', 'Content creation and campaign management', '87654321', manager_uuid);

    -- Add team members
    INSERT INTO public.team_members (team_id, user_id, role, invitation_status) VALUES
        (team1_uuid, admin_uuid, 'admin'::public.user_role, 'accepted'::public.invitation_status),
        (team1_uuid, manager_uuid, 'manager'::public.user_role, 'accepted'::public.invitation_status),
        (team1_uuid, member_uuid, 'member'::public.user_role, 'accepted'::public.invitation_status),
        (team2_uuid, manager_uuid, 'admin'::public.user_role, 'accepted'::public.invitation_status),
        (team2_uuid, member_uuid, 'member'::public.user_role, 'accepted'::public.invitation_status);

    -- Create events
    INSERT INTO public.events (id, title, description, location, event_date, creator_id, team_id, event_status) VALUES
        (event1_uuid, 'Weekly Sprint Planning', 'Plan tasks and goals for the upcoming sprint', 'Conference Room A', 
         CURRENT_TIMESTAMP + INTERVAL '1 day', admin_uuid, team1_uuid, 'published'::public.event_status),
        (event2_uuid, 'Content Review Session', 'Review and approve upcoming marketing materials', 'Virtual Meeting', 
         CURRENT_TIMESTAMP + INTERVAL '3 days', manager_uuid, team2_uuid, 'published'::public.event_status);

    -- Add event attendees
    INSERT INTO public.event_attendees (event_id, user_id, attendance_status) VALUES
        (event1_uuid, admin_uuid, 'going'::public.attendance_status),
        (event1_uuid, manager_uuid, 'going'::public.attendance_status),
        (event1_uuid, member_uuid, 'maybe'::public.attendance_status),
        (event2_uuid, manager_uuid, 'going'::public.attendance_status),
        (event2_uuid, member_uuid, 'going'::public.attendance_status);

    -- Add sample comments
    INSERT INTO public.event_comments (event_id, author_id, content) VALUES
        (event1_uuid, manager_uuid, 'Looking forward to discussing the new features!'),
        (event1_uuid, member_uuid, 'I have prepared the design mockups for review.'),
        (event2_uuid, member_uuid, 'The latest campaign materials are ready for feedback.');

EXCEPTION
    WHEN foreign_key_violation THEN
        RAISE NOTICE 'Foreign key error: %', SQLERRM;
    WHEN unique_violation THEN
        RAISE NOTICE 'Unique constraint error: %', SQLERRM;
    WHEN OTHERS THEN
        RAISE NOTICE 'Unexpected error: %', SQLERRM;
END $$;