module Main exposing (Model)

import Browser
import Html exposing (Html, button, div, h1, span, text)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import PomodoroTimer exposing (PomodoroEvent(..), PomodoroTimer, State(..))
import Time exposing (Posix, millisToPosix)


defaultWorkDurationSeconds =
    25 * 60


defaultBreakDurationSeconds =
    5 * 60


type alias LoadedModel =
    { posixTime : Posix
    , pomodoroTimer : PomodoroTimer
    }


type Model
    = Loading
    | Loaded LoadedModel


main =
    Browser.element { init = init, view = view, update = update, subscriptions = subscriptions }


subscriptions : Model -> Sub Msg
subscriptions model =
    Time.every 500 Tick


init : () -> ( Model, Cmd msg )
init _ =
    ( Loading, Cmd.none )


type Msg
    = LoadedMsg LoadedMsg
    | Tick Posix


type LoadedMsg
    = StartWork
    | StartBreak
    | Stop


update : Msg -> Model -> ( Model, Cmd msg )
update msg model =
    case msg of
        Tick timeNow ->
            case model of
                Loading ->
                    ( Loaded (LoadedModel timeNow (PomodoroTimer.init defaultWorkDurationSeconds defaultBreakDurationSeconds)), Cmd.none )

                Loaded loadedModel ->
                    let
                        result =
                            PomodoroTimer.update timeNow loadedModel.pomodoroTimer
                    in
                    case result.event of
                        None ->
                            ( Loaded (LoadedModel timeNow result.timer), Cmd.none )

                        WorkEnded ->
                            -- TODO: Show alert, play sound
                            ( Loaded (LoadedModel timeNow result.timer), Cmd.none )

                        BreakEnded ->
                            -- TODO: Show alert, play sound
                            ( Loaded (LoadedModel timeNow result.timer), Cmd.none )

        LoadedMsg loadedMsg ->
            case model of
                Loading ->
                    ( model, Cmd.none )

                Loaded loadedModel ->
                    case loadedMsg of
                        StartWork ->
                            ( Loaded
                                { loadedModel | pomodoroTimer = PomodoroTimer.startWork loadedModel.posixTime loadedModel.pomodoroTimer }
                            , Cmd.none
                            )

                        StartBreak ->
                            ( Loaded { loadedModel | pomodoroTimer = PomodoroTimer.startBreak loadedModel.posixTime loadedModel.pomodoroTimer }
                            , Cmd.none
                            )

                        Stop ->
                            ( Loaded { loadedModel | pomodoroTimer = PomodoroTimer.stop loadedModel.pomodoroTimer }
                            , Cmd.none
                            )


view : Model -> Html Msg
view model =
    case model of
        Loading ->
            h1 [] [ text "Loading..." ]

        Loaded loadedModel ->
            div []
                [ h1 [] [ text "Pomodoro timer" ]
                , span [] [ text (secondsToHumanDuration (PomodoroTimer.timeLeftSeconds loadedModel.pomodoroTimer loadedModel.posixTime)) ]
                , viewPomodoroCount (PomodoroTimer.pomodorosCompleted loadedModel.pomodoroTimer)
                , div [] (viewControls loadedModel.pomodoroTimer)
                ]


viewControls : PomodoroTimer -> List (Html Msg)
viewControls pomodoroTimer =
    case PomodoroTimer.state pomodoroTimer of
        Stopped ->
            [ button [ onClick (LoadedMsg StartWork) ] [ text "Work" ]
            , button [ onClick (LoadedMsg StartBreak) ] [ text "Break" ]
            ]

        Work _ ->
            [ button [ onClick (LoadedMsg Stop) ] [ text "Stop" ] ]

        Break _ ->
            [ button [ onClick (LoadedMsg Stop) ] [ text "Stop" ] ]


viewPomodoroCountItem : Html msg
viewPomodoroCountItem =
    div
        [ style "width" "20px"
        , style "height" "20px"
        , style "background-color" "black"
        , style "margin" "1px"
        ]
        [ text " " ]


viewPomodoroCount : Int -> Html msg
viewPomodoroCount count =
    div
        [ style "display" "flex"
        , style "flex-direction" "row"
        ]
        (List.map
            (\_ -> viewPomodoroCountItem)
            (List.range 1 count)
        )


secondsToHumanDuration : Int -> String
secondsToHumanDuration durationSeconds =
    let
        minutes =
            durationSeconds // 60

        seconds =
            Basics.modBy 60 durationSeconds

        secondsPrefix =
            if seconds < 10 then
                "0"

            else
                ""
    in
    String.fromInt minutes ++ ":" ++ secondsPrefix ++ String.fromInt seconds
