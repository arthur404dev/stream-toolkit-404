var db = connect("localhost:27017/auth")
// db.auth("root", "localpassword")
// db = db.getSiblingDB("auth")
db.tokens.insert({
  // You can set your own id here, or keep this uuid, this will be the id referred on the .env file
  _id: ObjectId("613bd14df645ab06d68c0216"),
  accesstoken: "access_token",
  accesstokenexpiresin: 3600,
  accesstokenexpiresat: "2021-09-10T22:14:58.386Z",
  accesstokenexpiresepoch: 1631312098,
  refreshtoken: "refresh_token",
  refreshtokenexpiresin: 31536000,
  refreshtokenexpiresat: "2022-09-10T21:14:58.386Z",
  refreshtokenexpiresepoch: 1662844498,
  scopes: [
    "profile.default.read",
    "channels.default.read",
    "chat.default.read",
    "chat.write",
    "channels.write",
    "stream.default.read",
  ],
  tokentype: "Bearer",
})
