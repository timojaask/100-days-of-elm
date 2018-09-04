module Main exposing (Model, Msg(..), cellToString, init, main, styleBoard, styleCell, styleRow, update, view, viewBoard, viewCell)

import Array exposing (Array)
import Board exposing (Board, Cell, CellPosition, CellState(..), GameState(..))
import Browser
import Debug
import Html exposing (Html)
import Html.Attributes
import Html.Events


main =
    Browser.sandbox
        { init = init
        , view = view
        , update = update
        }


type alias Model =
    { board : Board
    , appState : GameState
    , statusText : String
    }


init : Model
init =
    Model Board.newBoard Playing "Hello"


type Msg
    = CellClicked CellPosition


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


view : Model -> Html Msg
view model =
    Html.div []
        [ Html.text model.statusText
        , viewBoard model.board
        , viewAppState model.appState
        ]


viewAppState : GameState -> Html msg
viewAppState appState =
    let
        message =
            case appState of
                Playing ->
                    "Playing"

                XWon ->
                    "You won!"

                Draw ->
                    "It's a draw!"

                OWon ->
                    "You lost."
    in
    Html.div [] [ Html.text message ]


styleRow =
    [ Html.Attributes.style "display" "flex"
    , Html.Attributes.style "flex-direction" "row"
    ]


styleBoard =
    [ Html.Attributes.style "display" "flex"
    , Html.Attributes.style "flex-direction" "column"
    ]


viewBoard : Board -> Html Msg
viewBoard board =
    let
        cells =
            Board.cells board
    in
    Html.div
        styleBoard
        (List.map
            (\row ->
                Html.div styleRow (List.map viewCell row)
            )
            cells
        )


styleCell =
    [ Html.Attributes.style "width" "30px"
    , Html.Attributes.style "height" "30px"
    , Html.Attributes.style "border" "1px solid black"
    , Html.Attributes.style "display" "flex"
    , Html.Attributes.style "justify-content" "center"
    , Html.Attributes.style "align-items" "center"
    , Html.Attributes.style "cursor" "default"
    ]


viewCell : Cell -> Html Msg
viewCell cell =
    Html.div
        ([ Html.Events.onClick (CellClicked cell.position)
         ]
            ++ styleCell
        )
        [ Html.text (cellToString cell) ]


cellToString : Cell -> String
cellToString { state } =
    case state of
        Empty ->
            "_"

        CellX ->
            "X"

        CellO ->
            "O"
