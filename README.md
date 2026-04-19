# MatchUpUni 🎓

MatchUpUni is a full-stack application designed to help university students find teammates for competitions, camps, workshops, and other academic or extracurricular activities.

## ✨ Features

- **Activity & Team Posts:** Create posts to find teammates or share activities (Competitions, Camps, Startups, Tech, etc.).
- **Chat System:** Integrated direct messaging allowing users to communicate and discuss projects.
- **Notifications:** Receive notifications for new messages and unread chat indicators.
- **User Profiles:** Customize user profiles, skills, and manage personal posts/favorites.
- **Search & Filtering:** Efficiently search and filter posts by activity type, tags, or required skills.

## 🛠 Tech Stack

- **Frontend:** Flutter & Dart
- **Backend:** Node.js (Express.js)
- **Database:** PostgreSQL
- **Deployment:** Dokku

---

## 🗄️ Server & Database Access (For Admins)

If you need to access the production database or check runtime errors/logs on the backend, you can connect to the server via SSH.

### 1. Connect to the Server

Open your terminal and run the following SSH command:

```bash
ssh assessor@chanakancloud.net
```

_(Password: `kJhEJN+cbwAGc+tdFX0eL7MSRGsZ/1QIh7lO+T6l0g4=`)_

### 2. Access PostgreSQL Database (Shell)

Once connected to the server successfully, run the following command to access the database shell directly:

```bash
dokku postgres:connect matchupuni
```

### 3. View Backend Logs

To view the live output, runtime info, or check for errors on the backend server, run:

```bash
dokku logs matchupuni
```

---

## 🚀 Getting Started (Local Development)

### 1. Backend Setup

1. Navigate to the `backend/` directory:
   ```bash
   cd backend
   ```
2. Install dependencies:
   ```bash
   npm install
   ```
3. Setup your `.env` file in the `backend/` folder. You will need a PostgreSQL database running:

   ```env
   # You can use a URL string:
   DATABASE_URL=postgres://user:password@localhost:5432/matchupuni

   # Or individual parameters:
   DB_HOST=localhost
   DB_USER=your_db_user
   DB_PASSWORD=your_db_password
   DB_DATABASE=matchupuni
   DB_PORT=5432

   # Other keys
   PORT=3000
   JWT_SECRET=your_jwt_secret_key
   ```

4. Run the database migrations to set up your tables:
   ```bash
   npm run migrate
   ```
5. Start the server (runs on `http://localhost:3000` by default):
   ```bash
   npm start
   ```

### 2. Frontend Setup

1. Navigate to the `frontend/` directory:
   ```bash
   cd frontend
   ```
2. Get Flutter dependencies:
   ```bash
   flutter pub get
   ```
3. Configure the API URL:
   - Go to `frontend/lib/config/api_config.dart`
   - By default, it connects to the production server (`https://matchupuni.app.chanakancloud.net`).
   - Change `static const bool useLocalhost = true;` if you want to connect to your local backend.
4. Run the app on your preferred emulator or physical device:
   ```bash
   flutter run
   ```
