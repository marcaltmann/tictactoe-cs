// Generated by CoffeeScript 1.8.0

/*
 TicTacToe Game
 */

(function() {
  var TicTacToe, configMap, domMap, drawGrid, handleClick, handleLinkClick, handlePopstate, initModule, nextStep, setDomMap, stateMap, updateGameStatus, updateHistory,
    __slice = [].slice;

  configMap = {
    baseHtml: '' + '<div id="tictactoe-grid">' + '<div id="tictactoe-grid-field0"></div>' + '<div id="tictactoe-grid-field1"></div>' + '<div id="tictactoe-grid-field2"></div>' + '<div id="tictactoe-grid-field3"></div>' + '<div id="tictactoe-grid-field4"></div>' + '<div id="tictactoe-grid-field5"></div>' + '<div id="tictactoe-grid-field6"></div>' + '<div id="tictactoe-grid-field7"></div>' + '<div id="tictactoe-grid-field8"></div>' + '</div>' + '<div id="game-status"></div>',
    blankHtml: '' + '<svg viewBox="0 0 199 199" preserveAspectRatio="xMinYMin meet" xmlns="http://www.w3.org/2000/svg">' + '<title>Blank</title>' + '</svg>',
    xHtml: '' + '<svg viewBox="0 0 199 199" preserveAspectRatio="xMinYMin meet" xmlns="http://www.w3.org/2000/svg">' + '<title>Cross</title>' + '<polygon points="35 49, 49 35, 100 86, 151 35, 165 49, 114 100, 165 151,' + ' 151 165, 100 114, 49 165, 35 151, 86 100" stroke="none" fill="yellow" />' + '</svg>',
    oHtml: '' + '<svg viewBox="0 0 199 199" preserveAspectRatio="xMinYMin meet" xmlns="http://www.w3.org/2000/svg">' + '<title>Circle</title>' + '<circle cx="100" cy="100" r="55" style="stroke: yellow; stroke-width: 20; fill: none" />' + '</svg>'
  };

  stateMap = {
    aiOpponent: true,
    currentPlayer: 0,
    tictactoe: null,
    gameOver: false,
    winner: false,
    firstHistory: false
  };

  domMap = {};


  /* Class TicTacToe
    Represents the current state of the playing field (grid)
    and provides methods for (among others)
      * making a move as a human player
      * making a move as a computer player
      * getting information on who has the next move, if the game is won and
        on the current status of the playing field
   */

  TicTacToe = (function() {

    /*
      Constants
     */
    TicTacToe.prototype.GRID_BLANK = '~';

    TicTacToe.prototype.GRID_X = 'x';

    TicTacToe.prototype.GRID_O = 'o';

    TicTacToe.prototype.CHECKPOSITIONSMAP = {
      0: [[1, 2], [3, 6], [4, 8]],
      1: [[0, 2], [4, 7]],
      2: [[0, 1], [5, 8], [4, 6]],
      3: [[4, 5], [0, 6]],
      4: [[3, 5], [1, 7], [0, 8], [2, 6]],
      5: [[3, 4], [2, 8]],
      6: [[7, 8], [0, 3], [2, 4]],
      7: [[6, 8], [1, 4]],
      8: [[6, 7], [2, 5], [0, 4]]
    };


    /*
      /Constructor/
      Purpose: Initializes the game.
      Arguments:
        * xBegins - boolean
     */

    function TicTacToe(xBegins) {
      var x;
      if (xBegins == null) {
        xBegins = true;
      }
      this.grid = (function() {
        var _i, _results;
        _results = [];
        for (x = _i = 0; _i <= 8; x = ++_i) {
          _results.push(this.GRID_BLANK);
        }
        return _results;
      }).call(this);
      if (xBegins) {
        this.nextMove = this.GRID_X;
      } else {
        this.nextMove = this.GRID_O;
      }
    }


    /*
      'Public' functions
     */

    TicTacToe.prototype.switchPlayer = function() {
      if (this.nextMove === this.GRID_X) {
        return this.nextMove = this.GRID_O;
      } else {
        return this.nextMove = this.GRID_X;
      }
    };

    TicTacToe.prototype.makeHumanMove = function(position) {
      var serPos, _ref, _ref1;
      if (((2 < (_ref = position.x) && _ref < 0)) || ((2 < (_ref1 = position.y) && _ref1 < 0))) {
        throw 'out of grid boundaries';
      }
      serPos = this.serializePosition(position);
      if (this.grid[serPos] === this.GRID_BLANK) {
        this.grid[serPos] = this.nextMove;
        return true;
      } else {
        return false;
      }
    };

    TicTacToe.prototype.makeComputerMove = function() {
      var highest, highestIndices, i, rand, weight, weightMap;
      weightMap = this.makeWeightMap();
      highest = Math.max.apply(Math, weightMap);
      if (highest === -1) {
        return false;
      }
      highestIndices = (function() {
        var _i, _len, _results;
        _results = [];
        for (i = _i = 0, _len = weightMap.length; _i < _len; i = ++_i) {
          weight = weightMap[i];
          if (weight === highest) {
            _results.push(i);
          }
        }
        return _results;
      })();
      rand = highestIndices[Math.floor(Math.random() * highestIndices.length)];
      this.grid[rand] = this.nextMove;
      return this.deserializePosition(rand);
    };

    TicTacToe.prototype.getNext = function() {
      return this.nextMove;
    };

    TicTacToe.prototype.setNext = function(player) {
      if (player === this.GRID_X || player === this.GRID_O) {
        return this.nextMove = player;
      } else {
        throw 'wrong player';
      }
    };

    TicTacToe.prototype.getGrid = function() {
      return this.grid;
    };

    TicTacToe.prototype.setGrid = function(newGrid) {
      return this.grid = newGrid;
    };

    TicTacToe.prototype.determineWinner = function() {
      if (this.analyseGrid(this.GRID_X, 3).length > 0) {
        return this.GRID_X;
      } else if (this.analyseGrid(this.GRID_O, 3).length > 0) {
        return this.GRID_O;
      } else {
        return false;
      }
    };

    TicTacToe.prototype.isGameOver = function() {
      return this.analyseGrid(this.GRID_BLANK, 1).length === 0 || this.determineWinner();
    };

    TicTacToe.prototype.toString = function() {
      return "" + this.grid.slice(0, 3) + "\n" + this.grid.slice(3, 6) + "\n" + this.grid.slice(6, 9);
    };


    /*
      Internal functions
     */

    TicTacToe.prototype.serializePosition = function(position) {
      return position.y * 3 + position.x;
    };

    TicTacToe.prototype.deserializePosition = function(index) {
      return {
        x: index % 3,
        y: Math.floor(index / 3)
      };
    };

    TicTacToe.prototype.analyseGrid = function(token, numMatches) {
      var countTokens, returnCodes;
      returnCodes = [];
      countTokens = function() {
        var count, pos, positions, token, _i, _len;
        token = arguments[0], positions = 2 <= arguments.length ? __slice.call(arguments, 1) : [];
        count = 0;
        for (_i = 0, _len = positions.length; _i < _len; _i++) {
          pos = positions[_i];
          if (pos === token) {
            count += 1;
          }
        }
        return count;
      };
      if (countTokens(token, this.grid[0], this.grid[1], this.grid[2]) >= numMatches) {
        returnCodes.push(0);
      }
      if (countTokens(token, this.grid[3], this.grid[4], this.grid[5]) >= numMatches) {
        returnCodes.push(1);
      }
      if (countTokens(token, this.grid[6], this.grid[7], this.grid[8]) >= numMatches) {
        returnCodes.push(2);
      }
      if (countTokens(token, this.grid[0], this.grid[3], this.grid[6]) >= numMatches) {
        returnCodes.push(3);
      }
      if (countTokens(token, this.grid[1], this.grid[4], this.grid[7]) >= numMatches) {
        returnCodes.push(4);
      }
      if (countTokens(token, this.grid[2], this.grid[5], this.grid[8]) >= numMatches) {
        returnCodes.push(5);
      }
      if (countTokens(token, this.grid[0], this.grid[4], this.grid[8]) >= numMatches) {
        returnCodes.push(6);
      }
      if (countTokens(token, this.grid[6], this.grid[4], this.grid[2]) >= numMatches) {
        returnCodes.push(7);
      }
      return returnCodes;
    };

    TicTacToe.prototype.makeWeightMap = function() {
      var x, _i, _ref, _results;
      _results = [];
      for (x = _i = 0, _ref = this.grid.length; 0 <= _ref ? _i < _ref : _i > _ref; x = 0 <= _ref ? ++_i : --_i) {
        _results.push(this.calculateWeight(x));
      }
      return _results;
    };

    TicTacToe.prototype.calculateWeight = function(index) {
      var dirVal, direction, directions, opponent, player, totalVal, _i, _len;
      if (this.grid[index] !== this.GRID_BLANK) {
        return -1;
      }
      player = this.nextMove;
      if (this.nextMove === this.GRID_X) {
        opponent = this.GRID_O;
      } else {
        opponent = this.GRID_X;
      }
      directions = this.CHECKPOSITIONSMAP[index];
      totalVal = 0;
      for (_i = 0, _len = directions.length; _i < _len; _i++) {
        direction = directions[_i];
        dirVal = 0;
        if (this.grid[direction[0]] === this.GRID_BLANK && this.grid[direction[1]] === this.GRID_BLANK) {
          dirVal = 1;
        }
        if (this.grid[direction[0]] === opponent && this.grid[direction[1]] === opponent) {
          dirVal = 5;
        }
        if (this.grid[direction[0]] === player && this.grid[direction[1]] === player) {
          dirVal = 25;
        }
        totalVal += dirVal;
      }
      return totalVal;
    };

    return TicTacToe;

  })();


  /*
    End of TicTacToe class
   */


  /*
    DOM methods
   */

  setDomMap = function(container) {
    return domMap = {
      container: container,
      grid: document.getElementById('tictactoe-grid'),
      field0: document.getElementById('tictactoe-grid-field0'),
      field1: document.getElementById('tictactoe-grid-field1'),
      field2: document.getElementById('tictactoe-grid-field2'),
      field3: document.getElementById('tictactoe-grid-field3'),
      field4: document.getElementById('tictactoe-grid-field4'),
      field5: document.getElementById('tictactoe-grid-field5'),
      field6: document.getElementById('tictactoe-grid-field6'),
      field7: document.getElementById('tictactoe-grid-field7'),
      field8: document.getElementById('tictactoe-grid-field8'),
      gameStatus: document.getElementById('game-status')
    };
  };

  updateGameStatus = function() {
    var aiOpponent, currentPlayer, dom_gameStatus, linkElement, playerStr, winMsg, winner;
    currentPlayer = stateMap.currentPlayer;
    aiOpponent = stateMap.aiOpponent;
    winner = stateMap.winner;
    dom_gameStatus = domMap.gameStatus;
    if (!stateMap.gameOver) {
      if (aiOpponent && currentPlayer === 0) {
        playerStr = 'Your move (x)';
      } else {
        playerStr = (function() {
          switch (currentPlayer) {
            case 0:
              return 'Player 1\'s move (x)';
            case 1:
              return 'Player 2\'s move (o)';
          }
        })();
      }
      return dom_gameStatus.innerHTML = "<p>" + playerStr + "</p>";
    } else {
      if (stateMap.winner === false) {
        winMsg = 'Game over, no winners!';
      } else {
        if (aiOpponent) {
          if (winner === 'x') {
            winMsg = 'You have won!';
          } else {
            winMsg = 'The computer has won!';
          }
        } else {
          if (winner === 'x') {
            winMsg = 'Player 1 (x) has won!';
          } else {
            winMsg = 'Player 2 (o) has won!';
          }
        }
      }
      dom_gameStatus.innerHTML = "<p>" + winMsg + "</p>";
      dom_gameStatus.innerHTML += '<p><button id="play-again" href="#">Play again</button></p>';
      linkElement = document.getElementById('play-again');
      return linkElement.addEventListener('click', handleLinkClick, false);
    }
  };

  drawGrid = function() {
    var elem, grid, i, pos, tictactoe, _i, _len, _results;
    tictactoe = stateMap.tictactoe;
    grid = tictactoe.getGrid();
    _results = [];
    for (i = _i = 0, _len = grid.length; _i < _len; i = ++_i) {
      pos = grid[i];
      elem = domMap['field' + i];
      elem.innerHTML = (function() {
        switch (pos) {
          case tictactoe.GRID_X:
            return configMap.xHtml;
          case tictactoe.GRID_O:
            return configMap.oHtml;
          case tictactoe.GRID_BLANK:
            return configMap.blankHtml;
        }
      })();
      if (pos === tictactoe.GRID_BLANK && !stateMap.gameOver) {
        _results.push(elem.classList.remove('tictactoe-taken'));
      } else {
        _results.push(elem.classList.add('tictactoe-taken'));
      }
    }
    return _results;
  };

  updateHistory = function() {
    var stateObj;
    stateObj = {
      grid: stateMap.tictactoe.getGrid(),
      currentPlayer: stateMap.currentPlayer,
      aiOpponent: stateMap.aiOpponent
    };
    if (stateMap.aiOpponent && stateMap.currentPlayer === 0) {
      return history.replaceState(stateObj, '', '');
    } else {
      return history.pushState(stateObj, '', '');
    }
  };


  /*
    Event handlers
   */

  handleClick = function(event) {
    var container, id, idNumber, idText, position, result, tictactoe;
    tictactoe = stateMap.tictactoe;
    container = event.target.parentNode;
    id = container.id;
    idNumber = parseInt(id.slice(-1), 10);
    idText = id.slice(0, -1);
    if ((idText === 'tictactoe-grid-field') && (container.className.indexOf('tictactoe-taken') === -1)) {
      position = {
        x: idNumber % 3,
        y: Math.floor(idNumber / 3)
      };
      result = tictactoe.makeHumanMove(position);
      if (result) {
        tictactoe.switchPlayer();
        stateMap.currentPlayer = 1 - stateMap.currentPlayer;
        updateHistory();
      } else {
        throw "could not make move to " + (JSON.stringify(position));
      }
      nextStep();
    }
    return false;
  };

  handleLinkClick = function(event) {
    event.preventDefault();
    return initModule(domMap.container);
  };

  handlePopstate = function(event) {
    var stateObj, tictactoe;
    tictactoe = stateMap.tictactoe;
    stateObj = event.state;
    if (stateObj == null) {
      stateObj = history.state;
    }
    stateMap.currentPlayer = stateObj.currentPlayer;
    stateMap.aiOpponent = stateObj.aiOpponent;
    tictactoe.setGrid(stateObj.grid);
    if (stateMap.currentPlayer === 0) {
      tictactoe.setNext(tictactoe.GRID_X);
    } else {
      tictactoe.setNext(tictactoe.GRID_O);
    }
    return nextStep();
  };


  /*
    Game Logic
   */

  nextStep = function() {
    var tictactoe;
    tictactoe = stateMap.tictactoe;
    if (tictactoe.isGameOver()) {
      stateMap.gameOver = true;
      stateMap.winner = tictactoe.determineWinner();
    } else {
      stateMap.gameOver = false;
      stateMap.winner = false;
      if (stateMap.aiOpponent && stateMap.currentPlayer === 1) {
        tictactoe.makeComputerMove();
        tictactoe.switchPlayer();
        stateMap.currentPlayer = 0;
        updateHistory();
        nextStep();
      }
    }
    drawGrid();
    return updateGameStatus();
  };

  initModule = function(container) {
    var stateObj, xBegins;
    stateMap.gameOver = false;
    stateMap.winner = false;
    stateMap.currentPlayer = Math.round(Math.random());
    if (stateMap.currentPlayer === 0) {
      xBegins = true;
    } else {
      xBegins = false;
    }
    stateMap.tictactoe = new TicTacToe(xBegins);
    stateMap.aiOpponent = confirm('Would you like to play against the computer?');
    container.innerHTML = configMap.baseHtml;
    setDomMap(container);
    drawGrid();
    updateGameStatus();
    domMap.grid.addEventListener('click', handleClick, false);
    domMap.grid.addEventListener('touchstart', handleClick, false);
    window.addEventListener('popstate', handlePopstate, false);
    stateObj = {
      grid: stateMap.tictactoe.getGrid(),
      currentPlayer: stateMap.currentPlayer,
      aiOpponent: stateMap.aiOpponent
    };
    if (stateMap.firstHistory === false) {
      history.replaceState(stateObj, '', '');
      stateMap.firstHistory = true;
    } else {
      history.pushState(stateObj, '', '');
    }
    if (stateMap.aiOpponent && stateMap.currentPlayer === 1) {
      stateMap.tictactoe.makeComputerMove();
      stateMap.tictactoe.switchPlayer();
      stateMap.currentPlayer = 0;
      updateHistory();
      return nextStep();
    }
  };

  window.TicTacToe = {
    initModule: initModule
  };

}).call(this);