# 📅 TeamSync – Team Calendar App

**TeamSync** is a mobile app built with **Flutter** that helps teams manage events, schedule meetings, and track attendance.  
With **Supabase** integration, all data is stored securely and synchronized in real time.

---

## 🚀 Features

- 📆 **Calendar views** – Day, Week, and Month  
- 👥 **Team support** – events filtered by `team_id`  
- 🔄 **Real-time synchronization** with Supabase  
- ✏️ **Event management**:
  - Create new events  
  - Edit events  
  - Delete events  
  - Duplicate events  
- 🔔 **Attendance tracking** – users can accept or decline invitations  
- 💬 **Event comments** for better collaboration  
- 🎨 **Modern UI/UX** with intuitive navigation  

---

## 🖼️ Screenshots

### Event Preview
![Event Preview](assets/screenshots/EventPreview.png)
(assets/screenshots/EventPreview2.png)

### Join Team
![Weekly Calendar](assets/screenshots/Join_team.png)

### Invite Code Generation System
![Event Details](assets/screenshots/InviteCodeGeneration.png)

---

## 🛠️ Tech Stack

- **Flutter** – cross-platform mobile development  
- **Supabase** – database, authentication & storage  
- **PostgreSQL** – relational database with RLS policies  
- **Dart** – main programming language  

---

## ⚙️ Installation

1. Clone the repository:
   ```bash
   git clone https://github.com/Lukex1/teamsync.git
   
2. Navigate to the project folder:
    ```bash
    cd teamsync_calendar

3. Install dependencies:
    ```bash
    flutter pub get

4. Configure your Supabase project URL and API key in assets/.env
    ```bash
    SUPABASE_URL = https://YOUR-PROJECT.supabase.co
    SUPABASE_ANON_KEY = YOUR-ANON-KEY

5. Run the app:
    ```bash
    flutter run
