# Jan Shop — E-Commerce Web Application

A premium, mobile-responsive, single-file e-commerce web application built for Philippine beauty and lifestyle products. 

## Files Included
- `index.html` - The complete frontend application (HTML, CSS, JS).
- `manifest.json` - PWA configuration for installing as an app.
- `icon.svg` - App icon.
- `database.sql` - (Provide this separately) SQL script to set up Supabase.

## How to Setup (For Client/Developer)

1. **Database Setup:**
   - Create a new project on [Supabase](https://supabase.com).
   - Go to the **SQL Editor**, paste the contents of `database.sql`, and click **Run**.
2. **API Keys:**
   - Go to **Project Settings -> API**.
   - Copy the **Project URL** and **anon public key**.
3. **Update Code:**
   - Open `index.html` in a text editor.
   - Find `const SUPABASE_URL` and `const SUPABASE_ANON_KEY` at the bottom.
   - Replace them with your own keys.
4. **Admin Access:**
   - In Supabase, go to **Authentication -> Users**, create a new user (e.g., `admin@janshop.com`).
   - Run this in the SQL Editor: 
     `update profiles set role = 'admin' where email = 'admin@janshop.com';`
5. **Deploy:** 
   - You can host the `index.html` file on GitHub Pages, Netlify, or Vercel.

## Admin Credentials (Demo)
- Email: `admin@janshop.com`
- Password: `admin123`
