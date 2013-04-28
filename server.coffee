###
  BEGIN server routine
###
fs = require('fs')
app = require('http').createServer (req, res) ->
  page = if req.url is '/' then '/index.html' else req.url
  fs.readFile(
    __dirname + page,
  (err, data) ->
    if err
      res.writeHead 500
      res.end "Error loading #{page}"
    else
      res.writeHead 200
      res.end data
  )
io = require('socket.io').listen app
app.listen 8080
###
  END server r outine
###

model = require('./js/model.js') # loading common model for game

gamemap = new model.World()

io.sockets.on('connection', (socket) ->

  socket.on('new user', (player) ->
    if gamemap.ExistCond(player)
      gamemap.addPlayer(player)
      socket.emit('add world', gamemap)
      socket.broadcast.emit('add user', player)
  )

  socket.on('update user', (player) ->
    socket.broadcast.emit('change user', player)
  )

)