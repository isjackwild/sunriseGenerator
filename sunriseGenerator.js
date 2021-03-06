// Generated by CoffeeScript 1.6.2
(function() {
  var bottomFill, ctx, cv, horizonCols, skyCols, sunriseEngine, topFill,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; },
    _this = this;

  cv = document.getElementById('sunriseGenerator');

  cv.width = screen.width;

  cv.height = screen.height;

  ctx = cv.getContext('2d');

  topFill = document.getElementById('topFill');

  bottomFill = document.getElementById('bottomFill');

  skyCols = [
    {
      r: 241,
      g: 250,
      b: 255
    }, {
      r: 9,
      g: 91,
      b: 184
    }, {
      r: 179,
      g: 44,
      b: 44
    }, {
      r: 69,
      g: 65,
      b: 104
    }, {
      r: 40,
      g: 171,
      b: 197
    }, {
      r: 128,
      g: 172,
      b: 219
    }, {
      r: 0,
      g: 80,
      b: 146
    }, {
      r: 47,
      g: 44,
      b: 67
    }, {
      r: 42,
      g: 42,
      b: 97
    }, {
      r: 131,
      g: 63,
      b: 24
    }, {
      r: 58,
      g: 182,
      b: 196
    }, {
      r: 39,
      g: 135,
      b: 254
    }
  ];

  horizonCols = [
    {
      r: 242,
      g: 92,
      b: 76
    }, {
      r: 253,
      g: 141,
      b: 24
    }, {
      r: 252,
      g: 254,
      b: 112
    }, {
      r: 253,
      g: 64,
      b: 103
    }, {
      r: 252,
      g: 230,
      b: 149
    }, {
      r: 255,
      g: 224,
      b: 55
    }, {
      r: 251,
      g: 210,
      b: 92
    }, {
      r: 250,
      g: 191,
      b: 70
    }, {
      r: 179,
      g: 69,
      b: 1
    }, {
      r: 248,
      g: 248,
      b: 164
    }, {
      r: 255,
      g: 56,
      b: 105
    }, {
      r: 255,
      g: 128,
      b: 22
    }
  ];

  sunriseEngine = (function() {
    sunriseEngine.prototype._gradScale = null;

    sunriseEngine.prototype._streakyness = null;

    sunriseEngine.prototype._minusOffset = null;

    sunriseEngine.prototype._plusOffset = null;

    sunriseEngine.prototype._skyCol = null;

    sunriseEngine.prototype._horizonCol = null;

    sunriseEngine.prototype._finalCol = null;

    sunriseEngine.prototype._radius = null;

    sunriseEngine.prototype._sunPosOffset = null;

    sunriseEngine.prototype._noiseVariation = null;

    sunriseEngine.prototype._throttle = 1500;

    function sunriseEngine(ctx, w, h) {
      this.fillInSides = __bind(this.fillInSides, this);
      this.saveSunrise = __bind(this.saveSunrise, this);
      this.render = __bind(this.render, this);
      this.addNoise = __bind(this.addNoise, this);
      this.makeSun = __bind(this.makeSun, this);
      this.makeGradient = __bind(this.makeGradient, this);
      this.randomise = __bind(this.randomise, this);
      this.lerpColour = __bind(this.lerpColour, this);
      this.convertToRange = __bind(this.convertToRange, this);
      this.randomNumber = __bind(this.randomNumber, this);
      this.init = __bind(this.init, this);      this._ctx = ctx;
      this._w = w;
      this._h = h;
    }

    sunriseEngine.prototype.init = function() {
      this.randomise();
      return this.render();
    };

    sunriseEngine.prototype.randomNumber = function(min, max, int) {
      if (int == null) {
        int = true;
      }
      if (int === true) {
        return Math.ceil(Math.random() * (max - min) + min);
      } else {
        return Math.random() * (max - min) + min;
      }
    };

    sunriseEngine.prototype.convertToRange = function(value, srcRange, dstRange) {
      var adjValue, dstMax, srcMax;

      if (value < srcRange[0]) {
        return dstRange[0];
      } else if (value > srcRange[1]) {
        return dstRange[1];
      } else {
        srcMax = srcRange[1] - srcRange[0];
        dstMax = dstRange[1] - dstRange[0];
        adjValue = value - srcRange[0];
        return (adjValue * dstMax / srcMax) + dstRange[0];
      }
    };

    sunriseEngine.prototype.lerpColour = function(control, from, to) {
      var result, resultB, resultG, resultR;

      resultR = from.r + (to.r - from.r) * control;
      resultG = from.g + (to.g - from.g) * control;
      resultB = from.b + (to.b - from.b) * control;
      resultR = Math.ceil(resultR);
      resultG = Math.ceil(resultG);
      resultB = Math.ceil(resultB);
      result = {
        r: resultR,
        g: resultG,
        b: resultB
      };
      return result;
    };

    sunriseEngine.prototype.randomise = function() {
      this._minusOffset = this.randomNumber(1, 3);
      this._plusOffset = this.randomNumber(2, 5);
      this._gradScale = this.randomNumber(0, 0.33, false);
      this._streakyness = this.randomNumber(4, 12);
      this._noiseVariation = this.randomNumber(3, 8);
      this._skyCol = skyCols[Math.ceil(Math.random() * skyCols.length) - 1];
      this._horizonCol = horizonCols[Math.ceil(Math.random() * horizonCols.length) - 1];
      this._radius = this.randomNumber(this._h / 6, (this._h / 6) * 1.33);
      return this._sunPosOffset = this.randomNumber(0, this._h / 4);
    };

    sunriseEngine.prototype.makeGradient = function() {
      var colourJump, colourStep, i, lerpControl, tempCol, tempColRGB, _i, _ref, _results;

      colourStep = 0;
      _results = [];
      for (i = _i = 0, _ref = this._h; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        colourJump = this.randomNumber(-(this._streakyness + this._minusOffset), this._streakyness + this._plusOffset);
        colourStep += colourJump;
        lerpControl = this.convertToRange(colourStep, [0, this._h], [-this._gradScale, 1 + this._gradScale]);
        if (lerpControl < 0) {
          tempCol = this._skyCol;
        } else if (lerpControl > 1) {
          tempCol = this._horizonCol;
        } else {
          tempCol = this.lerpColour(lerpControl, this._skyCol, this._horizonCol);
        }
        tempColRGB = "rgb(" + tempCol.r + "," + tempCol.g + "," + tempCol.b + ")";
        this._ctx.strokeStyle = tempColRGB;
        this._ctx.beginPath();
        this._ctx.moveTo(0, i);
        this._ctx.lineTo(this._w, i);
        this._ctx.stroke();
        if (i === this._h - 1) {
          _results.push(this._finalCol = tempCol);
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    sunriseEngine.prototype.makeSun = function() {
      this._ctx.beginPath();
      this._ctx.arc(this._w / 2, (this._h / 2) + this._sunPosOffset, this._radius, 0, 2 * Math.PI);
      this._ctx.fillStyle = "#FFFFFF";
      return this._ctx.fill();
    };

    sunriseEngine.prototype.addNoise = function() {
      var brightness, i, noise, tempImage, _i, _ref;

      tempImage = this._ctx.getImageData(0, 0, this._w, this._h);
      brightness = 0;
      for (i = _i = 0, _ref = tempImage.data.length; 0 <= _ref ? _i < _ref : _i > _ref; i = 0 <= _ref ? ++_i : --_i) {
        if (i % 4 !== 3) {
          brightness += tempImage.data[i];
        } else {
          brightness /= 3;
          tempImage.data[i] = 255;
          noise = this.randomNumber(-this._noiseVariation, this._noiseVariation);
          noise *= this.convertToRange(brightness, [0, 255], [0.2, 1]);
          tempImage.data[i - 1] += noise;
          noise = this.randomNumber(-this._noiseVariation, this._noiseVariation);
          noise *= this.convertToRange(brightness, [0, 255], [0.2, 1]);
          tempImage.data[i - 2] += noise;
          noise = this.randomNumber(-this._noiseVariation, this._noiseVariation);
          noise *= this.convertToRange(brightness, [0, 255], [0.2, 1]);
          tempImage.data[i - 1] += noise;
          brightness = 0;
        }
        i++;
      }
      return this._ctx.putImageData(tempImage, 0, 0);
    };

    sunriseEngine.prototype.render = function() {
      var that;

      this._ctx.clearRect(0, 0, this._w, this._h);
      this.randomise();
      this.makeGradient();
      this.addNoise();
      this.makeSun();
      this.fillInSides();
      that = this;
      return setTimeout(function() {
        return window.requestAnimationFrame(that.render);
      }, this._throttle);
    };

    sunriseEngine.prototype.saveSunrise = function() {
      return cv.toBlob(function(blob) {
        return saveAs(blob, 'sunrise.png');
      });
    };

    sunriseEngine.prototype.fillInSides = function() {
      topFill.style.background = "rgb(" + this._skyCol.r + "," + this._skyCol.g + "," + this._skyCol.b + ")";
      return bottomFill.style.background = "rgb(" + this._finalCol.r + "," + this._finalCol.g + "," + this._finalCol.b + ")";
    };

    return sunriseEngine;

  })();

  $(window).load(function() {
    var gui, sunEngine;

    sunEngine = new sunriseEngine(ctx, cv.width, cv.height);
    sunEngine.init();
    gui = new dat.GUI();
    gui.add(sunEngine, '_throttle');
    gui.add(sunEngine, '_gradScale').listen();
    gui.add(sunEngine, '_streakyness').listen();
    gui.add(sunEngine, '_minusOffset').listen();
    gui.add(sunEngine, '_plusOffset').listen();
    gui.add(sunEngine, '_noiseVariation').listen();
    return document.getElementById('sunriseGenerator').onclick = function() {
      console.log('click');
      return sunEngine.saveSunrise();
    };
  });

  $('#closeAbout').click(function() {
    console.log("close");
    $('#about').toggleClass('closed');
    return setTimeout(function() {
      return $('#about').bind("click", function() {
        $('#about').toggleClass('closed');
        return $('#about').unbind("click");
      });
    }, 0);
  });

}).call(this);
