import Browser
import Html exposing (Html)
import Html.Events exposing (onClick)
import Svg exposing (..)
import Svg.Attributes exposing (..)
import Time
import Task

main = Browser.element { init = init, view = view, update = update, subscriptions = subscriptions }

-- MODEL

type alias LocalTime =
  { hour : Float
  , minute : Float
  , second : Float
  }

type alias Model = 
  { zone : Time.Zone
  , time : Time.Posix
  , isRunning : Bool
  }

init : () -> (Model, Cmd Msg)
init _ =
  ( Model Time.utc (Time.millisToPosix 0) True
  , Task.perform AdjustTimeZone Time.here
  )

-- UPDATE
type Msg
  = Tick Time.Posix
  | AdjustTimeZone Time.Zone
  | ToggleIsRunning
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Tick newTime ->
      ({ model | time = newTime }, Cmd.none)

    AdjustTimeZone newZone ->
      ({ model | zone = newZone }, Cmd.none)

    ToggleIsRunning ->
      ({ model | isRunning = not model.isRunning }, Cmd.none)

-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  if model.isRunning then
    Time.every 1000 Tick
  else
    Sub.none

-- VIEW
view : Model -> Html Msg
view model =
  let
    hour = toFloat (Time.toHour model.zone model.time)
    minute = toFloat (Time.toMinute model.zone model.time)
    second = toFloat (Time.toSecond model.zone model.time)
    localTime = LocalTime hour minute second
  in
    Html.div []
    [ drawClock localTime
    , text (debugTimeString localTime)
    , Html.button [ onClick ToggleIsRunning ] [ text "Start/Stop" ]
    ]

drawClock : LocalTime -> Html Msg
drawClock localTime =
  svg [ viewBox "0 0 100 100", width "300px" ]
    ( (drawClockBackground 50 50 45)
    ++ (drawHourHand 50 50 localTime)
    ++ (drawMinuteHand 50 50 localTime)
    ++ (drawSecondHand 50 50 localTime)
    )

drawClockBackground : Float -> Float -> Float -> List (Html Msg)
drawClockBackground bgCX bgCY bgR =
  (List.map (drawMinuteTick 50 50) (List.range 0 59)) ++
  [ circle -- White filled circle covering the minute ticks
    [ cx (String.fromFloat bgCX)
    , cy (String.fromFloat bgCY)
    , r (String.fromFloat (bgR - 6))
    , fill "white"
    ] []
  ] ++
  (List.map (drawHourTick 50 50) (List.range 0 11)) ++
  [ circle -- White filled circle covering the hour ticks
    [ cx (String.fromFloat bgCX)
    , cy (String.fromFloat bgCY)
    , r (String.fromFloat (bgR - 10))
    , fill "white"
    ] []
  ] ++
  [ circle -- Gray overall border
    [ cx (String.fromFloat bgCX)
    , cy (String.fromFloat bgCY)
    , r (String.fromFloat bgR)
    , fillOpacity "0"
    , strokeWidth "2px"
    , stroke "gray"
    ] []
  , circle -- white line covering outer ends of hour and minute ticks
    [ cx (String.fromFloat bgCX)
    , cy (String.fromFloat bgCY)
    , r (String.fromFloat (bgR - 2))
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
      [ x1 (String.fromFloat centerX)
      , y1 (String.fromFloat centerY)
      , x2 (String.fromFloat handX)
      , y2 (String.fromFloat handY)
      , stroke "#000000"
      , strokeWidth (String.fromFloat width)
      ] []
  


drawSecondHand : Float -> Float -> LocalTime -> List (Html Msg)
drawSecondHand centerX centerY localTime =
  let
    handLength = 30
    coords = secondHandCoord centerX centerY handLength localTime
    handX = Tuple.first coords
    handY = Tuple.second coords
  in
  [ line
    [ x1 (String.fromFloat centerX)
    , y1 (String.fromFloat centerY)
    , x2 (String.fromFloat handX)
    , y2 (String.fromFloat handY)
    , stroke "#FF0000"
    ] []
  , circle
    [ cx (String.fromFloat handX)
    , cy (String.fromFloat handY)
    , r "3.7px"
    , fill "#FF0000"
    ] []
  ]

drawMinuteHand : Float -> Float -> LocalTime -> List (Html Msg)
drawMinuteHand centerX centerY localTime =
  let
    handLength = 40
    coords = minuteHandCoord centerX centerY handLength localTime
    handX = Tuple.first coords
    handY = Tuple.second coords
  in
    [ line
      [ x1 (String.fromFloat centerX)
      , y1 (String.fromFloat centerY)
      , x2 (String.fromFloat handX)
      , y2 (String.fromFloat handY)
      , stroke "#000000"
      , strokeWidth "2px"
      ] []
    ]

drawHourHand : Float -> Float -> LocalTime -> List (Html Msg)
drawHourHand centerX centerY localTime =
  let
    handLength = 30
    coords = hourHandCoord centerX centerY handLength localTime
    handX = Tuple.first coords
    handY = Tuple.second coords
  in
    [ line
      [ x1 (String.fromFloat centerX)
      , y1 (String.fromFloat centerY)
      , x2 (String.fromFloat handX)
      , y2 (String.fromFloat handY)
      , stroke "#000000"
      , strokeWidth "4px"
      ] []
    ]

debugTimeString : LocalTime -> String
debugTimeString localTime =
  (String.fromFloat localTime.hour) ++ ":" ++
  (String.fromFloat localTime.minute) ++ ":" ++
  (String.fromFloat localTime.second)

secondHandCoord : Float -> Float -> Float -> LocalTime -> (Float, Float)
secondHandCoord cx cy r localTime =
  handCoord cx cy r 60 localTime.second

minuteHandCoord : Float -> Float -> Float -> LocalTime -> (Float, Float)
minuteHandCoord cx cy r localTime =
  handCoord cx cy r 60 localTime.minute

hourHandCoord : Float -> Float -> Float -> LocalTime -> (Float, Float)
hourHandCoord cx cy r localTime =
  handCoord cx cy r 12 localTime.hour

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