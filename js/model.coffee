class Player
  constructor: (name, x, y, id, direction, bombcount, bombtype, bombpwr ,bombs) ->
    @name = name
    @x = x
    @y = y
    @id = id
    @direction = direction
    @bombcount = bombcount
    @bombtype = bombtype
    @bombpwr = bombpwr
    @bombs = bombs
  addBomb: (b) ->
    @bombs.push(b)
  delBomb: () ->
    @bombs.splice(0,1)
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

class Bomb
  constructor: (type, x, y, time, frpwr) ->
    @type = type
    @x = x
    @y = y
    @time = time
    @frpwr = frpwr
  BlockColl: (map) ->
    if 1 < map[ Math.floor(@y/48) ][ Math.floor(@x/48) ] < 4
      map[ Math.floor(@y/48) ][ Math.floor(@x/48) ] = 0
    bfrpwr = 1
    while bfrpwr < @frpwr+1
      if 0 < map[ Math.floor(@y/48) ][ Math.floor((@x-(48*bfrpwr))/48) ] < 4
        if 1 < map[ Math.floor(@y/48) ][ Math.floor((@x-(48*bfrpwr))/48) ] < 4
          map[ Math.floor(@y/48) ][ Math.floor((@x-(48*bfrpwr))/48) ] = 0
        break
      bfrpwr++

    bfrpwr = 1
    while bfrpwr < @frpwr+1
      if 0 < map[ Math.floor(@y/48) ][ Math.floor((@x+(48*bfrpwr))/48) ] < 4
        if  1 < map[ Math.floor(@y/48) ][ Math.floor((@x+(48*bfrpwr))/48) ] < 4
          map[ Math.floor(@y/48) ][ Math.floor((@x+(48*bfrpwr))/48) ] = 0
        break
      bfrpwr++

    bfrpwr = 1
    while bfrpwr < @frpwr+1
      if 0 < map[ Math.floor((@y-(48*bfrpwr))/48) ][ Math.floor(@x/48) ] < 4
        if 1 < map[ Math.floor((@y-(48*bfrpwr))/48) ][ Math.floor(@x/48) ] < 4
          map[ Math.floor((@y-(48*bfrpwr))/48) ][ Math.floor(@x/48) ] = 0
        break
      bfrpwr++

    bfrpwr = 1
    while bfrpwr < @frpwr+1
      if 0 < map[ Math.floor((@y+(48*bfrpwr))/48) ][ Math.floor(@x/48) ] < 4
        if 1 < map[ Math.floor((@y+(48*bfrpwr))/48) ][ Math.floor(@x/48) ] < 4
          map[ Math.floor((@y+(48*bfrpwr))/48) ][ Math.floor(@x/48) ] = 0
        break
      bfrpwr++

  PlayerColl: (players) ->
    blow = []
    for pl in players
      if ( pl.x+48 > @x and pl.x < @x+48 ) and ( pl.y+48 > @y and pl.y < @y+48 ) then blow.push(pl.id)
      if ( pl.x+48 > @x-48 and pl.x < @x ) and ( pl.y+48 > @y and pl.y < @y+48 ) then blow.push(pl.id)
      if ( pl.x+48 > @x+48 and pl.x < @x+96 ) and ( pl.y+48 > @y and pl.y < @y+48 ) then blow.push(pl.id)
      if ( pl.x+48 > @x and pl.x < @x+48 ) and ( pl.y+48 > @y-48 and pl.y < @y ) then blow.push(pl.id)
      if ( pl.x+48 > @x and pl.x < @x+48 ) and ( pl.y+48 > @y+48 and pl.y < @y+96 ) then blow.push(pl.id)
    return blow
  BombPlace: (players) ->
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
    for pl in players
      if pl.bombs.length > 0
        for bomb in pl.bombs
          if @x is bomb.x and @y is bomb.y
            @x=-96
            @y=-96

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
      else
        @players = []
        @map = [[]]
        @blocks = []
  addMap: (map) ->
    @map = map
  addPlayer: (pl) ->
    @players[pl.id] = pl
  delPlayer: (pl) ->
    pl.x = -48
    pl.y = -48
    pl.bombs = []
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