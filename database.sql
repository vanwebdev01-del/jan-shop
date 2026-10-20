-- ==========================================
-- JAN SHOP DATABASE SETUP
-- ==========================================

-- 1. TABLES
create table profiles (
  id uuid references auth.users on delete cascade primary key,
  email text,
  full_name text,
  role text default 'customer' check (role in ('customer','admin')),
  created_at timestamptz default now()
);

create table products (
  id bigserial primary key,
  name text not null,
  category text not null,
  price numeric(10,2) not null,
  tag text,
  icon text default 'serum',
  rating numeric(3,1) default 4.8,
  reviews int default 0,
  grad_from text default '#F6E3E7',
  grad_to text default '#EBC7D2',
  image_url text,
  created_at timestamptz default now()
);

create table orders (
  id bigserial primary key,
  order_code text unique,
  user_id uuid references auth.users,
  customer_name text,
  customer_email text,
  items int default 0,
  total numeric(10,2) default 0,
  status text default 'pending' check (status in ('pending','paid','shipped','delivered','cancelled')),
  created_at timestamptz default now()
);

-- 2. TRIGGERS
create function public.handle_new_user()
returns trigger as $$
begin
  insert into public.profiles (id, email, full_name, role)
  values (new.id, new.email, coalesce(new.raw_user_meta_data->>'full_name', ''), 'customer');
  return new;
end;
$$ language plpgsql security definer;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute procedure public.handle_new_user();

-- 3. ROW LEVEL SECURITY (RLS)
alter table profiles enable row level security;
alter table products enable row level security;
alter table orders enable row level security;

create policy "Public profiles" on profiles for select using (true);
create policy "Update own profile" on profiles for update using (auth.uid() = id);

create policy "Products readable" on products for select using (true);
create policy "Admin insert products" on products for insert with check (exists(select 1 from profiles where id = auth.uid() and role = 'admin'));
create policy "Admin update products" on products for update using (exists(select 1 from profiles where id = auth.uid() and role = 'admin'));
create policy "Admin delete products" on products for delete using (exists(select 1 from profiles where id = auth.uid() and role = 'admin'));

create policy "Read own orders" on orders for select using (auth.uid() = user_id or exists(select 1 from profiles where id = auth.uid() and role = 'admin'));
create policy "Users insert own orders" on orders for insert with check (auth.uid() = user_id);

-- 4. STORAGE BUCKET (Para sa Image Uploads)
insert into storage.buckets (id, name, public) values ('product-images', 'product-images', true) on conflict do nothing;
create policy "Public read images" on storage.objects for select using (bucket_id = 'product-images');
create policy "Admin insert images" on storage.objects for insert with check (bucket_id = 'product-images' and exists(select 1 from profiles where id = auth.uid() and role = 'admin'));
create policy "Admin update images" on storage.objects for update using (bucket_id = 'product-images' and exists(select 1 from profiles where id = auth.uid() and role = 'admin'));
create policy "Admin delete images" on storage.objects for delete using (bucket_id = 'product-images' and exists(select 1 from profiles where id = auth.uid() and role = 'admin'));
