module Main exposing (main)

import Array exposing (Array)
import Browser exposing (Document)
import Browser.Dom
import Browser.Events
import Browser.Navigation as Nav
import Debug
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Json.Decode as Decode
import Random
import Task
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
    case model.boardState of
        Loading ->
            Sub.none

        Loaded _ ->
            Browser.Events.onKeyDown keyDownDecoder


keyDownDecoder : Decode.Decoder Msg
keyDownDecoder =
    Decode.map keyToDirection (Decode.field "key" Decode.string)


keyToDirection : String -> Msg
keyToDirection key =
    case key of
        "ArrowLeft" ->
            OnKeyPressed (Just Left)

        "ArrowRight" ->
            OnKeyPressed (Just Right)

        "ArrowUp" ->
            OnKeyPressed (Just Up)

        "ArrowDown" ->
            OnKeyPressed (Just Down)

        _ ->
            OnKeyPressed Nothing


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


validValues =
    [ 0, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024, 2048 ]


isValidValue : Int -> Bool
isValidValue v =
    List.any ((==) v) validValues


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


boardContains2048 : List Cell -> Bool
boardContains2048 =
    List.any
        (\cell -> cell.value == 2048)


boardContainsEmptyCells : List Cell -> Bool
boardContainsEmptyCells =
    List.any
        (\cell -> cell.value == 0)


canMove : List Cell -> Direction -> Bool
canMove board direction =
    let
        boardAfterMove =
            move direction board
    in
    board /= boardAfterMove


canMoveAnywhere : List Cell -> Bool
canMoveAnywhere board =
    let
        canMoveResults =
            List.map (canMove board) [ Left, Right, Up, Down ]
    in
    List.any ((==) True) canMoveResults


getGameState : List Cell -> GameState
getGameState board =
    if boardContains2048 board then
        Won

    else if canMoveAnywhere board then
        Playing

    else
        Lost


updateWithMove : Model -> Direction -> ( Model, Cmd Msg )
updateWithMove model direction =
    case model.boardState of
        Loading ->
            ( model, Cmd.none )

        Loaded board ->
            -- 1. gather all pieces up as much as possible, to remove empty spaces
            -- 2. join any joinable pieces up
            -- 3. gather all pieces up as much as possible, to remove empty spaces
            let
                newBoard =
                    move direction board

                cmd =
                    if newBoard == board || getGameState newBoard /= Playing then
                        Cmd.none

                    else
                        findRandomEmptyCellCmd newBoard
            in
            ( { model | boardState = Loaded newBoard }, cmd )


move : Direction -> List Cell -> List Cell
move direction board =
    -- 1. gather all pieces up as much as possible, to remove empty spaces
    -- 2. join any joinable pieces up
    -- 3. gather all pieces up as much as possible, to remove empty spaces
    gatherCells direction board
        |> joinCells direction
        |> gatherCells direction


gatherCells : Direction -> List Cell -> List Cell
gatherCells direction board =
    gatherCellsOnOneLine direction 0 board
        |> gatherCellsOnOneLine direction 1
        |> gatherCellsOnOneLine direction 2
        |> gatherCellsOnOneLine direction 3


gatherCellsOnOneLine : Direction -> Int -> List Cell -> List Cell
gatherCellsOnOneLine direction rowOrColIdx board =
    case direction of
        Up ->
            let
                column =
                    getColumn rowOrColIdx board

                columnValuesGatheredTopToBottom =
                    gatherValuesInLine column
            in
            applyValuesToColumn columnValuesGatheredTopToBottom rowOrColIdx board

        Down ->
            let
                column =
                    getColumn rowOrColIdx board

                columnValuesGatheredBottomToTop =
                    List.reverse (gatherValuesInLine (List.reverse column))
            in
            applyValuesToColumn columnValuesGatheredBottomToTop rowOrColIdx board

        Left ->
            let
                row =
                    getRow rowOrColIdx board

                rowValuesGatheredLeftToRight =
                    gatherValuesInLine row
            in
            applyValuesToRow rowValuesGatheredLeftToRight rowOrColIdx board

        Right ->
            let
                row =
                    getRow rowOrColIdx board

                rowValuesGatheredRightToLeft =
                    List.reverse (gatherValuesInLine (List.reverse row))
            in
            applyValuesToRow rowValuesGatheredRightToLeft rowOrColIdx board


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


joinCells : Direction -> List Cell -> List Cell
joinCells direction board =
    joinCellsOnLine direction 0 board
        |> joinCellsOnLine direction 1
        |> joinCellsOnLine direction 2
        |> joinCellsOnLine direction 3


joinCellsOnLine : Direction -> Int -> List Cell -> List Cell
joinCellsOnLine direction rowOrColIdx board =
    case direction of
        Up ->
            joinCellsIfSame 1 rowOrColIdx 0 rowOrColIdx board
                |> joinCellsIfSame 2 rowOrColIdx 1 rowOrColIdx
                |> joinCellsIfSame 3 rowOrColIdx 2 rowOrColIdx

        Down ->
            joinCellsIfSame 2 rowOrColIdx 3 rowOrColIdx board
                |> joinCellsIfSame 1 rowOrColIdx 2 rowOrColIdx
                |> joinCellsIfSame 0 rowOrColIdx 1 rowOrColIdx

        Left ->
            joinCellsIfSame rowOrColIdx 1 rowOrColIdx 0 board
                |> joinCellsIfSame rowOrColIdx 2 rowOrColIdx 1
                |> joinCellsIfSame rowOrColIdx 3 rowOrColIdx 2

        Right ->
            joinCellsIfSame rowOrColIdx 2 rowOrColIdx 3 board
                |> joinCellsIfSame rowOrColIdx 1 rowOrColIdx 2
                |> joinCellsIfSame rowOrColIdx 0 rowOrColIdx 1


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


type GameState
    = Playing
    | Won
    | Lost


type BoardState
    = Loading
    | Loaded (List Cell)


type alias Model =
    { boardState : BoardState
    , key : Nav.Key
    , url : Url.Url
    }


focusOnNewGameButton : Cmd Msg
focusOnNewGameButton =
    -- It looks like we need to focus on something before keyboard events will start propagating
    Task.attempt (\_ -> NoOp) (Browser.Dom.focus "board")


init : () -> Url.Url -> Nav.Key -> ( Model, Cmd Msg )
init flags url key =
    let
        maybeBoard =
            boardFromUrl url
    in
    case maybeBoard of
        Nothing ->
            -- No valid board in URL, start a new game with empty board, and add a number at random cell
            let
                cmd =
                    Cmd.batch
                        [ findRandomEmptyCellCmd emptyBoard
                        , focusOnNewGameButton
                        ]
            in
            ( Model Loading key url, cmd )

        Just board ->
            -- Load board from URL, and do nothing (no adding random cell)
            ( Model (Loaded board) key url, focusOnNewGameButton )

initGame : Url.Url -> (BoardState, Cmd Msg)
initGame url =


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
    | OnKeyPressed (Maybe Direction)
    | NoOp


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        NewGame ->
            let
                newBoard =
                    emptyBoard
            in
            ( { model | boardState = Loaded newBoard }, findRandomEmptyCellCmd newBoard )

        Move direction ->
            updateWithMove model direction

        RandomCell emptyCellIndex ->
            let
                board =
                    case model.boardState of
                        Loading ->
                            emptyBoard

                        Loaded board_ ->
                            board_

                newBoard =
                    insertNewValue board emptyCellIndex
            in
            ( { model | boardState = Loaded newBoard }, Cmd.none )

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

        OnKeyPressed maybeDirection ->
            case maybeDirection of
                Just direction ->
                    updateWithMove model direction

                Nothing ->
                    ( model, Cmd.none )


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
    let
        board =
            case model.boardState of
                Loading ->
                    emptyBoard

                Loaded board_ ->
                    board_

        gameState =
            getGameState board

        isPlaying =
            gameState == Playing
    in
    { title = "2048"
    , body =
        [ button [ onClick NewGame ] [ text "New game" ]
        , viewBoard board
        , viewControls model.boardState
        , viewMessage model.boardState
        ]
    }


viewMessage : BoardState -> Html Msg
viewMessage boardState =
    case boardState of
        Loading ->
            text ""

        Loaded board ->
            case getGameState board of
                Won ->
                    span [ class "wonMessage" ] [ text "Congratulations, you won!" ]

                Lost ->
                    span [ class "lostMessage" ] [ text "Game over, there are no possible moves remaining." ]

                Playing ->
                    text ""


viewControls : BoardState -> Html Msg
viewControls boardState =
    case boardState of
        Loading ->
            text ""

        Loaded board ->
            case getGameState board of
                Won ->
                    text ""

                Lost ->
                    text ""

                Playing ->
                    div [ class "controls" ]
                        [ button [ class "buttonLeft", onClick (Move Left) ] [ text "<" ]
                        , button [ class "buttonUp", onClick (Move Up) ] [ text "^" ]
                        , button [ class "buttonDown", onClick (Move Down) ] [ text "v" ]
                        , button [ class "buttonRight", onClick (Move Right) ] [ text ">" ]
                        ]


viewBoard : List Cell -> Html Msg
viewBoard board =
    div [ class "board", id "board" ]
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
                "boardCell " ++ "boardCell--value " ++ "color" ++ String.fromInt cell.value
    in
    div
        [ class cellClass ]
        [ span [] [ text (String.fromInt cell.value) ]
        ]
