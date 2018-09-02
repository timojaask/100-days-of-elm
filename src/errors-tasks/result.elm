import Html exposing (Html, span, text)
import Html.Attributes exposing (class)

view : String -> Html msg
view userInputAge =
  case String.toInt userInputAge of
    Err msg ->
      span [class "error"] [text msg]
    
    Ok age ->
      if age < 0 then
        span [class "error"] [text "I bet you are older than that!"]
      else if age > 140 then
        span [class "error"] [text "Seems unlikely..."]
      else
        text "OK!"