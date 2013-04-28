###
  Здесь реализована модель проекта. В частности игрок.
###

class Player
  constructor: (obj, x, y) ->
    @name = obj
    @x = x
    @y = y
  BoundColX: (posX) ->
    if posX > 1088 then return posX-12
    if posX < 0 then return posX+12
    return posX
  BoundColY: (posY) ->
    if posY > 720 then return posY-8
    if posY < 0 then return posY+8
    return posY

class World
  players : []
  names : []
  addPlayer: (pl) ->
    @players[pl.name] = pl
    @names.push(pl.name)
  ExistCond: (pl) ->
    cond = false
    if @players[pl.name] is undefined then cond = true
    cond
  constructor: (obj) ->
    switch typeof obj
      when 'object'
        @players = obj.players
        @names = obj.names
      else
        @players = []
        @names = []

#exports for client (window.) and server  (require(...).)
module?.exports =
  Player : Player
  World: World
window?.Player = Player
window?.World = World