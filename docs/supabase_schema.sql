create table if not exists public.telemetry (
  id bigint generated always as identity primary key,
  robot_id text not null,
  x integer not null,
  y integer not null,
  aqi text not null check (aqi in ('GOOD', 'MODERATE', 'DANGEROUS', 'HIGH', 'POOR')),
  front_cm integer not null,
  left_cm integer not null,
  right_cm integer not null,
  back_cm integer not null,
  battery integer not null check (battery between 0 and 100),
  obstacle boolean not null default false,
  safe_directions jsonb not null default '[]'::jsonb,
  created_at timestamptz not null default now()
);

create index if not exists telemetry_robot_created_idx
  on public.telemetry (robot_id, created_at desc);

create table if not exists public.scan_sessions (
  id bigint generated always as identity primary key,
  robot_id text not null,
  status text not null,
  started_at timestamptz not null default now(),
  completed_at timestamptz,
  summary jsonb not null default '{}'::jsonb
);
