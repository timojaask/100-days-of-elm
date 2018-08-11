import Html exposing (Html)
import Html.Events exposing (onClick)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Time exposing (Time)
import Date

main = Html.program { init = init, view = view, update = update, subscriptions = subscriptions }

-- MODEL
type alias Model = 
  { time : Time
  , isRunning : Bool
  }

init : (Model, Cmd Msg)
init = (Model 0 True, Cmd.none)

-- UPDATE
type Msg
  = Tick Time
  | ToggleIsRunning
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Tick newTime ->
      ({ model | time = newTime }, Cmd.none)
    ToggleIsRunning ->
      ({ model | isRunning = not model.isRunning }, Cmd.none)

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  if model.isRunning then
    Time.every Time.second Tick
  else
    Sub.none

-- VIEW
view : Model -> Html Msg
view model =
  let
    coords = secondsHandEndCoords 50 50 40 model.time
    handX = toString (Tuple.first coords)
    handY = toString (Tuple.second coords)
  in
    Html.div []
    [ svg [ viewBox "0 0 100 100", width "300px" ]
      [ circle [ cx "50", cy "50", r "45", fill "#0B79CE" ] []
      , line [ x1 "50", y1 "50", x2 handX, y2 handY, stroke "#023963" ] []
      ]
    , text ("offset = " ++ (toString (secondsHandEndCoords 50 50 40 model.time)))
    , text ("second = " ++ (toString (second model.time)))
    , Html.button [ onClick ToggleIsRunning ] [ text "Start/Stop" ]
    ]

second : Time -> Int
second time =
  Date.second (Date.fromTime time)

secondsHandEndCoords : Int -> Int -> Int -> Time -> (Float, Float)
secondsHandEndCoords cx cy r time =
  let
    offset = secondsHandOffset time
  in
    ( toFloat cx + Tuple.first offset * toFloat r
    , toFloat cy + Tuple.second offset * toFloat r
    )

secondsHandOffset : Time -> (Float, Float)
secondsHandOffset time =
  let
    secondsDegrees = 360 / 60 * (toFloat (second time))
    secondsRadians = secondsDegrees * 3.14159265359 / 180
    secondsXOffset = sin(secondsRadians)
    secondsYOffset = cos(secondsRadians) * -1
  in
    (secondsXOffset, secondsYOffset)