# OAuth Testing Instructions for Lamlayers Viewer

## Application Information
- **Homepage URL**: https://lamlayers.zenithsyntax.com
- **Privacy Policy URL**: https://lamlayers.zenithsyntax.com/#/privacy
- **Project ID**: mystical-studio-475013-g5
- **Client ID**: 95582377829-f64u9joo19djd769u06mp3719hh2vg1l.apps.googleusercontent.com

## How to Access and Test the Application

### Step 1: Access the Homepage
1. Navigate to: **https://lamlayers.zenithsyntax.com**
2. The homepage displays information about the Lamlayers Digital Viewer application
3. You will see a prominent **Privacy Policy** link in the hero section and in the footer

### Step 2: Navigate to the OAuth Consent Screen
1. To test the OAuth flow, you need to access a file viewer page
2. The application uses Google Sign-In to authenticate users for accessing Google Drive files
3. You can test the OAuth flow by:
   - Using a test Google Drive file URL, OR
   - Accessing the viewer directly with a file parameter

### Step 3: Testing the Login Flow

#### Option A: Using a Test File URL
1. Create or use an existing Google Drive file (any file will work for testing)
2. Get the shareable link from Google Drive
3. Navigate to: `https://lamlayers.zenithsyntax.com/#/lambook-view?file=YOUR_GOOGLE_DRIVE_FILE_URL`
4. Replace `YOUR_GOOGLE_DRIVE_FILE_URL` with your actual Google Drive file URL

#### Option B: Direct Testing (Recommended)
1. Navigate to: **https://lamlayers.zenithsyntax.com**
2. Click the "Get Started" button
3. Follow the instructions to create a test URL with a Google Drive file
4. When you access a file, the app will prompt for Google Sign-In

### Step 4: OAuth Consent Screen Navigation (with 2FA Disabled)

**IMPORTANT**: Before testing, ensure 2FA (Two-Factor Authentication) is **DISABLED** on your test Google account.

1. When you access a file that requires Google Drive authentication, you'll see a "Sign in with Google" button
2. Click the "Sign in with Google" button
3. You will be redirected to Google's OAuth consent screen
4. Since the app is unverified, you may see a warning screen:
   - Click **"Advanced"** at the bottom of the warning screen
   - Then click **"Go to Lamlayers Viewer (unsafe)"** to proceed
5. Select your Google account (ensure 2FA is disabled)
6. Review the requested permissions:
   - **Scope**: `https://www.googleapis.com/auth/drive.readonly`
   - **Description**: Read-only access to Google Drive files
7. Click **"Allow"** to grant permissions
8. You will be redirected back to the application
9. The application will then attempt to download and display the file

### Step 5: Testing the Application Features

After successful authentication:
1. The app will download the file from Google Drive
2. You'll see a progress indicator during download
3. Once downloaded, you can view the file content
4. The app provides page-turn animations for viewing digital scrapbooks

## Troubleshooting

### If you cannot see the OAuth consent screen:
- Ensure popup blockers are disabled in your browser
- Check browser console for any errors
- Try using a different browser (Chrome recommended)
- Clear browser cache and cookies

### If authentication fails:
- Verify that 2FA is disabled on the test account
- Ensure the test account has access to the Google Drive file
- Check that the file URL is correctly formatted
- Verify the OAuth consent screen is accessible

### If you see "unverified app" warning:
- This is expected behavior for apps pending verification
- Click "Advanced" → "Go to Lamlayers Viewer (unsafe)" to continue
- This is safe as the app only requests read-only access

## Privacy Policy Access

The Privacy Policy is easily accessible from the homepage:
1. **In the Hero Section**: Click the "Privacy Policy" link below the "Get Started" button
2. **In the Navigation Bar**: Click "Privacy Policy" in the top navigation (desktop/tablet)
3. **In the Footer**: Click the "Privacy Policy" link in the footer section
4. **Direct URL**: https://lamlayers.zenithsyntax.com/#/privacy

## Test Account Requirements

For testing purposes, please use a Google account with:
- ✅ 2FA (Two-Factor Authentication) **DISABLED**
- ✅ Access to Google Drive
- ✅ At least one test file in Google Drive (for testing file access)

## Contact Information

If you encounter any issues during testing, please contact the development team or refer to the application's support documentation.

---

**Note**: This application is designed to view `.lamlayers` files (digital scrapbook files) from Google Drive. The OAuth flow is necessary to securely access files stored in the user's Google Drive account.

