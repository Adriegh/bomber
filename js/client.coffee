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
    for bl in map.blocks
      if bl.type is 1 then ctx.drawImage(imgSpr, 0, 0, 48, 48, bl.x, bl.y, 48, 48)
      if bl.type is 2 then ctx.drawImage(imgSpr, 49, 0, 48, 48, bl.x, bl.y, 48, 48)
      if bl.type is 3 then ctx.drawImage(imgSpr, 98, 0, 48, 48, bl.x, bl.y, 48, 48)
    for pl in map.players
      if pl.bt > 0
        for bomb in pl.bombs
          if bomb.type is 1 then ctx.drawImage(imgSpr, 147, 0, 48, 48, bomb.x, bomb.y, 48, 48)
    for pl in map.players
      ctx.drawImage(imgSpr, 148, 55, 48, 64, pl.x, pl.y-16, 48, 64)
      ctx.fillText(pl.name, pl.x+8, pl.y+14)

  usergamemap = new World()
  mvdwn = 0
  mvup = 0
  meb = 0
  control = 0

  me = new Player("P#{1}", ( Math.ceil(Math.random()*6 )+1)*48, ( Math.ceil(Math.random()*5)+1)*48, 0, 0, pbombs = [])

  socket.emit('try_con', me)

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
    me.delBomb()
    bomb = new Bomb(meb, me.x, me.y-48, 0)
    dbls = bomb.BlockColl(bomb.x, bomb.y, usergamemap.blocks)
    for dbl in dbls
      usergamemap.delBlock(dbl)

    usergamemap.addPlayer(me)

    socket.emit('update user', me)
    socket.emit('update world', usergamemap.blocks)

    drawWorld(usergamemap)
    setInterval(movePl, 100)
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

  socket.on('change world', (gblocks) ->
    usergamemap.blocks = gblocks
    drawWorld(usergamemap)
  )

  $(window).on('unload', (e) ->
    socket.emit('leave', me)
  )

  $("body").keydown((e) ->
    if e.keyCode is 39 then mvdwn = 1
    if e.keyCode is 37 then mvdwn = 2
    if e.keyCode is 38 then mvdwn = 3
    if e.keyCode is 40 then mvdwn = 4
    if e.keyCode is 32 then meb = 1
  )

  $("body").keyup((e) ->
    if e.keyCode is 37 or 38 or 39 or 40 then mvup = 1
  )

  movePl = () ->
    if control isnt -1
      if ( mvdwn is 1 ) and me.BoundColl( me.x+12, me.y, usergamemap ) then me.x = me.x+12
      else if ( mvdwn is 2 ) and me.BoundColl( me.x-12, me.y, usergamemap ) then me.x = me.x-12
      else if ( mvdwn is 3 ) and me.BoundColl( me.x, me.y-12, usergamemap ) then me.y = me.y-12
      else if ( mvdwn is 4 ) and me.BoundColl( me.x, me.y+12, usergamemap ) then me.y = me.y+12
      if me.bt > 0
        for bmb in me.bombs
          if bmb.time > 0 then bmb.time -= 1
          else
            bidarr = bmb.BlockColl(bmb.x, bmb.y, usergamemap.blocks)
            if bidarr.length > 0
              for bid in bidarr
                usergamemap.delBlock(bid)
                #alert bid
            pidarr = bmb.PlayerColl(bmb.x, bmb.y, usergamemap.players)
            if pidarr.length > 0
              for pid in pidarr
                socket.emit('leave', usergamemap.players[pid])
            me.delBomb()
            me.bt--
            socket.emit('update user', me)
            socket.emit('update world', usergamemap.blocks)
            drawWorld(usergamemap)
      if meb is 1
        bomb = new Bomb(meb, me.x, me.y, 30)
        bomb.BombPlace(bomb.x, bomb.y, usergamemap.players)
        me.addBomb(bomb)
        meb = 0
        me.bt++
      if mvdwn > 0 or meb > 0 or me.bt > 0
        if mvup is 1 then mvdwn = 0
        socket.emit('update user', me)
        drawWorld(usergamemap)
)


