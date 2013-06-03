do ($ = jQuery) -> $(document).ready(() ->
  socket = io.connect(document.URL.match(/^http:\/\/[^/]*/))

  imgSpr = new Image()
  imgSpr.src = 'img\\spritesBeta2.png'
  imgBack = new Image()

  imgBack1 = new Image()
  imgBack1.src = 'img\\backBeta1.png'
  imgBack2 = new Image()
  imgBack2.src = 'img\\backBeta2.png'
  imgBack3 = new Image()
  imgBack3.src = 'img\\backBeta3.png'

  imgBlow = new Image()
  imgBlow.src = 'img\\spriteBlow.png'

  authorize = (() ->
    $('.container-login').show();
    $('.container-login .register').on('click', () ->
      data = {
        username: $('.container-login .username').val(),
        password: $('.container-login .password').val(),
      }

      socket.emit('register', data)
    )
  )

  drawWorld = (map) ->
    canva = document.getElementById("canvas")
    ctx = canva.getContext("2d")
    ctx.drawImage(imgBack, 0, 0)

    canvabar = document.getElementById("canvasbar")
    bctx = canvabar.getContext("2d")
    bctx.fillStyle="white"
    bctx.fillRect(0,0,64,720)
    bctx.font="14px Arial"
    bctx.fillStyle="black"
    barx = 0
    for pl in map.players
      if pl.condition is 1
        bctx.fillText(pl.name, 10, 20+(70*barx))
        bctx.fillText(pl.score, 40, 20+(70*barx))
        barx++

    ctx.font="12px Arial"
    ctx.fillStyle="black"
    for pl in map.players
      if pl.bombs.length > 0
        for bomb in pl.bombs
          ctx.drawImage(imgSpr, 0, 49*bomb.type, 48, 48, bomb.x, bomb.y, 48, 48)
          if bomb.time <= 0
            ctx.drawImage(imgSpr, 495, 0, 48*bomb.blowmap[1], 48, bomb.x+48, bomb.y, 48*bomb.blowmap[1], 48)
            ctx.drawImage(imgSpr, 495, 0, 48*bomb.blowmap[0], 48, bomb.x-48*bomb.blowmap[0], bomb.y, 48*bomb.blowmap[0], 48)
            ctx.drawImage(imgSpr, 495, 0, 48, 48*bomb.blowmap[3], bomb.x, bomb.y+48, 48, 48*bomb.blowmap[3])
            ctx.drawImage(imgSpr, 495, 0, 48, 48*bomb.blowmap[2], bomb.x, bomb.y-48*bomb.blowmap[2], 48, 48*bomb.blowmap[2])
    y = 0
    for Btype in map.map
      x = 0
      for type in Btype
        if type > 0 then ctx.drawImage(imgSpr, 49*(type-1), 0, 48, 48, 48*x, 48*y, 48, 48)
        x++
      y++
    for pl in map.players
      if pl.condition is 1
        if stdir[pl.id][3] > 2
          stdir[pl.id][2] = if stdir[pl.id][2] is 0 then 1 else 0
          stdir[pl.id][3] = 0
        else stdir[pl.id][3]++
        if pl.direction is 0
          ctx.drawImage(imgSpr, stdir[pl.id][0], stdir[pl.id][1], 48, 64, pl.x, pl.y-20, 48, 64)
          #ctx.drawImage(imgSpr, 49, 49, 24, 24, pl.x-26, pl.y-32, 24, 24)
          #ctx.fillText(pl.name, pl.x-22, pl.y-24)
        if pl.direction is 1
          ctx.drawImage(imgSpr, 391+(48*stdir[pl.id][2]), 49+(64*pl.skin), 48, 64, pl.x, pl.y-20, 48, 64)
          #ctx.drawImage(imgSpr, 49, 49, 24, 24, pl.x-26, pl.y-32, 24, 24)
          #ctx.fillText(pl.name, pl.x-22, pl.y-24)
          stdir[pl.id][0] = 391+48*stdir[pl.id][2]
          stdir[pl.id][1] = 49+(64*pl.skin)
        if pl.direction is 2
          ctx.drawImage(imgSpr, 291+(48*stdir[pl.id][2]), 49+(64*pl.skin), 48, 64, pl.x, pl.y-20, 48, 64)
          #ctx.drawImage(imgSpr, 49, 49, 24, 24, pl.x-26, pl.y-32, 24, 24)
          #ctx.fillText(pl.name, pl.x-22, pl.y-24)
          stdir[pl.id][0] = 291+48*stdir[pl.id][2]
          stdir[pl.id][1] = 49+(64*pl.skin)
        if pl.direction is 3
          ctx.drawImage(imgSpr, 103+(48*stdir[pl.id][2]), 49+(64*pl.skin), 48, 64, pl.x, pl.y-20, 48, 64)
          #ctx.drawImage(imgSpr, 49, 49, 24, 24, pl.x-26, pl.y-32, 24, 24)
          #ctx.fillText(pl.name, pl.x-22, pl.y-24)
          stdir[pl.id][0] = 103+48*stdir[pl.id][2]
          stdir[pl.id][1] = 49+(64*pl.skin)
        if pl.direction is 4
          ctx.drawImage(imgSpr, 197+(48*stdir[pl.id][2]), 49+(64*pl.skin), 48, 64, pl.x, pl.y-20, 48, 64)
          #ctx.drawImage(imgSpr, 49, 49, 24, 24, pl.x-26, pl.y-32, 24, 24)
          #ctx.fillText(pl.name, pl.x-22, pl.y-24)
          stdir[pl.id][0] = 197+48*stdir[pl.id][2]
          stdir[pl.id][1] = 49+(64*pl.skin)



  usergamemap = new World()
  mvup = 0
  meb = 0
  meb2 = 0
  control = 0
  intervalid = 0

  me = new Player("P#{1}", -48, -48, 0, Math.ceil(Math.random()*5)-1, 2, 1, 2, 4)
                 # name     x    y  id              sk               bt bp ba ms

  stdir = [[197, 49+(64*me.skin), 0, 0]]

  ###
  socket.emit('try_con', me)

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

  # socket.emit('new user', me)

  authorize()

  socket.on('add world', (worldmap, newid) ->
    usergamemap = new World(worldmap)
    me.id = newid
    me.name = "P#{me.id + 1}"
    y = 0
    for line in usergamemap.map
      x = 0
      for cell in line
        if cell is -5
          me.x = x*48
          me.y = y*48
          usergamemap.map[y][x] = 0
          break
        else
          x++
      if me.x > 0 then break
      y++
    if me.x > 0
      bomb = new Bomb(me.bombtype, me.x, me.y-48, 0, 1)
      bomb.BlockColl(usergamemap.map, usergamemap.players)
      me.addBomb(bomb)
      me.delBomb(0)
      bomb = new Bomb(me.bombtype, me.x, me.y-48, 0, 1)
      bomb.BlockColl(usergamemap.map, usergamemap.players)
      me.addBomb(bomb)
      me.delBomb(0)
    skinid = 0
    for i in [0...usergamemap.players.length]
      stdir[i]=[197, 49+64*usergamemap.players[i].skin, 0, 0]
    #while stdir.length < usergamemap.players.length
    #  if usergamemap.players[skinid].id isnt me.id
    #    stdir.push([197, 49+64*usergamemap.players[skinid].skin, 0, 0])
    #    skinid++

    if worldmap.type is 1
      imgBack = imgBack1
    else if worldmap.type is 2
      imgBack = imgBack2
    else if worldmap.type is 3
      imgBack = imgBack3

    socket.emit('update user', me)
    socket.emit('update world', usergamemap.map)

    drawWorld(usergamemap)
    if me.x < 0
      alert "Room is full. You will be disconnected."
      socket.emit('leave', me.id)
    intervalid = setInterval(movePl, 50) #150
  )

  socket.on('add user', (pl) ->
    usergamemap.addPlayer(pl)
    stdir.push([197, 49+(64*pl.skin), 0, 0])
    drawWorld(usergamemap)
  )

  socket.on('delete user', (id) ->
    if id is me.id
      clearInterval(intervalid)
      me.condition = 0
      me.x = -48
      me.y = -48
      while me.bombs.length > 0
        me.delBomb(0)
      me.direction = 0
      socket.emit('update user', me)
  )

  socket.on('change user', (pl) ->
    usergamemap.players[pl.id] = pl
    drawWorld(usergamemap)
  )

  socket.on('change world', (gmap) ->
    usergamemap.map = gmap
    drawWorld(usergamemap)
  )

  socket.on('change bombs', (players) ->
    for pl in players
      if pl.id is me.id
        for idbomb in [0..pl.bombs.length]
          if me.bombs[idbomb].trig isnt pl.bombs[idbomb].trig then me.bombs[idbomb].time = 0
      socket.emit('update user', me)
    drawWorld(usergamemap)
  )

  $(window).on('unload', (e) ->
    clearInterval(intervalid)
    me.condition = 0
    me.x = -48
    me.y = -48
    while me.bombs.length > 0
      me.delBomb(0)
    me.direction = 0
    socket.emit('update user', me)
  )

  $("body").keydown((e) ->
    if 37 <= e.keyCode <= 40 then mvup = 0
    if e.keyCode is 39 then me.direction = 1
    if e.keyCode is 37 then me.direction = 2
    if e.keyCode is 38 then me.direction = 3
    if e.keyCode is 40 then me.direction = 4
    if e.keyCode is 32 and me.bombs.length < me.bombamount then meb = 1
    if e.keyCode is 16 and me.bombs.length > 0 and me.bombtype is 2 then meb2 = 1
  )

  $("body").keyup((e) ->
    if 37 <= e.keyCode <= 40 then mvup = 1
  )

  movePl = () ->
    if control isnt -1
      oldx = me.x
      oldy = me.y
      if ( me.direction is 1 ) and me.BoundColl( me.x+me.mspeed, me.y, usergamemap.map ) then me.x += me.mspeed
      else if ( me.direction is 2 ) and me.BoundColl( me.x-me.mspeed, me.y, usergamemap.map ) then me.x -= me.mspeed
      else if ( me.direction is 3 ) and me.BoundColl( me.x, me.y-me.mspeed, usergamemap.map ) then me.y -= me.mspeed
      else if ( me.direction is 4 ) and me.BoundColl( me.x, me.y+me.mspeed, usergamemap.map ) then me.y += me.mspeed
      if oldx isnt me.x or oldy isnt me.y
        if me.BonusCheck(usergamemap.map, oldx, oldy) then socket.emit('update world', usergamemap.map)
        socket.emit('update user', me)
      if me.bombs.length > 0
        idbomblength = me.bombs.length
        for idbomb in [0...idbomblength]
          if me.bombtype is 1 or me.bombtype is 3
            if me.bombs[idbomb].time > 0 then me.bombs[idbomb].time -= 1
            if me.bombs[idbomb].time is 0
              idarr = me.bombs[idbomb].BlockColl(usergamemap.map, usergamemap.players)
              if idarr.length > 0
                for id in idarr
                  socket.emit('leave', id)
                  me.score += 10
              socket.emit('explosion', usergamemap.players)
              me.bombs[idbomb].time--
            if me.bombs[idbomb].time < 0
              me.bombs[idbomb].time--
              if me.bombs[idbomb].time is -3
                me.delBomb(idbomb)
                idbomb--
                idbomblength--
                socket.emit('update user', me)
                socket.emit('update world', usergamemap.map)
                drawWorld(usergamemap)
          if me.bombtype is 2
            if me.bombs[idbomb].time is 0
              idarr = me.bombs[idbomb].BlockColl(usergamemap.map, usergamemap.players)
              if idarr.length > 0
                for id in idarr
                  socket.emit('leave', id)
                  me.score += 10
              socket.emit('explosion', usergamemap.players)
              me.bombs[idbomb].time--
            if me.bombs[idbomb].time < 0
              me.bombs[idbomb].time--
              if me.bombs[idbomb].time is -3
                me.delBomb(idbomb)
                idbomb--
                idbomblength--
                socket.emit('update user', me)
                socket.emit('update world', usergamemap.map)
                drawWorld(usergamemap)
      if meb is 1
        bomb = new Bomb(me.bombtype, me.x, me.y, 90, me.bombpwr)
        bomb.BombPlace()
        if bomb.Checkbombs(usergamemap.players )
          me.addBomb(bomb)
          me.delBomb(me.bombs.length-1)
        else
          me.addBomb(bomb)
        meb = 0
      if meb2 is 1
        if me.bombs.length > 0
          me.bombs[0].time = 0
        meb2 = 0
      if me.direction > 0 or meb > 0 or me.bombs.length > 0
        if mvup is 1 then me.direction = 0
        socket.emit('update user', me)
        drawWorld(usergamemap)
)


