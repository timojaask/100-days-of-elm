## Day 3

Quick review of day 2:

Three main parts of a typical Elm program:

- Model: the state of the application
- Update: a way to change the state
- View: a way to view the state and get user interaction

User interactions are received by the applications as messages (a simple object, like an enum). Application then decided what to do when a message is received -- usually some state would be changed.

Elm functions used to achieve the things above are:
- update function: takes message and model as parameters and returns a new model.
- view function: takes a model and returns an Html object that represents the DOM.

To create a DOM element, call a function of the same name as the element (div, button, etc) and passit two parameters: a list of attributes and a list of child elements. Some of the Elm functions used to create DOM elements. To insert a regular text use a `text` function, which takes only one parameter -- the string to display.

User interaction is handled by sending messages. For example, if you have a `button` element, you can define its `onClick` attribute by calling `onClick` Elm function and passing it your message, e.g. like in yesterday's example: `button [ onClick Decrement ] [ text "-" ]`.

When you define the functions in Elm, you would also define its function signature, which looks like: `view : Model -> Html Msg`, this means the function is named `view`, it takes one parameter of type `Model` and returns a value of type `Html` that can produce values of type `Msg` (these are passed to the `update` function).

----

Today I continue by finishing the "Buttons" chapter, starting right with the exercise, where I have to add a reset button to the counter. I'll modify the [buttons.elm](./user-input/buttons.elm) file to implement that.

Adding a reset functionality is very straight forward. Just add a new message value to `Msg`:
```
type Msg = Increment | Decrement | Reset
```
Then add a case for handling it in the `update` method:
```
update msg model =
  case msg of
    Increment ->
      model + 1

    Decrement -> 
      model - 1

    Reset ->
      0
```
And finally add a reset button that sends `Reset` message on click to `view` function:
```
view model =
  div []
    [ button [ onClick Decrement ] [ text "-" ]
    , div [] [ text  (toString model) ]
    , button [ onClick Increment ] [ text "+" ]
    , button [ onClick Reset ] [ text "reset" ]
    ]
```

By the way, the code can be run by navigating to the project root, running `elm-reactor` command, and then navigating to `http://localhost:8000` in your browser.

----

Next I'm going through the Text Fields chapter.

The code can be found in [text-input.elm](./user-input/text-input.elm)

The app in the chapter is very simple and similar to the previous button example. It just has one input field, and one text field. When user types any text into the input field, the text is reversed and the result is displayed in the text field.

New things compared to the previous application:
- In the first app the model was a simple integer. In this app the model is a record that has one field of type String.
- There is only one type of message this time, but it's different in a way that it actually takes a parameter, wheres in the previous app neither message received a parameter.
- Now the model is modified by changing one field in the record (as with everything in Elm, this actually creates a new record and returns it, there's no mutation happening).
- The input DOM element takes two arguments, and the text is accessing the model that's passed into the view function as a parameter.

---

Proceeding to the next chapter: Forms.

The code can be found in [forms.elm](./user-input/forms.elm)

This code is again very similar to the previous app (text-input). The model has three fields for each of the inputs. The update function has three cases for whenever user changes any of the three inputs.

The view got one new interesting addition -- instead of calling directly Elm's DOM generating functions, we call our own function that generates some DOM. One thing I don't understand here is why `viewValidation`'s return type is `Html msg` while `view`'s return type is `Html Msg` -- as in, why one `msg` is capitalized and the other one is not? What's the meaning of this?

There's also a new thing -- `let .. in` So I'm guessing it's a scoped variable declaration. Variables `color` and `message` are declared after `let` and are available after `in`.

Onto the exercises. Same as with buttons, I'm going to modify the `forms.elm` code directly. Adding the following things:
- check that password is longer than 8 characters. Just add a new if/else case for this check.
- make sure the password contains uppercase, lowercase and numeric characters. For this I just added some more if/else cases that use regex pattern matching.
- Add age field and check that it's a number. Same as password check.
- Add a submit button and only show errors after it's pressed. To do this I added another style attribute to the validation div that controls the `display` property. Also added another model field that reflects whether the form was submitted or not. Default `display` value is `none`, but if `submitted` is `True`, then it's set to `block`.

Finally, I'm gonna try to add a checkbox. Created a `checkbox` function that returns an HTML label with checkbox type input and text. `onClick` is tied to a toggle message that writes a boolean into the model.

That's it for day 3.