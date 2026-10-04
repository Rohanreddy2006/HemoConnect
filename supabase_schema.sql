-- =====================================================================
-- HEMOCONNECT — SUPABASE POSTGRESQL SCHEMA FOR HOSPITALS
-- Run this in your Supabase SQL Editor:
-- https://supabase.com/dashboard/project/clgxntuxhmxfpcbenvbm/sql/new
-- =====================================================================

-- 1. Create the hospitals table
CREATE TABLE IF NOT EXISTS public.hospitals (
    id TEXT PRIMARY KEY,
    hospital_name TEXT NOT NULL,
    location TEXT,
    district TEXT,
    city TEXT DEFAULT 'Hyderabad',
    address TEXT,
    emergency_contact TEXT,
    corporate_email TEXT,
    hak TEXT,
    inventory JSONB DEFAULT '{"O+": 15, "O-": 8, "A+": 12, "A-": 4, "B+": 20, "B-": 6, "AB+": 9, "AB-": 3}'::jsonb,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. Enable Row Level Security (RLS)
ALTER TABLE public.hospitals ENABLE ROW LEVEL SECURITY;

-- 3. Drop existing policies if any to avoid duplicates
DROP POLICY IF EXISTS "Allow public read access" ON public.hospitals;
DROP POLICY IF EXISTS "Allow public insert access" ON public.hospitals;
DROP POLICY IF EXISTS "Allow public update access" ON public.hospitals;
DROP POLICY IF EXISTS "Allow public delete access" ON public.hospitals;

-- 4. Create permissive policies for publishable / authenticated roles
CREATE POLICY "Allow public read access" ON public.hospitals
    FOR SELECT USING (true);

CREATE POLICY "Allow public insert access" ON public.hospitals
    FOR INSERT WITH CHECK (true);

CREATE POLICY "Allow public update access" ON public.hospitals
    FOR UPDATE USING (true) WITH CHECK (true);

CREATE POLICY "Allow public delete access" ON public.hospitals
    FOR DELETE USING (true);

-- 5. Seed Initial Hospitals with Real Contacts & Stock
INSERT INTO public.hospitals (id, hospital_name, location, district, city, address, emergency_contact, corporate_email, hak, inventory)
VALUES
('h-1', 'Apollo Hospitals', 'Jubilee Hills', 'Jubilee Hills', 'Hyderabad', 'Road No 72, Opposite Bharatiya Vidya Bhavan, Jubilee Hills', '+914023607777', 'admin@apollohospitals.org', 'hak-apollo-01', '{"O+": 25, "O-": 12, "A+": 18, "A-": 6, "B+": 22, "B-": 8, "AB+": 14, "AB-": 4}'::jsonb),
('h-2', 'Yashoda Hospitals', 'Somajiguda', 'Somajiguda', 'Hyderabad', 'Raj Bhavan Road, Matha Nagar, Somajiguda', '+914045674567', 'admin@yashodahospitals.org', 'hak-yashoda-02', '{"O+": 30, "O-": 15, "A+": 20, "A-": 7, "B+": 25, "B-": 9, "AB+": 16, "AB-": 5}'::jsonb),
('h-3', 'Gandhi Hospital', 'Secunderabad', 'Secunderabad', 'Hyderabad', 'Musheerabad, Padmarao Nagar, Secunderabad', '+914027505566', 'admin@gandhihospital.org', 'hak-gandhi-03', '{"O+": 40, "O-": 20, "A+": 28, "A-": 10, "B+": 35, "B-": 12, "AB+": 18, "AB-": 6}'::jsonb),
('h-4', 'Osmania General Hospital', 'Afzal Gunj', 'Charminar', 'Hyderabad', 'Afzal Gunj, High Court Road, Hyderabad', '+914024600121', 'admin@osmaniahospital.org', 'hak-osmania-04', '{"O+": 35, "O-": 18, "A+": 24, "A-": 8, "B+": 30, "B-": 11, "AB+": 15, "AB-": 5}'::jsonb),
('h-5', 'Care Hospitals', 'Banjara Hills', 'Banjara Hills', 'Hyderabad', 'Road No 1, Banjara Hills, Hyderabad', '+914061656565', 'admin@carehospitals.org', 'hak-care-05', '{"O+": 22, "O-": 10, "A+": 16, "A-": 5, "B+": 19, "B-": 7, "AB+": 11, "AB-": 3}'::jsonb),
('h-6', 'Continental Hospitals', 'Gachibowli', 'Gachibowli', 'Hyderabad', 'Financial District, Nanakramguda, Gachibowli', '+914067000000', 'admin@continentalhospitals.org', 'hak-continental-06', '{"O+": 28, "O-": 14, "A+": 19, "A-": 6, "B+": 24, "B-": 8, "AB+": 13, "AB-": 4}'::jsonb),
('h-7', 'NIMS Hospital', 'Punjagutta', 'Punjagutta', 'Hyderabad', 'Punjagutta Main Road, Hyderabad', '+914023489000', 'admin@nims.edu.in', 'hak-nims-07', '{"O+": 32, "O-": 16, "A+": 21, "A-": 7, "B+": 27, "B-": 10, "AB+": 15, "AB-": 5}'::jsonb)
ON CONFLICT (id) DO NOTHING;
