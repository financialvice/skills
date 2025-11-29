# Instant CLI

Manage schema and permissions from terminal.

## Login

```shell
npx instant-cli@latest login
```

Opens browser for auth. After auth, you can interact with Instant apps.

## Logout

```shell
npx instant-cli@latest logout
```

Clears stored credentials from local device.

## Init

In project root:

```shell
npx instant-cli@latest init
```

Creates two files:
- `instant.schema.ts` - data model
- `instant.perms.ts` - permission rules

See [Modeling Data](/docs/modeling-data) and [permissions](/docs/permissions).

## Push

Push schema changes:

```shell
npx instant-cli@latest push schema
```

Push permission changes:

```shell
npx instant-cli@latest push perms
```

## Pull

Pull latest schema and perms from production:

```shell
npx instant-cli@latest pull
```

Generates new `instant.schema.ts` and `instant.perms.ts` from production state.

## App ID

Provide as option:

```shell
npx instant-cli@latest init --app $MY_APP_ID
```

Or in `.env`:

```yaml
INSTANT_APP_ID=*****
```

Supported env vars:
- `INSTANT_APP_ID`
- `NEXT_PUBLIC_INSTANT_APP_ID` (next)
- `PUBLIC_INSTANT_APP_ID` (svelte)
- `VITE_INSTANT_APP_ID` (vite)
- `NUXT_PUBLIC_INSTANT_APP_ID` (nuxt)
- `EXPO_PUBLIC_INSTANT_APP_ID` (expo)

## File locations

Default search paths:
1. `./`
2. `./src`
3. `./app`

Custom locations via env vars:

```yaml
INSTANT_SCHEMA_FILE_PATH=./src/db/instant.schema.ts
INSTANT_PERMS_FILE_PATH=./src/db/instant.perms.ts
```

## CI Authentication

For CI, use `INSTANT_CLI_AUTH_TOKEN` env var.

Get token:

```shell
npx instant-cli@latest login -p
```

Prints token to console instead of saving locally. Copy and use as `INSTANT_CLI_AUTH_TOKEN` in CI.

## Init without files

Create app without generating files or modifying .env:

```shell
npx instant-cli@latest init-without-files --title "Hello World"
```

Ephemeral apps (auto-cleanup after 24h):

```shell
npx instant-cli@latest init-without-files --title "Hello World" --temp
```

Extract app info with jq:

```shell
output=$(npx instant-cli@latest init-without-files --title "Hello World" --temp)
if echo "$output" | jq -e '.error' > /dev/null; then
  echo "Error: $(echo "$output" | jq -r '.error')"
  exit 1
fi
appId=$(echo "$output" | jq -r '.appId')
adminToken=$(echo "$output" | jq -r '.adminToken')
```
