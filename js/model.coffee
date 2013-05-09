class Player
  constructor: (name, x, y, id, bt, bombs) ->
    @name = name
    @x = x
    @y = y
    @id = id
    @bt = bt
    @bombs = bombs
  addBomb: (b) ->
    @bombs.push(b)
  delBomb: () ->
    @bombs.splice(0,1)
  BoundColl: ( posX, posY, blocks) ->
    XColl = false
    YColl = false
    for bl in blocks
      if bl.x is Math.ceil(posX / 48)*48 and ( bl.y is Math.ceil(posY / 48)*48 or bl.y is (Math.ceil(posY / 48)-1)*48 )
        if posX+48 > bl.x and posX < bl.x+48 then XColl = true
        if posY+48 > bl.y and posY < bl.y+48 then YColl = true
      if bl.x is Math.floor(posX / 48)*48 and ( bl.y is Math.ceil(posY / 48)*48 or bl.y is (Math.ceil(posY / 48)-1)*48 )
        if posX < bl.x+48 and posX+48 > bl.x then XColl = true
        if posY < bl.y+48 and posY+48 > bl.y then YColl = true
    if (XColl and YColl) then return false
    return true

class Bomb
  constructor: (type, box, boy, time, frpwr) ->
    @type = type
    @x = box
    @y = boy
    @time = time
    @frpwr = frpwr
  BlockColl: (blocks) ->
    blow = []
    for bl in blocks
      if bl.type > 1
        if bl.x is bposX and bl.y is bposY then blow.push(bl.id)
        else if bl.x is @x-48 and bl.y is @y then blow.push(bl.id)
        else if bl.x is @x+48 and bl.y is @y then blow.push(bl.id)
        else if bl.y is @y-48 and bl.x is @x then blow.push(bl.id)
        else if bl.y is @y+48 and bl.x is @x then blow.push(bl.id)
        ###
        cap = blow.length
        if bl.x is @x and bl.y is @y then blow.push(bl.id)
        for bfrpwr in [0...@frpwr]
          if ( blow.length - cap is 0 ) and bl.x is @x-(48+48*bfrpwr) and bl.y is @y
            blow.push(bl.id)
            alert blow.length-1-cap
        while bfrpwr < @frpwr
          if bl.x is @x+48+(48*bfrpwr) and bl.y is @y
            blow.push(bl.id)
            bfrpwr = @frpwr
          bfrpwr++
        bfrpwr = 0
        while bfrpwr < @frpwr
          if bl.y is @y-48-(48*bfrpwr) and bl.x is @x
            blow.push(bl.id)
            bfrpwr = @frpwr
          bfrpwr++
        bfrpwr = 0
        while bfrpwr < @frpwr
          if bl.y is @y+48+(48*bfrpwr) and bl.x is @x
            blow.push(bl.id)
            bfrpwr = @frpwr
          bfrpwr++
        ###
    return blow
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
    if ( @x+1 ) % 48 > 23 and ( @y+1 ) % 48 > 23
      @x = Math.ceil(@x / 48)*48
      @y = Math.ceil(@y / 48)*48
    else if ( @x+1 ) % 48 > 23
      @x = Math.ceil(@x / 48)*48
      @y = Math.floor(@y / 48)*48
    else if ( @y+1 ) % 48 > 23
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
        @mapTemp = obj.mapTemp
        @blocks = obj.blocks
        @mapTempW = obj.mapTempW
        @mapTempH = obj.mapTempH
      else
        @players = []
        @mapTemp = []
        @blocks = []
        @mapTempW = 0
        @mapTempH = 0
  addMapTemp: (map, mW, mH) ->
    @mapTemp = map
    @mapTempW = mW
    @mapTempH = mH
  addPlayer: (pl) ->
    @players[pl.id] = pl
  delPlayer: (pl) ->
    pl.x = -48
    pl.y = -48
    pl.bombs = []
  addBlock: (bl) ->
    @blocks.push(bl)
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