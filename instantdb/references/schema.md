# Modeling data

How to model data with Instant's schema.

## Schema as Code

Use CLI to generate `instant.schema.ts` and `instant.perms.ts`:

```shell
npx instant-cli@latest init
```

## instant.schema.ts

Example micro-blog schema with authors, posts, comments, tags:

```typescript
// instant.schema.ts
import { i } from '@instantdb/react';

const _schema = i.schema({
  entities: {
    $users: i.entity({
      email: i.string().unique().indexed(),
    }),
    profiles: i.entity({
      nickname: i.string(),
      createdAt: i.date(),
    }),
    posts: i.entity({
      title: i.string(),
      body: i.string(),
      createdAt: i.date(),
    }),
    comments: i.entity({
      body: i.string(),
      createdAt: i.date(),
    }),
    tags: i.entity({
      title: i.string(),
    }),
  },
  links: {
    postAuthor: {
      forward: { on: 'posts', has: 'one', label: 'author' },
      reverse: { on: 'profiles', has: 'many', label: 'authoredPosts' },
    },
    commentPost: {
      forward: { on: 'comments', has: 'one', label: 'post' },
      reverse: { on: 'posts', has: 'many', label: 'comments' },
    },
    commentAuthor: {
      forward: { on: 'comments', has: 'one', label: 'author' },
      reverse: { on: 'profiles', has: 'many', label: 'authoredComments' },
    },
    postsTags: {
      forward: { on: 'posts', has: 'many', label: 'tags' },
      reverse: { on: 'tags', has: 'many', label: 'posts' },
    },
    profileUser: {
      forward: { on: 'profiles', has: 'one', label: '$user' },
      reverse: { on: '$users', has: 'one', label: 'profile' },
    },
  },
});

type _AppSchema = typeof _schema;
interface AppSchema extends _AppSchema {}
const schema: AppSchema = _schema;

export type { AppSchema };
export default schema;
```

Three core building blocks: Namespaces, Attributes, Links.

## 1) Namespaces

Namespaces = tables (SQL) or collections (NoSQL). Examples: `$users`, `profiles`, `posts`, `comments`, `tags`.

```typescript
const _schema = i.schema({
  entities: {
    posts: i.entity({
      // ...
    }),
  },
});
```

## 2) Attributes

Attributes = columns (SQL) or fields (NoSQL). Properties on namespaces.

```typescript
const _schema = i.schema({
  entities: {
    posts: i.entity({
      title: i.string(),
      body: i.string(),
      createdAt: i.date(),
    }),
  },
});
```

### Typing attributes

Available types: `i.string()`, `i.number()`, `i.boolean()`, `i.date()`, `i.json()`, `i.any()`.

`i.date()` accepts numeric timestamp (milliseconds) or ISO 8601 string. `JSON.stringify(new Date())` returns ISO 8601.

Instant enforces types and provides TypeScript hints.

### Required constraints

All attributes are required by default. Backend enforces this - errors if you try to add entity without required attribute.

```typescript
const _schema = i.schema({
  entities: {
    posts: i.entity({
      title: i.string(), // required
      published: i.date(), // required
    }),
  },
});

db.transact(
  db.tx.posts[id()].update({
    title: 'abc', // no published - will throw
  }),
);
```

Mark as optional with `.optional()`:

```typescript
const _schema = i.schema({
  entities: {
    posts: i.entity({
      title: i.string(), // required
      published: i.date().optional(), // optional
    }),
  },
});

db.transact(
  db.tx.posts[id()].update({
    title: 'abc', // no published - ok
  }),
);
```

Query results reflect this: `title: string` vs `published: string | number | null`.

Can set required on forward links:

```typescript
postAuthor: {
  forward: { on: 'posts', has: 'one', label: 'author', required: true },
  reverse: { on: 'profiles', has: 'many', label: 'authoredPosts' },
},
```

For legacy attributes that need TypeScript non-null type but no backend check, use `.clientRequired()`:

```typescript
const _schema = i.schema({
  entities: {
    posts: i.entity({
      title: i.string().clientRequired(),
      published: i.date().optional(),
    }),
  },
});
```

### Unique constraints

Mark attributes as unique - Instant guarantees constraint. Also speeds up queries filtering by that attribute.

```typescript
const _schema = i.schema({
  entities: {
    posts: i.entity({
      slug: i.string().unique(),
    }),
  },
});
```

```typescript
const query = {
  posts: {
    $: {
      where: {
        slug: 'completing_sicp', // fast query
      },
    },
  },
};
```

### Indexing attributes

Index attributes to speed up queries. Indexed attributes can use comparison operators (`$gt`, `$lt`, `$gte`, `$lte`) and `order` clauses.

```typescript
const _schema = i.schema({
  entities: {
    products: i.entity({
      price: i.number().indexed(),
    }),
  },
});
```

```typescript
const query = {
  products: {
    $: {
      where: {
        price: { $lt: 100 },
      },
      order: {
        price: 'desc',
      },
    },
  },
};
```

Indexing speeds up queries even without comparison operators or order clauses.

## 3) Links

Links connect two namespaces. Define in both forward and reverse direction:

```typescript
postAuthor: {
  forward: { on: "posts", has: "one", label: "author" },
  reverse: { on: "profiles", has: "many", label: "authoredPosts" },
}
```

- `posts.author` links to one `profiles` entity
- `profiles.authoredPosts` links back to many `posts` entities

Query in both directions:

```typescript
// Query posts with author
const query1 = {
  posts: {
    author: {},
  },
};

// Query profiles with authoredPosts
const query2 = {
  profiles: {
    authoredPosts: {},
  },
};
```

Four relationship types: many-to-many, many-to-one, one-to-many, one-to-one.

### Cascade Delete

Links with `has: "one"` can set `onDelete: "cascade"`. Deleting one entity deletes linked entities:

```typescript
postAuthor: {
  forward: { on: "posts", has: "one", label: "author", onDelete: "cascade" },
  reverse: { on: "profiles", has: "many", label: "authoredPosts" },
}

// deletes profile and all linked posts
db.tx.profiles[user_id].delete();
```

Without cascade, deleting only removes links, not entities.

Can model links in other direction:

```typescript
postAuthor: {
  forward: { on: "profiles", has: "many", label: "authoredPosts" },
  reverse: { on: "posts", has: "one", label: "author", onDelete: "cascade" },
}
```

## Publishing your schema

Push schema to app:

```shell
npx instant-cli@latest push schema
```

CLI shows changes and runs them.

## Use schema for typesafety

Use schema in `init`:

```typescript
import { init } from '@instantdb/react';
import schema from '../instant.schema.ts';

const db = init({
  appId: process.env.NEXT_PUBLIC_INSTANT_APP_ID!,
  schema,
});
```

All queries and transactions get typesafety.

If you haven't pushed schema via CLI, `transact` auto-creates missing entities.

## Update or Delete attributes

Can modify or delete attributes after creating. Can't use CLI yet, use dashboard.

To rename `posts.createdAt` to `posts.publishedAt`:

1. Go to [Dashboard](https://instantdb.com/dash)
2. Click Explorer
3. Click posts
4. Click Edit Schema
5. Click `createdAt`

Modal lets you rename, index, or delete attribute.

## Secure your schema with permissions

New entities/attributes can be created on the fly via `transact` - useful for dev, not for production.

Prevent schema changes by adding permissions:

```typescript
// instant.perms.ts
import type { InstantRules } from '@instantdb/react';

const rules = {
  attrs: {
    allow: {
      $default: 'false',
    },
  },
} satisfies InstantRules;

export default rules;
```

Push to production:

```bash
npx instant-cli@latest push perms
```

Can still make changes in explorer or CLI, but client-side transactions that modify schema will fail.
