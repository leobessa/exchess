# ChessApp

ChessApp is a Phoenix chess server that uses Phoenix channels.
Try it online: https://exchess.herokuapp.com

## REST JSON API

### Authorization
  Some API endpoint requires an `authorization` header like this `Authorization: Bearer TOKEN_STRING`

### POST    /api/accounts

```
Authorization is not required.
parameters = {"account": {"username": "jon","password": "secret"}}
```

### POST    /api/auth_tokens

```
Authorization is not required.
parameters    = {"account": {"username": "jon","password": "secret"}}
response_body = {"data": {"jwt": "TOKEN_STRING"}}
```

### POST    /api/matches

```
Authorization is required.
No parameters.
response_body   = {"data":
  {
    "id": "cbcf0143-07e5-4b69-9c64-f07549d14c33",
    "player1_id": "549d5beb-6804-49ea-aa8e-556d903469d7",
    "player2_id": null,
    finished: false
  }
}
```

### GET     /api/matches, /api/matches/playing, /api/matches/waiting, /api/matches/finished

```
Authorization is required.

Optional pagination parameters: page

response_headers
  link: <http://localhost:4000/api/matches?page=1>; rel="first", <http://localhost:4000/api/matches?page=1>; rel="last"
  total: 6
  per-page: 10
  total-pages: 1
  page-number: 1

response_body   = {"data":
  [{
    "id": "cbcf0143-07e5-4b69-9c64-f07549d14c33",
    "player1_id": "549d5beb-6804-49ea-aa8e-556d903469d7",
    "player2_id": null,
    finished: false
  }]
}
```

## Channel API

```javascript
let socket = new Socket("/socket", {
  params: {jwt: jwt},
  logger: ((kind, msg, data) => { console.log(`${kind}: ${msg}`, data) })
})

let channel = socket.channel("match:" + matchId, {})
channel.join()
  .receive("ok", resp => { console.log("Joined successfully", resp) })
  .receive("error", resp => { console.log("Unable to join", resp) })

channel.push("move", {an: "e2e4"})
  .receive("ok", resp => { console.log("Move successfully", resp) })
  .receive("error", resp => { console.log("Unable to move", resp) })

channel.on("game_state_sync", msg => {
  board.position(msg.fen) // update client board
})

channel.on("game_state_updated", msg => {
  board.position(msg.fen) // update client board
})
```

## Phoenix

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.create && mix ecto.migrate`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](http://www.phoenixframework.org/docs/deployment).

## Learn more

  * Official website: http://www.phoenixframework.org/
  * Guides: http://phoenixframework.org/docs/overview
  * Docs: https://hexdocs.pm/phoenix
  * Mailing list: http://groups.google.com/group/phoenix-talk
  * Source: https://github.com/phoenixframework/phoenix
