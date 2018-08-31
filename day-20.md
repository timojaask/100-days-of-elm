## Day 20

Quick review of day 19:

I finished watching [talk by Evan Czaplicki](https://www.youtube.com/watch?v=XpDsk374LDE) on when to break Elm code into separate modules. Main points:
- It's okay to have large Elm souce code files, unlike in JS.
- Only break out modules when it really give you some benefit.
- Use data structures to enforce rules, and try to make it impossible to represent invalid state.
- When more complicated rules cannot be enforced only by data structures, you can implement helper functions and break the code into separate module to hide the implementation details.

Then I watched a video [by Richard Feldman on Making Impossible States Impossible](https://www.youtube.com/watch?v=IcgmSRJHu_8). It essentially talks about the same subject as the previous talk by Evan -- use data structures to limit the ways that the state can be in, eliminating the possibility of having an "impossible" state. Then, when data structures alone cannot enforce all the rules, break it into a separate module and use helper functions to enforce the rules and hide the implementation details.

> Testing is good, impossible is better
> -- Richard Feldman

---

Today I'm going to take a look at another Richard Feldman's talk [Scaling Elm Apps](https://www.youtube.com/watch?v=DoA4Txr4GUs). Where [Evan's Life of a file talk](https://www.youtube.com/watch?v=XpDsk374LDE) talked about breaking down one file into two files, Richard's talk is going to touch on a larger picture of growing Elm applications.

The basic development cycle that Richard promotes is BUILD -> DISCOVER -> REFACTOER -> BUILD -> ...

But eventually code gets large, and things are harder to find. Also it gets too big to fit in our heads. And potentially code gets duplicated. Let's look at how to tackle these three problems.

Let's say we have a huge `view` function, with 700 lines of code, we can break it down by adding comments. Or we can break it down to helper functions, so that the `view` function itself becomes well organized.

To see how Richard literally organizes his code, you can see his [Elm SPA example on Github](https://github.com/rtfeldman/elm-spa-example).

When code gets too big to fit on our heads, try to solve one problem at a time. Focus on one thing at a time and break it into smaller pieces. If we take the previous example where we split the `view` function into multiple helper functions, also make it so that the helper functions don't take the entire `Model` as their parameter, but instead, only take the things that they really need, or even make it just data instead of function, because sometimes view pieces, such as a footer, don't need any model.

You can break down your `update` function as well. Here as well, you should try to pass only the values that the sub-update function really needs. This way it will be easier to see which function is capable to edit which parts of the larger model. So if we are ever debugging, looking for that code that modifies a certain model field, we can easily discard functions that don't touch it at all, so we have fewer lines of code to go through. Also, some of the sub update functions don't necessarily send any messages, so remove `Msg` from the return type too.

You can also split `Msg` to smaller parts, which requires changing syntax a bit, but use sub-update functions, which make it nicer.

You can also split the `Model` by using comments, but of course you can use more type aliases to split the model. Then you can write functions that works on just a subset of the model, and not the entire model -- this is good stuff. However, if you nest data structures, then you need to worry about accessing it, which, in case of deeply nested structures, might require use of lenses. 

So If you don't want to break up your model, you can use extensible records to pass model down into functions that require less parameters. So you can just pass the `model`, even though a function takes just an `Address a`, because an extensible record is by definition a record that takes the defined fields, *or more*. In our case, the model of course has the fields. The benefit here is that you don't have to worry about your sub-function taking the entire model.

Essentially you can't reduce the size of model, but we can make use of it easier with extensible records.

Eventually you might want to write a reusable piece of view. When these get complicated and interactive, you might want to write their own view, update and Msg for that new view, and then just call these functions inside of the main view and update functions. One cool thing to notice here, is that these nested view and update functions don't need to return the standard return types, because we are going to use them ourselves, not the Elm runtime. So for example, if your subview needs to return some information back to the main code, you can use the update function to return one extra parameter in addition to the default stuff, since the return type can be anything!

```
-- typical update function:
update : Msg -> Model -> (Model, Cmd Msg)

-- A sub-view update function can be anything really:
update : Msg -> Model -> ( model : Model, cmd : Cmd Msg, isVisible : Bool )
update : Msg -> Model -> Result Error Model
update : Session -> Msg -> Model -> Model

-- Using a custom update function like that, inside a parent update function:
update msg model =
  SignupFormMsg subMsg ->
    let
      ( newState, cmd, isVisible ) =
        Form.update subMsg model.formState
    in
      { model
        | formState = newState
        , formVisible = isVisible
      }
```

So when you're building a reusable view, think of what its API should be at best? Any of thse could be the API:
```
Html msg -- not even a function, just a view element

User -> Html msg -- a view that draws different things depending on a parameter passed

(Bool -> msg) -> Bool -> Html msg -- a view that produces a message and takes a bool
```

Key lesson here: Use the simples API possible.

DO NOT DO MODULES WITH SIGNATURES LIKE THIS:

```
Model -> Html Msg
Msg -> Model -> ( Model, Cmd Msg )

Model -> Html Msg
Msg -> Model -> ( Model, Cmd Msg )

Model -> Html Msg
Msg -> Model -> ( Model, Cmd Msg )

Model -> Html Msg
Msg -> Model -> ( Model, Cmd Msg )
```

That is like trying to do OOP in Elm. We end up with lots of complex code in every model. Instead, try to *use the simplest API possible*. Focus on simplifying things:

```
-- A simple button doesn't even need to be a function!
subscribeButton : Html msg

-- A badge doesn't need an update function, nor messages!
badge : User -> Html msg

-- A checkbox doesn't need an update function!
checkbox : (Bool -> msg) -> Bool -> Html msg

-- Even if you need an update function, you might not need the whole Model!
view : State -> Html Msg
update : Msg -> State -> ( State, Cmd Msg)
```

> GOAL: Keep less in our heads by narrowing our types.