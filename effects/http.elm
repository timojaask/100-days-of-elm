import Browser
import Html exposing (..)
import Html.Attributes exposing (src, href, placeholder, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode
import Url.Builder as Url

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

loadingGif : String
loadingGif = "./img/waiting.gif"

-- MODEL
type alias Model =
  { topic : String
  , gifUrl : String
  , errorMessage : String
  }

init : () -> (Model, Cmd Msg)
init _ =
  (Model "cats" loadingGif "", Cmd.none)

-- UPDATE
type Msg
  = MorePlease
  | SetTopic String
  | NewGif (Result Http.Error String)
update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
  case msg of
    MorePlease ->
      ({ model | gifUrl = loadingGif, errorMessage = "" }, getRandomGif model.topic)
    
    NewGif result -> 
      case result of
        Ok newUrl ->
          ({ model | gifUrl = newUrl, errorMessage = "" }, Cmd.none)

        Err err ->
          ({ model | errorMessage = errorToString err }, Cmd.none)

    SetTopic newTopic ->
      ({ model | topic = newTopic }, Cmd.none)

errorToString : Http.Error -> String
errorToString err =
  case err of
    Http.BadUrl str ->
      "Bad URL"
    Http.Timeout ->
      "Timeout"
    Http.NetworkError ->
      "Network error"
    Http.BadStatus response ->
      "Bad status: " ++ (String.fromInt response.status.code) ++ ": " ++ response.status.message
    Http.BadPayload errStr response ->
      "BadPayload. Reason: " ++ errStr

getRandomGif : String -> Cmd Msg
getRandomGif topic =
  let
    request = Http.get (toGiphyUrl topic) gifDecoder
  
  in
    Http.send NewGif request

toGiphyUrl : String -> String
toGiphyUrl topic =
  Url.crossOrigin "https://api.giphy.com" ["v1","gifs","random"]
    [ Url.string "api_key" "dc6zaTOxFJmzC"
    , Url.string "tag" topic
    ]

gifDecoder : Decode.Decoder String
gifDecoder =
  Decode.at ["data", "image_url"] Decode.string

-- VIEW
view : Model -> Html Msg
view model =
  div []
    [ topicDropdown model
    , img [ src model.gifUrl, (Html.Attributes.style "maxWidth" "150px") ] []
    , button [ onClick MorePlease ] [ text "More Please!" ]
    , text model.errorMessage
    ]

topics : List String
topics = [ "cats", "dogs", "cars" ]

topicDropdown : Model -> Html Msg
topicDropdown model =
  select [ onInput SetTopic ]
    (List.map optionElement topics)

optionElement : String -> Html Msg
optionElement name =
  option [ value name ] [ text name ]