# Firebase Authentication Troubleshooting Guide

## 🔥 Common Causes of 400 Bad Request for Firebase Auth

Based on your error, here are the most likely causes and solutions:

### 1. **Email/Password Authentication Not Enabled** (Most Likely)

Your Firebase project might not have Email/Password authentication enabled.

**Solution:**

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Navigate to **Authentication > Sign-in method**
4. Click on **Email/Password**
5. **Enable** both options:
   - Email/Password ✅
   - Email link (passwordless sign-in) ✅ (optional)
6. Click **Save**

### 2. **Authorized Domains Issue**

Your localhost domain might not be authorized.

**Solution:**

1. In Firebase Console > Authentication > Settings > Authorized domains
2. Make sure `localhost` is in the list
3. Add `localhost` if it's missing

### 3. **Firebase Configuration**

Your `firebase_options.dart` might have incorrect API keys.

**Current API Key from your error:** `AIzaSyDhf9R5_EkQK7DOrtI8jhbHFnNeKPdiPJM`

### 4. **Admin User Already Exists**

The admin user might already exist but with different credentials.

**Try this:**

1. Click "Create Admin User" button
2. If you get "email-already-in-use" error, try logging in directly with:
   - Email: `admin@mit.edu`
   - Password: `MITAdmin123!`

### 5. **Firebase Project Quota/Billing**

Free tier limitations might be reached.

## 🧪 Testing Steps

1. **Test Firebase Connection** - Click the "Test Firebase Connection" button
2. **Check Admin Creation** - Click "Create Admin User"
3. **Try Login** - Use the pre-filled credentials

## 🔧 Quick Fix Actions

If the above doesn't work, try these in order:

1. **Re-enable Email Auth** in Firebase Console
2. **Check Authorized Domains** includes localhost
3. **Create admin via Firebase Console** manually:
   - Go to Authentication > Users
   - Click "Add user"
   - Email: `admin@mit.edu`
   - Password: `MITAdmin123!`
4. **Try signing in** with the manual account

## 📋 Error Details from Your Request

- **Endpoint:** `accounts:signUp` (User creation)
- **Method:** POST
- **Status:** 400 Bad Request
- **Email:** admin@mit.edu
- **Firebase Project:** 513843255433

The error suggests the signup endpoint is rejecting the request, most commonly due to Email/Password auth being disabled.
