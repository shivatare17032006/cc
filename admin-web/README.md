# Admin Web Panel

This is a standalone admin website for Campus Canteen. It does not modify or depend on the Flutter app code.

## Features

- Admin login using backend auth
- View dashboard stats: orders, revenue, complaints, users
- Update order status: Pending, Preparing, Ready, Completed
- Resolve complaints
- View recent users

## Run

1. Start backend server from the backend folder.
2. Serve this folder using any static file server.

Example with Node.js:

```bash
npx serve .
```

Then open the URL from the terminal output.

## Create Or Promote Admin User

From the backend folder:

```bash
npm run admin:create -- --email admin@campus.local --password Admin@12345 --name "Canteen Admin"
```

This command creates a new admin user if the email does not exist, or promotes the existing user to admin and resets its password.

## Notes

- Enter backend URL in the login form (default: `http://localhost:5000`).
- Login must be with a user that has role `admin`.
