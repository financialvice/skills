# Instant on the Backend

Admin SDK for server-side use - scripts, custom auth, sensitive logic.

## Admin SDK

`@instantdb/admin` - similar to client SDK with server tweaks.

### init

```javascript
import { init, id } from '@instantdb/admin';

const APP_ID = '__APP_ID__';
const db = init({
  appId: APP_ID,
  adminToken: process.env.INSTANT_APP_ADMIN_TOKEN,
});
```

Must init before queries/writes. Exposes appId is fine, adminToken must stay secret. Admin API bypasses permission checks. Regenerate token if leaked.

## Reading and Writing Data

### query

```javascript
const data = await db.query({ goals: {}, todos: {} });
const { goals, todos } = data;
```

Async `db.query` fires once and returns result (vs `db.useQuery` live queries in React).

### transact

```javascript
const res = await db.transact([db.tx.todos[id()].update({ title: 'Get fit' })]);
console.log('New todo entry made for with tx-id', res['tx-id']);
```

Async function, returns `tx-id` on success.

## Subscriptions on the backend

`db.subscribeQuery` subscribes to queries - useful for backend processes reacting to DB changes.

### With callbacks

```typescript
const sub = db.subscribeQuery({ tasks: { $: { limit: 10 } } }, (payload) => {
  if (payload.type === 'error') {
    console.log('error', error);
    sub.close();
  } else {
    console.log('got data!', payload.data);
  }
});

// Close when done:
sub.close();
```

### With async iterator

```typescript
const sub = db.subscribeQuery({ tasks: { $: { limit: 10 } } });

for await (const payload of sub) {
  if (payload.type === 'error') {
    console.log('error', error);
    sub.close();
  } else {
    console.log('data', payload.data);
  }
}

// Close when done:
sub.close();
```

Subscriptions keep live connection open. Close when no longer needed to avoid tying up resources.

## Schema

```typescript
import { init, id } from '@instantdb/admin';
import schema from '../instant.schema.ts';

const APP_ID = '__APP_ID__';
const db = init({
  appId: APP_ID,
  adminToken: process.env.INSTANT_APP_ADMIN_TOKEN,
  schema,
});
```

Adding schema gives `db.query` and `db.transact` autocompletion and typesafety. Backend also uses schema to generate missing attributes.

More: https://www.instantdb.com/docs/modeling-data

## Impersonating users

Admin SDK bypasses permissions. Use `db.asUser` to make queries on behalf of users and respect permissions.

```javascript
// Scope by email
const scopedDb = db.asUser({ email: 'alyssa_p_hacker@instantdb.com' });
// Or with auth token
const token = db.auth.createToken({ email: 'alyssa_p_hacker@instantdb.com' });
const scopedDb = db.asUser({ token });
// Or as guest
const scopedDb = db.asUser({ guest: true });
// Queries/transactions run with those permissions
await scopedDb.query({ logs: {} });
```

### Running Admin SDK in client environments

Impersonation lets you run Admin SDK without exposing admin token.

```javascript
import { init } from '@instantdb/admin';

// Skip admin credentials when only impersonating
const db = init({
  appId: process.env.INSTANT_APP_ID!
});

// Pass user token
const userDB = db.asUser({
  token: "...",
});

// Or run as guest
const guestDB = db.asUser({
  guest: true,
});

// Queries/transactions work with respective permissions
await userDB.query({ todos: {} });
await guestDB.query({ publicData: {} });
```

Perfect for places needing Admin SDK without exposing admin credentials (e.g., background daemon on user's machine).

Without `adminToken`, must use `.asUser({ token })` or `asUser({ guest: true })` for all ops. Direct queries on base `db` will fail, can't impersonate with `asUser({ email })`. In protected environments, include `adminToken`.

## Retrieve a user

Retrieve user record by `email`, `id`, or `refresh_token` with `db.auth.getUser`.

```javascript
const user = await db.auth.getUser({ email: 'alyssa_p_hacker@instantdb.com' });
const user = await db.auth.getUser({ id: userId });
const user = await db.auth.getUser({ refresh_token: userRefreshToken });
```

## Delete a user

Delete user record by `email`, `id`, or `refresh_token` with `db.auth.deleteUser`.

```javascript
const deletedUser = await db.auth.deleteUser({ email: 'alyssa_p_hacker@instantdb.com' });
const deletedUser = await db.auth.deleteUser({ id: userId });
const deletedUser = await db.auth.deleteUser({ refresh_token: userRefreshToken });
```

Only deletes user record and associated data with cascade on delete. Clean up other data manually:

```javascript
const { goals, todos } = await db.query({
  goals: { $: { where: { creator: userId } } },
  todos: { $: { where: { creator: userId } } },
});

await db.transact([
  ...goals.map((item) => db.tx.goals[item.id].delete()),
  ...todos.map((item) => tx.todos[item.id].delete()),
]);
// Now delete user
await db.auth.deleteUser({ id: userId });
```

## Presence in the Backend

Query room data from admin API with `db.rooms.getPresence`. Useful for notifications - skip if user already online.

```js
const data = await db.rooms.getPresence('chat', 'room-123');
console.log(Object.values(data));
// [{
//     'peer-id': '...',
//     user: { id: '...', email: 'foo@bar.com', ... },
//     data: { typing: true, ... },
//   },
// }];
```

## Sign Out

`db.auth.signOut` logs out users. By `email` or `id` logs out all sessions. By `refresh_token` logs out specific session.

```javascript
// All sessions for this email
await db.auth.signOut({ email: 'alyssa_p_hacker@instantdb.com' });
// All sessions for this user id
const user = await db.auth.signOut({ id: userId });
// Just this refresh token session
await db.auth.signOut({ refresh_token: userRefreshToken });
```

## Custom Auth

Implement custom auth flows with backend + frontend changes.

### 1. Backend: db.auth.createToken

Create `sign-in` endpoint using `db.auth.createToken` to generate auth token.

```javascript
app.post('/sign-in', async (req, res) => {
  // your custom logic for signing users in
  // ...
  // on success, create and return token
  const token = await db.auth.createToken({ email });
  return res.status(200).send({ token });
});
```

`db.auth.createToken` accepts email or UUID:

```javascript
const token = await db.auth.createToken({ id });
```

If user doesn't exist, `db.auth.createToken` creates the user.

### 2. Frontend: db.auth.signInWithToken

Frontend calls `sign-in` endpoint, then uses token with `db.auth.signInWithToken`.

```javascript
import React, { useState } from 'react';
import { init } from '@instantdb/react';

const APP_ID = "__APP_ID__";
const db = init({ appId: APP_ID });

async function customSignIn(
  email: string,
  password: string
): Promise<{ token: string }> {
  const response = await fetch('your-website.com/api/sign-in', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
    },
    body: JSON.stringify({ email, password }),
  });
  const data = await response.json();
  return data;
}

function App() {
  const { isLoading, user, error } = db.useAuth();
  if (isLoading) {
    return <div>Loading...</div>;
  }
  if (error) {
    return <div>Uh oh! {error.message}</div>;
  }
  if (user) {
    return <div>Hello {user.email}!</div>;
  }
  return <Login />;
}

function Login() {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');

  const handleEmailChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setEmail(event.target.value);
  };

  const handlePasswordChange = (event: React.ChangeEvent<HTMLInputElement>) => {
    setPassword(event.target.value);
  };

  const handleSignIn = async () => {
    const data = await customSignIn(email, password); // initiate custom sign in
    db.auth.signInWithToken(data.token); // sign in with token on success
  };

  return (
    <div>
      <input
        type="email"
        placeholder="Enter your email"
        value={email}
        onChange={handleEmailChange}
      />
      <input
        type="password"
        placeholder="Enter your password"
        value={password}
        onChange={handlePasswordChange}
      />
      <button onClick={handleSignIn}>Sign In</button>
    </div>
  );
}
```

## Custom magic codes

Default magic code flow supported out of box. Use your own email provider with `db.auth.generateMagicCode`:

```typescript
app.post('/custom-send-magic-code', async (req, res) => {
  const { code } = await db.auth.generateMagicCode(req.body.email);
  // Use your email provider to send magic codes
  await sendMyCustomMagicCodeEmail(req.body.email, code);
  return res.status(200).send({ ok: true });
});
```

Use Instant's default email provider with `db.auth.sendMagicCode`:

```typescript
// Trigger magic code email in backend
const { code } = await db.auth.sendMagicCode(req.body.email);
```

Verify magic code with `db.auth.verifyMagicCode`:

```typescript
const user = await db.auth.verifyMagicCode(req.body.email, req.body.code);
const token = user.refresh_token;
```

## Authenticated Endpoints

Use Admin SDK to authenticate users in custom endpoints.

### 1. Frontend: user.refresh_token

`user` object has `refresh_token` property. Pass to your endpoint:

```javascript
// client
import { init } from '@instantdb/react';

const db = init(/* ... */)

function App() {
  const { user } = db.useAuth();
  // call your api with `user.refresh_token`
  function onClick() {
    myAPI.customEndpoint(user.refresh_token, ...);
  }
}
```

### 2. Backend: auth.verifyToken

Use `auth.verifyToken` to verify `refresh_token`.

```javascript
app.post('/custom_endpoint', async (req, res) => {
  // verify the token this user passed in
  const user = await db.auth.verifyToken(req.headers['token']);
  if (!user) {
    return res.status(401).send('Uh oh, you are not authenticated');
  }
  // ...
});
```
