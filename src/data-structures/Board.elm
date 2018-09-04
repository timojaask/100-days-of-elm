module Board exposing (Board, Cell, CellPosition, CellState(..), GameState(..), cellClicked, cells, newBoard)

import Array exposing (Array)
import Debug


type alias CellPosition =
    { row : Int, col : Int }


type CellState
    = Empty
    | CellX
    | CellO


type GameState
    = Playing
    | XWon
    | OWon
    | Draw


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


positionIsFree : Board -> CellPosition -> Maybe Bool
positionIsFree board position =
    case findCell board position of
        Nothing ->
            Nothing

        Just cell ->
            Just (cell.state == Empty)


cellIsAtPosition : CellPosition -> Cell -> Bool
cellIsAtPosition position cell =
    cell.position.row == position.row && cell.position.col == position.col


findCell : Board -> CellPosition -> Maybe Cell
findCell (Board list) position =
    List.head (List.filter (cellIsAtPosition position) list)


nextOPosition : Board -> Maybe CellPosition
nextOPosition (Board list) =
    let
        remainingCells =
            List.filter cellIsEmpty list
    in
    case List.head remainingCells of
        Nothing ->
            Nothing

        Just cell ->
            Just cell.position


isDraw : Board -> Bool
isDraw (Board list) =
    let
        remainingCells =
            List.filter cellIsEmpty list
    in
    List.isEmpty remainingCells


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


winningPositionSets : List (List CellPosition)
winningPositionSets =
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
