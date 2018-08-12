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
    Html.div []
    [ drawClock model.time
    , text (debugTimeString model.time)
    , Html.button [ onClick ToggleIsRunning ] [ text "Start/Stop" ]
    ]

drawClock : Time -> Html Msg
drawClock time =
  svg [ viewBox "0 0 100 100", width "300px" ]
    ( (drawClockBackground 50 50 45)
    ++ (drawHourHand 50 50 time)
    ++ (drawMinuteHand 50 50 time)
    ++ (drawSecondHand 50 50 time)
    )

drawClockBackground : Float -> Float -> Float -> List (Html Msg)
drawClockBackground bgCX bgCY bgR =
  (List.map (drawMinuteTick 50 50) (List.range 0 59)) ++
  [ circle -- White filled circle covering the minute ticks
    [ cx (toString bgCX)
    , cy (toString bgCY)
    , r (toString (bgR - 6))
    , fill "white"
    ] []
  ] ++
  (List.map (drawHourTick 50 50) (List.range 0 11)) ++
  [ circle -- White filled circle covering the hour ticks
    [ cx (toString bgCX)
    , cy (toString bgCY)
    , r (toString (bgR - 10))
    , fill "white"
    ] []
  ] ++
  [ circle -- Gray overall border
    [ cx (toString bgCX)
    , cy (toString bgCY)
    , r (toString bgR)
    , fillOpacity "0"
    , strokeWidth "2px"
    , stroke "gray"
    ] []
  , circle -- white line covering outer ends of hour and minute ticks
    [ cx (toString bgCX)
    , cy (toString bgCY)
    , r (toString (bgR - 2))
    , fillOpacity "0"
    , strokeWidth "2px"
    , stroke "white"
    ] []
  ]

drawHourTick : Float -> Float -> Int -> Html Msg
drawHourTick centerX centerY hour =
  drawTick centerX centerY 2.5 12 hour

drawMinuteTick : Float -> Float -> Int -> Html Msg
drawMinuteTick centerX centerY minute =
  drawTick centerX centerY 1.0 60 minute

drawTick : Float -> Float -> Float -> Float -> Int -> Html Msg
drawTick centerX centerY width maxValue value =
  let
    handLength = 45
    coords =  handCoord centerX centerY handLength maxValue (toFloat value)
    handX = Tuple.first coords
    handY = Tuple.second coords
  in
    line
      [ x1 (toString centerX)
      , y1 (toString centerY)
      , x2 (toString handX)
      , y2 (toString handY)
      , stroke "#000000"
      , strokeWidth (toString width)
      ] []
  


drawSecondHand : Float -> Float -> Time -> List (Html Msg)
drawSecondHand centerX centerY time =
  let
    handLength = 30
    coords = secondHandCoord centerX centerY handLength time
    handX = Tuple.first coords
    handY = Tuple.second coords
  in
  [ line
    [ x1 (toString centerX)
    , y1 (toString centerY)
    , x2 (toString handX)
    , y2 (toString handY)
    , stroke "#FF0000"
    ] []
  , circle
    [ cx (toString handX)
    , cy (toString handY)
    , r "3.7px"
    , fill "#FF0000"
    ] []
  ]

drawMinuteHand : Float -> Float -> Time -> List (Html Msg)
drawMinuteHand centerX centerY time =
  let
    handLength = 40
    coords = minuteHandCoord centerX centerY handLength time
    handX = Tuple.first coords
    handY = Tuple.second coords
  in
    [ line
      [ x1 (toString centerX)
      , y1 (toString centerY)
      , x2 (toString handX)
      , y2 (toString handY)
      , stroke "#000000"
      , strokeWidth "2px"
      ] []
    ]

drawHourHand : Float -> Float -> Time -> List (Html Msg)
drawHourHand centerX centerY time =
  let
    handLength = 30
    coords = hourHandCoord centerX centerY handLength time
    handX = Tuple.first coords
    handY = Tuple.second coords
  in
    [ line
      [ x1 (toString centerX)
      , y1 (toString centerY)
      , x2 (toString handX)
      , y2 (toString handY)
      , stroke "#000000"
      , strokeWidth "4px"
      ] []
    ]

debugTimeString : Time -> String
debugTimeString time =
  (toString (hour time)) ++ ":" ++ (toString (minute time)) ++ ":" ++ (toString (second time))

second : Time -> Float
second time =
  toFloat (Date.second (Date.fromTime time))

minute: Time -> Float
minute time =
  toFloat (Date.minute (Date.fromTime time))

hour: Time -> Float
hour time =
  toFloat (Date.hour (Date.fromTime time))

secondHandCoord : Float -> Float -> Float -> Time -> (Float, Float)
secondHandCoord cx cy r time =
  handCoord cx cy r 60 (second time)

minuteHandCoord : Float -> Float -> Float -> Time -> (Float, Float)
minuteHandCoord cx cy r time =
  handCoord cx cy r 60 (minute time)

hourHandCoord : Float -> Float -> Float -> Time -> (Float, Float)
hourHandCoord cx cy r time =
  handCoord cx cy r 12 (hour time)

handCoord : Float -> Float -> Float -> Float -> Float -> (Float, Float)
handCoord cx cy r maxValue curValue =
  let
    directionPoint = handDirectionPoint maxValue curValue
  in
    ( cx + Tuple.first directionPoint * r
    , cy + Tuple.second directionPoint * r
    )

handDirectionPoint : Float -> Float -> (Float, Float)
handDirectionPoint maxValue curValue =
  let
    handDegrees = 360 / maxValue * curValue
    handRadians = handDegrees * pi / 180
    pointX = sin(handRadians)
    pointY = cos(handRadians) *  -1
  in
    (pointX, pointY)