## Day 21

Quick review of day 20:

Yesterday I watched Richard Feldman's [talk](https://www.youtube.com/watch?v=DoA4Txr4GUs) about scaling Elm apps.

He talked about ways we can break down `view`, `update`, `Msg`, and `Model`. He stressed the fact that we should focus on making it easier for us to keep the code in our head, and making it easier to navigate large projects.

For example, we shouldn't blindly break the `view` and `update` functions to all look the same in all files:

```
-- SubscribeButton.elm
view : Model -> Html Msg
update : Msg -> Model -> ( Model, Msg )

-- Badge.elm
view : Model -> Html Msg
update : Msg -> Model -> ( Model, Msg )

-- Checkbox.elm
view : Model -> Html Msg
update : Msg -> Model -> ( Model, Msg )

-- LongForm.elm
view : Model -> Html Msg
update : Msg -> Model -> ( Model, Msg )
```

This might feel like a good idea, because we're creating something like OOP, where we have familiar "objects". However, it's not really helping us to read the code. We don't really know why does SubscribeButton take a `Model` or what does the `update` function do with the model. Does it modify something? We would be forced to read it and find out what's going on, even if nothing is going on.

It would be a better idea to remove this mental load by simplifying the APIs of our modules:


```
-- SubscribeButton.elm
subscribeButton : Html msg

-- Badge.elm
badge : User -> Html msg

-- Checkbox.elm
checkbox : (Bool -> msg) -> Bool -> Html msg

-- LongForm.elm
view : FormState -> Html Msg
update : Msg -> FormState -> ( FormState, Msg )
```

This way we can see what goes in (if anything!), and what comes out, and it greatly reduces our mental overhead in reading the code!

---

Today I'm going to watch another (!) video by Richard Feldman: [Make Data Structures](https://www.youtube.com/watch?v=x1FU3e0sT1I). Am I becoming a fanboy?

In this video Richard asks himself what would be the advice he would give to his past, less experienced Elm developer self? And the answer is that there are so many advices. But, one stands out most is this:

> MAKE DATA STRUCTURES

So what does he mean by this? If you read the the previous two days of my 100 Day of Elm ramblings, you probably already know what this is going to be about.

To start with, Richard originally tried to build the app based on visual feedback -- building one UI block at a time, in isolation from each other. And eventually connect them somehow in the application. This was a mistake, because even though they are visually separate pieces, they aren't actually separate in sense of internal data structure. They are not actually isolated -- they are coupled and have interdependencies! Things built in isolation, and then put together don't often fit well.

Building things in isolation has the benefit of revealing isolated problems early. However, it doesn't reveal the overall structural problems until after you put things together, and the problem with it is that *structural problems are costly to fix*. To do structural changes, you'll end up changing the `Model`.

What does changing `Model` mean? It means:
- changing `view`
- changing `update`
- changing `init`
- changing `subscriptions`

But! There is no cost to changing model, if these other parts have not yet been implemented!

So with this, the advice is to design data structures first:

> 1. Design data structures to capture the UI.
> 2. Create interfaces to them.
> 3. Render them.

An example of how the data structure design process might go:

The application is a fiction writing app. The UI has three parts: Menu with icons, chapters list, and the document itself. It needs to load data from a backend server, then from a local database, and finally, if neither exists, then create a default document. We could start by modelling it like so:

```
type Model
  = Loading
  | Success Doc
  | Failure Problem
```

So here, at first it's in a Loading state, and we're probably showing some kind of a loading indicator. Then, if loading succeeds, we get the document, and we'll show that. Or, if error occurs, we're going to display some sort of error. Looks good at first. Do we need the `Doc` in any other cases? Probably not in `Loading`, but in `Failure` we will probably want it, because what does user do after reading the error message? We want to display some kind of document, at least let the user start writing a new one! If the user dismisses the error message, we can then transition to the `Success` state, where we're not rendering the error message any longer, but we still have the `Doc`.

But then, when we start building this data structure and logic, we realize some more stuff. Since we're loading the doc from a server, and from an index DB, we need for both to return something before we proceed to the next state. So if one returns success before the other one, where do we keep that state? Or if one returns error before the other one? We can add it to `Loading`:

```
type Model
  = Loading (Maybe Doc) (Maybe Problem)
  | Success Doc
  | Failure Problem Doc
```

But whenever you see two maybes, you should check if you created an impossible state by accident there. Write down all possible states that you can make here:
```
Nothing         Nothing
(Just someDoc)  Nothing
Nothing         (Just someDoc)
(Just someDoc)  (Just someDoc)
```

So we created a possibility of an impossible state -- we can't have both Doc and Problem in Loading, because of both server and DB return, then we should be changing to either Success or Failure. Let's try to make that impossible state impossible to achieve:

```
type Model
  = Loading
  | LoadedOne Doc
  | LoadingProblem Problem
  | Success Doc
  | Failure Problem Doc
```

Then when you think about it, the three loading states are probably going to show a spinner, and the success and failure states will just render the page normally, one with an error banner, and the other without. Might as well combine at least the last two, because they are doing almost the same thing, so it would be annoying to repeat it:

```
type Model
  = Loading
  | LoadedOne Doc
  | LoadingProblem Problem
  | Loaded Doc (Maybe Problem)
```

Now if we have a problem, we will show a banner, and if user dismisses it, we change to `Loaded` state with `Maybe Problem` set to `Nothing` and the banner will be hidden.

Then we're going to add some more state to the app. We will need some state for holding the menu data -- `Menu`, and `Settings`:

```
type Model
  = Loading
  | LoadedOne Doc
  | LoadingProblem Problem
  | Loaded Doc (Maybe Problem) Menu Settings
```

Except that now it's kind of awkward, because when we're setting the `Loaded` state, we will have a bunch of values without names on them. So maybe it's a good idea to use a record at this point:

```
type Model
  = Loading
  | LoadedOne Doc
  | LoadingProblem Problem
  | Loaded
      { doc : Doc
      , problem : (Maybe Problem)
      , menu : Menu
      , settings : Settings
      }
```

But we're probably gonna end up passing this straight to the `view` function, so maybe it's better to make a type alias for this record because of this:

```
type alias LoadedModel =
  { doc : Doc
  , problem : (Maybe Problem)
  , menu : Menu
  , settings : Settings
  }

type Model
  = Loading
  | LoadedOne Doc
  | LoadingProblem Problem
  | Loaded LoadedModel

view : Model -> Html Msg
view model =
  case model of
    Loaded loadedModel ->
      viewLoaded loadedModel
    Loading ->
      viewLoadingSpinner
    ...

viewLoaded : LoadedModel -> Html Msg
```

Then Richard shows an example of use of an opaque type -- a custom type where we don't expose its constructor, so we can hide the implementation details:

```
module DocId exposing (DocId, encode, decoder, generator) -- instead of DocId(..)

-- Below we declare a type which creates one constructor, which we choose not to expose in module declaration above
type DocId
  = DocId Int

decoder : Decoder DocId

encode : DocId -> Value

generator : Random.Generator DocId
```

It's nicer than `type alias DocId = Int` because this way it will be impossible to accidentally mistake it for some other `Int` value. And it's also nicer to use the decoder and encode functions: `DocId.decoder`, `DocId.encode`. And, if we decide to change it to `String` in future, we can do it internally, since no one outside even know what its internal implementation is, since we did not expose the constructor of our type. So if we change it internally, the code that is using it will not break.

In contrast, we do want to code to break if we change our `Problem` impelementation, because it's essentially an enumeration of different problems, and we *want* the users to know if we change or add items to it:

```
-- exposing (Problem(..))

type Problem
  = ServerProblem Http.Error
  | DatabaseProblem String
```

So what about the `Doc` type:

```
mudule Doc exposing (Doc, encode, decoder, generator, docId, title, mapTitle, chapters, mapChapters, words)

type Doc
  = Doc
    { docId : DocId
    , title : String
    , chapters : List Chapter
    , words : Int
    }

generator : Random.Generator Doc
docId : Doc -> DocId
title : Doc -> String
mapTitle : (String -> String) -> Doc -> Doc
chapters : Doc -> List Chapter
mapChapters : (List Chapter -> List Chapter) -> Doc -> Doc
words : Doc -> int
```

The good thing about exposing some things as read-only, is that if we needed to cache the `words` cound (because it takes a lot of CPU to calculate) we can now be sure that it will *only* be modified in `decoder`, `generator`, or in `mapChapters`, so we can safely assume that those are the only functions after which we need to update our word count cache!

So according to Richard it's a good idea to write accessors and mappers for opaque types. Interestingly, Evan was saying that it's a smell if you end up writing getters and setters for your modules, but perhaps Evan meant getters and setters in more classical OOP sense, where you write it for every field? Don't know.

> Start with a type
>
> Go *opaque* by default

That's it for today!