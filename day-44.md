## Day 44

Quick review of day 43:

- Using modules: There's no need to use modules only for the sake of reducing number of lines in a file, or hiding implementation details just because you can. Use them intentionally when hiding details is going to drive certain behavior. For example when you want to limit the ways that a certain kind of data can be created, eliminating the possibility of initializing it in an incorrect state.
- Using types to enforce behavior: Use types to enforce a certain behavior, such as requiring a restricted type as a function or message parameter, to make sure it's being called only when that type can be initialized.
- Using narrow types in function arguments and return values: using narrowest possible type will tell more precisely what this function affects, making it easier to read and reason about the code.

-----------------

### Helper functions

You can create helper functions to facilitate code reuse -- for example when we have two very similar parts of code, or even exactly the same parts of code, and we can extract them into one function that will be called twice.

### Similar vs same

However, we shouldn't fall into a trap of trying to reuse all the things that look similar. There are times when you actually want to repeat yourself against the advice of DRY, at least when writing in Elm.

Consider the following three types:

```
-- Article loading status
type Status a
    = Loading
    | LoadingSlowly
    | Loaded a
    | Failed
```

```
-- Profile loading status
type Status a
    = Loading Username
    | LoadingSlowly Username
    | Loaded a
    | Failed Username
```

```
-- Editor loading status
type Status
    -- Edit Article
    = Loading Slug
    | LoadingSlowly Slug
    | LoadingFailed Slug
    | Saving Slug Form
    | Editing Slug (List Problem) Form
      -- New Article
    | EditingNew (List Problem) Form
    | Creating Form
```

As you can see, they are similar, but not the same. We might have an itch that tells us that we shouln't be repeating ourselves -- let's reuse! But in fact, they are different enough, that trying to reuse them would result in a more than necessary complicated code. And for what benefit would we add that complexity? Would be it so that we'd only need to update code once? But that update wouldn't necessarily even be needed for, let's say, Article loading. Would we save on writing tests? But for this code, we actually probably want to test different things for each of these three different statuses.

In JavaScript a good reason to try and reuse as much as possible is that we would also save on writing tests. Any code you write in JS often requires some tests to tell you that, yes, this code actually works. In Elm, however, this is not the same, because you don't need tests to tell you that your custom type works correctly -- the Elm compiler does that automatically.

Where the code above can fail, is where you have to write logic, such as the logic that does transition between `Loading Username` and `LoadingSlowly Username` -- we want to make sure that hte username is preserved. But we don't need to test that for the Article Status. There's actually nothing much to test there at all when using Elm, because compiler guarantees the correct use anyway.

### Reusing view functions

The following icon can be used on many different pages across the application, each having their own messages, etc.
```
icon : Html msg
icon =
    Html.img
        [ Asset.src Asset.loading
        , width 64
        , heigh 64
        , alt "Loading..."
        ]
        []
```
We can, however, reuse this piece of code. And the reason we can, is because it has an unbound type variable. So this means it can work with any `Html Msg` bounded type, on any of our pages.

Here's a more complex example of the same unbound type variable usage:

```
followButton :
    (Cred -> UnfollowedAuthor -> msg)
    -> Cred
    -> UnfollowedAuthor
    -> Html msg
followButton toMsg cred ((UnfollowedAuthor uname _) as author) =
    toggleFollowButton "Follow"
        [ "btn-outline-secondary" ]
        (toMsg cred author)
        uname
```

And another one:

```
favoriteButton :
    Cred
    -> msg
    -> List (Attribute msg)
    -> List (Html msg)
    -> Html msg
favoriteButton _ msg attrs kids =
    toggleFavoriteButton "btn btn-sm btn-outline-primary" msg attrs kids
```

Also, what if your view function can send different messages, for example if it displays multiple different buttons? You can just pass those:

```
bunchOfFavoriteButtons :
    Cred
    -> { fave: msg, superFave: msg, funkyFave: msg }
    ...
```

### Html.map & Cmd.map

TODO: Start listening from around - 2:00 of the video

So there are three ways we can approach reusing view functions. And we usually want to consider them in the order of lightest to heaviest. In order words, only go for the heavier option if it provides a benefit compared to a lighter one. Lighter is always better if lighter version can be used.

#### 1. Lightest: no messages passed along

No messages are sent, no need to know what the messages can be, the caller doesn't need to tell how their messages look like:

```
icon : Html msg
icon = 
    Html.img
        [ Asset.src Asset.loading
        , width 64
        , height 64
        , alt "Loading..."
        ]
        []

-- Another example:

error : String -> Html msg
error str =
    Html.text ("Error loading " ++ str ++ ".")
```

#### 2. Medium: the caller creates the messages

If we can't get away with using option 1, and we still think that reuse is the right choice, as opposed to deciding to just write this view code multiple times for different purposes, then we can use the medium heavy method, where we ask the caller to define all the necessary messages for us:

```
favoriteButton :
    Cred
    -> msg
    -> List (Attribute msg)
    -> List (Html msg)
    -> Html msg
favoriteButton _ msg attrs kids =
    toggleFavoriteButton "btn btn-sm btn-outline-primary" msg attrs kids
```

#### 3. Heavy: the function has its own messages, model, and update, view, etc

If we've condiered option 2, but it turned out that it would require excessive configuration on caller's part to create and handle the messages for our functionality, and it seems like it would be beneficial to us to just take them out of the caller and place in its own enclosed module, then we can go for it. This is a situation where we have lots of module specific messages that need to be handled, there's lots of custom logic that needs to be run, and it's quite burdesome on the caller.

This method, however, still leaves some boilerplate code for the caller to have, however, it's fixed, so we don't need to worry about it. However, we don't want to use this method for everything, because we'd end up writing lots of boilerplate code to support it.

This used to be a typical beginner mistake in Elm, where people would create a component, then immediately go ahead and write it its own Model, its own Msg, its own update, its own init, and its own view, and introduce all the boilerplate to work with it from the caller side. Most of the time the better approach is to turn to one of the lighter methods listed above. It's better to keep things as lean and as light as possible given your situation.

So how to do things this way?

The module would have its own Msg type. These are the messages that the potential collers would have have to implement if we went with a lighter option. Since we have four of those, we can decide to go with this option 3, because we don't want the potential callers to have to implement all four of these messages:

```
type Msg
    = ClickedDismissErrors
    | ClickedFavorite Cred Slug
    | ClickedUnfavorite Cred Slug
    | CompletedFavorite (Result Http.Error (Article Preview))
```

The variants of the Msg type is not exposed to the caller, it's opaque to everyone else, so the caller can't handle them even if they wanted to:

```
export Feed { Model, Msg, init, ... }
```

We also have an opaque Model:

```
type Model
    = Model Internals
```

And the only way that the caller can create this model is by calling the init function:

```
init : Session -> paginatedList (Article Preview) -> Model
init session articles =
    Model { ... some init code here ... }
```

Once the caller has the model returned by `init`, they can't do anything to it, because it's opaque -- they cannot mess with it. All they can do is hold on to it, and pass it off to our `Feed` module to work on it.

Now if the caller wants the `Feed` to actually do anything, then they need to call something like this:

```
update : Maybe Cred -> Msg -> Model -> ( Model, Cmd Msg )
update maybeCred msg (Model model) =
    case msg of
        ... some update code of Feed that handles the four different Msg variants ...
```

Note that the `Msg` and `Model` types in the `update` function are `Feed`'s `Msg` and `Model`, not caller's, even if they happen to be called the same way. So all of this logic is completely opaque to the callers. Because it takes opaque message and opaque model, and returns opaque message and opaque model -- no one outside knows what's going on there!

All the callers can do is call the `update`, passing the opaque model that they got from `init`, and the only way they can get `Msg` is by calling one of the `Feed`'s view functions that produce these opaque messages, because no one else can possibly produce these messages:

```
viewPreview : Maybe Cred -> Time.Zone -> Article Preview -> Html Msg
viewPreview maybeCred timeZone article =
    ... producing some Html which is capable of sending one of the opaque `Msg` types of the `Feed` ...
```

So these `Feed`'s view functions can send `Feed`'s opaque `Msg` type messages, that can only be handled by `Feed`'s `update` function. All the callers do is take these opaque messages and pass them to `Feed` to handle. 

So how do we handle these things on the caller side?

We will have just one message type that will handle all of the `Feed`'s messages in one place:

```
-- caller's Msg type:

type Msg
    = ...
    | GotFeedMsg Feed.Msg
    | ...
```

```
-- somewhere in caller's update:

GotFeedMsg subMsg ->
    case model.feed of
        Loaded feed ->
            let
                ( newFeed, subCmd ) =
                    Feed.update (Session.cred model.session) subMsg feed
            in
            ( { model | feed = Loaded newFeed }
            , Cmd.map GotFeedMsg subCmd
            )
        ...
```

So what's happening here? First of all, we have `GotFeedMsg Feed.Msg` message. This is the only message that caller is ever going to get from `Feed`. The argument is the `Msg` from the `Feed`, which can be one of the four types, but caller cannot know that, it just passes it along.

So we call `Feed.update` and pass it the `Feed.Msg`, and `Feed.Model`, and it returns a new `Feed.Model` and `Cmd Feed.Msg`. Updating the model is easy, we just write new value in our model, but what do we do with the command? We can wrap the command inside of a message that we know how to handle:

```
Cmd.map GotFeedMsg subCmd
```

Remeber that Cmd takes in the message that it's going to call once the command is done.

So what we're doing here, it asking Elm runtime to do this thing `subCmd`, which we don't know what it is, but we don't care, and then once it is done, produce a message of type `GotFeedMsg`, so that we can handle it here in our `GotFeedMsg` where we can send the result to `Feed.update`.

Okay, then how do we render any of the `Feed`'s views that produce those `Feed.Msg` messages?

```
view : Model -> Html Msg
view model =
    ...
    Feed.viewArticles model.timeZone feed
        |> List.map (Html.map GotFeedMsg)
    ...
```

Here, the `Feed.viewArticles` function is going to return us a list of articles, each of type `Html Feed.Msg`. What we're doing with it is mapping over that list, and wrapping each result into `GotFeedMsg` message that we know how to handle.

`Html.map` does the same thing that `Cmd.map` does, which is: "here's some Html that got some foreign Html message type that I don't know how to deal with (or I've got some Cmd message type that I don't know how to deal with), and all I want to do is wrap it in this `GotFeedMsg Feed.Msg` message that I know how to handle". 

Additionally, we can do the same trick with subscriptions, if the module needs to be subscribed to something, but that's more rare.

We can also have cases where we only do `Html.map` or `Cmd.map`, but it's more common that both are needed, because usually they go hand in hand.