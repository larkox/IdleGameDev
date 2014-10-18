// Generated by CoffeeScript 1.8.0
var Environment, GeneralGameScreenLoop, Loop, State, constants, loadImage, loadSound, playSound,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

constants = {
  "KEY_ENTER": 13,
  "KEY_ESC": 27,
  "KEY_LEFT": 37,
  "KEY_UP": 38,
  "KEY_RIGHT": 39,
  "KEY_DOWN": 40,
  "GENERAL": {
    "start": {
      x: 30,
      y: 30
    },
    "dimensions": {
      "w": 200,
      "h": 100
    },
    "line_height": 10
  },
  "UI": {
    "money": {
      "x": 10,
      "y": 10,
      "w": 100,
      "h": 100
    }
  },
  "INCOMES": [
    {
      "name": "freelancing",
      "each": 100,
      "cost": 1,
      "base_income": 0.1
    }, {
      "name": "engine",
      "each": 1000,
      "cost": 10,
      "base_income": 1
    }, {
      "name": "game dev",
      "each": 5000,
      "cost": 100,
      "base_income": 10
    }
  ],
  "STAFF": [
    {
      "name": "Billy",
      "scope": "everything",
      "description": "Can do a little of everything. Improve every income.",
      "base_effect": 0.01,
      "cost": 500
    }
  ]
};

State = (function() {
  function State() {
    var attribute, attribute_name, income_def, index, staff_def, _i, _j, _len, _len1, _ref, _ref1;
    this.money = 1;
    this.income = [];
    _ref = constants.INCOMES;
    for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
      income_def = _ref[index];
      this.income[index] = {};
      for (attribute_name in income_def) {
        attribute = income_def[attribute_name];
        this.income[index][attribute_name] = attribute;
      }
      this.income[index].powerup = 0;
      this.income[index].level = 0;
      this.income[index].income = 0;
      this.income[index].left = this.income[index].each;
    }
    this.staff = [];
    _ref1 = constants.STAFF;
    for (index = _j = 0, _len1 = _ref1.length; _j < _len1; index = ++_j) {
      staff_def = _ref1[index];
      this.staff[index] = {};
      for (attribute_name in staff_def) {
        attribute = staff_def[attribute_name];
        this.staff[index][attribute_name] = attribute;
      }
      this.staff[index].current = 0;
      this.staff[index].level = 0;
    }
    this.setup();
  }

  State.prototype.animate = function(environment, delta) {
    var definition, index, name, object, _i, _j, _len, _len1, _ref, _ref1, _results;
    _ref = this.income;
    for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
      definition = _ref[index];
      definition.left -= delta;
      if (definition.left <= 0) {
        this.money += definition.income * (1 + definition.powerup) * -(Math.floor(definition.left / definition.each));
        definition.left += definition.each * -(Math.floor(definition.left / definition.each));
      }
    }
    $("span#money").text(this.money.toFixed(2));
    _ref1 = (function() {
      switch (environment.current) {
        case "buttons_incomes":
          return {
            "object": this.income,
            "name": "income"
          };
        case "buttons_staff":
          return {
            "object": this.staff,
            "name": "staff"
          };
      }
    }).call(this), object = _ref1.object, name = _ref1.name;
    _results = [];
    for (index = _j = 0, _len1 = object.length; _j < _len1; index = ++_j) {
      definition = object[index];
      if (this.money >= definition.cost) {
        _results.push($("div#" + name + "_" + index).css("background-color", "green"));
      } else {
        _results.push($("div#" + name + "_" + index).css("background-color", "red"));
      }
    }
    return _results;
  };

  State.prototype.levelUpIncome = function(income_id) {
    if (this.income[income_id].cost <= this.money) {
      this.money -= this.income[income_id].cost;
      this.income[income_id].level += 1;
      this.income[income_id].cost += this.income[income_id].cost * 0.15;
      this.income[income_id].income += this.income[income_id].base_income;
      this.updateIncome(income_id);
      this.updateMpS();
      if (this.income[income_id].level === 1 && this.income.length > income_id) {
        return $("div#income_" + (income_id + 1)).fadeIn(1000);
      }
    }
  };

  State.prototype.levelUpStaff = function(staff_id) {
    var income, index, _i, _len, _ref;
    if (this.staff[staff_id].cost <= this.money) {
      this.money -= this.staff[staff_id].cost;
      this.staff[staff_id].level += 1;
      this.staff[staff_id].cost += this.staff[staff_id].cost * 0.50;
      this.staff[staff_id].current += this.staff[staff_id].base_effect;
      if (this.staff[staff_id].scope === "everything") {
        _ref = this.income;
        for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
          income = _ref[index];
          income.powerup += this.staff[staff_id].base_effect;
          this.updateIncome(index);
        }
      }
      this.updateStaff(staff_id);
      this.updateMpS();
      if (this.staff[staff_id].level === 1 && this.staff.length > staff_id) {
        return $("div#staff_" + (staff_id + 1)).fadeIn(1000);
      }
    }
  };

  State.prototype.updateMpS = function() {
    var acum, definition, _i, _len, _ref;
    acum = 0;
    _ref = this.income;
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      definition = _ref[_i];
      acum += definition.income * (1 + definition.powerup) / definition.each;
    }
    return $("span#mps").text((acum * 1000).toFixed(2));
  };

  State.prototype.updateIncome = function(income_id) {
    $("div#income_" + income_id + " .level").text(this.income[income_id].level);
    $("div#income_" + income_id + " .income").text((this.income[income_id].income * (1 + this.income[income_id].powerup)).toFixed(2));
    $("div#income_" + income_id + " .powerup").text(this.income[income_id].powerup.toFixed(2));
    $("div#income_" + income_id + " .each").text((this.income[income_id].each / 1000).toFixed(2));
    return $("div#income_" + income_id + " .cost").text(this.income[income_id].cost.toFixed(2));
  };

  State.prototype.updateStaff = function(staff_id) {
    $("div#staff_" + staff_id + " .level").text(this.staff[staff_id].level);
    $("div#staff_" + staff_id + " .current").text(this.staff[staff_id].current);
    return $("div#staff_" + staff_id + " .cost").text(this.staff[staff_id].cost.toFixed(2));
  };

  State.prototype.setup = function() {
    var element, income_def, index, staff_def, text, _i, _j, _len, _len1, _ref, _ref1;
    _ref = this.income;
    for (index = _i = 0, _len = _ref.length; _i < _len; index = ++_i) {
      income_def = _ref[index];
      text = "" + income_def.name + "<br />";
      text += "Level: <span class=\"level\">" + income_def.level + "</span><br />";
      text += "Income: <span class=\"income\">" + income_def.income + "</span><br />";
      text += "Each: <span class=\"each\">" + ((income_def.each / 1000).toFixed(2)) + "</span>s<br />";
      text += "Cost: <span class=\"cost\">" + income_def.cost + "</span><br />";
      element = $("<div>", {
        "class": "income_box",
        "id": "income_" + index,
        "width": 200,
        "height": 100,
        "html": text,
        "hidden": "hidden"
      });
      element.click((function(state) {
        return function() {
          return state.levelUpIncome(parseInt($(this)[0].id.split("_")[1]));
        };
      })(this));
      element.on("tap", (function(state) {
        return function() {
          return state.levelUpIncome(parseInt($(this)[0].id.split("_")[1]));
        };
      })(this));
      $("div#incomes_frame").append(element);
    }
    $("div#income_0").fadeIn(1000);
    _ref1 = this.staff;
    for (index = _j = 0, _len1 = _ref1.length; _j < _len1; index = ++_j) {
      staff_def = _ref1[index];
      text = "" + staff_def.name + "<br />";
      text += "Level: <span class=\"level\">" + staff_def.level + "</span><br />";
      text += "Description: <span class=\"description\">" + staff_def.description + "</span><br />";
      text += "Current: <span class=\"current\">" + (staff_def.current.toFixed(2)) + "</span>s<br />";
      text += "Cost: <span class=\"cost\">" + staff_def.cost + "</span><br />";
      element = $("<div>", {
        "class": "staff_box",
        "id": "staff_" + index,
        "width": 200,
        "height": 100,
        "html": text,
        "hidden": "hidden"
      });
      element.click((function(state) {
        return function() {
          return state.levelUpStaff(parseInt($(this)[0].id.split("_")[1]));
        };
      })(this));
      element.on("tap", (function(state) {
        return function() {
          return state.levelUpStaff(parseInt($(this)[0].id.split("_")[1]));
        };
      })(this));
      $("div#staff_frame").append(element);
    }
    return $("div#staff_0").fadeIn(1000);
  };

  return State;

})();

loadSound = function(environment, src) {
  var request, result;
  result = {
    "loaded": {
      "_": false
    },
    "content": {}
  };
  request = new XMLHttpRequest();
  request.open("GET", src, true);
  request.responseType = "arraybuffer";
  request.onload = function() {
    if (this.readyState === 4) {
      return environment.sound_context.decodeAudioData(this.response, (function(buffer) {
        result.loaded._ = true;
        return result.content._ = buffer;
      }), function() {});
    }
  };
  request.send();
  return result;
};

playSound = function(environment, buffer) {
  var source;
  source = environment.sound_context.createBufferSource();
  source.buffer = buffer;
  source.connect(environment.sound_context.destination);
  return source.start(0);
};

Environment = (function() {
  function Environment() {
    this.loop = new GeneralGameScreenLoop(new State(this));
    this.loading = true;
    this.constants = constants;
    this.keys = {};
    this.data = {};
    this.time = new Date();
    this.sound_context = new AudioContext();
    this.current = $("#buttons_incomes")[0].id;
    document.onkeydown = (function(_this) {
      return function(event) {
        return _this.onKeyDown(event);
      };
    })(this);
    document.onkeyup = (function(_this) {
      return function(event) {
        return _this.onKeyUp(event);
      };
    })(this);
    document.onmousedown = (function(_this) {
      return function(event) {
        return _this.onMouseDown(event);
      };
    })(this);
    document.onmouseup = (function(_this) {
      return function(event) {
        return _this.onMouseUp(event);
      };
    })(this);
    document.onmousemove = (function(_this) {
      return function(event) {
        return _this.onMouseMove(event);
      };
    })(this);
    this.change_loop = false;
    this.loop_to_change = function() {};
    $("div#buttons div").click(this.getClickFunction());
    $("div#buttons div").on("touch", this.getClickFunction());
    setTimeout(((function(_this) {
      return function() {
        return _this.tick();
      };
    })(this)), this.loop.frame_time);
  }

  Environment.prototype.getClickFunction = function() {
    return (function(environment) {
      return function() {
        var id;
        id = $(this)[0].id;
        if (id !== environment.current) {
          switch (environment.current) {
            case "buttons_incomes":
              $("#incomes_frame").slideToggle(1000).queue();
              break;
            case "buttons_staff":
              $("#staff_frame").slideToggle(1000).queue();
          }
          switch (id) {
            case "buttons_incomes":
              $("#incomes_frame").slideToggle(1000).queue();
              break;
            case "buttons_staff":
              $("#staff_frame").slideToggle(1000).queue();
          }
          return environment.current = id;
        }
      };
    })(this);
  };

  Environment.prototype.tick = function() {
    var delta;
    if (this.loading) {
      this.loading = !this.loop.isReady();
      return setTimeout(((function(_this) {
        return function() {
          return _this.tick();
        };
      })(this)), this.loop.frame_time);
    } else {
      delta = this.time;
      this.time = new Date();
      delta = this.time - delta;
      $("#fps").text((1000 / delta).toFixed(2));
      this.loop.animate(this, delta);
      if (this.change_loop) {
        this.loop = this.loop_to_change();
        this.change_loop = false;
      }
      return setTimeout(((function(_this) {
        return function() {
          return _this.tick();
        };
      })(this)), this.loop.frame_time - (new Date() - this.time));
    }
  };

  Environment.prototype.onKeyDown = function(event) {
    if (!this.loading) {
      this.keys[event.keyCode] = true;
      return this.loop.onKeyDown(event, this);
    }
  };

  Environment.prototype.onKeyUp = function(event) {
    if (!this.loading) {
      this.keys[event.keyCode] = false;
      return this.loop.onKeyUp(event, this);
    }
  };

  Environment.prototype.onMouseDown = function(event) {
    if (!this.loading) {
      return this.loop.onMouseDown(event, this);
    }
  };

  Environment.prototype.onMouseUp = function(event) {
    if (!this.loading) {
      return this.loop.onMouseUp(event, this);
    }
  };

  Environment.prototype.onMouseMove = function(event) {
    if (!this.loading) {
      return this.loop.onMouseMove(event, this);
    }
  };

  return Environment;

})();

Loop = (function() {
  function Loop() {
    this.frame_time = 1000 / 32;
  }

  Loop.prototype.isReady = function() {
    return true;
  };

  Loop.prototype.animate = function() {};

  Loop.prototype.onKeyDown = function(event, environment) {};

  Loop.prototype.onKeyUp = function(event, environment) {};

  Loop.prototype.onMouseDown = function(event, environment) {};

  Loop.prototype.onMouseUp = function(event, environment) {};

  Loop.prototype.onMouseMove = function(event, environment) {};

  return Loop;

})();

GeneralGameScreenLoop = (function(_super) {
  __extends(GeneralGameScreenLoop, _super);

  function GeneralGameScreenLoop(state) {
    this.state = state;
    GeneralGameScreenLoop.__super__.constructor.call(this);
  }

  GeneralGameScreenLoop.prototype.animate = function(environment, delta) {
    return this.state.animate(environment, delta);
  };

  return GeneralGameScreenLoop;

})(Loop);

loadImage = function(src) {
  var result;
  result = {
    "loaded": {
      "_": false
    },
    "content": new Image
  };
  result.content.onload = function() {
    return result.loaded._ = true;
  };
  result.content.src = src;
  return result;
};