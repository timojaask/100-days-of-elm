module Main exposing (main)

import Array exposing (Array)
import Browser exposing (Document)
import Browser.Navigation as Nav
import Debug
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Random
import Url
import Url.Parser
import Url.Parser.Query


main =
    Browser.application
        { init = init
        , update = update
        , subscriptions = subscriptions
        , view = view
        , onUrlChange = UrlChanged
        , onUrlRequest = LinkClicked
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none


type alias Cell =
    { row : Int
    , col : Int
    , value : Int
    }


emptyBoard : List Cell
emptyBoard =
    [ Cell 0 0 0
    , Cell 0 1 0
    , Cell 0 2 0
    , Cell 0 3 0
    , Cell 1 0 0
    , Cell 1 1 0
    , Cell 1 2 0
    , Cell 1 3 0
    , Cell 2 0 0
    , Cell 2 1 0
    , Cell 2 2 0
    , Cell 2 3 0
    , Cell 3 0 0
    , Cell 3 1 0
    , Cell 3 2 0
    , Cell 3 3 0
    ]


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
                findRandomEmptyCellCmd model.board
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
            List.reverse (gatherValuesInLine (List.reverse column))
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
            List.reverse (gatherValuesInLine (List.reverse row))
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
            if fromCell.value == toCell.value && fromCell.value /= 0 then
                setCellValue toCell.row toCell.col (toCell.value + fromCell.value) board
                    |> setCellValue fromCell.row fromCell.col 0

            else
                board

        ( _, _ ) ->
            board


insertNewValue : List Cell -> Int -> List Cell
insertNewValue board emptyCellIndex =
    let
        -- TODO: Make this random -- either 2 or 4
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
    , key : Nav.Key
    , url : Url.Url
    }


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        maybeBoard =
            boardFromUrl url
    in
    case maybeBoard of
        Nothing ->
            -- No valid board in URL, start a new game with empty board, and add a number at random cell
            ( Model emptyBoard key url, findRandomEmptyCellCmd emptyBoard )

        Just board ->
            -- Load board from URL, and do nothing (no adding random cell)
            ( Model board key url, Cmd.none )


boardUrlParser : Url.Parser.Parser (Maybe String -> a) a
boardUrlParser =
    Url.Parser.query (Url.Parser.Query.string "board")


flattenMaybe : Maybe (Maybe a) -> Maybe a
flattenMaybe maybe =
    case maybe of
        Nothing ->
            Nothing

        Just some ->
            some


intRowFromString : String -> Maybe (List Int)
intRowFromString string =
    List.foldl
        (\strCellValue ->
            \maybeRowResult_ ->
                case maybeRowResult_ of
                    Nothing ->
                        Nothing

                    Just rowResult ->
                        case String.toInt strCellValue of
                            Nothing ->
                                Nothing

                            Just intValue ->
                                Just (List.append rowResult [ intValue ])
        )
        (Just [])
        (String.split "_" string)


listOfMaybesToMaybeList : List (Maybe a) -> Maybe (List a)
listOfMaybesToMaybeList listOfMaybes =
    List.foldl
        (\maybeItem ->
            \maybeResultList ->
                case ( maybeItem, maybeResultList ) of
                    ( Just item, Just resultList ) ->
                        Just (List.append resultList [ item ])

                    ( _, _ ) ->
                        Nothing
        )
        (Just [])
        listOfMaybes


isValidValue : Int -> Bool
isValidValue v =
    v
        == 0
        || v
        == 2
        || v
        == 4
        || v
        == 8
        || v
        == 16
        || v
        == 32
        || v
        == 64
        || v
        == 128
        || v
        == 256
        || v
        == 512
        || v
        == 1024
        || v
        == 2048


boardFromString : String -> Maybe (List Cell)
boardFromString string =
    let
        listOfMaybeInt =
            List.map String.toInt (String.split "_" string)

        maybeListOfValidValues =
            listOfMaybesToMaybeList
                (List.map
                    (\maybeInt ->
                        case maybeInt of
                            Nothing ->
                                Nothing

                            Just int ->
                                if isValidValue int then
                                    Just int

                                else
                                    Nothing
                    )
                    listOfMaybeInt
                )
    in
    case maybeListOfValidValues of
        Nothing ->
            Nothing

        Just listOfIntValues ->
            if List.length emptyBoard == List.length listOfIntValues then
                Just
                    (List.map2
                        (\cell ->
                            \value ->
                                { cell | value = value }
                        )
                        emptyBoard
                        listOfIntValues
                    )

            else
                Nothing


boardFromUrl : Url.Url -> Maybe (List Cell)
boardFromUrl url =
    let
        maybeBoardString =
            flattenMaybe (Url.Parser.parse boardUrlParser url)
    in
    case maybeBoardString of
        Nothing ->
            Nothing

        Just boardString ->
            boardFromString boardString


type Msg
    = Move Direction
    | NewGame
    | RandomCell Int
    | LinkClicked Browser.UrlRequest
    | UrlChanged Url.Url


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NewGame ->
            ( { model | board = emptyBoard }, findRandomEmptyCellCmd model.board )

        Move direction ->
            move model direction

        RandomCell emptyCellIndex ->
            let
                newBoard =
                    insertNewValue model.board emptyCellIndex
            in
            ( { model | board = newBoard }, Cmd.none )

        LinkClicked urlRequest ->
            case urlRequest of
                Browser.Internal url ->
                    ( model, Nav.pushUrl model.key (Url.toString url) )

                Browser.External href ->
                    ( model, Nav.load href )

        UrlChanged url ->
            ( { model | url = url }
            , Cmd.none
            )


findRandomEmptyCellCmd : List Cell -> Cmd Msg
findRandomEmptyCellCmd board =
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
        [ button [ onClick NewGame ] [ text "New game" ]
        , viewBoard model.board
        , viewControls
        ]
    }


viewControls : Html Msg
viewControls =
    div [ class "controls" ]
        [ button [ class "buttonLeft", onClick (Move Left) ] [ text "<" ]
        , button [ class "buttonUp", onClick (Move Up) ] [ text "^" ]
        , button [ class "buttonDown", onClick (Move Down) ] [ text "v" ]
        , button [ class "buttonRight", onClick (Move Right) ] [ text ">" ]
        ]


viewBoard : List Cell -> Html Msg
viewBoard board =
    div [ class "board" ]
        [ viewBoardRow 0 board
        , viewBoardRow 1 board
        , viewBoardRow 2 board
        , viewBoardRow 3 board
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
