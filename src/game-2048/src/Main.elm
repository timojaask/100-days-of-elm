module Main exposing (main)

import Array exposing (Array)
import Browser exposing (Document)
import Debug
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Random


main =
    Browser.document
        -- { init = testModel
        { init = initialModel
        , update = update
        , subscriptions = subscriptions
        , view = view
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


boardIndices : List ( Int, Int )
boardIndices =
    [ ( 0, 0 )
    , ( 1, 0 )
    , ( 2, 0 )
    , ( 3, 0 )
    , ( 0, 1 )
    , ( 1, 1 )
    , ( 2, 1 )
    , ( 3, 1 )
    , ( 0, 2 )
    , ( 1, 2 )
    , ( 2, 2 )
    , ( 3, 2 )
    , ( 0, 3 )
    , ( 1, 3 )
    , ( 2, 3 )
    , ( 3, 3 )
    ]


type alias Cell =
    { row : Int
    , col : Int
    , value : Int
    }


emptyBoard : List Cell
emptyBoard =
    List.map
        (\( row, col ) -> Cell row col 0)
        boardIndices


emptyCells : List Cell -> List Cell
emptyCells board =
    List.filter
        (\cell -> cell.value == 0)
        board


getRow : Int -> List Cell -> List Cell
getRow rowIndex board =
    List.filter
        (\cell -> cell.row == rowIndex)
        board


getColumn : Int -> List Cell -> List Cell
getColumn columnIndex board =
    List.filter
        (\cell -> cell.col == columnIndex)
        board


setCellValue : Int -> Int -> Int -> List Cell -> List Cell
setCellValue row col value board =
    List.map
        (\cell ->
            if cell.row == row && cell.col == col then
                { cell | value = value }

            else
                cell
        )
        board


type Direction
    = Up
    | Down
    | Left
    | Right


move : Model -> Direction -> ( Model, Cmd Msg )
move model direction =
    -- 1. gather all pieces up as much as possible, to remove empty spaces
    -- 2. join any joinable pieces up
    -- 3. gather all pieces up as much as possible, to remove empty spaces
    let
        newBoard =
            case direction of
                Up ->
                    gatherCellsUp model.board
                        |> joinUp
                        |> gatherCellsUp

                Down ->
                    gatherCellsDown model.board
                        |> joinDown
                        |> gatherCellsDown

                Left ->
                    gatherCellsLeft model.board
                        |> joinLeft
                        |> gatherCellsLeft

                Right ->
                    gatherCellsRight model.board
                        |> joinRight
                        |> gatherCellsRight

        cmd =
            if newBoard == model.board then
                Cmd.none

            else
                generateEmptyCellIndex model.board
    in
    ( { model | board = newBoard }, cmd )


gatherCellsUp : List Cell -> List Cell
gatherCellsUp =
    -- Gather all pieces up as much as possible, to remove empty spaces
    gatherCellsUpInColumn 0
        >> gatherCellsUpInColumn 1
        >> gatherCellsUpInColumn 2
        >> gatherCellsUpInColumn 3


gatherCellsDown : List Cell -> List Cell
gatherCellsDown =
    gatherCellsDownInColumn 0
        >> gatherCellsDownInColumn 1
        >> gatherCellsDownInColumn 2
        >> gatherCellsDownInColumn 3


gatherCellsLeft : List Cell -> List Cell
gatherCellsLeft =
    gatherCellsLeftInRow 0
        >> gatherCellsLeftInRow 1
        >> gatherCellsLeftInRow 2
        >> gatherCellsLeftInRow 3


gatherCellsRight : List Cell -> List Cell
gatherCellsRight =
    gatherCellsRightInRow 0
        >> gatherCellsRightInRow 1
        >> gatherCellsRightInRow 2
        >> gatherCellsRightInRow 3


gatherCellsUpInColumn : Int -> List Cell -> List Cell
gatherCellsUpInColumn columnIndex board =
    let
        column =
            getColumn columnIndex board

        columnValuesGatheredTopToBottom =
            gatherValuesInLine column
    in
    applyValuesToColumn columnValuesGatheredTopToBottom columnIndex board


gatherCellsDownInColumn : Int -> List Cell -> List Cell
gatherCellsDownInColumn columnIndex board =
    let
        column =
            getColumn columnIndex board

        columnValuesGatheredBottomToTop =
            List.reverse (gatherValuesInLine column)
    in
    applyValuesToColumn columnValuesGatheredBottomToTop columnIndex board


gatherCellsLeftInRow : Int -> List Cell -> List Cell
gatherCellsLeftInRow rowIndex board =
    let
        row =
            getRow rowIndex board

        rowValuesGatheredLeftToRight =
            gatherValuesInLine row
    in
    applyValuesToRow rowValuesGatheredLeftToRight rowIndex board


gatherCellsRightInRow : Int -> List Cell -> List Cell
gatherCellsRightInRow rowIndex board =
    let
        row =
            getRow rowIndex board

        rowValuesGatheredRightToLeft =
            List.reverse (gatherValuesInLine row)
    in
    applyValuesToRow rowValuesGatheredRightToLeft rowIndex board


applyValuesToColumn : List Int -> Int -> List Cell -> List Cell
applyValuesToColumn values columnIndex board =
    let
        arrayOfValues =
            Array.fromList values
    in
    setCellValue 0 columnIndex (getArrayValueDefault arrayOfValues 0 0) board
        |> setCellValue 1 columnIndex (getArrayValueDefault arrayOfValues 1 0)
        |> setCellValue 2 columnIndex (getArrayValueDefault arrayOfValues 2 0)
        |> setCellValue 3 columnIndex (getArrayValueDefault arrayOfValues 3 0)


applyValuesToRow : List Int -> Int -> List Cell -> List Cell
applyValuesToRow values rowIndex board =
    let
        arrayOfValues =
            Array.fromList values
    in
    setCellValue rowIndex 0 (getArrayValueDefault arrayOfValues 0 0) board
        |> setCellValue rowIndex 1 (getArrayValueDefault arrayOfValues 1 0)
        |> setCellValue rowIndex 2 (getArrayValueDefault arrayOfValues 2 0)
        |> setCellValue rowIndex 3 (getArrayValueDefault arrayOfValues 3 0)


getArrayValueDefault : Array a -> Int -> a -> a
getArrayValueDefault array index defaultValue =
    case Array.get index array of
        Nothing ->
            defaultValue

        Just value ->
            value


gatherValuesInLine : List Cell -> List Int
gatherValuesInLine lineOfCells =
    let
        nonEmptyCells =
            List.filter
                (\cell -> cell.value /= 0)
                lineOfCells

        nonEmptyValues =
            List.map
                (\cell -> cell.value)
                nonEmptyCells
    in
    case List.length nonEmptyCells of
        0 ->
            [ 0, 0, 0, 0 ]

        1 ->
            nonEmptyValues ++ [ 0, 0, 0 ]

        2 ->
            nonEmptyValues ++ [ 0, 0 ]

        3 ->
            nonEmptyValues ++ [ 0 ]

        _ ->
            nonEmptyValues


joinUp : List Cell -> List Cell
joinUp =
    joinUpColumn 0
        >> joinUpColumn 1
        >> joinUpColumn 2
        >> joinUpColumn 3


joinDown : List Cell -> List Cell
joinDown =
    joinDownColumn 0
        >> joinDownColumn 1
        >> joinDownColumn 2
        >> joinDownColumn 3


joinLeft : List Cell -> List Cell
joinLeft =
    joinLeftRow 0
        >> joinLeftRow 1
        >> joinLeftRow 2
        >> joinLeftRow 3


joinRight : List Cell -> List Cell
joinRight =
    joinRightRow 0
        >> joinRightRow 1
        >> joinRightRow 2
        >> joinRightRow 3


joinUpColumn : Int -> List Cell -> List Cell
joinUpColumn columnIndex board =
    joinCellsIfSame 1 columnIndex 0 columnIndex board
        |> joinCellsIfSame 2 columnIndex 1 columnIndex
        |> joinCellsIfSame 3 columnIndex 2 columnIndex


joinDownColumn : Int -> List Cell -> List Cell
joinDownColumn columnIndex board =
    joinCellsIfSame 2 columnIndex 3 columnIndex board
        |> joinCellsIfSame 1 columnIndex 2 columnIndex
        |> joinCellsIfSame 0 columnIndex 1 columnIndex


joinLeftRow : Int -> List Cell -> List Cell
joinLeftRow rowIndex board =
    joinCellsIfSame rowIndex 1 rowIndex 0 board
        |> joinCellsIfSame rowIndex 2 rowIndex 1
        |> joinCellsIfSame rowIndex 3 rowIndex 2


joinRightRow : Int -> List Cell -> List Cell
joinRightRow rowIndex board =
    joinCellsIfSame rowIndex 2 rowIndex 3 board
        |> joinCellsIfSame rowIndex 1 rowIndex 2
        |> joinCellsIfSame rowIndex 0 rowIndex 1


getCell : Int -> Int -> List Cell -> Maybe Cell
getCell rowIndex columnIndex board =
    List.head
        (List.filter
            (\cell -> cell.row == rowIndex && cell.col == columnIndex)
            board
        )


joinCellsIfSame : Int -> Int -> Int -> Int -> List Cell -> List Cell
joinCellsIfSame fromRow fromCol toRow toCol board =
    let
        maybeFromCell =
            getCell fromRow fromCol board

        maybeToCell =
            getCell toRow toCol board
    in
    case ( maybeFromCell, maybeToCell ) of
        ( Just fromCell, Just toCell ) ->
            if fromCell.value == toCell.value then
                setCellValue toCell.row toCell.col (toCell.value + fromCell.value) board
                    |> setCellValue fromCell.row fromCell.col 0

            else
                board

        ( _, _ ) ->
            board


insertNewValue : List Cell -> Int -> List Cell
insertNewValue board emptyCellIndex =
    let
        newValue =
            2

        justEmptyCells =
            emptyCells board

        emptyCellsWithOneValue =
            List.indexedMap
                (\idx ->
                    \cell ->
                        if idx == emptyCellIndex then
                            { cell | value = newValue }

                        else
                            cell
                )
                justEmptyCells

        cellWithNewValue =
            List.head
                (List.filter
                    (\cell -> cell.value == newValue)
                    emptyCellsWithOneValue
                )
    in
    case cellWithNewValue of
        Nothing ->
            board

        Just cell ->
            setCellValue cell.row cell.col newValue board


type alias Model =
    { board : List Cell
    }


testBoard : List Cell
testBoard =
    -- row 0
    [ Cell 0 0 2
    , Cell 0 1 2
    , Cell 0 2 4
    , Cell 0 3 0

    -- row 1
    , Cell 1 0 0
    , Cell 1 1 0
    , Cell 1 2 0
    , Cell 1 3 0

    -- row 2
    , Cell 2 0 0
    , Cell 2 1 0
    , Cell 2 2 0
    , Cell 2 3 0

    -- row 3
    , Cell 3 0 0
    , Cell 3 1 0
    , Cell 3 2 0
    , Cell 3 3 0
    ]


testModel : () -> ( Model, Cmd Msg )
testModel _ =
    ( Model testBoard, Cmd.none )


initialModel : () -> ( Model, Cmd Msg )
initialModel _ =
    ( Model emptyBoard, generateEmptyCellIndex emptyBoard )


type Msg
    = Move Direction
    | NewGame
    | RandomCell Int


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewGame ->
            ( Model emptyBoard, generateEmptyCellIndex model.board )

        Move direction ->
            move model direction

        RandomCell emptyCellIndex ->
            let
                newBoard =
                    insertNewValue model.board emptyCellIndex
            in
            ( { model | board = newBoard }, Cmd.none )


generateEmptyCellIndex : List Cell -> Cmd Msg
generateEmptyCellIndex board =
    let
        numEmptyCells =
            List.length (emptyCells board)
    in
    -- Making sure we don't up with empty list, otherwise the generator would try to generate values from 0 to -1, in which case I don't know what happens!
    if numEmptyCells == 0 then
        Cmd.none

    else
        let
            emptyCellIndexGenerator =
                Random.int 0 (numEmptyCells - 1)
        in
        Random.generate RandomCell emptyCellIndexGenerator


view : Model -> Document Msg
view model =
    { title = "2048"
    , body =
        [ viewBoard model.board
        , viewControls
        ]
    }


viewControls : Html Msg
viewControls =
    div [ class "controls" ]
        [ button [ onClick (Move Left) ] [ text "<" ]
        , button [ onClick (Move Up) ] [ text "^" ]
        , button [ onClick (Move Down) ] [ text "v" ]
        , button [ onClick (Move Right) ] [ text ">" ]
        ]


viewBoard : List Cell -> Html Msg
viewBoard board =
    div [ class "board" ]
        [ div
            [ class "boardColumn" ]
            [ viewBoardRow 0 board
            , viewBoardRow 1 board
            , viewBoardRow 2 board
            , viewBoardRow 3 board
            ]
        ]


viewBoardRow : Int -> List Cell -> Html Msg
viewBoardRow rowIndex board =
    let
        rowCells =
            getRow rowIndex board
    in
    div
        [ class "boardRow" ]
        (List.map
            viewCell
            rowCells
        )


viewCell : Cell -> Html Msg
viewCell cell =
    let
        cellClass =
            if cell.value == 0 then
                "boardCell " ++ "boardCell--empty"

            else
                "boardCell " ++ "boardCell--value"
    in
    div
        [ class cellClass ]
        [ span [] [ text (String.fromInt cell.value) ]
        ]