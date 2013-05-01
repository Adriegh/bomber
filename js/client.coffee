###
  Здесь  реализован веьс клиентский JavaScript. Подразумевается, что модель
  подключается заранее.
###

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
      for bomb in pl.bombs
        if bomb.type is 1 then ctx.drawImage(imgSpr, 147, 0, 48, 48, bomb.x, bomb.y, 48, 48)
    for pl in map.players
      ctx.drawImage(imgSpr, 148, 55, 48, 64, pl.x, pl.y-16, 48, 64)
      ctx.fillText(pl.name, pl.x+8, pl.y+14)

  usergamemap = new World()
  mv = 0
  meb = 0
  medb = 0
  me = new Player("P#{1}", ( Math.ceil(Math.random()*6 )+1)*48, ( Math.ceil(Math.random()*5)+1)*48, 0)

  socket.emit('new user', me )
  socket.on('add world', (worldmap, meid) ->
    usergamemap = new World(worldmap)
    if me.id isnt meid
      me.id = meid
      me.name = "P#{me.id + 1}"

    bomb = new Bomb(meb, me.x, me.y, 0)
    dbls = bomb.BlockColl(bomb.x, bomb.y, usergamemap)
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
    usergamemap.addPlayer(new Player(pl.name, pl.x, pl.y, pl.id))
    drawWorld(usergamemap)
  )
  socket.on('change user', (pl) ->
    usergamemap.players[pl.id] = new Player(pl.name, pl.x, pl.y, pl.id)
    drawWorld(usergamemap)
  )
  socket.on('change world', (gblocks) ->
    usergamemap.blocks = gblocks
    drawWorld(usergamemap)
  )

  ###
  socket.on('ping', (justvar) ->
    socket.emit('pong', "fine", me.id)
  )

  socket.on('delete user', (pl) ->
    usergamemap.delPlayer(pl.id)
    drawWorld(usergamemap)
  )
  ###

  $("body").keydown((e) ->
    if e.keyCode is 39 then mv = 1
    if e.keyCode is 37 then mv = 2
    if e.keyCode is 38 then mv = 3
    if e.keyCode is 40 then mv = 4
    if e.keyCode is 32 then meb = 1
  )

  $("body").keyup((e) ->
    if e.keyCode is 37 or 38 or 39 or 40 then mv = 0
  )


  movePl = () ->
    if ( mv is 1 ) and me.BoundColl( me.x+12, me.y, usergamemap ) then me.x = me.x+12
    else if ( mv is 2 ) and me.BoundColl( me.x-12, me.y, usergamemap ) then me.x = me.x-12
    else if ( mv is 3 ) and me.BoundColl( me.x, me.y-12, usergamemap ) then me.y = me.y-12
    else if ( mv is 4 ) and me.BoundColl( me.x, me.y+12, usergamemap ) then me.y = me.y+12
    if medb > 0
      for bmb in me.bombs
        if bmb.time > 0 then bmb.time -= 1
        else
          bidarr = bmb.BlockColl(bmb.x, bmb.y, usergamemap)
          if bidarr.length > 0
            for bid in bidarr
              usergamemap.delBlock(bid)
              alert bid
          me.delBomb()
          medb--
          socket.emit('update user', me)
          socket.emit('update world', usergamemap.blocks)
          drawWorld(usergamemap)
    if meb is 1
      bomb = new Bomb(meb, me.x, me.y, 30)
      me.addBomb(bomb)
      meb = 0
      medb++
    if mv > 0 or meb > 0 or medb > 0
      socket.emit('update user', me)
      drawWorld(usergamemap)

)


