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
      if bl.type is 1 then ctx.drawImage(imgSpr, 0, 0, 32, 48, bl.x, bl.y, 32, 48)
      if bl.type is 2 then ctx.drawImage(imgSpr, 34, 0, 32, 48, bl.x, bl.y, 32, 48)
      if bl.type is 3 then ctx.drawImage(imgSpr, 68, 0, 32, 48, bl.x, bl.y, 32, 48)
    for nam in map.names
      for bomb in map.players[nam].bombs
        if bomb.type is 1 then ctx.drawImage(imgSpr, 0, 50, 32, 48, bomb.x, bomb.y, 32, 48)
      ctx.drawImage(imgSpr, 102, 0, 32, 48, map.players[nam].x, map.players[nam].y, 32, 48)
      ctx.fillText(map.players[nam].name, map.players[nam].x+4, map.players[nam].y+14)

  usergamemap = new World()
  mv = 0
  meb = 0
  medb = 0
  me = new Player("P#{Math.ceil(Math.random()*16)}", Math.ceil(Math.random()*10)*8, Math.ceil(Math.random()*10)*12)

  socket.emit('new user', me)
  socket.on('add world', (worldmap) ->
    usergamemap = new World(worldmap)
    usergamemap.addPlayer(me)
    drawWorld(usergamemap)
    setInterval(movePl, 100)
    #setInterval(drawWorld, 45, usergamemap)
  )
  socket.on('add user', (pl) ->
    usergamemap.addPlayer(new Player(pl.name, pl.x, pl.y))
    drawWorld(usergamemap)
  )
  socket.on('change user', (pl) ->
    usergamemap.players[pl.name] = new Player(pl.name, pl.x, pl.y)
    drawWorld(usergamemap)
  )

  $("body").keydown((e) ->
    switch e.keyCode
      when 39 then mv = 1
      when 37 then mv = 2
      when 38 then mv = 3
      when 40 then mv = 4
    if e.keyCode is 32 then meb = 1
  )

  $("body").keyup((e) ->
    if e.keyCode is 37 or 38 or 39 or 40 then mv = 0
    #if e.keyCode is 32 then meb = 0
  )

  movePl = () ->
    if mv is 1 then me.x = me.BoundColX( me.x+8 )
    else if mv is 2 then me.x = me.BoundColX( me.x-8 )
    else if mv is 3 then me.y = me.BoundColY( me.y-12 )
    else if mv is 4 then me.y = me.BoundColY( me.y+12 )
    for bmb in me.bombs
      if bmb.time > 0 then bmb.time -= 1
      else
        me.delBomb()
        medb--
    if meb is 1
      bomb = new Bomb(meb, me.x, me.y, 30)
      me.addBomb(bomb)
      meb = 0
      medb++
    if mv > 0 or meb > 0 or medb > 0
      socket.emit('update user', me)
      drawWorld(usergamemap)

)


