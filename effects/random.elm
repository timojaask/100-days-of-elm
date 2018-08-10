import Html
import Html.Attributes exposing (src, href)
import Html.Events exposing (onClick)
import Random
import Svg exposing (..)
import Svg.Attributes exposing (..)

main : Program Never Model Msg
main =
  Html.program
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
  ,  dieFace2 : Int
  }

-- UPDATE
type Msg
  = Roll
  | NewFace (Int, Int)
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Roll ->
      (model
      , Random.generate NewFace
        ( Random.pair (Random.int 1 6) (Random.int 1 6) )
      )

    NewFace (newFace1, newFace2) ->
      (Model newFace1 newFace2, Cmd.none)

-- VIEW
view : Model -> Html.Html Msg
view model =
  Html.div []
    [ dieFace model.dieFace1
    , dieFace model.dieFace2
    , Html.button [ onClick Roll ] [ Html.text "Roll" ]
    , attribution
    ]

dieFaceImage : Int -> Html.Html msg
dieFaceImage dieFace =
  Html.img [ src ("./img/dice-" ++ (toString dieFace) ++ ".png") ] []

dieFace : Int -> Html.Html msg
dieFace dieFace =
  if dieFace == 1 then dieFace1
  else if dieFace == 2 then dieFace2
  else if dieFace == 3 then dieFace3
  else if dieFace == 4 then dieFace4
  else if dieFace == 5 then dieFace5
  else if dieFace == 6 then dieFace6
  else dieFace1
    
dieFaceProps : List (Attribute msg)
dieFaceProps = [ width "100", height "100", viewBox "0 0 100 100" ]
dieFaceRect : Html.Html msg
dieFaceRect = rect [ fill "green", x "0", y "0", width "100", height "100" ] []
dieFaceCircle : Int -> Int -> Html.Html msg
dieFaceCircle x y = circle [ fill "white", cx (toString x), cy (toString y), r "10" ] []

dieFace1 : Html.Html msg
dieFace1 =
  svg
    dieFaceProps
    [ dieFaceRect
    , dieFaceCircle 50 50
    ]

dieFace2 : Html.Html msg
dieFace2 =
  svg
    dieFaceProps
    [ dieFaceRect
    , dieFaceCircle 20 20
    , dieFaceCircle 80 80
    ]

dieFace3 : Html.Html msg
dieFace3 =
  svg
    dieFaceProps
    [ dieFaceRect
    , dieFaceCircle 20 20
    , dieFaceCircle 50 50
    , dieFaceCircle 80 80
    ]

dieFace4 : Html.Html msg
dieFace4 =
  svg
    dieFaceProps
    [ dieFaceRect
    , dieFaceCircle 20 20
    , dieFaceCircle 20 80
    , dieFaceCircle 80 80
    , dieFaceCircle 80 20
    ]

dieFace5 : Html.Html msg
dieFace5 =
  svg
    dieFaceProps
    [ dieFaceRect
    , dieFaceCircle 20 20
    , dieFaceCircle 20 80
    , dieFaceCircle 50 50
    , dieFaceCircle 80 80
    , dieFaceCircle 80 20
    ]

dieFace6 : Html.Html msg
dieFace6 =
  svg
    dieFaceProps
    [ dieFaceRect
    , dieFaceCircle 20 20
    , dieFaceCircle 20 50
    , dieFaceCircle 20 80
    , dieFaceCircle 80 80
    , dieFaceCircle 80 50
    , dieFaceCircle 80 20
    ]

attribution : Html.Html msg
attribution =
  Html.span []
    [ Html.text "Icon made by "
    , Html.a [ href "https://smashicons.com/" ] [ Html.text "Smashicons" ]
    , Html.text " from "
    , Html.a [ href "https://www.flaticon.com"] [ Html.text "www.flaticon.com" ]
  ]

init : (Model, Cmd Msg)
init =
  (Model 6 1, Cmd.none)