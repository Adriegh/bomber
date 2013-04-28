###
  Здесь реализована модель проекта. В частности игрок.
###

class Player
  bombs : []
  constructor: (obj, x, y) ->
    @name = obj
    @x = x
    @y = y
  addBomb: (b) ->
    @bombs.push(b)
  delBomb: () ->
    @bombs.splice(0,1)
  BoundColX: (posX) ->
    if posX > 1088 then return posX-8
    if posX < 0 then return posX+8
    return posX
  BoundColY: (posY) ->
    if posY > 720 then return posY-12
    if posY < 0 then return posY+12
    return posY

class Bomb
  constructor: (type, box, boy, time) ->
    @type = type
    @x = box
    @y = boy
    @time = time

class Block
  constructor: (material, blx, bly) ->
    @type = material
    @x = blx*32
    @y = bly*48

class World
  players : []
  names : []
  mapTemp : []
  blocks : []
  mapTempW : 0
  mapTempH : 0
  addMapTemp: (map, mW, mH) ->
    @mapTemp = map
    @mapTempW = mW
    @mapTempH = mH
  addPlayer: (pl) ->
    @players[pl.name] = pl
    @names.push(pl.name)
  addBlock: (bl) ->
    @blocks.push(bl)
  ExistCond: (pl) ->
    cond = false
    if @players[pl.name] is undefined then cond = true
    cond
  constructor: (obj) ->
    switch typeof obj
      when 'object'
        @players = obj.players
        @names = obj.names
        @mapTemp = obj.mapTemp
        @blocks = obj.blocks
        @mapTempW = obj.mapTempW
        @mapTempH = obj.mapTempH
      else
        @players = []
        @names = []
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