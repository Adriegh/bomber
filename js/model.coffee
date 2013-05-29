class Player
  constructor: (name, x, y, id, skin, bombtype, bombpwr, bombamount, mspeed) ->
    @name = name
    @x = x
    @y = y
    @id = id
    @skin = skin
    @condition = 1
    @direction = 0
    @score = 0
    @mspeed = mspeed
    @bombtype = bombtype
    @bombpwr = bombpwr
    @bombamount = bombamount
    @bombs = []
  addBomb: (b) ->
    @bombs.push(b)
  delBomb: (id) ->
    @bombs.splice(id,1)
  BoundColl: ( x, y, map) ->
    XColl = false
    YColl = false
    if  0 < map[ Math.floor(y/48) ][ Math.ceil(x/48) ] < 4 or
    0 < map[ Math.ceil(y/48) ][ Math.ceil(x/48) ] < 4
      if x+48 > 48*Math.ceil(x/48) and x < 48*Math.ceil(x/48)+48 then XColl = true
      if y+48 > 48*Math.ceil(y/48) and y < 48*Math.ceil(y/48)+48 then YColl = true
    if 0 < map[ Math.floor(y/48) ][ Math.floor(x/48) ] < 4 or
    0 < map[ Math.ceil(y/48) ][ Math.floor(x/48) ] < 4
      if x < 48*Math.ceil(x/48)+48 and x+48 > 48*Math.ceil(x/48) then XColl = true
      if y < 48*Math.ceil(y/48)+48 and y+48 > 48*Math.ceil(y/48) then YColl = true
    if (XColl and YColl) then return false
    return true
  BonusCheck: (map, ox, oy) ->
    tx = 0
    ty = 0
    if @x % 48 > 23 and @y % 48 > 23
      tx = Math.ceil(@x / 48)
      ty = Math.ceil(@y / 48)
    else if @x % 48 > 23
      tx = Math.ceil(@x / 48)
      ty = Math.floor(@y / 48)
    else if @y % 48 > 23
      tx = Math.floor(@x / 48)
      ty = Math.ceil(@y / 48)
    else
      tx = Math.floor(@x / 48)
      ty = Math.floor(@y / 48)

    if 3 < map[ ty][ tx ] < 9
      if map[ ty][ tx ] is 4 then @bombamount++
      if map[ ty][ tx ] is 5
        difX = 0
        difY = 0
        if @mspeed is 4
          @mspeed = 8
          if @x % 8 isnt 0 then difX = 4
          if @y % 8 isnt 0 then difY = 4
        else if @mspeed is 8
          @mspeed = 12
          if @x % 12 isnt 0 then difX = 4
          if @y % 12 isnt 0 then difY = 4
        else if @mspeed is 12
          @mspeed = 24
          if @x % 24 isnt 0 then difX = 12
          if @y % 24 isnt 0 then difY = 4

        if ox < @x then @x += difX
        if ox > @x then @x -= difX
        if oy < @y then @y += difY
        if oy > @y then @y -= difY

      if map[ ty][ tx ] is 6 then @bombpwr++
      if map[ ty][ tx ] is 7 then @bombtype = 2
      if map[ ty][ tx ] is 8 then @bombtype = 3
      map[ ty][ tx ] = 0
      return true

class Bomb
  constructor: (type, x, y, time, frpwr) ->
    @type = type
    @x = x
    @y = y
    @time = time
    @frpwr = frpwr
    @blowmap = [0,0,0,0]
    @cond = 1
  BlockColl: (map, players) ->
    blow = []
    if 1 < map[ Math.floor(@y/48) ][ Math.floor(@x/48) ] < 9
      map[ Math.floor(@y/48) ][ Math.floor(@x/48) ] = 0

    bfrpwr = 1
    while bfrpwr < @frpwr+1
      if 0 < map[ Math.floor(@y/48) ][ Math.floor((@x-(48*bfrpwr))/48) ] < 9
        if 1 < map[ Math.floor(@y/48) ][ Math.floor((@x-(48*bfrpwr))/48) ] < 9
          if map[ Math.floor(@y/48) ][ Math.floor((@x-(48*bfrpwr))/48) ] is 3
            block = Math.ceil(Math.random()*5)+3
            map[ Math.floor(@y/48) ][ Math.floor((@x-(48*bfrpwr))/48) ] = block
          else
            map[ Math.floor(@y/48) ][ Math.floor((@x-(48*bfrpwr))/48) ] = 0
          @blowmap[0]++
          if @type isnt 3 then break
          else if @type is 3 then @blowmap[0]--
        if map[ Math.floor(@y/48) ][ Math.floor((@x-(48*bfrpwr))/48) ] is 1 then break
      else if map[ Math.floor(@y/48) ][ Math.floor((@x-(48*bfrpwr))/48) ] is 0
        for pl in players
          if ( pl.x+48 > @x-(48*bfrpwr) and pl.x < @x+48-(48*bfrpwr) ) and ( pl.y+48 > @y and pl.y < @y+48 )
            blow.push pl
          i = 0
          for bomb in pl.bombs
            if bomb.x is @x-48*bfrpwr and bomb.y is @y
              players[pl.id].bombs[i].type = 3
            i++
      bfrpwr++
      @blowmap[0]++

    bfrpwr = 1
    while bfrpwr < @frpwr+1
      if 0 < map[ Math.floor(@y/48) ][ Math.floor((@x+(48*bfrpwr))/48) ] < 9
        if  1 < map[ Math.floor(@y/48) ][ Math.floor((@x+(48*bfrpwr))/48) ] < 9
          if  map[ Math.floor(@y/48) ][ Math.floor((@x+(48*bfrpwr))/48) ] is 3
            block = Math.ceil(Math.random()*5)+3
            map[ Math.floor(@y/48) ][ Math.floor((@x+(48*bfrpwr))/48) ] = block
          else
            map[ Math.floor(@y/48) ][ Math.floor((@x+(48*bfrpwr))/48) ] = 0
          @blowmap[1]++
          if @type isnt 3 then break
          else if @type is 3 then @blowmap[1]--
        if  map[ Math.floor(@y/48) ][ Math.floor((@x+(48*bfrpwr))/48) ] is 1 then break
      else if map[ Math.floor(@y/48) ][ Math.floor((@x+(48*bfrpwr))/48) ] is 0
        for pl in players
          if ( pl.x+48 > @x+(48*bfrpwr) and pl.x < @x+48+(48*bfrpwr) ) and ( pl.y+48 > @y and pl.y < @y+48 )
            blow.push(pl.id)
      bfrpwr++
      @blowmap[1]++

    bfrpwr = 1
    while bfrpwr < @frpwr+1
      if 0 < map[ Math.floor((@y-(48*bfrpwr))/48) ][ Math.floor(@x/48) ] < 9
        if 1 < map[ Math.floor((@y-(48*bfrpwr))/48) ][ Math.floor(@x/48) ] < 9
          if map[ Math.floor((@y-(48*bfrpwr))/48) ][ Math.floor(@x/48) ] is 3
            block = Math.ceil(Math.random()*5)+3
            map[ Math.floor((@y-(48*bfrpwr))/48) ][ Math.floor(@x/48) ] = block
          else
            map[ Math.floor((@y-(48*bfrpwr))/48) ][ Math.floor(@x/48) ] = 0
          @blowmap[2]++
          if @type isnt 3 then break
          else if @type is 3 then @blowmap[2]--
        if map[ Math.floor((@y-(48*bfrpwr))/48) ][ Math.floor(@x/48) ] is 1 then break
      else if map[ Math.floor((@y-(48*bfrpwr))/48) ][ Math.floor(@x/48) ] is 0
        for pl in players
          if ( pl.x+48 > @x and pl.x < @x+48 ) and ( pl.y+48 > @y-(48*bfrpwr) and pl.y < @y+48-(48*bfrpwr) )
            blow.push(pl.id)
      bfrpwr++
      @blowmap[2]++

    bfrpwr = 1
    while bfrpwr < @frpwr+1
      if 0 < map[ Math.floor((@y+(48*bfrpwr))/48) ][ Math.floor(@x/48) ] < 9
        if 1 < map[ Math.floor((@y+(48*bfrpwr))/48) ][ Math.floor(@x/48) ] < 9
          if map[ Math.floor((@y+(48*bfrpwr))/48) ][ Math.floor(@x/48) ] is 3
            block = Math.ceil(Math.random()*5)+3
            map[ Math.floor((@y+(48*bfrpwr))/48) ][ Math.floor(@x/48) ] = block
          else
            map[ Math.floor((@y+(48*bfrpwr))/48) ][ Math.floor(@x/48) ] = 0
          @blowmap[3]++
          if @type isnt 3 then break
          else if @type is 3 then @blowmap[3]--
        if map[ Math.floor((@y+(48*bfrpwr))/48) ][ Math.floor(@x/48) ] is 1 then break
      else if map[ Math.floor((@y+(48*bfrpwr))/48) ][ Math.floor(@x/48) ] is 0
        for pl in players
          if ( pl.x+48 > @x and pl.x < @x+48 ) and ( pl.y+48 > @y+(48*bfrpwr) and pl.y < @y+48+(48*bfrpwr) )
            blow.push(pl.id)
      bfrpwr++
      @blowmap[3]++

    return blow
  BombPlace: () ->
    if @x % 48 > 23 and @y % 48 > 23
      @x = Math.ceil(@x / 48)*48
      @y = Math.ceil(@y / 48)*48
    else if @x % 48 > 23
      @x = Math.ceil(@x / 48)*48
      @y = Math.floor(@y / 48)*48
    else if @y % 48 > 23
      @x = Math.floor(@x / 48)*48
      @y = Math.ceil(@y / 48)*48
    else
      @x = Math.floor(@x / 48)*48
      @y = Math.floor(@y / 48)*48

  Checkbombs: (players) ->
    Coll = false
    for pl in players
      if pl.bombs.length > 0
        for bomb in pl.bombs
          if @x is bomb.x and @y is bomb.y
            Coll = true
            break
    return Coll

class Block
  constructor: (material, blx, bly, id) ->
    @type = material
    @x = blx*48
    @y = bly*48
    @id = id

class World
  constructor: (obj) ->
    switch typeof obj
      when 'object'
        @players = obj.players
        @map = obj.map
        @blocks = obj.blocks
        @type - obj.type
      else
        @players = []
        @map = [[]]
        @blocks = []
        @type = 0
  addMap: (map) ->
    @map = map
  addPlayer: (pl) ->
    @players[pl.id] = pl
  delPlayer: (pl) ->
    pl.x = -48
    pl.y = -48
    pl.bombs = []
    pl.direction = 0
  addBlock: (bl) ->
    @blocks[bl.id]=bl
  delBlock: (id) ->
    @blocks[id].x = -48
    @blocks[id].y = -48
    @blocks[id].type = -1
    @blocks[id].id = -1


#exports for client (window.) and server  (require(...).)
module?.exports =
  Player : Player
  World: World
  Block: Block
  Bomb: Bomb
window?.Player = Player
window?.World = World
window?.Block = Block
window?.Bomb = Bomb