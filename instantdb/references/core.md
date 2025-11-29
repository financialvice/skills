# Init

## Basic

```javascript
import { init } from '@instantdb/react';

const APP_ID = '__APP_ID__';
const db = init({ appId: APP_ID });

function App() {
  return <Main />;
}
```

Now use `db` for [writes](/docs/instaml), [queries](/docs/instaql), [auth](/docs/auth), etc.

## Typesafety

```typescript
import { init, i } from '@instantdb/react';

const schema = i.schema({
  entities: {
    $files: i.entity({
      path: i.string().unique().indexed(),
      url: i.any(),
    }),
    $users: i.entity({
      email: i.string().unique().indexed(),
    }),
    todos: i.entity({
      text: i.string(),
      done: i.boolean(),
      createdAt: i.number(),
    }),
  },
});

const db = init({ appId: APP_ID, schema });
```

More on schemas: [Modeling your data](/docs/modeling-data)

## Flexible Init

Instant maintains single connection per app ID - safe to call `init` multiple times. Recommended pattern:

```typescript
// lib/db.ts
import { init } from '@instantdb/react';
import schema from '../instant.schema';

const APP_ID = '__APP_ID__';
export const db = init({ appId: APP_ID, schema });

// app/page.tsx
"use client";
import { db } from '../lib/db';

function App() {
  db.useQuery({ todos: {} });
}
```

## Config Options

- **appId** (required): Your app ID
- **schema?**: From `instant.schema.ts` for typesafety
- **websocketURI?**: Custom endpoint (default: `'wss://api.instantdb.com/runtime/session'`)
- **apiURI?**: Custom HTTP endpoint (default: `'https://api.instantdb.com'`)
- **devtool?**: Controls dev tool (default: `true` on localhost). Set `false` or `{ position: 'bottom-right', allowedHosts: ['localhost'] }`
- **verbose?**: Logs WebSocket messages for debugging
- **queryCacheLimit?**: Max cached query subscriptions (default: `10`)
- **useDateObjects?**: Returns `Date` objects for date columns (default: `false`)

# Patterns

## App ID

Similar to Firebase - app ID can be exposed to client. Secure with [permissions](/docs/permissions).

## Restrict New Attributes

Lock schema by adding to [permissions](/dash?t=perms):

```json
{
  "attrs": { "allow": { "$default": "false" } }
}
```

## Attribute Level Permissions

`fields` clause restricts returned attributes but client can query again. Use permission rules for [`fields`](/docs/instaql/#fields) to enforce visibility.

## Find Entities With No Links

```javascript
const { data } = db.useQuery({
  posts: {
    $: {
      where: {
        'author.id': { $isNull: true },
      },
    },
  },
});
```

## Limit Via Permissions

Schema:

```typescript
// instant.schema.ts
import { i } from '@instantdb/core';

const _schema = i.schema({
  entities: {
    $users: i.entity({
      email: i.string().unique().indexed(),
    }),
    todos: i.entity({
      label: i.string(),
    }),
  },
  links: {
    userTodos: {
      forward: { on: 'todos', has: 'one', label: 'owner' },
      reverse: { on: '$users', has: 'many', label: 'ownedTodos' },
    },
  },
});

type _AppSchema = typeof _schema;
interface AppSchema extends _AppSchema {}
const schema: AppSchema = _schema;
export type { AppSchema };
export default schema;
```

Permissions:

```typescript
// instant.perms.ts
import type { InstantRules } from '@instantdb/react';

const rules = {
  todos: {
    allow: {
      create: "size(data.ref('owner.ownedTodos.id')) <= 2",
    },
  },
} satisfies InstantRules;

export default rules;
```

## Connection Status

```javascript
// Vanilla JS
const unsub = db.subscribeConnectionStatus((status) => {
  const statusMap = {
    connecting: 'authenticating',
    opened: 'authenticating',
    authenticated: 'connected',
    closed: 'closed',
    errored: 'errored',
  };
  console.log('Connection:', statusMap[status]);
});

// React
function App() {
  const status = db.useConnectionStatus();
  const statusMap = { /* same as above */ };
  return <div>Connection: {statusMap[status]}</div>;
}
```

## CDN

```jsx
<script src="https://www.unpkg.com/@instantdb/core@latest/dist/standalone/index.umd.cjs"></script>

<script>
  const { init, id } = instant;
  const db = init({ appId: '__APP_ID__' });

  async function createMessage() {
    await db.transact(
      db.tx.messages[id()].update({ text: 'Hello world!' })
    );
  }
</script>
```

## Local IDs

Persistent identifier across refreshes - useful for guest mode:

```js
import { init } from '@instantdb/react';

const db = init({ appId: '__APP_ID__' });

// Vanilla
const id = await db.getLocalId('guest');
console.log(id, 'stays same on refresh');

// React hook
function App() {
  const id = db.useLocalId('guest');
  if (!id) return;
  console.log(id, 'stays same on refresh');
}
```

Different args produce different IDs. Use in transactions, queries, [ruleParams](/docs/permissions#rule-params).

## Admin Queries + NextJS Caching

[`adminDB.query`](/docs/backend#query) uses fetch - NextJS caching works by default. Control via [fetch options](https://nextjs.org/docs/app/building-your-application/caching#fetch):

```js
// Revalidate hourly
await adminDB.query(
  { goals: {} },
  { fetchOpts: { next: { revalidate: 3600 } } }
);

// Tag-based
await adminDB.query(
  { goals: {} },
  { fetchOpts: { next: { tags: ['goals:all'] } } }
);
```

## Composite Keys

No built-in composite keys - create composite column:

```js
import { i } from '@instantdb/core';

const _schema = i.schema({
  entities: {
    locations: i.entity({
      latitude: i.number().indexed(),
      longitude: i.number().indexed(),
      latLong: i.string().unique() // composite
    }),
  },
});
```

Usage:

```js
function createLocation({ latitude, longitude }) {
  db.transact(
    db.tx.locations[id()].update({
      latitude,
      longitude,
      latLong: `${latitude}_${longitude}`,
    })
  );
}
```

Enforce via permissions:

```js
const rules = {
  locations: {
    allow: {
      create: "(data.latitude + '_' + data.longitude) == data.latLong",
      update: "(newData.latitude + '_' + newData.longitude) == newData.latLong",
    },
  },
};
```

## Local vs Production Apps

Separate apps for each env:

```javascript
// lib/db.ts
import { init } from '@instantdb/react';

const APP_ID = process.env.NEXT_PUBLIC_INSTANT_APP_ID;
export const db = init({ appId: APP_ID });
```

```bash
# .env.local
NEXT_PUBLIC_INSTANT_APP_ID=your-local-app-id

# .env.production
NEXT_PUBLIC_INSTANT_APP_ID=your-production-app-id
```

Workflow:

1. Push schema/perms locally: `npx instant-cli push --app your-local-app-id`
2. Test locally
3. Push to prod: `npx instant-cli push --app your-production-app-id`
4. Deploy code

## Timeouts

5 second limit for queries and transactions. Use Sandbox tab to measure (30s limit there).

Optimize: add indexes, use pagination, batch large transactions.

# Common Mistakes

## Schema

### Reusing Labels

```
// ❌ Conflicting labels
const _schema = i.schema({
  links: {
    postAuthor: {
      forward: { on: 'posts', has: 'one', label: 'author' },
      reverse: { on: 'profiles', has: 'many', label: 'posts' },
    },
    postEditor: {
      forward: { on: 'posts', has: 'one', label: 'editor' },
      reverse: { on: 'profiles', has: 'many', label: 'posts' }, // Conflicts!
    },
  },
});

// ✅ Unique labels
const _schema = i.schema({
  links: {
    postAuthor: {
      forward: { on: 'posts', has: 'one', label: 'author' },
      reverse: { on: 'profiles', has: 'many', label: 'authoredPosts' },
    },
    postEditor: {
      forward: { on: 'posts', has: 'one', label: 'editor' },
      reverse: { on: 'profiles', has: 'many', label: 'editedPosts' },
    },
  },
});
```

## Permissions

### Missing data.ref

```
// ❌ Error
{
  "comments": {
    "allow": {
      "update": "auth.id in data.post.author.id"
    }
  }
}

// ✅ Use data.ref
{
  "comments": {
    "allow": {
      "update": "auth.id in data.ref('post.author.id')"
    }
  }
}
```

### Missing Attribute in data.ref

```
// ❌ No attribute
"view": "auth.id in data.ref('author')"

// ✅ Specify attribute
"view": "auth.id in data.ref('author.id')"
```

### Using == Instead of in

```
// ❌ data.ref returns list
"view": "data.ref('admins.id') == auth.id"

// ✅ Use in operator
"view": "auth.id in data.ref('admins.id')"
```

Even one-to-one relationships return lists:

```
// ❌ Wrong
"view": "auth.id == data.ref('owner.id')"

// ✅ Correct
"view": "auth.id in data.ref('owner.id')"
```

### Checking Empty Lists

```
// ❌ Wrong approaches
"view": "data.ref('owner.id') != null"
"view": "data.ref('owner.id').length > 0"
"view": "data.ref('owner') != []"

// ✅ Correct
"view": "data.ref('owner.id') != []"
```

### Missing $user Prefix

```
// ❌ Missing prefix
{
  "adminActions": {
    "allow": {
      "create": "'admin' in auth.ref('role.type')"
    }
  }
}

// ✅ Use $user prefix
{
  "adminActions": {
    "allow": {
      "create": "'admin' in auth.ref('$user.role.type')"
    }
  }
}
```

### auth.ref Extract First Element

```
// ❌ auth.ref returns list
"create": "auth.ref('$user.role.type') == 'admin'"

// ✅ Extract first
"create": "auth.ref('$user.role.type')[0] == 'admin'"
```

### newData.ref Doesn't Exist

```
// ❌ newData.ref not available
{
  "posts": {
    "allow": {
      "update": "auth.id == data.authorId && newData.ref('isPublished') == data.ref('isPublished')"
    }
  }
}
```

Only `newData.attribute` works directly.

### ref Requires String Literals

```
// ❌ Variables not allowed
"view": "auth.id in data.ref(someVariable + '.members.id')"

// ✅ String literals only
"view": "auth.id in data.ref('team.members.id')"
```

## Transactions

### No create Method

```
// ❌ create doesn't exist
db.transact(db.tx.todos[id()].create({ text: "Buy groceries" }));

// ✅ Use update
db.transact(db.tx.todos[id()].update({ text: "Buy groceries" }));
```

### update vs merge for Nested Objects

```
// ❌ Overwrites entire object
db.transact(
  db.tx.profiles[userId].update({
    preferences: { theme: 'dark' }, // Other prefs lost
  })
);

// ✅ Use merge
db.transact(db.tx.profiles[userId].merge({
  preferences: { theme: "dark" }
}));
```

### Removing Keys from Nested Objects

```
// ❌ update overwrites
db.transact(db.tx.profiles[userId].update({
  preferences: { notifications: null }
}));

// ✅ merge removes key
db.transact(db.tx.profiles[userId].merge({
  preferences: { notifications: null }
}));
```

### Large Transaction Timeouts

```
// ❌ 1000 items at once - timeout
const txs = [];
for (let i = 0; i < 1000; i++) {
  txs.push(db.tx.todos[id()].update({ text: `Todo ${i}` }));
}
await db.transact(txs);

// ❌ 1000 separate transactions - timeout
for (let i = 0; i < 1000; i++) {
  db.transact(db.tx.todos[id()].update({ text: `Todo ${i}` }));
}

// ✅ Batch properly
const batchSize = 100;
const createManyTodos = async (count) => {
  for (let i = 0; i < count; i += batchSize) {
    const batch = [];
    for (let j = 0; j < batchSize && i + j < count; j++) {
      batch.push(db.tx.todos[id()].update({
        text: `Todo ${i + j}`,
        done: false
      }));
    }
    await db.transact(batch);
  }
};

createManyTodos(1000);
```

## Queries

### Not Nesting Namespaces

```
// ❌ Fetches all goals and all todos separately
const query = { goals: {}, todos: {} };

// ✅ Fetch goals with their todos
const query = { goals: { todos: {} } };
```

### where Placement

```
// ❌ where outside $
const query = {
  goals: {
    where: { id: 'goal-1' },
  },
};

// ✅ where inside $
const query = {
  goals: {
    $: { where: { id: 'goal-1' } },
  },
};
```

### Filtering Associated Values

```
// ❌ Wrong syntax
const query = {
  goals: {
    $: {
      where: {
        todos: { title: 'Go running' },
      },
    },
  },
};

// ✅ Use dot notation
const query = {
  goals: {
    $: {
      where: {
        'todos.title': 'Go running',
      },
    },
    todos: {},
  },
};
```

### or and and Operators

```
// ❌ or takes array not object
const query = {
  todos: {
    $: {
      where: {
        or: { priority: 'high', dueDate: { $lt: tomorrow } },
      },
    },
  },
};

// ✅ Array syntax
const query = {
  todos: {
    $: {
      where: {
        or: [{ priority: 'high' }, { dueDate: { $lt: tomorrow } }],
      },
    },
  },
};
```

### Comparison Operators

```
// ❌ Non-indexed attribute
const query = {
  todos: {
    $: {
      where: {
        nonIndexedAttr: { $gt: 5 },
      },
    },
  },
};

// ✅ Indexed attribute
const query = {
  todos: {
    $: {
      where: {
        timeEstimate: { $gt: 2 },
      },
    },
  },
};

// Operators: $gt, $lt, $gte, $lte
```

### limit on Nested Namespaces

```
// ❌ limit only works top-level
const query = {
  goals: {
    todos: {
      $: { limit: 5 },
    },
  },
};

// ✅ Top-level only
const query = {
  todos: {
    $: { limit: 10 },
  },
};

// With offset
const query = {
  todos: {
    $: { limit: 10, offset: 10 },
  },
};
```

### orderBy vs order

```
// ❌ orderBy doesn't exist
const query = {
  todos: {
    $: {
      orderBy: { serverCreatedAt: 'desc' },
    },
  },
};

// ✅ Use order
const query = {
  todos: {
    $: {
      order: { serverCreatedAt: 'desc' },
    },
  },
};
```

### Ordering Non-Indexed Fields

```
// ❌ Must be indexed
const query = {
  todos: {
    $: {
      order: { nonIndexedField: 'desc' },
    },
  },
};
```

## Backend

### useQuery on Server

```
// ❌ Don't use useQuery
const { data, isLoading, error } = db.useQuery({ todos: {} });

// ✅ Use db.query (async)
const fetchTodos = async () => {
  try {
    const data = await db.query({ todos: {} });
    const { todos } = data;
    console.log(`Found ${todos.length} todos`);
    return todos;
  } catch (error) {
    console.error('Error:', error);
    throw error;
  }
};
```

Admin SDK queries bypass permissions.

## Auth

InstantDB doesn't provide username/password auth.

Use magic code or OAuth flows client-side. For password auth, implement custom flow with Admin SDK.
