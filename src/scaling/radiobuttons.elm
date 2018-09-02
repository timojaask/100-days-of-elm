import Html exposing (Html, div, text, label, fieldset, input, section)
import Html.Attributes exposing (type_)
import Html.Events exposing (onClick)

main = Html.beginnerProgram
  { model = (Model Small "hello")
  , view = view
  , update = update
  }

type alias Model =
  { fontSize : FontSize
  , content: String
  }

type FontSize = Small | Medium | Large

type Msg = SwitchTo FontSize
update : Msg -> Model -> Model
update msg model =
  case msg of
    SwitchTo newFontSize ->
      { model | fontSize = newFontSize }

view : Model -> Html Msg
view model =
  div []
    [ viewPicker
      [ ("Small", SwitchTo Small)
      , ("Medium", SwitchTo Medium)
      , ("Large", SwitchTo Large)
      ]
      , section [] [ text model.content ]
    ]

viewPicker : List (String, msg) -> Html msg
viewPicker options =
  fieldset [] (List.map radio options)

radio : (String, msg) -> Html msg
radio (name, msg) =
  label []
    [ input [ type_ "radio", onClick msg ] []
    , text name
    ]