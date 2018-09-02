import Browser
import Html exposing (Html)
import Html.Attributes
import Html.Events
import Array exposing (Array)
import Board exposing (Board, Cell, CellState(..), CellPosition)

main = Browser.sandbox
  { init = init
  , view = view
  , update = update
  }

type AppState
  = Playing
  | Won
  | Lost

type alias Model =
  { board : Board
  , appState : AppState
  }

init : Model
init = Model Board.newBoard Playing

type Msg
  = CellClicked CellPosition

update : Msg -> Model -> Model
update msg model =
  case msg of
    CellClicked pos ->
      { model | board = Board.cellClicked model.board pos }

view : Model -> Html Msg
view model =
  Html.div []
    [ Html.text "Hello"
    , viewBoard model.board
    ]

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
    cells = Board.cells board
  in
    Html.div
      styleBoard
      ( List.map
          (\row ->
            (Html.div styleRow (List.map viewCell row))
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
    ( [ Html.Events.onClick (CellClicked cell.position)
      ] ++
      styleCell
    )
    [ Html.text (cellToString cell) ]

cellToString : Cell -> String
cellToString { state } =
  case state of
    Empty -> "_"
    CellX -> "X"
    CellO -> "O"