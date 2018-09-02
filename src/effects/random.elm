module Main exposing (Model, Msg(..), attribution, borderColor, c1, c2, c3, canvasH, canvasW, circleColor, circleRadius, circleShadowColor, cornerRadius, dieCirclePositions, dieCirclePositionsFor, dieFaceBackground, dieFaceImage, dieFaceStyle, init, main, offset, rectColor, rectH, rectShadowColor, rectShadowWidth, rectW, rectX, rectY, renderCircle, renderCircles, renderDieFace, subscriptions, update, view)

import Array
import Browser
import Html
import Html.Attributes exposing (href, src)
import Html.Events exposing (onClick)
import Random
import Svg exposing (..)
import Svg.Attributes exposing (..)


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none



-- MODEL


type alias Model =
    { dieFace1 : Int
    , dieFace2 : Int
    }



-- UPDATE


type Msg
    = Roll
    | NewFace ( Int, Int )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Roll ->
            ( model
            , Random.generate NewFace
                (Random.pair (Random.int 1 6) (Random.int 1 6))
            )

        NewFace ( newFace1, newFace2 ) ->
            ( Model newFace1 newFace2, Cmd.none )



-- VIEW


view : Model -> Html.Html Msg
view model =
    Html.div []
        [ renderDieFace model.dieFace1
        , renderDieFace model.dieFace2
        , Html.button [ onClick Roll ] [ Html.text "Roll" ]
        , attribution
        ]


dieFaceImage : Int -> Html.Html msg
dieFaceImage dieFace =
    Html.img [ src ("./img/dice-" ++ String.fromInt dieFace ++ ".png") ] []


canvasW =
    100


canvasH =
    100


offset =
    10


rectX =
    offset


rectY =
    offset


rectW =
    canvasW - offset * 2


rectH =
    canvasH - offset * 2


cornerRadius =
    6


c1 =
    30


c2 =
    50


c3 =
    70


circleRadius =
    6


rectColor =
    "#ffe100"


rectShadowColor =
    "#ffa800"


circleColor =
    "#ffa800"


circleShadowColor =
    "#ff8800"


borderColor =
    "black"


rectShadowWidth =
    3


dieFaceStyle =
    [ width (String.fromInt canvasW), height (String.fromInt canvasH), viewBox ("0 0 " ++ String.fromInt canvasW ++ " " ++ String.fromInt canvasH) ]


dieFaceBackground =
    [ rect
        -- dice shadow color
        [ fill rectShadowColor
        , stroke borderColor
        , strokeWidth "3px"
        , x (String.fromInt rectX)
        , y (String.fromInt rectY)
        , width (String.fromInt rectW)
        , height (String.fromInt rectH)
        , rx (String.fromInt cornerRadius)
        , ry (String.fromInt cornerRadius)
        ]
        []
    , rect
        -- dice main color
        [ fill rectColor
        , strokeWidth "0"
        , x (String.fromInt rectX)
        , y (String.fromInt rectY)
        , width (String.fromInt (rectW - rectShadowWidth))
        , height (String.fromInt rectH)
        , rx (String.fromInt (cornerRadius + 2))
        , ry (String.fromInt (cornerRadius + 2))
        ]
        []
    , rect
        -- dice outer border
        [ fillOpacity "0"
        , stroke borderColor
        , strokeWidth "3px"
        , x (String.fromInt rectX)
        , y (String.fromInt rectY)
        , width (String.fromInt rectW)
        , height (String.fromInt rectH)
        , rx (String.fromInt cornerRadius)
        , ry (String.fromInt cornerRadius)
        ]
        []
    , rect
        -- dice inner border
        [ fillOpacity "0"
        , stroke borderColor
        , strokeWidth "3px"
        , x (String.fromInt (rectX + 6))
        , y (String.fromInt (rectY + 6))
        , width (String.fromInt (rectW - 6 * 2))
        , height (String.fromInt (rectH - 6 * 2))
        , rx (String.fromInt (cornerRadius - 3))
        , ry (String.fromInt (cornerRadius - 3))
        ]
        []
    ]


renderDieFace : Int -> Html.Html msg
renderDieFace dieFaceNumber =
    svg
        dieFaceStyle
        (dieFaceBackground ++ renderCircles (dieCirclePositionsFor dieFaceNumber))


dieCirclePositions : List (List ( Int, Int ))
dieCirclePositions =
    [ [ ( c2, c2 ) ] -- 1
    , [ ( c1, c1 ), ( c3, c3 ) ] -- 2
    , [ ( c1, c1 ), ( c2, c2 ), ( c3, c3 ) ] -- 3
    , [ ( c1, c1 ), ( c1, c3 ), ( c3, c3 ), ( c3, c1 ) ] -- 4
    , [ ( c1, c1 ), ( c1, c3 ), ( c2, c2 ), ( c3, c3 ), ( c3, c1 ) ] -- 5
    , [ ( c1, c1 ), ( c1, c2 ), ( c1, c3 ), ( c3, c3 ), ( c3, c2 ), ( c3, c1 ) ] -- 6
    ]


dieCirclePositionsFor : Int -> List ( Int, Int )
dieCirclePositionsFor dieFaceNumber =
    Maybe.withDefault [ ( 50, 50 ) ] (Array.get dieFaceNumber (Array.fromList dieCirclePositions))


renderCircles : List ( Int, Int ) -> List (Html.Html msg)
renderCircles circlePositions =
    List.concatMap renderCircle circlePositions


renderCircle : ( Int, Int ) -> List (Html.Html msg)
renderCircle ( x, y ) =
    [ circle
        -- circle shadow fill
        [ fill circleShadowColor
        , strokeWidth "0"
        , cx (String.fromInt x)
        , cy (String.fromInt y)
        , r (String.fromInt circleRadius)
        ]
        []
    , circle
        -- circle main fill
        [ fill circleColor
        , strokeWidth "0"
        , cx (String.fromInt (x - 2))
        , cy (String.fromInt y)
        , r (String.fromInt (circleRadius - 2))
        ]
        []
    , circle
        -- circle border
        [ fillOpacity "0"
        , stroke borderColor
        , strokeWidth "3px"
        , cx (String.fromInt x)
        , cy (String.fromInt y)
        , r (String.fromInt circleRadius)
        ]
        []
    ]


attribution : Html.Html msg
attribution =
    Html.span []
        [ Html.text "Icon made by "
        , Html.a [ href "https://smashicons.com/" ] [ Html.text "Smashicons" ]
        , Html.text " from "
        , Html.a [ href "https://www.flaticon.com" ] [ Html.text "www.flaticon.com" ]
        ]


init : () -> ( Model, Cmd Msg )
init _ =
    ( Model 6 1, Cmd.none )
