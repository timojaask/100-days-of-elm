module Board exposing (Board, Cell, CellPosition, CellState(..), cellClicked, cells, newBoard)

import Array exposing (Array)
import Debug


type alias CellPosition =
    { row : Int, col : Int }


type CellState
    = Empty
    | CellX
    | CellO


type alias Cell =
    { position : CellPosition
    , state : CellState
    }



-- Wrapped our Board type into a union type with only one constructor


type Board
    = Board (List Cell)


width =
    3


height =
    3


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


cellIsEmpty : Cell -> Bool
cellIsEmpty cell =
    case cell.state of
        Empty ->
            True

        CellX ->
            False

        CellO ->
            False


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


isDraw : Board -> Bool
isDraw (Board list) =
    let
        remainingCells =
            List.filter cellIsEmpty list
    in
    List.isEmpty remainingCells
