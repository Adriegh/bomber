//@ sourceMappingURL=client.map
// Generated by CoffeeScript 1.6.1

/*
  Здесь  реализован веьс клиентский JavaScript. Подразумевается, что модель
  подключается заранее.
*/


(function() {

  (function($) {
    return $(document).ready(function() {
      var drawWorld, imgBack, imgSpr, me, meb, medb, movePl, mv, socket, usergamemap;
      socket = io.connect(document.URL.match(/^http:\/\/[^/]*/));
      imgSpr = new Image();
      imgSpr.src = 'img\\spritesBeta.png';
      imgBack = new Image();
      imgBack.src = 'img\\backBeta.png';
      drawWorld = function(map) {
        var bl, bomb, canva, ctx, pl, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2, _ref3, _results;
        canva = document.getElementById("canvas");
        ctx = canva.getContext("2d");
        ctx.drawImage(imgBack, 0, 0);
        ctx.font = "12px Arial";
        ctx.fillStyle = "black";
        _ref = map.blocks;
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          bl = _ref[_i];
          if (bl.type === 1) {
            ctx.drawImage(imgSpr, 0, 0, 48, 48, bl.x, bl.y, 48, 48);
          }
          if (bl.type === 2) {
            ctx.drawImage(imgSpr, 49, 0, 48, 48, bl.x, bl.y, 48, 48);
          }
          if (bl.type === 3) {
            ctx.drawImage(imgSpr, 98, 0, 48, 48, bl.x, bl.y, 48, 48);
          }
        }
        _ref1 = map.players;
        for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
          pl = _ref1[_j];
          _ref2 = pl.bombs;
          for (_k = 0, _len2 = _ref2.length; _k < _len2; _k++) {
            bomb = _ref2[_k];
            if (bomb.type === 1) {
              ctx.drawImage(imgSpr, 147, 0, 48, 48, bomb.x, bomb.y, 48, 48);
            }
          }
        }
        _ref3 = map.players;
        _results = [];
        for (_l = 0, _len3 = _ref3.length; _l < _len3; _l++) {
          pl = _ref3[_l];
          ctx.drawImage(imgSpr, 148, 55, 48, 64, pl.x, pl.y - 16, 48, 64);
          _results.push(ctx.fillText(pl.name, pl.x + 8, pl.y + 14));
        }
        return _results;
      };
      usergamemap = new World();
      mv = 0;
      meb = 0;
      medb = 0;
      me = new Player("P" + 1, (Math.ceil(Math.random() * 6) + 1) * 48, (Math.ceil(Math.random() * 5) + 1) * 48, 0);
      socket.emit('new user', me);
      socket.on('add world', function(worldmap, meid) {
        var bomb, dbl, dbls, _i, _len;
        usergamemap = new World(worldmap);
        if (me.id !== meid) {
          me.id = meid;
          me.name = "P" + (me.id + 1);
        }
        bomb = new Bomb(meb, me.x, me.y, 0);
        dbls = bomb.BlockColl(bomb.x, bomb.y, usergamemap);
        for (_i = 0, _len = dbls.length; _i < _len; _i++) {
          dbl = dbls[_i];
          usergamemap.delBlock(dbl);
        }
        usergamemap.addPlayer(me);
        socket.emit('update user', me);
        socket.emit('update world', usergamemap.blocks);
        drawWorld(usergamemap);
        return setInterval(movePl, 100);
      });
      socket.on('add user', function(pl) {
        usergamemap.addPlayer(new Player(pl.name, pl.x, pl.y, pl.id));
        return drawWorld(usergamemap);
      });
      socket.on('change user', function(pl) {
        usergamemap.players[pl.id] = new Player(pl.name, pl.x, pl.y, pl.id);
        return drawWorld(usergamemap);
      });
      socket.on('change world', function(gblocks) {
        usergamemap.blocks = gblocks;
        return drawWorld(usergamemap);
      });
      /*
      socket.on('ping', (justvar) ->
        socket.emit('pong', "fine", me.id)
      )
      
      socket.on('delete user', (pl) ->
        usergamemap.delPlayer(pl.id)
        drawWorld(usergamemap)
      )
      */

      $("body").keydown(function(e) {
        if (e.keyCode === 39) {
          mv = 1;
        }
        if (e.keyCode === 37) {
          mv = 2;
        }
        if (e.keyCode === 38) {
          mv = 3;
        }
        if (e.keyCode === 40) {
          mv = 4;
        }
        if (e.keyCode === 32) {
          return meb = 1;
        }
      });
      $("body").keyup(function(e) {
        if (e.keyCode === 37 || 38 || 39 || 40) {
          return mv = 0;
        }
      });
      return movePl = function() {
        var bid, bidarr, bmb, bomb, _i, _j, _len, _len1, _ref;
        if ((mv === 1) && me.BoundColl(me.x + 12, me.y, usergamemap)) {
          me.x = me.x + 12;
        } else if ((mv === 2) && me.BoundColl(me.x - 12, me.y, usergamemap)) {
          me.x = me.x - 12;
        } else if ((mv === 3) && me.BoundColl(me.x, me.y - 12, usergamemap)) {
          me.y = me.y - 12;
        } else if ((mv === 4) && me.BoundColl(me.x, me.y + 12, usergamemap)) {
          me.y = me.y + 12;
        }
        if (medb > 0) {
          _ref = me.bombs;
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            bmb = _ref[_i];
            if (bmb.time > 0) {
              bmb.time -= 1;
            } else {
              bidarr = bmb.BlockColl(bmb.x, bmb.y, usergamemap);
              if (bidarr.length > 0) {
                for (_j = 0, _len1 = bidarr.length; _j < _len1; _j++) {
                  bid = bidarr[_j];
                  usergamemap.delBlock(bid);
                  alert(bid);
                }
              }
              me.delBomb();
              medb--;
              socket.emit('update user', me);
              socket.emit('update world', usergamemap.blocks);
              drawWorld(usergamemap);
            }
          }
        }
        if (meb === 1) {
          bomb = new Bomb(meb, me.x, me.y, 30);
          me.addBomb(bomb);
          meb = 0;
          medb++;
        }
        if (mv > 0 || meb > 0 || medb > 0) {
          socket.emit('update user', me);
          return drawWorld(usergamemap);
        }
      };
    });
  })(jQuery);

}).call(this);
