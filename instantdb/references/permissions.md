# Permissions

Secure data with Instant's Rule Language (inspired by Rails ActiveRecord, Google CEL, JSON).

```tsx
// instant.perms.ts
import type { InstantRules } from '@instantdb/react';

const rules = {
  "todos": {
    "allow": {
      "view": "auth.id != null",
      "create": "isOwner",
      "update": "isOwner && isStillOwner",
      "delete": "isOwner",
    },
    "bind": [
      "isOwner", "auth.id != null && auth.id == data.creatorId",
      "isStillOwner", "auth.id != null && auth.id == newData.creatorId"
    ]
  }
} satisfies InstantRules;

export default rules;
```

Manage permissions via config files or dashboard.

## Permissions as code

Generate `instant.perms.ts` with [CLI](/docs/cli):

```shell
npx instant-cli@latest init
```

Push changes to production:

```shell
npx instant-cli@latest push perms
```

## Permissions in dashboard

Dashboard has JSON-based permissions editor. Top-level keys = namespaces (goals, todos, etc). Special key `attrs` for creating new namespace/attribute types.

## Namespaces

Define `allow` rules for `view`, `create`, `update`, `delete`, plus field-level rules. Rules = boolean expressions.

Unset rules default to true. These are equivalent:

```json
{"todos": {"allow": {"view": "true", "create": "true", "update": "true", "delete": "true"}}}
```

```json
{"todos": {"allow": {"view": "true"}}}
```

```json
{}
```

### View

`view` rules run on `db.useQuery`. Backend evaluates each object before returning to client - users only see allowed data.

### Create, Update, Delete

Each transaction object evaluates respective rule. Transactions fail without adequate permission.

### Fields

Field-level permissions example - public `$users` table, hide emails:

```json
{
  "$users": {
    "allow": {"view": "true"},
    "fields": {"email": "auth.id == data.id"}
  }
}
```

### Default permissions

Default = `"true"`. Change with `"$default"`:

```json
{"todos": {"allow": {"$default": "false"}}}
```

equals:

```json
{"todos": {"allow": {"view": "false", "create": "false", "update": "false", "delete": "false"}}}
```

Override defaults:

```json
{"todos": {"allow": {"$default": "false", "view": "true"}}}
```

Use `$default` as namespace:

```json
{"$default": {"allow": {"view": "false"}}, "todos": {"allow": {"view": "true"}}}
```

Ultimate default:

```json
{"$default": {"allow": {"$default": "false"}}}
```

## Attrs

Special namespace for creating new data types on the fly. Only supports create rules. Lock down in production.

Data model:

```json
{"goals": { "id": UUID, "title": string }}
```

Rules:

```json
{"attrs": { "allow": { "create": "false" } }}
```

Allowed (existing attr types):

```javascript
db.transact(db.tx.goals[id()].update({title: "Hello World"})
```

Not allowed (new attr types):

```javascript
db.transact(db.tx.goals[id()].update({title: "Hello World", priority: "high"})
```

## CEL expressions

Rules = CEL code evaluating to true/false.

```json
{
  "todos": {
    "allow": {
      "view": "auth.id != null",
      "create": "auth.id in data.ref('creator.id')",
      "update": "!(newData.title == data.title)",
      "delete": "'joe@instantdb.com' in data.ref('users.email')"
    }
  }
}
```

### data

Refers to saved object. Available in `view`, `create`, `update`, `delete` rules.

### newData

In `update`, refers to changes being made.

### bind

Alias logic. These are equivalent:

```json
{"todos": {"allow": {"create": "isOwner"}, "bind": ["isOwner", "auth.id != null && auth.id == data.creatorId"]}}
```

```json
{"todos": {"allow": {"create": "auth.id != null && auth.id == data.creatorId"}}}
```

Useful for DRY and tidying:

```json
{
  "todos": {
    "allow": {"create": "isOwner || isAdmin"},
    "bind": [
      "isOwner", "auth.id != null && auth.id == data.creatorId",
      "isAdmin", "auth.email in ['joe@instantdb.com', 'stopa@instantdb.com']"
    ]
  }
}
```

### ref

Reference relations in checks:

```json
{"todos": {"allow": {"delete": "'joe@instantdb.com' in data.ref('users.email')"}}}
```

Works on `auth` too - restrict deletes to admin role:

```json
{"todos": {"allow": {"delete": "'admin' in auth.ref('$user.role.type')"}}}
```

See [managing users](/docs/users).

### ruleParams

Pass extra options to queries/transactions. Example: "Only people who know doc id can access it"

Query with ruleParams:

```javascript
const myDocId = getId(window.location);
const query = {docs: {}};
const { data } = db.useQuery(query, {
  ruleParams: { knownDocId: myDocId },
});
```

Transaction with ruleParams:

```js
db.transact(
  db.tx.docs[id].ruleParams({ knownDocId: id }).update({ title: 'eat' }),
);
```

Permission rules:

```json
{
  "documents": {
    "allow": {
      "view": "data.id == ruleParams.knownDocId",
      "update": "data.id == ruleParams.knownDocId",
      "delete": "data.id == ruleParams.knownDocId"
    }
  }
}
```

More patterns:

Access doc + all comments by one knownDocId:

```json
{
  "docs": {"view": "data.id == ruleParams.knownDocId"},
  "comment": {"view": "ruleParams.knownDocId in data.ref('parent.id')"}
}
```

Allow multiple documents:

```js
db.useQuery(..., { knownDocIds: [id1, id2, ...] })
```

```json
{"docs": {"view": "data.id in ruleParams.knownDocIds"}}
```

Share links with separate namespace:

```json
{"docs": {"view": "ruleParams.secret in data.ref('docLinks.secret')"}}
```

Separate view/edit links:

```json
{
  "docs": {
    "view": "hasViewerSecret || hasEditorSecret",
    "update": "hasEditorSecret",
    "delete": "hasEditorSecret",
    "bind": [
      "hasViewerSecret", "ruleParams.secret in data.ref('docViewLinks.secret')",
      "hasEditorSecret", "ruleParams.secret in data.ref('docEditLinks.secret')"
    ]
  }
}
```
