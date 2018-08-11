import Html exposing (..)
import Html.Attributes exposing (src, href, placeholder, value)
import Html.Events exposing (onClick, onInput)
import Http
import Json.Decode as Decode

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

loadingGif : String
loadingGif = "./img/waiting.gif"

-- MODEL
type alias Model =
  { topic : String
  , gifUrl : String
  , errorMessage : String
  }

init : (Model, Cmd Msg)
init =
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
    
    NewGif (Ok newUrl) ->
      ({ model | gifUrl = newUrl, errorMessage = "" }, Cmd.none)

    NewGif (Err err) ->
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
      "Bad status: " ++ (toString response.status.code) ++ ": " ++ response.status.message
    Http.BadPayload errStr response ->
      "BadPayload. Reason: " ++ errStr

getRandomGif : String -> Cmd Msg
getRandomGif topic =
  let
    url =
      "https://api.giphy.com/v1/gifs/random?api_key=dc6zaTOxFJmzC&tag=" ++ topic
    
    request = Http.get url decodeGifUrl
  
  in
    Http.send NewGif request

decodeGifUrl : Decode.Decoder String
decodeGifUrl =
  Decode.at ["data", "image_url"] Decode.string

-- VIEW
view : Model -> Html Msg
view model =
  div []
    [ topicDropdown model
    , img [ src model.gifUrl, Html.Attributes.style [("maxWidth", "150px")] ] []
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