# Reading data

How to read data with Instant using InstaQL.

Instant uses declarative syntax for querying. Like GraphQL without the configuration.

## Fetch namespace

Get all entities of a namespace.

```javascript
import { init } from '@instantdb/react';

const APP_ID = '__APP_ID__';
const db = init({ appId: APP_ID });

function App() {
  const query = { goals: {} };
  const { isLoading, error, data } = db.useQuery(query);
}
```

Result:

```javascript
console.log(data)
{
  "goals": [
    { "id": healthId, "title": "Get fit!" },
    { "id": workId, "title": "Get promoted!" }
  ]
}
```

SQL equivalent: `const data = { goals: doSQL('SELECT * FROM goals') };`

## Fetch multiple namespaces

```javascript
const query = { goals: {}, todos: {} };
const { isLoading, error, data } = db.useQuery(query);
```

Returns data for both namespaces.

SQL equivalent: two separate queries.

```javascript
const data = {
  goals: doSQL('SELECT * from goals'),
  todos: doSQL('SELECT * from todos'),
};
```

## Fetch specific entity

Use `where` to filter entities.

```javascript
const query = {
  goals: {
    $: {
      where: { id: healthId },
    },
  },
};
const { isLoading, error, data } = db.useQuery(query);
```

SQL equivalent: `const data = { goals: doSQL("SELECT * FROM goals WHERE id = 'healthId'") };`

## Fetch associations

Fetch goals and their related todos.

```javascript
const query = {
  goals: {
    todos: {},
  },
};
const { isLoading, error, data } = db.useQuery(query);
```

Returns goals with nested todos:

```javascript
{
  "goals": [
    {
      "id": healthId,
      "title": "Get fit!",
      "todos": [...],
    },
    {
      "id": workId,
      "title": "Get promoted!",
      "todos": [...],
    }
  ]
}
```

### SQL comparison

Complex SQL with joins or two queries with client-side marshalling:

```javascript
const _goals = doSQL("SELECT * from goals")
const _todos = doSQL("SELECT * from todos")
const data = {goals: _goals.map(g => (
  return {...g, todos: _todos.filter(t => t.goal_id === g.id)}
))
```

InstaQL is much simpler for nested relations.

## Fetch specific associations

### A) Associations for filtered namespace

```javascript
const query = {
  goals: {
    $: { where: { id: healthId } },
    todos: {},
  },
};
```

### B) Filter namespace by associated values

Filter namespaces by their associations:

```javascript
const query = {
  goals: {
    $: {
      where: { 'todos.title': 'Code a bunch' },
    },
    todos: {},
  },
};
```

### C) Filter associations

Filter associated data:

```javascript
const query = {
  goals: {
    todos: {
      $: { where: { title: 'Go on a run' } },
    },
  },
};
```

Returns all goals, but only todos matching the filter.

Difference between three cases:
- A) All todos for goal with id `health`
- B) Goals with at least one todo titled `Code a bunch`
- C) All goals with filtered associated todos by title `Go on a run`

## Inverse Associations

Associations work in reverse order.

```javascript
const query = {
  todos: {
    goals: {},
  },
};
```

## Defer queries

Defer queries until condition is met. Useful when waiting for data before running query.

```javascript
const { isLoading, user, error } = db.useAuth();

const {
  isLoading: isLoadingTodos,
  error,
  data,
} = db.useQuery(
  user
    ? {
        todos: {
          $: { where: { 'owner.id': user.id } },
        },
      }
    : null,
);
```

NOTE: Passing `null` to `db.useQuery` sets `isLoading` to true. `isLoadingTodos` will always be true if user is not logged in.

## Pagination

Limit items from top level namespace with `limit`:

```javascript
const query = {
  todos: {
    $: { limit: 10 }, // only for top-level namespaces
  },
};

const { isLoading, error, data, pageInfo } = db.useQuery(query);
```

Supports offset-based and cursor-based pagination for top-level namespaces.

### Offset

```javascript
const query = {
  todos: {
    $: {
      limit: 10,
      offset: 10, // only for top-level namespaces
    },
  },
};
```

React example:

```jsx
const [pageNumber, setPageNumber] = React.useState(1);
const pageSize = 10;

const query = {
  todos: {
    $: {
      limit: pageSize,
      offset: pageSize * (pageNumber - 1),
    },
  },
};

const { isLoading, error, data } = db.useQuery(query);

const loadNextPage = () => setPageNumber(pageNumber + 1);
const loadPreviousPage = () => setPageNumber(pageNumber - 1);
```

### Cursors

Next page with `endCursor` from `pageInfo`:

```javascript
const query = {
  todos: {
    $: {
      first: 10,
      after: pageInfo?.todos?.endCursor,
    },
  },
};
```

Previous page with `startCursor`:

```javascript
const query = {
  todos: {
    $: {
      last: 10,
      before: pageInfo?.todos?.startCursor,
    },
  },
};
```

React example:

```jsx
const pageSize = 10;
const [cursors, setCursors] = React.useState({ first: pageSize });

const query = {
  todos: {
    $: { ...cursors },
  },
};

const { isLoading, error, data, pageInfo } = db.useQuery(query);

const loadNextPage = () => {
  const endCursor = pageInfo?.todos?.endCursor;
  if (endCursor) {
    setCursors({ after: endCursor, first: pageSize });
  }
};

const loadPreviousPage = () => {
  const startCursor = pageInfo?.todos?.startCursor;
  if (startCursor) {
    setCursors({ before: startCursor, last: pageSize });
  }
};
```

### Ordering

Default ordering is by creation time, ascending. Change with `order`:

```javascript
const query = {
  todos: {
    $: {
      limit: 10,
      order: { serverCreatedAt: 'desc' }, // limited to top-level namespaces
    },
  },
};
```

`serverCreatedAt` is reserved key for time object was first persisted. Takes 'asc' (default) or 'desc'.

Can also order by any indexed attribute with checked type.

Add indexes and checked types from [Explorer on Instant dashboard](/dash?t=explorer) or [cli](/docs/cli).

```typescript
// Get todos due next
const query = {
  todos: {
    $: {
      limit: 10,
      where: { dueDate: { $gt: Date.now() } },
      order: { dueDate: 'asc' },
    },
  },
};
```

Order works in nested namespaces:

```typescript
// Goals with todos ordered by due date
const query = {
  goals: {
    todos: {
      $: { order: { dueDate: 'asc' } },
    },
  },
};
```

Order not supported on nested attributes (e.g., can't order todos by "owner.name"). This differs from `where`, which supports filtering on nested attributes.

```typescript
// Order does not support nested attributes
const query = {
  todos: {
    $: {
      order: { 'owner.name': 'asc' }, // Cannot order by nested attributes
    },
  },
};

// Where does support filtering on nested attributes
const query = {
  todos: {
    $: {
      where: { 'owner.name': 'alyssa.p.hacker@instantdb.com' },
    },
  },
};
```

## Advanced filtering

### Multiple `where` conditions

Multiple keys filter entities matching all conditions.

```javascript
const query = {
  todos: {
    $: {
      where: {
        completed: true,
        'goals.title': 'Get promoted!',
      },
    },
  },
};
```

### And

`and` queries useful for filtering entities matching multiple associated values.

Find goals with todos titled `Drink protein` and `Go on a run`:

```javascript
const query = {
  goals: {
    $: {
      where: {
        and: [
          { 'todos.title': 'Drink protein' },
          { 'todos.title': 'Go on a run' },
        ],
      },
    },
  },
};
```

### OR

`or` queries filter entities matching any clause:

```javascript
const query = {
  todos: {
    $: {
      where: {
        or: [{ title: 'Code a bunch' }, { title: 'Review PRs' }],
      },
    },
  },
};
```

### $in

`$in` filters entities matching any item in list. Shorthand for `or` on single key.

```javascript
const query = {
  todos: {
    $: {
      where: {
        title: { $in: ['Code a bunch', 'Review PRs'] },
      },
    },
  },
};
```

### Comparison operators

Comparison operators on indexed fields with checked types.

Add indexes and checked types from [Explorer on Instant dashboard](/dash?t=explorer) or [cli with Schema-as-code](/docs/modeling-data).

| Operator | Description | JS equivalent |
| :------: | :----------------------: | :-----------: |
| `$gt` | greater than | `>` |
| `$lt` | less than | `<` |
| `$gte` | greater than or equal to | `>=` |
| `$lte` | less than or equal to | `<=` |

```javascript
const query = {
  todos: {
    $: {
      where: { timeEstimateHours: { $gt: 24 } },
    },
  },
};
```

Dates stored as timestamps (milliseconds since epoch, e.g., `Date.now()`) or ISO 8601 strings (e.g., `JSON.stringify(new Date())`) and queried in same formats:

```javascript
const now = '2024-11-26T15:25:00.054Z';
const query = {
  todos: {
    $: { where: { dueDate: { $lte: now } } },
  },
};
```

Error if using comparison operators on non-indexed/non-type-checked data:

```javascript
console.log(error);
{
  "message": "Validation failed for query",
  "hint": {
    "errors": [
      {
        "message": "The `todos.priority` attribute must be indexed to use comparison operators."
      }
    ]
  }
}
```

### $ne

`$ne` returns entities not matching provided value, including where field is null or undefined.

```javascript
const query = {
  todos: {
    $: {
      where: { location: { $ne: 'work' } },
    },
  },
};
```

### $isNull

`$isNull` filters entities by whether field value is null or undefined.

`$isNull: true` returns entities where field is null or undefined.
`$isNull: false` returns entities where field is not null and not undefined.

```javascript
const query = {
  todos: {
    $: {
      where: { location: { $isNull: false } },
    },
  },
};
```

### $like

`$like` on indexed fields with checked `string` type.

`$like` queries return entities matching case sensitive substring.

For case insensitive matching use `$ilike`.

| Example | Description | JS equivalent |
| :-----------------------: | :-------------------: | :-----------: |
| `{ $like: "Get%" }` | Starts with 'Get' | `startsWith` |
| `{ $like: "%promoted!" }` | Ends with 'promoted!' | `endsWith` |
| `{ $like: "%fit%" }` | Contains 'fit' | `includes` |

Find goals ending with "promoted!":

```javascript
const query = {
  goals: {
    $: {
      where: { title: { $like: '%promoted!' } },
    },
  },
};
```

`$like` works in nested queries:

```javascript
// Find goals with todos containing "standup"
const query = {
  goals: {
    $: {
      where: { 'todos.title': { $like: '%standup%' } },
    },
  },
};
```

Case-insensitive matching with `$ilike`:

```javascript
const query = {
  goals: {
    $: {
      where: { 'todos.title': { $ilike: '%stand%' } },
    },
  },
};
```

## Select fields

InstaQL query fetches all fields for each object.

Select specific fields with `fields` param:

```javascript
const query = {
  goals: {
    $: { fields: ['status'] },
  },
};
```

`id` always returned even if not specified.

`fields` works with nested relations:

```javascript
const query = {
  goals: {
    $: { fields: ['title'] },
    todos: {
      $: { fields: ['id'] },
    },
  },
};
```

Using `fields` reduces data transfer and minimizes re-renders in React apps if no changes to selected fields.

`fields` doesn't restrict client from doing full query. For sensitive data use [permissions](/docs/permissions#fields) to restrict access.

## Typesafety

By default, `db.useQuery` is permissive. Don't need schema upfront.

```typescript
const query = {
  goals: {
    todos: {},
  },
};
const { isLoading, error, data } = db.useQuery(query);
```

As app grows, enforce types with [schema](/docs/modeling-data):

```typescript
// instant.schema.ts

import { i } from '@instantdb/react';

const _schema = i.schema({
  entities: {
    goals: i.entity({
      title: i.string(),
    }),
    todos: i.entity({
      title: i.string(),
      text: i.string(),
      done: i.boolean(),
      createdAt: i.date(),
      dueDate: i.date(),
    }),
  },
  links: {
    goalsTodos: {
      forward: { on: 'goals', has: 'many', label: 'todos' },
      reverse: { on: 'todos', has: 'many', label: 'goals' },
    },
  },
});

type _AppSchema = typeof _schema;
interface AppSchema extends _AppSchema {}
const schema: AppSchema = _schema;

export type { AppSchema };
export default schema;
```

Instant gives intellisense for queries.

### Utility Types

Utility types to help use schema in TypeScript.

Define query upfront:

```typescript
import { InstaQLParams } from '@instantdb/react';
import { AppSchema } from '../instant.schema.ts';

const query = {
  goals: { todos: {} },
} satisfies InstaQLParams<AppSchema>;
```

Define result type:

```typescript
import { InstaQLResult } from '@instantdb/react';
import { AppSchema } from '../instant.schema.ts';

type GoalsTodosResult = InstaQLResult<AppSchema, { goals: { todos: {} } }>;
```

Extract particular entity:

```typescript
import { InstaQLEntity } from '@instantdb/react';
import { AppSchema } from '../instant.schema.ts';

type Todo = InstaQLEntity<AppSchema, 'todos'>;
```

Specify links relative to entity:

```typescript
type TodoWithGoals = InstaQLEntity<AppSchema, 'todos', { goals: {} }>;
```

Learn more about writing schemas in [Modeling Data](/docs/modeling-data) section.

## Query once

Don't want subscription, just fetch data once. Use `queryOnce` instead of `useQuery`. Returns promise that resolves with data.

Unlike `useQuery`, `queryOnce` throws error if user is offline. Intended for use cases needing most up-to-date data.

```javascript
const query = { todos: {} };
const { data } = await db.queryOnce(query);
// returns same data as useQuery, but without isLoading and error fields
```

Pagination with `queryOnce`:

```javascript
const query = {
  todos: {
    $: {
      limit: 10,
      offset: 10,
    },
  },
};

const { data, pageInfo } = await db.queryOnce(query);
// pageInfo behaves same as with useQuery
```
