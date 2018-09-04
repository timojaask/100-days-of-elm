## Day 24

Quick review of day 23:

Yesterday I continued the Tic-Tac-Toe implementation. I decided to try out a new data structure for the board. Instead of using `List (List Cell)` I started using `List Cell`. I felt like it made some code a little more awkward, and some code a little bit clearer, so overall didn't feel like it was an improvement.

Then I added some logic to add Os after each turn. Then I added a check for a draw. And then I noticed a bug where if you click on the same cell repeatedly, it would keep adding Os.

---

Today I started by watching the first part of [Elm workshop](https://frontendmasters.com/workshops/elm-v2/) by Richard Feldman. He introduced basic concepts about Elm.

He compared Elm to some popular JavaScript frameworks and ecosystems surrounding them.

Richard mentioned an interesting thing about React -- apparently Jordan Walke originally intended it to use regular functions for creating the UI, just like Elm, but the engineers at Facebook who got used to some PHP templating library didn't like it, so he/they created JSX. I also noticed, if you read [Why did we build React?](https://reactjs.org/blog/2013/06/05/why-react.html) blog post, they say it pretty early on:
> This means React uses a real, full featured programming language to render views, which we see as an advantage over templates for a few reasons:
>
> ...
>
> We’ve also created JSX, an optional syntax extension, in case you prefer the readability of HTML to raw JavaScript.

I also learned (finally!) that in Elm the `if ... then ... else` is called an *if-expression*. I was mistakingly calling it an "if statement", which is of course plain wrong.

Richard made an interesting comparison to JavaScript conditional expression. Elm's if-expression is like that, but very different from JS's `if` statement:

Elm:

```
quantityMessage = if quantity >= 1 then "More than one" else "One or less"
```

Equivalent in JavaScript:

```
const quantityMessage = quantity >= 1 ? "More than one" : "One or less"
```

In both languages, you must specify both outcomes -- if condition is true *and* if condition is false. Both return a value, and thus can be used on the right side of an expression like above, saving the result.

However, JavaScript's `if` statement is different, because it doesn't return a result. It also doesn't require `else`

```
let quantityMessage
if quantity >= 1 {
    quantityMessage = "More than one"
} else {
    quantityMessage = "One or less"
}
```

Probably well know, but interesting not about Elm vs JavaScript is that Elm doesn't let you make much choices. It's very opinionated about how things should be done. In JavaScript, if you want to make a web app, you can first choose what dialect to write it in. ES5, ES6, TypeScript, etc. Then you can make a choice of what rendering framework to use or not to use (React, Vue, Ember). Then you can make a choice of state management (Redux, MobX, etc), then for async stuff we might choose redux-saga or other libraries, then we might use some utitities, lodash, jQuery, ramda, immutable, then package manager, npm, yarn, then he listed some other stuff I don't know.

But Elm is just Elm. Dialect is just Elm. UI is just the `view` function. State is `model`. Async is `update`, utilities are in `elm/core`, and for packages you use `elm install`.

Elm also has a code formatting tool, which has zero configuration options. So you don't have to debate that either -- there's just one code formatting option and that's it.

I only watched the first part of the workshop, and now I'm going back to the Tic-Tac-Toe game implementation.

---

So let's fix a bug where player can click the same cell multiple times.

Let's make a couple of helper functions:

```
cellIsAtPosition : CellPosition -> Cell -> Bool
cellIsAtPosition position cell =
    cell.position.row == position.row && cell.position.col == position.col


findCell : Board -> CellPosition -> Maybe Cell
findCell (Board list) position =
    List.head (List.filter (cellIsAtPosition position) list)
```

Now we can use this in our `cellClicked` to see if the clicked cell is empty or not. If it's not empty, then we don't do any changes:

```
cellClicked : Board -> CellPosition -> { board : Board, isDraw : Bool }
cellClicked board position =
    case findCell board position of
        Nothing ->
            { board = board, isDraw = isDraw board }

        Just cell ->
            if cellIsEmpty cell then
                let
                    boardAfterX =
                        setCellState CellX board position

                    endedWithDraw =
                        isDraw boardAfterX
                in
                if endedWithDraw then
                    { board = boardAfterX
                    , isDraw = True
                    }

                else
                    { board = insertO boardAfterX
                    , isDraw = False
                    }

            else
                { board = board, isDraw = isDraw board }
```

I also want to fix a bug where draw is not detected if O did the last move. This is not possible on a 3x3 board where X starts, but if this is ever expanded to a 4x4 board, then that's exactly what would happen:

```
cellClicked : Board -> CellPosition -> { board : Board, isDraw : Bool }
cellClicked board position =
    case findCell board position of
        Nothing ->
            { board = board, isDraw = isDraw board }

        Just cell ->
            if cellIsEmpty cell then
                let
                    boardAfterX =
                        setCellState CellX board position

                    endedWithDraw =
                        isDraw boardAfterX
                in
                if endedWithDraw then
                    { board = boardAfterX
                    , isDraw = True
                    }

                else
                    let
                        boardAfterO =
                            insertO boardAfterX
                    in
                    { board = boardAfterO
                    , isDraw = isDraw boardAfterO
                    }

            else
                { board = board, isDraw = isDraw board }
```

Great, now we can play the game without breaking it and will know if it ended in a draw. However, we still aren't detecting if one of the players wins. Let's see how we can do that. I'm not good at algorithms and set theories, so I'm just going to say there are exactly 8 positions which lead to a win. Well, here they all are:

```
X X X   _ _ _   _ _ _   X _ _
_ _ _   X X X   _ _ _   X _ _
_ _ _   _ _ _   X X X   X _ _

_ X _   _ _ X   X _ _   _ _ X
_ X _   _ _ X   _ X _   _ X _
_ X _   _ _ X   _ _ X   X _ _
```

Now I know this kind of thinking wouldn't work with boards of larger (or infinite) sizes, so -- bummer, but I'm gonna do this for the sake of simplicity now. Here are the same positions represented in code:

```
winningPositions : List (List CellPosition)
winningPositions =
    [ [ { row = 0, col = 0 }
      , { row = 0, col = 1 }
      , { row = 0, col = 2 }
      ]
    , [ { row = 1, col = 0 }
      , { row = 1, col = 1 }
      , { row = 1, col = 2 }
      ]
    , [ { row = 2, col = 0 }
      , { row = 2, col = 1 }
      , { row = 2, col = 2 }
      ]
    , [ { row = 0, col = 0 }
      , { row = 1, col = 0 }
      , { row = 2, col = 0 }
      ]
    , [ { row = 0, col = 1 }
      , { row = 1, col = 1 }
      , { row = 2, col = 1 }
      ]
    , [ { row = 0, col = 2 }
      , { row = 1, col = 2 }
      , { row = 2, col = 2 }
      ]
    , [ { row = 0, col = 0 }
      , { row = 1, col = 1 }
      , { row = 2, col = 2 }
      ]
    , [ { row = 0, col = 2 }
      , { row = 1, col = 1 }
      , { row = 2, col = 0 }
      ]
    ]
```

To make this somewhat reasonable I decided to move the state of the game into `Board` module:

```
type GameState
    = Playing
    | XWon
    | OWon
    | Draw
```

Then `cellClicked` would return the `Board` and the `GameState`:

```
cellClicked : Board -> CellPosition -> { board : Board, gameState : GameState }
cellClicked board position =
    let
        gameState =
            getGameState board
    in
    if gameState /= Playing then
        { board = board, gameState = gameState }

    else
        case positionIsFree board position of
            Nothing ->
                { board = board, gameState = gameState }

            Just isFree ->
                if not isFree then
                    { board = board, gameState = gameState }

                else
                    let
                        stateAfterXmove =
                            playerMove board CellX position
                    in
                    if stateAfterXmove.gameState /= Playing then
                        stateAfterXmove

                    else
                        let
                            oPosition =
                                nextOPosition stateAfterXmove.board
                        in
                        case oPosition of
                            Nothing ->
                                stateAfterXmove

                            Just nextPosition ->
                                playerMove stateAfterXmove.board CellO nextPosition
```

Getting current game state:

```
getGameState : Board -> GameState
getGameState board =
    if hasWinningPosition board CellX then
        XWon

    else if hasWinningPosition board CellO then
        OWon

    else if isDraw board then
        Draw

    else
        Playing

isInPositions : Board -> List CellPosition -> CellState -> Bool
isInPositions board positions state =
    List.all
        (\position ->
            case findCell board position of
                Nothing ->
                    False

                Just cell ->
                    cell.state == state
        )
        positions


hasWinningPosition : Board -> CellState -> Bool
hasWinningPosition board player =
    List.any
        (\winningPositionSet ->
            isInPositions board winningPositionSet player
        )
        winningPositionSets
```

And doing the actual move (both player and "AI"):

```
playerMove : Board -> CellState -> CellPosition -> { board : Board, gameState : GameState }
playerMove board player position =
    let
        boardAfter =
            case findCell board position of
                Nothing ->
                    board

                Just cell ->
                    if cellIsEmpty cell then
                        setCellState player board position

                    else
                        board
    in
    { board = boardAfter, gameState = getGameState boardAfter }
```

In the `TicTacToe` module, I removed the `AppState` and replaced it with the new `GameState`. Then changed the `update` function to handle the new `cellClicked` return type:

```
update : Msg -> Model -> Model
update msg model =
    case msg of
        CellClicked pos ->
            let
                result =
                    Board.cellClicked model.board pos

                statusText =
                    "Clicked: row: " ++ String.fromInt pos.row ++ ", col: " ++ String.fromInt pos.col
            in
            { model
                | board = result.board
                , statusText = statusText
                , appState = result.gameState
            }
```

Viola! We have a very dumb game of Tic-Tac-Toe! The computer player is 100% predictable and its "strategy" is to place O into the next available cell. Oh well.

I think next time I'll check some implementations of Tic-Tac-Toe in Elm on Github to see how others did it, and hopefully learn from it. That's it for today!