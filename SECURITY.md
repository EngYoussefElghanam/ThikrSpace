# ThikrSpace Security Policy

## Core Architecture
This project uses Firebase Authentication and Firestore. Security is enforced strictly at the database level via `firestore.rules`, NOT in the client application. The client is considered an untrusted environment.

## The Red Lines (Never Do These)
If you submit a pull request containing any of the following, it will be rejected immediately:

1. **Wildcard Writes:** Never use `match /{document=**} { allow write: if true; }` or `if request.auth != null`. This exposes the entire database. Access must always be scoped to the specific document or collection.
2. **Global/Public Collections:** There are no public collections. All user data MUST live under `/users/{uid}/*`. If global config is needed, it must be `allow read: if true; allow write: if false;` (admin-write only).
3. **Client-Writable Admin Flags:** Fields such as `betaAccess`, `pro`, or `isAdmin` must never be writable from the client application. They are manipulated strictly via the Firebase Console, Cloud Functions, or an Admin SDK.
4. **Trusting Client Validation:**
   Do not rely on Flutter form validation to protect the database. If a field has a max length or a max value (e.g., `dailyGoal <= 100`), that constraint must be duplicated in `firestore.rules`.

## Rule Deployment
The `firestore.rules` file in this repository is the single source of truth. Do not edit rules directly in the Firebase Console. Edit them here, test them, and deploy them via the Firebase CLI:
`firebase deploy --only firestore:rules`