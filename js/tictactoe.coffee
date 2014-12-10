###
 TicTacToe Game
###


# Config-Map mit Start-Konfiguration
configMap =
  # choose which icon the player gets
  # choose who starts
  baseHtml: '' +
    '<div id="tictactoe-grid">' +
    '<div id="tictactoe-grid-field0"></div>' +
    '<div id="tictactoe-grid-field1"></div>' +
    '<div id="tictactoe-grid-field2"></div>' +
    '<div id="tictactoe-grid-field3"></div>' +
    '<div id="tictactoe-grid-field4"></div>' +
    '<div id="tictactoe-grid-field5"></div>' +
    '<div id="tictactoe-grid-field6"></div>' +
    '<div id="tictactoe-grid-field7"></div>' +
    '<div id="tictactoe-grid-field8"></div>' +
    '</div>' +
    '<div id="game-status"></div>'

  # blank, x and o
  blankHtml: '' +
    '<svg viewBox="0 0 199 199" preserveAspectRatio="xMinYMin meet" xmlns="http://www.w3.org/2000/svg">' +
    '<title>Blank</title>' +
    '</svg>'
  xHtml: '' +
    '<svg viewBox="0 0 199 199" preserveAspectRatio="xMinYMin meet" xmlns="http://www.w3.org/2000/svg">' +
    '<title>Cross</title>' +
    '<polygon points="35 49, 49 35, 100 86, 151 35, 165 49, 114 100, 165 151,' +
    ' 151 165, 100 114, 49 165, 35 151, 86 100" stroke="none" fill="yellow" />' +
    '</svg>'

  oHtml: '' +
    '<svg viewBox="0 0 199 199" preserveAspectRatio="xMinYMin meet" xmlns="http://www.w3.org/2000/svg">' +
    '<title>Circle</title>' +
    '<circle cx="100" cy="100" r="55" style="stroke: yellow; stroke-width: 20; fill: none" />' +
    '</svg>'



# module-wide variables
stateMap =
  aiOpponent    : true
  currentPlayer : 0
  tictactoe     : null
  gameOver      : false
  winner        : false
  firstHistory  : false

domMap = {}


### Class TicTacToe
  Represents the current state of the playing field (grid)
  and provides methods for (among others)
    * making a move as a human player
    * making a move as a computer player
    * getting information on who has the next move, if the game is won and
      on the current status of the playing field
###
class TicTacToe
  ###
    Constants
  ###
  GRID_BLANK : '~'
  GRID_X     : 'x'
  GRID_O     : 'o'


  # This map is used by the computer algorithm to check relevant
  # grid positions
  CHECKPOSITIONSMAP:
    0 : [[1,2], [3,6], [4,8]]
    1 : [[0,2], [4,7]]
    2 : [[0,1], [5,8], [4,6]]
    3 : [[4,5], [0,6]]
    4 : [[3,5], [1,7], [0,8], [2,6]]
    5 : [[3,4], [2,8]]
    6 : [[7,8], [0,3], [2,4]]
    7 : [[6,8], [1,4]]
    8 : [[6,7], [2,5], [0,4]]


  ###
    /Constructor/
    Purpose: Initializes the game.
    Arguments:
      * xBegins - boolean
  ###
  constructor: (xBegins=true) ->
    # initialize grid
    @grid = (@GRID_BLANK for x in [0..8])

    # who begins
    if xBegins
      @nextMove = @GRID_X
    else
      @nextMove = @GRID_O


  ###
    'Public' functions
  ###


  # switchPlayer - switches the internal state of who has the next move: from 'x' to 'o' or vice versa
  switchPlayer: -> if @nextMove is @GRID_X then @nextMove = @GRID_O else @nextMove = @GRID_X


  # makeHumanMove - tries to occupy the given grid position
  # Arguments:
  #    * position object {x, y}
  # Returns:
  #   * true - if position was successfully occupied
  #   * false - if position was not empty or if current player is not human
  # Throws error if grid position is wrong
  makeHumanMove: (position) ->
    if (2 < position.x < 0) or (2 < position.y < 0)
      throw 'out of grid boundaries'

    serPos = @serializePosition position

    if @grid[serPos] is @GRID_BLANK
      # fill grid position with current players token
      @grid[serPos] = @nextMove
      return true
    else
      return false


  # makeComputerMove - make a move by algorithm
  # Algorithm:
  #   * Make a map of the playing field giving each position a weight. E.g. if position
  #     (0, 0) would lead to the player winning the match it should have the highest
  #     weight, i.e. 100.
  #   * Then simply choose the position with the highest weight for the move.
  #   * If several positions have the same weight, choose one randomly.
  #   * If all positions have a weight of -1, the grid is occupied, so the computer
  #     cannot make a move - return false
  # Returns:
  #   * Grid position as an object (for example: {0, 2}) or
  #   * false if no move could be made because all positions are occupied
  makeComputerMove: ->
    weightMap = @makeWeightMap()

    # determine highest weight
    highest = Math.max weightMap...

    # return false if grid is occupied
    if highest is -1 then return false

    # get the indices of positions that have a weight equal to highest
    highestIndices = (i for weight, i in weightMap when weight is highest)

    # pick one randomly and make a move
    rand = highestIndices[ Math.floor (Math.random() * highestIndices.length) ]
    @grid[rand] = @nextMove

    return @deserializePosition rand


  # getNext - returns who has the next move
  # Returns 'x' or 'o'
  getNext: -> @nextMove


  # setNext - sets who has the next move
  # Arguments:
  #   * player - 'x' or 'o'
  setNext: (player) ->
    if player is @GRID_X or player is @GRID_O
      @nextMove = player
    else
      throw 'wrong player'


  # getGrid - returns current grid as a onedimensional array
  getGrid: -> @grid


  # setGrid - sets the grid to the grid given as a parameter
  # Arguments:
  #   * newGrid - the new grid as a one-or two-dimensional array
  setGrid: (newGrid) -> @grid = newGrid


  # determineWinner - return winner if there is any
  # This function assumes that only one player has a tic-tac-toe at the moment.
  # Returns:
  #    * 'x' or 'o' if either has at least one tic-tac-toe
  #    * false if there is no winner (the game has not come to an end)
  determineWinner: ->
    if @analyseGrid(@GRID_X, 3).length > 0 then return @GRID_X
    else if @analyseGrid(@GRID_O, 3).length > 0 then return @GRID_O
    else return false


  # isGameOver - Checks if game is over
  # Returns true if grid is full or if there is a winner, false otherwise
  isGameOver: ->
    @analyseGrid(@GRID_BLANK, 1).length is 0 or @determineWinner()


  # toString - returns string representation of playing field (grid)
  toString: -> "#{@grid[0..2]}\n#{@grid[3..5]}\n#{@grid[6..8]}"


  ###
    Internal functions
  ###


  # serializePosition - converts x and y coordinates into an one-dimensional array index
  # needed because grid is represented sometimes as an one-dimensional array
  # Example: serializePosition { x: 2, y:1 } returns 5
  serializePosition: (position) -> position.y * 3 + position.x


  # deserializePosition - turn serialized index position into x, y coordinates
  # Example: deserializePosition 5 returns { x: 2, y: 1 }
  deserializePosition: (index) ->
    x: index % 3
    y: Math.floor (index / 3)


  # analyseGrid - general purpose grid analysis
  # Arguments:
  #   * token - 'x' or 'o'
  #   * numMatches - look for 1, 2 or 3 matches
  # Returns: An array that shows which rows, columns or diagonals contain matches
  #   Array is empty if no matches are found
  # Return codes:
  #   0 - first row (from top to bottom)
  #   1 - second row
  #   2 - third row
  #   3 - first column (from left to right)
  #   4 - second column
  #   5 - third column
  #   6 - first diagonal (top left to bottom right)
  #   7 - second diagonal (bottom left to top right)
  # Example:
  #   Grid: x~x
  #         ~~~
  #         ~~x
  #   analyseGrid('x', 2) returns [0, 5, 6] because there are two 'x' in the first row,
  #   in the third column and in the first diagonal.
  analyseGrid: (token, numMatches) ->
    returnCodes = [];

    countTokens = (token, positions...) ->
      count = 0
      count += 1 for pos in positions when pos is token
      count

    if countTokens(token, @grid[0], @grid[1], @grid[2]) >= numMatches then returnCodes.push 0
    if countTokens(token, @grid[3], @grid[4], @grid[5]) >= numMatches then returnCodes.push 1
    if countTokens(token, @grid[6], @grid[7], @grid[8]) >= numMatches then returnCodes.push 2
    if countTokens(token, @grid[0], @grid[3], @grid[6]) >= numMatches then returnCodes.push 3
    if countTokens(token, @grid[1], @grid[4], @grid[7]) >= numMatches then returnCodes.push 4
    if countTokens(token, @grid[2], @grid[5], @grid[8]) >= numMatches then returnCodes.push 5
    if countTokens(token, @grid[0], @grid[4], @grid[8]) >= numMatches then returnCodes.push 6
    if countTokens(token, @grid[6], @grid[4], @grid[2]) >= numMatches then returnCodes.push 7
    returnCodes


  # makeWeightMap - make a map that reflects the grid and has a specific weight for each
  # position to make the next computer move.
  # Basically, this is the main algorithm for a computer player.
  # The weights:
  #   25+ : At this position the game can be won with the next move - highest
  #   5+  : At this position a three-in-a-row of the opponent can be prevented
  #   4-0 : Normal move that contributes to 4, 3, 2, 1 or 0 possible tic-tac-toes,
  #         Examples:
  #         - If you place an 'x' in the middle of an empty playing field, it
  #           could potientially be a part of 4 different tic-tac-toes (horizontal,
  #           vertical and the two diagonals).
  #         - If the next player places an 'o' on position (1, 0), that is in the
  #           middle of the first row, it can only be a part of 1 potential
  #           tic-tac-toe (the horizontal one, the vertical is impossible because
  #           the other player has taken the middle position).
  #   -1  : Position already occupied
  makeWeightMap: -> (@calculateWeight x for x in [0...@grid.length])


  # calculateWeight - calculates weight for a single position
  # Arguments:
  #   * serialized position
  # Returns:
  #   * weight
  calculateWeight: (index) ->
    # return -1 if position is occupied
    if @grid[index] isnt @GRID_BLANK then return -1

    # determine player and opponent tokens
    player = @nextMove
    if @nextMove is @GRID_X
      opponent = @GRID_O
    else
      opponent = @GRID_X

    # otherwise, check relevant positions in the grid
    directions = @CHECKPOSITIONSMAP[index]
    totalVal = 0
    for direction in directions
      dirVal = 0
      if @grid[direction[0]] is @GRID_BLANK and @grid[direction[1]] is @GRID_BLANK
        dirVal = 1
      if @grid[direction[0]] is opponent and @grid[direction[1]] is opponent
        dirVal = 5
      if @grid[direction[0]] is player and @grid[direction[1]] is player
        dirVal = 25
      totalVal += dirVal

    totalVal

###
  End of TicTacToe class
###


###
  DOM methods
###

# setDomMap - caches DOM elements in a map
setDomMap = (container) ->
  domMap =
    container     : container
    grid          : document.getElementById 'tictactoe-grid'
    field0        : document.getElementById 'tictactoe-grid-field0'
    field1        : document.getElementById 'tictactoe-grid-field1'
    field2        : document.getElementById 'tictactoe-grid-field2'
    field3        : document.getElementById 'tictactoe-grid-field3'
    field4        : document.getElementById 'tictactoe-grid-field4'
    field5        : document.getElementById 'tictactoe-grid-field5'
    field6        : document.getElementById 'tictactoe-grid-field6'
    field7        : document.getElementById 'tictactoe-grid-field7'
    field8        : document.getElementById 'tictactoe-grid-field8'
    gameStatus    : document.getElementById 'game-status'


# updateGameStatus - updates the current player display
updateGameStatus = ->
  currentPlayer  = stateMap.currentPlayer
  aiOpponent     = stateMap.aiOpponent
  winner         = stateMap.winner
  dom_gameStatus = domMap.gameStatus

  unless stateMap.gameOver
    # if game is running
    if aiOpponent and currentPlayer is 0
      playerStr = 'Your move (x)'
    else
      playerStr = switch currentPlayer
        when 0 then 'Player 1\'s move (x)'
        when 1 then 'Player 2\'s move (o)'
    dom_gameStatus.innerHTML = "<p>#{playerStr}</p>"
  else
    # if game is over
    if stateMap.winner is false
      winMsg = 'Game over, no winners!'
    else
      if aiOpponent
        if winner is 'x' then winMsg = 'You have won!'
        else winMsg = 'The computer has won!'
      else
        if winner is 'x' then winMsg = 'Player 1 (x) has won!'
        else winMsg = 'Player 2 (o) has won!'
    # display winner message
    dom_gameStatus.innerHTML = "<p>#{winMsg}</p>"

    # insert a 'play again' link and bind it to click event
    dom_gameStatus.innerHTML += '<p><button id="play-again" href="#">Play again</button></p>'
    linkElement = document.getElementById('play-again')
    linkElement.addEventListener 'click', handleLinkClick, false


# Begin: drawGrid - 'redraw' elements of grid completely
drawGrid = ->
  tictactoe = stateMap.tictactoe
  grid      = tictactoe.getGrid()

  # Begin: for each cell
  for pos, i in grid
    elem = domMap['field' + i]

    # set proper SVG image
    elem.innerHTML = switch pos
      when tictactoe.GRID_X
        configMap.xHtml
      when tictactoe.GRID_O
        configMap.oHtml
      when tictactoe.GRID_BLANK
        configMap.blankHtml

    # set class indicating if position is clickable
    if pos is tictactoe.GRID_BLANK and not stateMap.gameOver
      elem.classList.remove 'tictactoe-taken'
    else
      elem.classList.add 'tictactoe-taken'
  # End: for each cell
# End: drawGrid


# updateHistory - get current state and push it to History
updateHistory = ->
  stateObj =
    grid          : stateMap.tictactoe.getGrid()
    currentPlayer : stateMap.currentPlayer
    aiOpponent    : stateMap.aiOpponent

  # if computer had the last move, use replaceState instead
  # of pushState so that is doesn't count as an extra step
  if stateMap.aiOpponent and stateMap.currentPlayer is 0
    history.replaceState stateObj, '', ''
  else
    history.pushState stateObj, '', ''

###
  Event handlers
###


# handleClick - tries to make a move on the clicked element
handleClick = (event) ->
  tictactoe = stateMap.tictactoe
  container = event.target.parentNode
  id        = container.id

  # parse id attribute of target element
  idNumber  = parseInt id.slice(-1), 10
  idText    = id.slice 0, -1

  if (idText is 'tictactoe-grid-field') and
  (container.className.indexOf('tictactoe-taken') is -1)

    position =
      x: idNumber % 3
      y: Math.floor (idNumber / 3)
    result = tictactoe.makeHumanMove position

    if result
      tictactoe.switchPlayer()
      stateMap.currentPlayer = 1 - stateMap.currentPlayer
      updateHistory()
    else throw "could not make move to #{JSON.stringify position}"

    # next step!
    nextStep()

  return false


# handleLinkClick - reloads page after 'Play again' link is clicked
handleLinkClick = (event) ->
  event.preventDefault()
  initModule domMap.container


# handlePopstate - replaces game state after back button is pressed
handlePopstate = (event) ->
  tictactoe = stateMap.tictactoe
  stateObj  = event.state
  if !stateObj? then stateObj = history.state

  stateMap.currentPlayer = stateObj.currentPlayer
  stateMap.aiOpponent    = stateObj.aiOpponent

  tictactoe.setGrid stateObj.grid
  if stateMap.currentPlayer is 0
    tictactoe.setNext tictactoe.GRID_X
  else
    tictactoe.setNext tictactoe.GRID_O

  nextStep()


###
  Game Logic
###

# nextStep
nextStep = ->
  tictactoe = stateMap.tictactoe

  if tictactoe.isGameOver()
    # game is already over
    stateMap.gameOver = true
    stateMap.winner = tictactoe.determineWinner()
  else
    # game is not over yet
    stateMap.gameOver = false
    stateMap.winner = false
    if stateMap.aiOpponent and stateMap.currentPlayer is 1
      # make an ai move
      tictactoe.makeComputerMove()
      tictactoe.switchPlayer()
      stateMap.currentPlayer = 0
      updateHistory()
      nextStep()

  # Update DOM
  drawGrid()
  updateGameStatus()


# initModule
initModule = (container) ->
  # set up game state
  stateMap.gameOver      = false
  stateMap.winner        = false
  stateMap.currentPlayer = Math.round Math.random()
  if stateMap.currentPlayer is 0 then xBegins = true else xBegins = false
  stateMap.tictactoe     = new TicTacToe(xBegins)
  stateMap.aiOpponent    = confirm 'Would you like to play against the computer?'

  # set up dom
  container.innerHTML = configMap.baseHtml
  setDomMap(container)
  drawGrid()
  updateGameStatus()

  # add event listeners
  domMap.grid.addEventListener 'click',      handleClick,    false
  domMap.grid.addEventListener 'touchstart', handleClick,    false
  window.addEventListener      'popstate',   handlePopstate, false

  # set first history snapshot
  stateObj =
    grid          : stateMap.tictactoe.getGrid()
    currentPlayer : stateMap.currentPlayer
    aiOpponent    : stateMap.aiOpponent
  if stateMap.firstHistory is false
    history.replaceState stateObj, '', ''
    stateMap.firstHistory = true
  else
    history.pushState stateObj, '', ''

  # if computer begins, make ai move and update history entry
  if stateMap.aiOpponent and stateMap.currentPlayer is 1
    stateMap.tictactoe.makeComputerMove()
    stateMap.tictactoe.switchPlayer()
    stateMap.currentPlayer = 0
    updateHistory()
    nextStep()

# export initModule function
window.TicTacToe = initModule: initModule
