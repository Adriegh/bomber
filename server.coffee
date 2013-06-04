# BEGIN server routine

mysql = require('mysql');
fs = require('fs')
connection = mysql.createConnection({
  host     : 'localhost',
  user     : 'root',
  password : '',
  database: 'bomber',
});
connection.connect();

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

#  END server routine

model = require('./js/model.js') # loading common model for game
jsonfile = require('./json/maps.json')
ind = Math.ceil(Math.random()*3)

if ind is 1 then testmap = jsonfile.map1
else if ind is 2 then testmap = jsonfile.map2
else if ind is 3 then testmap = jsonfile.map3


createBlocks = (testmap) ->
  for Btype in testmap
    x = 0
    for type in Btype
      if type is 0
        stype = Math.ceil(Math.random()*3)
        if stype > 1
          if stype is 3
            if Math.ceil(Math.random()*2) isnt 1 then stype = 2
        else stype = 0
        type = stype
      Btype[x] = type
      x++


pid = 0
arrpid = []
count = 0
gamemap = new model.World()
createBlocks(testmap)
gamemap.type = Math.ceil(Math.random()*3)
gamemap.addMap(testmap)

console.log ind
console.log gamemap.type

###
launch
launch = () ->
  setInterval(winner, 10000) #180000
winner = () ->
  tscore = 0
  winners = []
  if gamemap.players.length > 0
    for pl in gamemap.players
      if pl.condition is 1
        if pl.score > tscore
          tscore = pl.score

    for pl in gamemap.players
      if pl.condition is 1
        if pl.score is tscore
          winners.push(pl.id)

    if winners.length > 1
      console.log "draw"
      io.sockets.emit('round over', winners, "draw")
    else if winners.length is 1
      console.log "win"
      io.sockets.emit('round over', winners, "win")
    else if winners.length is 0
      console.log "no_one"
      io.sockets.emit('round over', winners, "no_one")

  ind = Math.ceil(Math.random()*3)

  if ind is 1 then testmap = jsonfile.map1
  else if ind is 2 then testmap = jsonfile.map2
  else if ind is 3 then testmap = jsonfile.map3

  pid = 0
  arrpid = []
  count = 0
  gamemap = new model.World()
  createBlocks(testmap)
  gamemap.type = Math.ceil(Math.random()*3)
  gamemap.addMap(testmap)

  console.log ind
  console.log gamemap.type
###

io.sockets.on('connection' , (socket) ->

  ###
  socket.on("try_con", (player) ->
    if count < 2
      socket.emit('response', "accept")
      count++
      if count is 2 then io.sockets.emit('response', "start")
    else
      socket.emit('response', "deny")
  )
  ###

  socket.on('register', (data) ->
    error = false
    connection.query('SELECT * FROM users WHERE username = "'  + connection.escape(data['username']) + '"', (err, results) ->
      if(results.count > 0)
        error = true
      )
    )

  socket.on('new user', (player ) ->
    player.id = pid
    pid++
    gamemap.addPlayer(player)
    socket.emit('add world', gamemap, player.id)
    socket.broadcast.emit('add user', player)
  )

  socket.on('explosion', (players) ->
    socket.emit('change bombs', players)
    socket.broadcast.emit('change bombs', players)
  )

  socket.on('leave', (id) ->
    socket.emit('delete user', id)
    socket.broadcast.emit('delete user', id)
  )


  socket.on('update user', (player) ->
    gamemap.addPlayer(player)
    socket.emit('change user', player)
    socket.broadcast.emit('change user', player)
  )

  socket.on('update world', (gmap) ->
    gamemap.map = gmap
    socket.broadcast.emit('change world', gmap)
  )
)
