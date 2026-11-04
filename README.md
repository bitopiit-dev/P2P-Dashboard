P2P Material Collection Dashboard

A single-page dashboard that turns the P2P Material Collection Tracker workbook (.xlsx) into a live view of deadline risk, progress by department and material, and who to chase next. It runs in any browser, fits any screen from a phone to a 4K TV, and holds no project data itself.

Open it: https://bitopiit-dev.github.io/P2P-Dashboard/

How to use it
Open the link on a phone, laptop or meeting-room screen.
Tap Load updated tracker (.xlsx) and choose the latest tracker file from your device, Google Drive or OneDrive.
The dashboard fills in. Your browser remembers the last file you loaded, so next time the dashboard opens with that data.
Load the new workbook whenever the tracker is updated. Forget data clears the saved copy from that device.

The dashboard uses Bitopi Group’s website colours and opens in dark mode. The half-circle button next to Forget data switches between dark and light, and each device remembers the choice.

On a computer, hover over any heatmap cell for details. On a phone or tablet, tap the cell and the details open at the bottom of the screen. Tap a pipeline stage to highlight only those items, or tap a department name to highlight its row. Clear highlights resets the view.

Your data stays on your device

The page reads the workbook inside your browser. Nothing is uploaded to GitHub or any server, and anyone who opens the link without the workbook sees an empty dashboard. This repository is public, so never commit the tracker .xlsx or any copy of the dashboard with data built in.

What the dashboard shows
Section	What it tells you
Deadline	Days left until the latest due date, items not yet received, and the items-per-day pace needed to finish on time
Weighted progress	Overall progress using the status weights below (outer ring) and the share of items approved (inner ring)
Collection pipeline	How many items sit at each status; tap a stage to filter the heatmap
Department × material heatmap	Status of every department and material pair; departments with no activity show in pink
Departments and materials by progress	Ranked bars showing who and what is lagging
Chase list	Departments with items not started, their focal person, and the missing materials
Review findings	Data-quality and risk checks recalculated on every load, such as silent departments, received items not yet reviewed, missing dates and an empty follow-up log
Workbook requirements

The dashboard expects the tracker's existing layout. Rename a sheet or column and loading will fail with a message naming the missing part.

Tracker sheet, with a header row containing Department, Mat #, Material, Status, Dept focal person, Due date, Date requested, Date received, Date approved, File / link / location and Remarks / blockers.
Setup sheet (optional): Report date, Due-soon window (days), and the status weight rows. When it is missing, the defaults below apply.
Follow-up Log sheet (optional): used to count logged reminders.
Status weights and flags

Progress is the average weight of all applicable items. N/A items are excluded. Weights in the workbook's Setup sheet override these defaults.

Status	Weight
Not Started	0%
Requested	10%
In Progress	40%
Revision Required	50%
Received	70%
Under Review	80%
Approved	100%

Flags use today's date on the viewing device. An item is Overdue when its due date has passed and it is not approved. It is Due soon when the due date falls within the due-soon window (3 days by default).

Updating the site
In this repository, open Add file → Upload files.
Drag in the new index.html and click Commit changes. It replaces the old file.
Wait for the pages build and deployment run under Actions to show a green check, usually one to two minutes.
Reload the site with Ctrl + F5 (or refresh on a phone).

GitHub Pages is configured under Settings → Pages to deploy from the main branch, / (root) folder.

Files
File	Purpose
index.html	The whole dashboard: layout, styles and logic in one file
README.md	This guide
Troubleshooting
Problem	Fix
404 "File not found"	Check that the file is named exactly index.html (lowercase), sits in the repository root, and that Pages deploys from main / (root).
"The spreadsheet reader needs an internet connection"	The page loads its Excel reader (SheetJS) from cdnjs. Connect to the internet and try again.
"No Tracker sheet found" or "Couldn't find the Tracker header row"	Use the original tracker workbook; the sheet must be named Tracker and keep its header row.
Old version still showing	Reload with Ctrl + F5, or clear the browser cache on the phone.
Fonts look plain	The Barlow and Inter fonts load from Google Fonts. Without internet, system fonts are used; all data still shows.
Built with

Plain HTML, CSS and JavaScript in a single file. SheetJS 0.18.5 reads the workbook in the browser. No build step and no server code.
