import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Regex exposing (regex)

main =
  Html.beginnerProgram { model = model, view = view, update = update }

-- MODEL
type alias Model =
  { name : String
  , password : String
  , passwordAgain : String
  , age : String
  , subscribe : Bool
  , surprise : Bool
  , submitted : Bool
  }
model : Model
model =
  Model "" "" "" "" False False False

-- UPDATE
type Msg
  = Name String
  | Password String
  | PasswordAgain String
  | Age String
  | Submit
  | ToggleSubscribe
  | ToggleSurprise
update : Msg -> Model -> Model
update msg model =
  case msg of
    Name name ->
      { model | name = name }
    Password password ->
      { model | password = password }
    PasswordAgain password ->
      { model | passwordAgain = password }
    Age age ->
      { model | age = age }
    ToggleSubscribe ->
      { model | subscribe = not model.subscribe }
    ToggleSurprise ->
      { model | surprise = not model.surprise }
    Submit ->
      { model | submitted = True }

-- VIEW
view : Model -> Html Msg
view model =
  div []
    [ input [ type_ "text", placeholder "Name", onInput Name ] []
    , input [ type_ "password", placeholder "Password", onInput Password ] []
    , input [ type_ "password", placeholder "Re-enter password", onInput PasswordAgain ] []
    , input [ type_ "text", placeholder "Age", onInput Age ] []
    , button [ onClick Submit ] [ text "Submit" ]
    , checkbox ToggleSubscribe "Subscribe to newsletter"
    , checkbox ToggleSurprise "Want a surprise?"
    , viewValidation model
    ]

checkbox : msg -> String -> Html msg
checkbox msg name =
  label [] [ input [ type_ "checkbox", onClick msg ] [], text name ]

viewValidation : Model -> Html msg
viewValidation model =
  let
    (color, message, display) =
      if not(model.submitted) then
        ("", "", "none")
      else if not(model.password == model.passwordAgain) then
        ("red", "Passwords do not match!", "block")
      else if String.length model.password < 8 then
        ("red", "Password must be at least 8 characters long!", "block")
      else if not(Regex.contains (regex "[A-Z]") model.password) then
        ("red", "Password must have at least one uppercase character!", "block")
      else if not(Regex.contains (regex "[a-z]") model.password) then
        ("red", "Password must have at least one lowercase character!", "block")
      else if not(Regex.contains (regex "[0-9]") model.password) then
        ("red", "Password must have at least one digit character!", "block")
      else if Regex.contains (regex "[^0-9]") model.age then
        ("red", "Age must be a number", "block")
      else
        ("green", "OK", "block")
  in
    div [ style [("color", color), ("display", display)] ] [ text message ]