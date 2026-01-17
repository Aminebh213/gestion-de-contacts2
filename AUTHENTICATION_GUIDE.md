# Authentication System - Setup and Usage Guide

## Overview
Your Flutter application now has a complete multi-user authentication system with:
- User registration with validation
- Secure login with password hashing
- Session management using SharedPreferences
- Automatic route protection
- Beautiful, modern UI with Material Design 3

## Changes Made

### Backend (Python/FastAPI)
1. **main.py** - Added password hashing using bcrypt
   - `hash_password()` - Hashes passwords before storing
   - `verify_password()` - Verifies passwords during login
   - Updated `/auth/register` endpoint to hash passwords
   - Updated `/auth/login` endpoint to verify hashed passwords

2. **requirements.txt** - Added `passlib[bcrypt]==1.7.4` for password hashing

### Frontend (Flutter)
1. **lib/models/user.dart** - Updated User model
   - Removed unnecessary `userID` field
   - Made `motDePasse` optional (for security in responses)
   - Added `toJsonWithId()` method for session storage

2. **lib/services/api_service.dart** - Added authentication methods
   - `register()` - Register new users
   - `login()` - Authenticate users
   - Proper error handling

3. **lib/services/auth_service.dart** - New file for session management
   - `saveUser()` - Save user session
   - `getCurrentUser()` - Get logged-in user
   - `isLoggedIn()` - Check authentication status
   - `logout()` - Clear user session

4. **lib/screens/login.dart** - Complete login screen
   - Form validation
   - Password visibility toggle
   - Loading states
   - Navigation to register screen

5. **lib/screens/register.dart** - Complete registration screen
   - Form validation (name, phone, password)
   - Password confirmation
   - Password strength validation (min 6 characters)
   - Navigation to login screen

6. **lib/main.dart** - Updated app routing
   - Added SplashScreen to check authentication status
   - Routes users to login or home based on session
   - Proper route definitions

7. **lib/screens/home.dart** - Updated logout functionality
   - Uses AuthService for proper logout
   - Confirmation dialog before logout

## Setup Instructions

### 1. Install Backend Dependencies
```bash
cd backend
pip install -r requirements.txt
```

### 2. Reset Database (Optional - if you have existing users with plain text passwords)
```bash
# Delete the old database to start fresh with hashed passwords
rm contacts.db
```

### 3. Start Backend Server
```bash
cd backend
python main.py
```
The server will run on http://localhost:8000

### 4. Install Flutter Dependencies
```bash
cd frontend
flutter pub get
```

### 5. Run Flutter App
```bash
flutter run
```

## Usage

### First Time Users
1. App opens to the login screen
2. Click "S'inscrire" to create an account
3. Fill in:
   - Nom (First name)
   - Prénom (Last name)
   - Numéro de téléphone (Phone number - min 8 digits)
   - Mot de passe (Password - min 6 characters)
   - Confirm password
4. Click "S'inscrire" to register
5. You'll be automatically logged in and redirected to the home screen

### Returning Users
1. Enter your phone number
2. Enter your password
3. Click "Se connecter"
4. Access the contacts management features

### Logout
1. Click the logout icon in the app bar
2. Confirm logout in the dialog
3. You'll be redirected to the login screen

## Features

### Security Features
- ✅ Passwords are hashed using bcrypt before storage
- ✅ Passwords are never returned in API responses
- ✅ Session management using SharedPreferences
- ✅ Automatic authentication check on app start
- ✅ Protected routes (home screen requires login)

### UI/UX Features
- ✅ Modern gradient design
- ✅ Form validation with helpful error messages
- ✅ Password visibility toggle
- ✅ Loading indicators during API calls
- ✅ Success/error notifications
- ✅ Smooth navigation between screens
- ✅ Logout confirmation dialog

## API Endpoints

### Authentication
- `POST /auth/register` - Register new user
  ```json
  {
    "nom": "Doe",
    "prenom": "John",
    "numero": "12345678",
    "mot_de_passe": "securepass123"
  }
  ```

- `POST /auth/login` - Login user
  ```json
  {
    "numero": "12345678",
    "mot_de_passe": "securepass123"
  }
  ```

### Person Management (requires login)
- `GET /personnes` - Get all contacts
- `POST /personnes` - Add new contact
- `GET /personnes/{id}` - Get contact by ID
- `PUT /personnes/{id}` - Update contact
- `DELETE /personnes/{id}` - Delete contact
- `GET /personnes/search/{query}` - Search contacts

## Testing

### Test User Registration
1. Open the app
2. Click "S'inscrire"
3. Fill the form with test data
4. Verify successful registration and automatic login

### Test User Login
1. Logout if logged in
2. Enter registered credentials
3. Verify successful login and redirect to home

### Test Session Persistence
1. Login to the app
2. Close and reopen the app
3. Verify you're still logged in (no login screen shown)

### Test Logout
1. Click logout icon
2. Confirm logout
3. Verify redirect to login screen
4. Try to access home (should redirect to login)

## Troubleshooting

### Can't login with existing users
- The database contains plain text passwords but the code now expects hashed passwords
- Solution: Delete `contacts.db` and restart the backend to create a fresh database

### Backend not accessible from emulator
- Make sure backend is running on `0.0.0.0:8000`
- Android emulator uses `10.0.2.2` to access host machine
- iOS simulator uses `localhost` or your machine's IP

### Session not persisting
- Check that `shared_preferences` package is installed
- Run `flutter pub get` if needed

## Next Steps (Optional Enhancements)

1. **Email verification** - Send verification emails on registration
2. **Password reset** - Allow users to reset forgotten passwords
3. **JWT tokens** - Use JWT for more secure authentication
4. **Refresh tokens** - Implement token refresh mechanism
5. **Profile management** - Allow users to update their profile
6. **Remember me** - Add option to stay logged in
7. **Biometric auth** - Add fingerprint/face ID login
8. **OAuth** - Add Google/Facebook login

## File Structure
```
backend/
├── main.py (✓ Updated with password hashing)
├── models.py
├── database.py
└── requirements.txt (✓ Updated with passlib)

frontend/
├── lib/
│   ├── main.dart (✓ Updated with auth flow)
│   ├── models/
│   │   ├── user.dart (✓ Updated)
│   │   └── person.dart
│   ├── services/
│   │   ├── api_service.dart (✓ Updated with auth methods)
│   │   └── auth_service.dart (✓ New file)
│   └── screens/
│       ├── login.dart (✓ Complete implementation)
│       ├── register.dart (✓ Complete implementation)
│       ├── home.dart (✓ Updated logout)
│       ├── add_person.dart
│       └── update_person.dart
└── pubspec.yaml
```

## Support
Your authentication system is now complete and ready to use! All users can register, login, and manage their sessions securely.
