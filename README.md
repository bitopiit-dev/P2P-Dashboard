# P2P Material Collection Dashboard

A dashboard for the P2P Material Collection Tracker. An admin uploads the tracker workbook (.xlsx) once, and everyone who opens the link sees the same up-to-date view of deadline risk, progress by department and material, and who to chase next. It fits any screen from a phone to a 4K TV.

**Open it:** https://bitopiit-dev.github.io/P2P-Dashboard/

## Who can do what

| Role | Can do |
|---|---|
| Viewer (anyone with the link) | See the latest published dashboard, filter and highlight, switch light or dark theme |
| Admin (signs in) | Everything a viewer can, plus upload a new tracker, see recent uploads, and delete an upload to roll back |

Viewers don't sign in. The published data, including focal people's names and department status, is visible to anyone who has the link.

## How it works

The page is a single `index.html` on GitHub Pages. Data and admin sign-in live in a free [Supabase](https://supabase.com) project:

- Each admin upload is read in the admin's browser and saved as one row in the `tracker_snapshots` table. The newest row is what everyone sees.
- Database rules (Row Level Security) let anyone read rows, but only signed-in users listed in `dashboard_admins` can add or delete them. The publishable key in `index.html` is meant to be public; it can't bypass these rules.
- Open screens check for a new upload every 5 minutes and whenever the page comes back into view. **Refresh** checks immediately.
- If the internet drops, a device shows the last copy it loaded and says so.

## One-time setup

1. **Create a Supabase project** at https://supabase.com (free plan). Note the region closest to Bangladesh, such as Singapore.
2. **Create the tables and rules.** In the project, open **SQL Editor → New query**, paste the whole of `supabase-setup.sql`, and click **Run**.
3. **Create the admin user.** Go to **Authentication → Users → Add user → Create new user**, enter the admin's email and a strong password, and tick **Auto Confirm User**.
4. **Mark that user as admin.** In **SQL Editor**, run (with the real email):
   ```sql
   insert into public.dashboard_admins (user_id, email)
   select id, email from auth.users where email = 'admin@example.com'
   on conflict (user_id) do nothing;
   ```
5. **Turn off public sign-ups.** In **Authentication → Sign In / Providers**, switch off **Allow new users to sign up**, so only users you create can sign in.
6. **Connect the page.** In **Project Settings → API Keys**, copy the **Project URL** and the **Publishable key** (`sb_publishable_…`). Paste them into the `P2P_CONFIG` block near the top of `index.html`:
   ```js
   window.P2P_CONFIG = {
     SUPABASE_URL: "https://abcdefgh.supabase.co",
     SUPABASE_PUBLISHABLE_KEY: "sb_publishable_..."
   };
   ```
   Never paste the **secret** key (`sb_secret_…`) or the legacy `service_role` key into `index.html`.
7. **Publish.** Upload the edited `index.html` to this repository and wait for the green check under **Actions**.

## Publishing a new tracker (admin)

1. Open the site and click **Admin**.
2. Sign in with the admin email and password.
3. Click **Upload new tracker (.xlsx)** and choose the workbook.
4. Check the summary (snapshot date, items, received, not started). Click **Publish to everyone**.

To undo a bad upload, delete it under **Recent uploads**; everyone then sees the previous one. To add another admin, repeat setup steps 3 and 4 for that person. To remove one, run `delete from public.dashboard_admins where email = '...';`.

## Workbook requirements

The upload expects the tracker's existing layout and stops with a message if something is missing.

- **Tracker** sheet with a header row containing `Department`, `Mat #`, `Material`, `Status`, `Dept focal person`, `Due date`, `Date requested`, `Date received`, `Date approved`, `File / link / location` and `Remarks / blockers`.
- **Setup** sheet (optional): `Report date`, `Due-soon window (days)` and the status weight rows.
- **Follow-up Log** sheet (optional): used to count logged reminders.

## Status weights and flags

Progress is the average weight of all applicable items; N/A items are excluded. Weights in the workbook's Setup sheet override these defaults.

| Status | Weight |
|---|---|
| Not Started | 0% |
| Requested | 10% |
| In Progress | 40% |
| Revision Required | 50% |
| Received | 70% |
| Under Review | 80% |
| Approved | 100% |

Flags use today's date on the viewing device. An item is **Overdue** when its due date has passed and it isn't approved, and **Due soon** when the due date is within the due-soon window (3 days by default).

## Updating the site code

Upload the new `index.html` with **Add file → Upload files → Commit changes**, wait for the green check under **Actions**, then reload with Ctrl + F5. Keep the `P2P_CONFIG` values when you replace the file. Never commit the tracker .xlsx; this repository is public.

## Files

| File | Purpose |
|---|---|
| `index.html` | The dashboard and admin panel |
| `supabase-setup.sql` | Creates the tables, admin check and security rules in Supabase |
| `README.md` | This guide |

## Troubleshooting

| Problem | Fix |
|---|---|
| Page says "Setup needed" | `P2P_CONFIG` still has the placeholder values. Paste the real Project URL and publishable key. |
| "No tracker published yet" | No admin has uploaded yet. |
| "Wrong email or password" | Check the admin user in Supabase **Authentication → Users**, or reset the password there. |
| "This account isn't on the admin list" | Run the `insert into public.dashboard_admins …` statement for that email. |
| "Couldn't publish: … row-level security …" | The signed-in user isn't in `dashboard_admins`, or `supabase-setup.sql` wasn't run fully. |
| 404 "File not found" | The file must be named `index.html` in the repository root, and Pages must deploy from `main` / `(root)`. |
| Old version still showing | Reload with Ctrl + F5, or refresh the page on a phone. |

Supabase pauses free projects after about a week without any requests. If the dashboard stops loading after a quiet period, open the project in Supabase and click **Restore**.

## Built with

Plain HTML, CSS and JavaScript in one file; SheetJS 0.18.5 reads the workbook in the browser; supabase-js 2.117.3 handles sign-in and data. No build step.
