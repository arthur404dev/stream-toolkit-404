require("dotenv").config()
const express = require("express")
const path = require("path")
const http = require("http")
const { v4: uuidv4 } = require("uuid")
const { WebSocketServer } = require("ws")

const app = express()
const server = http.createServer(app)

const port = process.env.PORT || 4200

const socket = new WebSocketServer({ server: server, path: "/ws" })

app.use(express.static(path.join(__dirname, "public")))
app.use(express.urlencoded({ extended: true }))
app.use(express.json())

app.post("/payload/submit", (req, res) => {
  const name = req.body.name
  console.log(req.body)
  res.end()
})

app.post("/oauth/token", (req, res) => {
  const accesstoken = uuidv4().split("-").join("")
  const refreshtoken = uuidv4().split("-").join("")
  const scope =
    "profile.default.read channels.default.read chat.default.read stream.default.read"
  const now = new Date()
  const accessTime = new Date(now.setHours(now.getHours() + 1))
  const refreshTime = new Date(now.setHours(now.getHours() + 365 * 24))
  const response = {
    access_token: accesstoken,
    expires: Number(accessTime),
    expires_in: 60 * 60,
    refresh_token: refreshtoken,
    scope,
    token_type: "Bearer",
    accessToken: accesstoken,
    accessTokenExpiresIn: 60 * 60,
    accessTokenExpiresAt: accessTime.toISOString(),
    accessTokenExpiresEpoch: Number(accessTime),
    refreshToken: refreshtoken,
    refreshTokenExpiresIn: 60 * 60 * 24 * 365,
    refreshTokenExpiresAt: refreshTime.toISOString(),
    refreshTokenExpiresEpoch: Number(refreshTime),
    scopeJson: scope.split(" "),
    tokenType: "Bearer",
  }
  res.json(response)
})
const message = {
  action: "event",
  payload: {
    connectionIdentifier: "message",
    eventIdentifier: "message",
    eventPayload: {
      author: {
        avatar: "https://avatars.githubusercontent.com/u/59490008?v=4",
        avatarUrl: "https://avatars.githubusercontent.com/u/59490008?v=4",
        picture: "https://avatars.githubusercontent.com/u/59490008?v=4",
        color: "red",
        displayName: "Arthur Andrade",
        id: "79sa7s9sh9has97as9",
        name: "Arthur Andrade",
        subscribedFor: 55,
      },
      bot: false,
      text: "olá lindíssimo",
      contentModifiers: {
        me: false,
        whisper: false,
      },
      replaces: [{}],
    },
    eventSourceId: 2,
    eventTypeId: 4,
    userId: 55,
  },
  stats: {},
  timestamp: Math.floor(Date.now() / 1000),
}

socket.on("connection", (socket, req) => {
  console.log(`Socket Connection estabilished using: ${req.url}`)
  socket.send(JSON.stringify(message))
})

server.listen(port, () => {
  console.log(`Feeder is running at localhost:${port}`)
})
