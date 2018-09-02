## Day 22

Quick review of day 21:

Yesterday I watched a talk by Richard Feldman: [Make Data Structures](https://www.youtube.com/watch?v=x1FU3e0sT1I).

Richard asked himself, what advice would he give to his past self, and came up with many advices, but one advice stood out as the most important: **make data structures**.

What he means by this is that when developing applications in Elm, we should design our data structures first before working on the rest of the application logic, such as `update` and `view` functions.

An important aspect of desining data structures is eliminating, or reducing number of impossible states in our applications. First we should strive to make it impossible to have impossible states by utilizing Elm's data structures. When you can't use only data structures to enforce the rules, it's a good idea to move it out into its own module and create functions that further limit the ways that the data can be interacted with, potentially hiding the internal implementation and really designing a stable API, that would ideally not change, even if the internal implementation of the data changes over time.

It is important to learn to think about your application states, making list of states that your data can end up in, and eliminate the states that should never happen. Richard was comparing this to building a solid foundation for a building, before proceeding to build the floors. If the foundation is not solid and you began construcing the floors, it will be later very challenging and costly to change the foundation. Application state is the foundation and `view` and `update` functions are the rest of the building, because the state affects them both.

---

Because data structures are so important, today I would like to dive a bit deeper into them, if possible, and maybe get more familiar with them.

Modelling a game of Tic Tac Toe.

These are the three possible states for our application:

```
type Model
  = Playing
  | Won
  | Lost
```

That's pretty straight forward. I think in all of these states we would like to be able to see the game board, so let's add that:

```
type Model
  = Playing Board
  | Won Board
  | Lost Board
```

And I'm guessing that is all for the main structure of the application state. So how do we represent the board? The board is a 3x3 grid, where each cell can be either empty, or have "X" or "O". That is *many* different states. Whare are different ways we can represent a board with cells?

- Flat list: List Cell
  - (-) Difficult to access individual cells
- Nested list: List (List Cell)
  - (-) Difficult to access individual cells
- Flat array: Array Cell
  - (+) Can access using indices
- Nested array: Array (Array Cell)
  - (+) Can access using indices
  - (+) Easier to understand 2D nature of game board
- Array of tuples: Array Tuple
  - (-) Awkward accessing of elements ("first", "second", "third")
- Three tuples: { first : Tuple, second : Tuple, third : Tuple}
  - (-) Awkward accessing of elements ("first", "second", "third")

From this it looks like I might want to go with a nested array. And let's say the `Cell` is going to be just `Char` for now, so we can have either `'_'`, `'X'`, or `'O'`. So in that case we could write it like so:

```
type alias Cell = Char

type alias Board = Array (Array Cell)

type Model
  = Playing Board
  | Won Board
  | Lost Board

init : Model
init = Playing Array.empty
```

Great! Now there are a bunch of problems with this implementation. First of all, we can write whatever we want into the `Cell`, not only one of the three characters. Let's fix that.

```
type Cell
  = Empty
  | CellX
  | CellO
```

Now there's simply no way to set it to anything else than what it can be.

Another thing that can go wrong with out data is initializing the arrays to be of wrong size. We can't control that with data structures only, so we'll probably have to make a new module and expose some helper functions to work on that.

```
module Board exposing (Board, Cell(..), newBoard, toString)

import Array exposing (Array)

type Cell
  = Empty
  | CellX
  | CellO

type Board = 
  Board (Array (Array Cell))

width = 3
height = 3

newBoard : Board
newBoard =
  Board
    ( Array.initialize height
      (\row ->
        ( Array.initialize width
          (\col -> Empty)
        )
      )
    )
```

Now the user of this module doesn't even know how the board is implemented internally, and the only way they can initialize it is by calling `Board.newBoard`. Great! Now the user cannot create a board of wrong size!

However, we need the API user to be able to somehow see the contents of the board to display them on the screen. Here we don't have to use the same data structure as our internal board representation. We can think again, what would be the best data structure to give to the UI layer?

- Flat list: List Cell
  - (+) Easy to map to Html element array
  - (-) Need to worry about row width
- Nested list: List (List Cell)
  - (+) Easy to map to Html element array
  - (+) Row width is taken care of
- Flat array: Array Cell
  - (-) Needs to be mapped to List
- Nested array: Array (Array Cell)
  - (-) Needs to be mapped to List
- Array of tuples: Array Tuple
  - (-) Needs to be converted to List somehow
- Three tuples: { first : Tuple, second : Tuple, third : Tuple}
  - (-) Needs to be converted to List somehow, probably

It looks like for displaying purposes it's best to have a list.

```
cells : Board -> List (List Cell)
cells (Board array) =
  Array.toList
    ( Array.map
        (Array.toList)
        array
    )
```

Since `Board` is a union type with one constructor, we don't necessarily have to access it using `case ... of`, we can just use a shortcut that's available for on-constructor union types only: `(Board array)`, which just gives us access to the one and only `Board Array` "case".

How do we handle clicking cells? Let's start with how do we know which cell was clicked? Perhaps each cell should have a position attached to it:

```
type alias CellPosition = { row : Int, col : Int }

type Cell
  = Empty CellPosition
  | CellX CellPosition
  | CellO CellPosition
```

Now we have a position always in the cell, so the UI can tell us *which* cell was clicked, when we do that.

Looking at the `Cell` and `Model` types, I don't like how they all have the same item in each of the items. Let's see if we can make a better `Cell`:

```
type CellState
  = Empty
  | CellX
  | CellO

type alias Cell =
  { position : CellPosition
  , state : CellState
  }
```

That looks alright, and I think it will help us also when we're using the `Cell` in our app, because we won't have to use `case .. of` every time we need to get `.position` of the cell.

Let's do the same for `Model`:

```
type AppState
  = Playing
  | Won
  | Lost

type alias Model =
  { board : Board
  , appState : AppState
  }
```

This is better also, for the same reason -- accessing the `Board` is now much easier.

We just have to make sure that in future, if we add an AppState that shouldn't have a `Board`, then this structure will no longer be as good, because we then we will allow an illegal state, but right now it's all good.

Now I wanted to write some kind of `cellClicked` function that would set the selected cell's state to `CellX`. But then I couldn't really figure out how do I get a row from the `Board` array while handling all the `Maybe`s. The following code does not compile:

```
cellClicked : Board -> CellPosition -> Board
cellClicked (Board array) position =
  Board Array.set
    position.row
    ( Array.set
      position.col
      CellX
      (Array.get position.row array)
    )
    array
```

The problem here is that `Array.get` returns a `Maybe Cell`. I can handle it, but then what do I do in case of `Nothing`? When I started thinking about this problem, I realized that now that each `Cell` contains its own position, I no longer need to use arrays. So let's see if this can work better with List:

```
type Board = 
  Board (List (List Cell))

...

newBoard =
  let
    rows = List.range 0 (height - 1)
    cols = List.range 0 (width - 1)
  in
    Board
      ( List.map (\row ->
          List.map (\col ->
            Cell (CellPosition row col) Empty
          ) cols
        ) rows
      )

...

cells (Board list) = list
```

Now let's implement a simple `cellClicked` function:

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

This works, but of course doesn't check for any game rules, such as, if three in a row has happened.

Today's learning time is up, I'll come back to this tomorrow.