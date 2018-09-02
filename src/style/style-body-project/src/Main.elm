import Browser
import Html

main = Browser.document
  { init = init
  , view = view
  , update = update
  , subscriptions = subscriptions
  }

init : () -> (Model, Cmd Msg)
init _ =
  (0, Cmd.none)

subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none

type alias Model = Int

type Msg = Idle

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    Idle -> (model, Cmd.none)

view : Model -> Browser.Document Msg
view model =
  { title = "Hello, world!"
  , body =
    [ Html.h1 [] [ Html.text "Header" ]
    , Html.span [] [ Html.text "span" ]
    ]
  }