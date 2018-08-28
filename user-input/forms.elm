import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onInput, onClick)
import Regex exposing (Regex)

main =
  Browser.sandbox { init = init, view = view, update = update }

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
  
init : Model
init =
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
    [ viewInput "text" "Name" model.name Name
    , viewInput "password" "Password" model.password Password
    , viewInput "password" "Re-enter password" model.passwordAgain PasswordAgain
    , viewInput "text" "Age" model.age Age
    , button [ onClick Submit ] [ text "Submit" ]
    , checkbox ToggleSubscribe "Subscribe to newsletter"
    , checkbox ToggleSurprise "Want a surprise?"
    , viewValidation model
    ]

viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
  input [ type_ t, placeholder p, value v, onInput toMsg ] []

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
      else if not(Regex.contains upperCase model.password) then
        ("red", "Password must have at least one uppercase character!", "block")
      else if not(Regex.contains lowerCase model.password) then
        ("red", "Password must have at least one lowercase character!", "block")
      else if not(Regex.contains someNumber model.password) then
        ("red", "Password must have at least one digit character!", "block")
      else if Regex.contains onlyNumbers model.age then
        ("red", "Age must be a number", "block")
      else
        ("green", "OK", "block")
  in
    div
      [ style "color" color
      , style "display" display
      ]
      [ text message ]

lowerCase : Regex
lowerCase =
  Maybe.withDefault Regex.never <|
    Regex.fromString "[a-z]"

upperCase : Regex
upperCase =
  Maybe.withDefault Regex.never <|
    Regex.fromString "[A-Z]"

someNumber : Regex
someNumber =
  Maybe.withDefault Regex.never <|
    Regex.fromString "[0-9]"

onlyNumbers : Regex
onlyNumbers =
  Maybe.withDefault Regex.never <|
    Regex.fromString "[^0-9]"