###
  Здесь реализована модель проекта. В частности игрок.
###

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
  BoundColl: ( posX, posY, map) ->
    XColl = false
    YColl = false
    for bl in map.blocks
      if bl.x is Math.ceil(posX / 48)*48 and ( bl.y is Math.ceil(posY / 48)*48 or bl.y is (Math.ceil(posY / 48)-1)*48 )
        if posX+48 > bl.x and posX < bl.x+48 then XColl = true
        if posY+48 > bl.y and posY < bl.y+48 then YColl = true
      if bl.x is Math.floor(posX / 48)*48 and ( bl.y is Math.ceil(posY / 48)*48 or bl.y is (Math.ceil(posY / 48)-1)*48 )
        if posX < bl.x+48 and posX+48 > bl.x then XColl = true
        if posY < bl.y+48 and posY+48 > bl.y then YColl = true
    if (XColl and YColl) then return false
    return true

class Bomb
  constructor: (type, box, boy, time) ->
    @type = type
    @x = box
    @y = boy
    @time = time
  BlockColl: ( bposX, bposY, map) ->
    blow = []
    for bl in map.blocks
      if bl.type > 1
        if bl.x is bposX and bl.y is bposY then blow.push(bl.id)
        else if bl.x is bposX-48 and bl.y is bposY then blow.push(bl.id)
        else if bl.x is bposX+48 and bl.y is bposY then blow.push(bl.id)
        else if bl.y is bposY-48 and bl.x is bposX then blow.push(bl.id)
        else if bl.y is bposY+48 and bl.x is bposX then blow.push(bl.id)
    return blow

class Block
  constructor: (material, blx, bly, id) ->
    @type = material
    @x = blx*48
    @y = bly*48
    @id = id

class World
  players : []
  mapTemp : []
  blocks : []
  mapTempW : 0
  mapTempH : 0
  addMapTemp: (map, mW, mH) ->
    @mapTemp = map
    @mapTempW = mW
    @mapTempH = mH
  addPlayer: (pl) ->
    @players[pl.id] = pl
  delPlayer: (pl) ->
    pl.x = -48
    pl.y = -48
  addBlock: (bl) ->
    @blocks.push(bl)
  delBlock: (id) ->
    @blocks[id].x = -48
    @blocks[id].y = -48
    @blocks[id].type = -1
    @blocks[id].id = -1
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