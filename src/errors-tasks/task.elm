import Html exposing (Html, div, text, button, span)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Http
import Json.Decode
import Json.Encode
import Task exposing (Task)
import Time

main : Program Never Model Msg
main =
    Html.program
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }

type alias Model =
  { responseTitle : Maybe String
  , responseError : Maybe String
  }

type Msg
  = SendRequest
  | NewResponse (Result Http.Error String)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    SendRequest ->
      ( model, Task.attempt NewResponse chainedTasks )

    NewResponse (Ok title) ->
      ( Model (Just title) Nothing, Cmd.none )

    NewResponse (Err error) ->
      ( Model Nothing (Just (httpErrorToString error)), Cmd.none )

httpErrorToString : Http.Error -> String
httpErrorToString error =
  case error of
    Http.BadUrl msg -> "BadUrl: " ++ msg
    Http.Timeout -> "Timeout"
    Http.NetworkError -> "NetworkError"
    Http.BadStatus response
      -> "BadStatus: "
      ++ (toString response.status.code)
      ++ ": " ++ response.status.message
    Http.BadPayload msg response
      -> "BadPayload: "
      ++ (toString response.status.code)
      ++ ": " ++ response.status.message
      ++ ". Error: " ++ msg

postsUrl : String
postsUrl = "https://jsonplaceholder.typicode.com/posts"

requestBody : String -> Http.Body
requestBody timeStr =
  Http.jsonBody 
    (Json.Encode.object [ ("title", Json.Encode.string timeStr) ] )

titleDecoder : Json.Decode.Decoder String
titleDecoder =
  Json.Decode.field "title" Json.Decode.string

titleRequest : String -> Http.Request String
titleRequest timeStr =
  Http.post postsUrl (requestBody timeStr) titleDecoder

titleTask : String -> Task Http.Error String
titleTask timeStr =
  Http.toTask (titleRequest timeStr)

chainedTasks : Task Http.Error String
chainedTasks =
  Task.andThen
    (\time -> (titleTask (toString time)))
    Time.now

subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.none

styleContainerDiv : List (String, String)
styleContainerDiv =
  [ ("display", "flex")
  , ("flex-direction", "column")
  , ("max-width", "300px")
  , ("margin", "25px")
  ]

view : Model -> Html Msg
view model =
    div [ style styleContainerDiv]
      [ viewError model.responseError
      , viewTitle model.responseTitle
      , button [ onClick SendRequest ] [ text "Send request" ]
      ]

viewError : Maybe String -> Html msg
viewError error =
  case error of
    Nothing -> span [] [ text "Error: No error" ]
    Just msg -> span [] [ text ("Error: " ++ msg) ]

viewTitle : Maybe String -> Html msg
viewTitle title =
  case title of
    Nothing -> text "Title: No title"
    Just msg -> text ("Title: " ++ msg)

init : (Model, Cmd Msg)
init =
  (Model Nothing Nothing, Cmd.none)
