module Board exposing (Board, Cell, CellState(..), CellPosition, newBoard, cells, cellClicked)

import Array exposing (Array)

type alias CellPosition = { row : Int, col : Int }

type CellState
  = Empty
  | CellX
  | CellO

type alias Cell =
  { position : CellPosition
  , state : CellState
  }

-- Wrapped our Board type into a union type with only one constructor
type Board = 
  Board (List (List Cell))

width = 3
height = 3

newBoard : Board
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

cells : Board -> List (List Cell)
cells (Board list) = list

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