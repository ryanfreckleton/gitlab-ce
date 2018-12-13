# Project traffic API

Every API call to project traffics must be authenticated.

## Get the HTTP fetches of the last 30 days

Retrieving the fetches statistics requires write access to the repository.

Fetches statistics includes both clones and pulls count.

```
GET /projects/:id/traffic/fetches
```

| Attribute  | Type   | Required | Description |
| ---------- | ------ | -------- | ----------- |
| `id `      | integer / string | yes      | The ID or [URL-encoded path of the project](README.md#namespaced-path-encoding) |

Example response:

```json
{
  "total_fetches": 50,
  "fetches": [
    {
      "fetch_count": 10,
      "date": "2018-01-10"
    },
    {
      "fetch_count": 10,
      "date": "2018-01-9"
    },
    {
      "fetch_count": 10,
      "date": "2018-01-8"
    },
    {
      "fetch_count": 10,
      "date": "2018-01-7"
    },
    {
      "fetch_count": 10,
      "date": "2018-01-6"
    }
  ]
}
```
