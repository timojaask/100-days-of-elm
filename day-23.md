## Day 23

Quick review of day 22:

Yesterday I started modelling a Tic Tac Toe game. Started with basic game state and grew it to enfoce various game rules, eventually breaking part of the model into its own module. Some of the things practiced where:
- Thinking how to make impossible states impossible relying solely on data structures.
- If only data structures is not enough, thinking how enforce rules by abstracting data structure away using module and functions.
- Thinking what data structure works best for representation of a given concept, by listing different possiblities and evalutating one at a time with pros and cons.


---

Today I looked at the [Tic-Tac-Toe Wikipedia article](https://en.wikipedia.org/wiki/Tic-tac-toe) and learned that you spell it with dashes 😄

Yesterday I forgot to link the actual source code in the test. [Here](./src/data-structures/TicTacToe.elm) it is.

Last thing I worked on was the `cellClicked` function, which looked like so:

```
cellClicked : Board -> CellPosition -> Board
cellClicked (Board list) position =
  Board
    ( List.map
        (\row ->
          List.map
            (\cell ->
              if cell.position.row == position.row &&
                 cell.position.col == position.col then
                Cell position CellX
              else
                cell
            )
            row
        )
        list
    )
```

It simply sets the clicked cell to `CellX` value. This is not helpful, because we could override any `CellO` value, which shouldn't happen, so we can easily enforce that rule:

```
cellIsEmpty : Cell -> Bool
cellIsEmpty cell =
    case cell.state of
        Empty ->
            True

        CellX ->
            False

        CellO ->
            False


cellClicked : Board -> CellPosition -> Board
cellClicked (Board list) position =
    Board
        (List.map
            (\row ->
                List.map
                    (\cell ->
                        if
                            cellIsEmpty cell
                                && cell.position.row
                                == position.row
                                && cell.position.col
                                == position.col
                        then
                            Cell position CellX

                        else
                            cell
                    )
                    row
            )
            list
        )
```

So an unprecedented thing happened here -- the code formatter that I installed since the beginning of 100 days of Elm suddenly kicked in and re-formatted the code 😂 Also linter started working *correctly*. I'm in shock. I think it worked once of twice before in the beginning of this project, but the rest of the time it did absolutely nothing on any of my source files. This is all fine as long as it keeps working consistently.

Let's add a possibility to add the Os, which I assume will be added by the computer. So we're going to generalize `cellClicked` a bit:

```
setCellState : CellState -> Board -> CellPosition -> Board
setCellState state (Board list) position =
    Board
        (List.map
            (\row ->
                List.map
                    (\cell ->
                        if
                            cellIsEmpty cell
                                && cell.position.row
                                == position.row
                                && cell.position.col
                                == position.col
                        then
                            Cell position state

                        else
                            cell
                    )
                    row
            )
            list
        )
```

And now we can update our `cellClicked` to use the new function:

```
cellClicked : Board -> CellPosition -> Board
cellClicked board position =
    setCellState CellX board position
```

This syntax *is weird* for me. What's with the `&&` and `==` aligned like that? They don't represent nearly the same concepts in my head:

```
if
    cellIsEmpty cell
        && cell.position.row
        == position.row
        && cell.position.col
        == position.col
then
```

🤷‍

Back to the game. Would it be nicer if the internal board representation would be a flat list? Then mapping over it would be easier, and for now we didn't benefit from the 2D structure at all. We can leave it still 2D for the `cell` function that the UI would be using. Let's try flattening it:

```
type Board
    = Board (List Cell)
```

Okay, so we need to update a few things now. `newBoard` function implementation got somewhat awkward:

```
newBoard : Board
newBoard =
    let
        rows =
            List.range 0 (height - 1)

        cols =
            List.range 0 (width - 1)

        rowsCols =
            List.foldl
                (\row ->
                    \acc ->
                        acc
                            ++ List.map
                                (\col ->
                                    ( row, col )
                                )
                                cols
                )
                []
                rows
    in
    Board
        (List.map
            (\t ->
                Cell (CellPosition (Tuple.first t) (Tuple.second t)) Empty
            )
            rowsCols
        )
```

I bet I'm missing some better way of doing this. That `foldl`/`map` looks vulgar. I can't come up with anything better right now, so let's roll with it. `cell` now needs to map from `List Cell` to `List (List Cell)`:

```
cells : Board -> List (List Cell)
cells (Board list) =
    let
        rows =
            List.range 0 (height - 1)
    in
    List.map
        (\row ->
            List.filter
                (\cell -> cell.position.row == row)
                list
        )
        rows
```

I wished it was more elegant. Maybe I'll learn one day.

And finally, `setCellState`:

```
setCellState : CellState -> Board -> CellPosition -> Board
setCellState state (Board list) position =
    Board
        (List.map
            (\cell ->
                if
                    cellIsEmpty cell
                        && cell.position.row
                        == position.row
                        && cell.position.col
                        == position.col
                then
                    Cell position state

                else
                    cell
            )
            list
        )
```

Well, it's one layer less now. So this is what we gained from the change. We flattened the `setCellState` function a bit. Was it worth it? I don't know. Let's see what happens next.

Let's add a some logic that inserts some Os after each click. Zero intelligence, just insert at next available spot.

```
insertO : Board -> Board
insertO (Board list) =
    let
        remainingCells =
            List.filter cellIsEmpty list
    in
    case List.head remainingCells of
        Nothing ->
            Board list

        Just cell ->
            setCellState CellO (Board list) cell.position
```

And then update our click handler to insert an O right after inserting an X:

```
cellClicked : Board -> CellPosition -> Board
cellClicked board position =
    insertO (setCellState CellX board position)
```

Whoa! Now it looks more like a game, against a dumb opponent. However, it still doesn't detect when game is supposed to end. Let's see how we can do that.

A low hanging fruit is to detect a draw. When there are no more empty cells left, and assuming that no one has won, we can conclude a draw. The winning logic will be added later:

```
isDraw : Board -> Bool
isDraw (Board list) =
    let
        remainingCells =
            List.filter cellIsEmpty list
    in
    List.isEmpty remainingCells
```

Now we can see if game ended in a draw before making the next move, and also return `isDraw` boolean to back to the caller:

```
cellClicked : Board -> CellPosition -> { board : Board, isDraw : Bool }
cellClicked board position =
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
```

This assumes that board can get filled only when X is placed, which is a case of a 3x3 board. If we have some other board, like 4x4, then that's incorrect. Another problem here is that if the user keeps clicking the same cell repeatedly, and no new Xs are placed, there's a new O placed with every click anyway. So that's messed up. Will come back to work on that tomorrow.

---

On a side note: I learned to use the [Debug package](https://package.elm-lang.org/packages/elm/core/latest/Debug) a little bit. It turns out to be extremely simple. I tried the `Debug.log` function, which takes a value, logs it, and then returns it as is. So you can insert `Debug.log` anywhere in your code and log away! Super handy:

```
cellClicked board position =
    let
        boardAfterX =
            setCellState CellX board position

        endedWithDraw =
            Debug.log "isDraw" (isDraw boardAfterX)
    in
        ...
```

---