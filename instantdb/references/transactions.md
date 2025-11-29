# Writing data

Write data with InstaML (Firebase-inspired mutation language).

## Creating data

Use `create` to make entities:

```typescript
import { init, id } from '@instantdb/react';

const db = init({ appId: '__APP_ID__' });

db.transact(db.tx.goals[id()].create({ title: 'eat' }));
```

Creates a goal with random id via `id()` and attribute `title: 'eat'`.

Store strings, numbers, booleans, arrays, objects. Can use functions for values:

```javascript
db.transact(
  db.tx.goals[id()].create({
    title: ['eat', 'sleep', 'hack', 'repeat'][Math.floor(Math.random() * 4)],
  }),
);
```

## Update data

`update` modifies entities:

```javascript
const eatId = id();
db.transact(db.tx.goals[eatId].update({ lastTimeEaten: 'Today' }));
```

Only updates specified attributes. NoSQL-style - entities in same namespace can have different schemas.

`update` works as upsert (create or update). To force strict update mode:

```javascript
db.transact(
  db.tx.goals[eatId].update({ lastTimeEaten: 'Today' }, { upsert: false }),
);
```

## Merge data

`update` overwrites attributes. For JSON objects this loses unspecified data and risks clobbering other clients' changes.

```javascript
// User 1 saves {'0-0': 'red'}
db.transact(db.tx.games[gameId].update({ state: { '0-0': 'red' } }));

// User 2 saves {'0-1': 'blue'}
db.transact(db.tx.games[gameId].update({ state: { '0-1': 'blue' } }));

// Problem: User 2 overwrites User 1
// Final State: {'0-1': 'blue' }
```

`merge` deep merges objects like [lodash merge](https://lodash.com/docs/4.17.15#merge):

```javascript
// User 1 saves {'0-0': 'red'}
db.transact(db.tx.games[gameId].merge({ state: { '0-0': 'red' } }));

// User 2 saves {'0-1': 'blue'}
db.transact(db.tx.games[gameId].merge({ state: { '0-1': 'blue' } }));

// Both states merged
// Final State: {'0-0': 'red', '0-1': 'blue' }
```

`merge` only merges objects. For arrays, numbers, booleans it overwrites.

Remove keys by setting to `null` (not `undefined`):

```javascript
// State: {'0-0': 'red', '0-1': 'blue' }
db.transact(db.tx.games[gameId].merge({ state: { '0-1': null } }));
// New State: {'0-0': 'red' }
```

## Delete data

```javascript
db.transact(db.tx.goals[eatId].delete());
```

Delete all entities in namespace:

```javascript
const { data } = db.useQuery({ goals: {} });
db.transact(data.goals.map((g) => db.tx.goals[g.id].delete()));
```

`delete` also removes associations - no cleanup needed.

## Link data

`link` creates associations:

```javascript
db.transact([
  db.tx.todos[workoutId].update({ title: 'Go on a run' }),
  db.tx.goals[healthId].update({ title: 'Get fit!' }),
]);

db.transact(db.tx.goals[healthId].link({ todos: workoutId }));
```

Can chain in one transact:

```javascript
db.transact([
  db.tx.todos[workoutId].update({ title: 'Go on a run' }),
  db.tx.goals[healthId]
    .update({ title: 'Get fit!' })
    .link({ todos: workoutId }),
]);
```

Link multiple ids:

```javascript
db.transact([
  db.tx.todos[workoutId].update({ title: 'Go on a run' }),
  db.tx.todos[proteinId].update({ title: 'Drink protein' }),
  db.tx.todos[sleepId].update({ title: 'Go to bed early' }),
  db.tx.goals[healthId]
    .update({ title: 'Get fit!' })
    .link({ todos: [workoutId, proteinId, sleepId] }),
]);
```

Links are bi-directional - query in both directions:

```javascript
const { data } = db.useQuery({
  goals: { todos: {} },
  todos: { goals: {} },
});
```

## Unlink data

```javascript
db.transact(db.tx.goals[healthId].unlink({ todos: workoutId }));
```

Removes links in both directions. Can unlink from either side:

```javascript
db.transact([db.tx.todos[workoutId].unlink({ goals: healthId })]);
```

Unlink multiple ids:

```javascript
db.transact([
  db.tx.goals[healthId].unlink({ todos: [workoutId, proteinId, sleepId] }),
  db.tx.goals[workId].unlink({ todos: [standupId, reviewPRsId, focusId] }),
]);
```

## Lookup by unique attribute

Use `lookup` instead of id for entities with unique attributes:

```javascript
import { lookup } from '@instantdb/react';

db.transact(
  db.tx.profiles[lookup('email', 'eva_lu_ator@instantdb.com')].update({
    name: 'Eva Lu Ator',
  }),
);
```

Takes attribute name and value. Updates entity with that value or creates new one if none exists.

Works with `update`, `delete`, `merge`, `link`, `unlink`.

## Lookups in links

Use lookups for linked entity ids:

```javascript
db.transact(
  db.tx.users[lookup('email', 'eva_lu_ator@instantdb.com')].link({
    posts: lookup('number', 15),
  }),
);
```

## Transacts are atomic

All transactions in `db.transact` commit atomically. If any fail, none commit.

## Typesafety

By default `db.transact` is permissive - creates missing attributes:

```typescript
db.tx.todos[workoutId].update({
  dueDate: Date.now() + 60 * 1000, // auto-creates attribute
});
```

Use [schema](/docs/modeling-data) to enforce types:

```typescript
// instant.schema.ts
const _schema = i.schema({
  entities: {
    todos: i.entity({
      dueDate: i.date(),
    }),
  },
});
```

Instant enforces types and provides intellisense.

Utility types for abstractions:

```typescript
import { UpdateParams } from '@instantdb/react';
import { AppSchema } from '../instant.schema.ts';

type EntityTypes = keyof AppSchema['entities'];

function myCustomUpdate<EType extends EntityTypes>(
  etype: EType,
  args: UpdateParams<AppSchema, EType>,
) {
  // ..
}
```

```typescript
import { LinkParams } from '@instantdb/react';
import { AppSchema } from '../instant.schema.ts';

type EntityTypes = keyof AppSchema['entities'];

function myCustomLink<EType extends EntityTypes>(
  etype: EType,
  args: LinkParams<AppSchema, EType>,
) {
  // ..
}
```

See [Modeling Data](/docs/modeling-data) for more on schemas.

## Batching transactions

Batch large transaction sets to avoid limits and timeouts.

Create 3000 goals in batches of 100:

```javascript
const batchSize = 100;
const createGoals = async (total) => {
  let goals = [];
  const batches = [];

  for (let i = 0; i < total; i++) {
    const goalNumber = i + 1;
    goals.push(
      db.tx.goals[id()].update({ goalNumber, title: `Goal ${goalNumber}` }),
    );

    if (goals.length >= batchSize) {
      batches.push(goals);
      goals = [];
    }
  }

  if (goals.length) {
    batches.push(goals);
  }

  for (const batch of batches) {
    await db.transact(batch);
  }
};
```

## Using the tx proxy object

`db.tx` is a [proxy object](https://developer.mozilla.org/en-US/docs/Web/JavaScript/Reference/Global_Objects/Proxy) for creating transaction chunks.

Format: `db.tx.NAMESPACE_LABEL[ENTITY_IDENTIFIER].ACTION(ACTION_SPECIFIC_DATA)`

- `NAMESPACE_LABEL`: namespace (e.g. `goals`, `todos`)
- `ENTITY_IDENTIFIER`: uuid for entity lookup. Use `id()` to generate
- `ACTION`: `create`, `update`, `merge`, `delete`, `link`, `unlink`
- `ACTION_SPECIFIC_DATA`:
  - `create`/`update`: object with data
  - `merge`: object to deep merge
  - `delete`: no data
  - `link`/`unlink`: object of label-entity pairs
