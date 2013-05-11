do ($ = jQuery) -> $(document).ready(() ->
  socket = io.connect(document.URL.match(/^http:\/\/[^/]*/))

  imgSpr = new Image()
  imgSpr.src = 'img\\spritesBeta.png'
  imgBack = new Image()
  imgBack.src = 'img\\backBeta.png'

  drawWorld = (map) ->
    canva = document.getElementById("canvas")
    ctx = canva.getContext("2d")
    ctx.drawImage(imgBack, 0, 0)

    ctx.font="12px Arial"
    ctx.fillStyle="black"
    for pl in map.players
      if pl.bombcount > 0
        for bomb in pl.bombs
          if bomb.type is 1 then ctx.drawImage(imgSpr, 147, 0, 48, 48, bomb.x, bomb.y, 48, 48)
          if bomb.time is 0
            bombid.push(5)
            bombX.push(bomb.x)
            bombY.push(bomb.y)
    if bombid.length > 0
      bid = 0
      while bid < bombid.length

        pwr = 1
        while pwr < me.bombpwr+1
          ctx.drawImage(imgSpr, 0, 48, 48, 48, bombX[bid]+(48*pwr), bombY[bid], 48, 48)
          pwr++
        pwr=1
        while pwr < me.bombpwr+1
          ctx.drawImage(imgSpr, 0, 48, 48, 48, bombX[bid]-(48*pwr), bombY[bid], 48, 48)
          pwr++
        pwr=1
        while pwr < me.bombpwr+1
          ctx.drawImage(imgSpr, 0, 48, 48, 48, bombX[bid], bombY[bid]+(48*pwr), 48, 48)
          pwr++
        pwr=1
        while pwr < me.bombpwr+1
          ctx.drawImage(imgSpr, 0, 48, 48, 48, bombX[bid], bombY[bid]-(48*pwr), 48, 48)
          pwr++

        bid++
    y = 0
    for Btype in map.map
      x = 0
      for type in Btype
        if type is 1 then ctx.drawImage(imgSpr, 0, 0, 48, 48, 48*x, 48*y, 48, 48)
        if type is 2 then ctx.drawImage(imgSpr, 49, 0, 48, 48, 48*x, 48*y, 48, 48)
        if type is 3 then ctx.drawImage(imgSpr, 98, 0, 48, 48, 48*x, 48*y, 48, 48)
        x++
      y++
    for pl in map.players
      ctx.drawImage(imgSpr, 148, 55, 48, 64, pl.x, pl.y-16, 48, 64)
      ctx.fillText(pl.name, pl.x+8, pl.y+14)

  bombsDraw = () ->
    countid = 0
    arrid = []
    if bombid.length > 0
      while countid < bombid.length
        bombid[countid] -= 1
        if bombid[countid] is 0
          arrid.push(countid)
          bombX.splice(countid,1)
          bombY.splice(countid,1)
        countid++
      for id in arrid
        bombid.splice(id, 1)
        drawWorld(usergamemap)

  usergamemap = new World()
  mvup = 0
  meb = 0
  bombid = []
  bombX = []
  bombY = []
  control = 0

  me = new Player("P#{1}", ( Math.ceil(Math.random()*6 )+1)*48, ( Math.ceil(Math.random()*5)+1)*48, 0, 0, 0, 1, 2, pbombs = [])
                 # name                    x                                   y                  id  dir bc bt bp  bombs

  #socket.emit('try_con', me)

  ###
  socket.on('response', (index) ->
    if index is "accept"
      alert "Waiting for other players..."
    if index is "deny"
      alert "Room is full!"
    if index is "start"
      alert "Connection..."
      socket.emit('new user', me )
  )
  ###

  socket.emit('new user', me)

  socket.on('add world', (worldmap, meid) ->
    usergamemap = new World(worldmap)
    me.id = meid
    me.name = "P#{me.id + 1}"
    bomb = new Bomb(me.bombtype, me.x, me.y-48, 0, 1)
    bomb.BlockColl(usergamemap.map)
    me.delBomb()
    usergamemap.addPlayer(me)

    oldx = me.x
    oldy = me.y
    usergamemap.map[Math.floor(me.y/48)][Math.floor(me.x/48)] = 9
    socket.emit('update user', me)
    socket.emit('update world', usergamemap.map)

    drawWorld(usergamemap)
    setInterval(movePl, 100)
    setInterval(bombsDraw, 100)
    #setInterval(drawWorld, 45, usergamemap)
  )

  socket.on('add user', (pl) ->
    usergamemap.addPlayer(pl)
    drawWorld(usergamemap)
  )

  socket.on('change user', (pl) ->
    usergamemap.players[pl.id] = pl
    if pl.id is me.id
      control = -1
    drawWorld(usergamemap)
  )

  socket.on('change world', (gmap) ->
    usergamemap.map = gmap
    drawWorld(usergamemap)
  )

  $(window).on('unload', (e) ->
    socket.emit('leave', me)
  )

  $("body").keydown((e) ->
    if e.keyCode is 39 then me.direction = 1
    if e.keyCode is 37 then me.direction = 2
    if e.keyCode is 38 then me.direction = 3
    if e.keyCode is 40 then me.direction = 4
    if e.keyCode is 32 then meb = 1
  )

  $("body").keyup((e) ->
    if e.keyCode is 37 or 38 or 39 or 40 then mvup = 1
  )

  movePl = () ->
    if control isnt -1
      oldx = me.x
      oldy = me.y
      if ( me.direction is 1 ) and me.BoundColl( me.x+12, me.y, usergamemap.map ) then me.x = me.x+12
      else if ( me.direction is 2 ) and me.BoundColl( me.x-12, me.y, usergamemap.map ) then me.x = me.x-12
      else if ( me.direction is 3 ) and me.BoundColl( me.x, me.y-12, usergamemap.map ) then me.y = me.y-12
      else if ( me.direction is 4 ) and me.BoundColl( me.x, me.y+12, usergamemap.map ) then me.y = me.y+12
      if oldx isnt me.x or oldy isnt me.y
        socket.emit('update user', me)
        newx = me.x
        newy = me.y
        if newx % 48 > 23 then newmx = Math.ceil(newx / 48)
        else newmx = Math.floor(newx / 48)
        if newy % 48 > 23 then newmy = Math.ceil(newy / 48)
        else newmy = Math.floor(newy / 48)

        if oldx % 48 > 23 then oldmx = Math.ceil(oldx / 48)
        else oldmx = Math.floor(oldx / 48)
        if oldy % 48 > 23 then oldmy = Math.ceil(oldy / 48)
        else oldmy = Math.floor(oldy / 48)

        usergamemap.map[oldmy][oldmx] = 0
        usergamemap.map[newmy][newmx] = 9
        socket.emit('update world', usergamemap.map)
      if me.bombcount > 0
        for bomb in me.bombs
          if bomb.time > 0 then bomb.time -= 1
          else
            bomb.BlockColl(usergamemap.map)
            idarr = bomb.PlayerColl(usergamemap.players)
            if idarr.length > 0
              for id in idarr
                socket.emit('leave', usergamemap.players[id])
            me.delBomb()
            me.bombcount--
            socket.emit('update user', me)
            socket.emit('update world', usergamemap.map)
            drawWorld(usergamemap)
      if meb is 1
        bomb = new Bomb(me.bombtype, me.x, me.y, 30, me.bombpwr)
        bomb.BombPlace(usergamemap.players)
        me.addBomb(bomb)
        meb = 0
        me.bombcount++
      if me.direction > 0 or meb > 0 or me.bombcount > 0
        if mvup is 1 then me.direction = 0
        socket.emit('update user', me)
        drawWorld(usergamemap)
)


