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
app.listen 12345
###
  END server r outine
###

model = require('./js/model.js') # loading common model for game

testmap = [
            1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
            1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1
            1,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,1
            1,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,1
            1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1
            1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1
            1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1
            1,1,1,1,1,0,0,0,1,1,1,1,1,0,0,0,1,1,1,1,1
            1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1
            1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1
            1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,1
            1,0,0,1,0,0,0,0,0,0,1,0,0,0,0,0,0,1,0,0,1
            1,0,1,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,1,0,1
            1,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,1
            1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1
          ]

createBlocks = (map) ->
  x = 0
  y = 0
  id = 0
  for type in map.mapTemp
    if type is 1
      block = new model.Block(type, x, y, id)
      map.addBlock(block)
      id++
    else if type is 0
      z = Math.ceil(Math.random()*3)
      if z > 1
        block = new model.Block(z, x, y, id)
        map.addBlock(block)
        id++
    x++
    if x is map.mapTempW
      y++
      x = 0

testmapW = 21
testmapH = 15
gamemap = new model.World()
gamemap.addMapTemp(testmap, testmapW, testmapH)
createBlocks(gamemap)


io.sockets.on('connection' , (socket) ->

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