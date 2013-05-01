//@ sourceMappingURL=model.map
// Generated by CoffeeScript 1.6.1

/*
  Здесь реализована модель проекта. В частности игрок.
*/


(function() {
  var Block, Bomb, Player, World;

  Player = (function() {

    Player.prototype.bombs = [];

    function Player(name, x, y, id) {
      switch (typeof name) {
        case 'string':
          this.name = name;
          this.x = x;
          this.y = y;
          this.id = id;
          break;
        default:
          this.name = "";
          this.x = 0;
          this.y = 0;
          this.id = -1;
          this.bombs = [];
      }
    }

    Player.prototype.addBomb = function(b) {
      return this.bombs.push(b);
    };

    Player.prototype.delBomb = function() {
      return this.bombs.splice(0, 1);
    };

    Player.prototype.BoundColl = function(posX, posY, map) {
      var XColl, YColl, bl, _i, _len, _ref;
      XColl = false;
      YColl = false;
      _ref = map.blocks;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        bl = _ref[_i];
        if (bl.x === Math.ceil(posX / 48) * 48 && (bl.y === Math.ceil(posY / 48) * 48 || bl.y === (Math.ceil(posY / 48) - 1) * 48)) {
          if (posX + 48 > bl.x && posX < bl.x + 48) {
            XColl = true;
          }
          if (posY + 48 > bl.y && posY < bl.y + 48) {
            YColl = true;
          }
        }
        if (bl.x === Math.floor(posX / 48) * 48 && (bl.y === Math.ceil(posY / 48) * 48 || bl.y === (Math.ceil(posY / 48) - 1) * 48)) {
          if (posX < bl.x + 48 && posX + 48 > bl.x) {
            XColl = true;
          }
          if (posY < bl.y + 48 && posY + 48 > bl.y) {
            YColl = true;
          }
        }
      }
      if (XColl && YColl) {
        return false;
      }
      return true;
    };

    /*BoundColX: (posX, map) ->
      if posX > 960 then return posX-12
      if posX < 0 then return posX+12
      return posX
    BoundColY: (posY, map) ->
      if posY > 672 then return posY-12
      if posY < 0 then return posY+12
      return posY
    */


    return Player;

  })();

  Bomb = (function() {

    function Bomb(type, box, boy, time) {
      this.type = type;
      this.x = box;
      this.y = boy;
      this.time = time;
    }

    Bomb.prototype.BlockColl = function(bposX, bposY, map) {
      var bl, blow, _i, _len, _ref;
      blow = [];
      _ref = map.blocks;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        bl = _ref[_i];
        if (bl.type > 1) {
          if (bl.x === bposX && bl.y === bposY) {
            blow.push(bl.id);
          } else if (bl.x === bposX - 48 && bl.y === bposY) {
            blow.push(bl.id);
          } else if (bl.x === bposX + 48 && bl.y === bposY) {
            blow.push(bl.id);
          } else if (bl.y === bposY - 48 && bl.x === bposX) {
            blow.push(bl.id);
          } else if (bl.y === bposY + 48 && bl.x === bposX) {
            blow.push(bl.id);
          }
        }
      }
      return blow;
    };

    return Bomb;

  })();

  Block = (function() {

    function Block(material, blx, bly, id) {
      this.type = material;
      this.x = blx * 48;
      this.y = bly * 48;
      this.id = id;
    }

    return Block;

  })();

  World = (function() {

    World.prototype.players = [];

    World.prototype.mapTemp = [];

    World.prototype.blocks = [];

    World.prototype.mapTempW = 0;

    World.prototype.mapTempH = 0;

    World.prototype.addMapTemp = function(map, mW, mH) {
      this.mapTemp = map;
      this.mapTempW = mW;
      return this.mapTempH = mH;
    };

    World.prototype.addPlayer = function(pl) {
      return this.players[pl.id] = pl;
    };

    World.prototype.addBlock = function(bl) {
      return this.blocks.push(bl);
    };

    World.prototype.delBlock = function(id) {
      this.blocks[id].x = -48;
      this.blocks[id].y = -48;
      this.blocks[id].type = -1;
      return this.blocks[id].id = -1;
    };

    function World(obj) {
      switch (typeof obj) {
        case 'object':
          this.players = obj.players;
          this.mapTemp = obj.mapTemp;
          this.blocks = obj.blocks;
          this.mapTempW = obj.mapTempW;
          this.mapTempH = obj.mapTempH;
          break;
        default:
          this.players = [];
          this.mapTemp = [];
          this.blocks = [];
          this.mapTempW = 0;
          this.mapTempH = 0;
      }
    }

    return World;

  })();

  if (typeof module !== "undefined" && module !== null) {
    module.exports = {
      Player: Player,
      World: World,
      Block: Block,
      Bomb: Bomb
    };
  }

  if (typeof window !== "undefined" && window !== null) {
    window.Player = Player;
  }

  if (typeof window !== "undefined" && window !== null) {
    window.World = World;
  }

  if (typeof window !== "undefined" && window !== null) {
    window.Block = Block;
  }

  if (typeof window !== "undefined" && window !== null) {
    window.Bomb = Bomb;
  }

}).call(this);
