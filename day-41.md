## Day 41

### Opaque types

You can make module boundries to create some guarantees. For example:

```
module Email exposing (Email, fromString, toString)

{-| Guaranteed to be a valid email address. -}
type Email =
    ValidEmail String

fromString : String -> Result String Email

toString : Email -> String
```

In the module above, the comment that says "guaranteed to be a valid email address" is true, because since we're not exposing the `ValidEmail String` variant to the outside world, the only way to create an email us to use the `fromString` function, which runs the validation code. So we are forcing users to run the validation -- there is no other way, so any `Email` ever created therefore must be a valid email.

If we instead chose to expose the variants of `Email` type, like so:

```
module Email exposiing (Email(..), fromString, toString)
```

then we could no longer guarantee the validity, because a user could just take `ValidEmail String` and use it to create a new `Email` with whatever string value, bypassing the `fromString` validation.

---

So we call it an opaque type, when we expose a type, but do not expose its variants, hiding the implementation details from the outside world, and making it impossible for the module user to create an instance of this type on their own, thus forcing them to use some of the functions we create that instan

---

Another example:

```
module Validate exposing (Validator, Valid, fromValid, validate, ...)

type Valid a =
    Valid a

fromValid : Valid a -> a

validate : Validator error subject -> subject -> Result (List error) (Valid subject)
```

This module can then be used in code like:

```
submitForm : Valid Form -> Http.Request User
```

What happens here, is that `Valid` type is opaque. So we can't construct it ourselves. The type itself is super boring, as it doesn't do anything, it just wraps any value. Then you can unwrap it using `fromValid`. But the only way you can construct it is using `validate` -- that is the only function that returns a value of type `Valid`.

So if we wanted to pass a value of type `Valid` into the `submitForm` function, we will be forced to use `validate` to get the value out first.

This way we can guarantee that the `submitForm` will never be called with a invalid form values.

---

Another example:

```
module Credentials exposing (Cred, login)

type Cred = ...

login : LoginInfo -> Http.Request Cred
```

Here, we can say that the only way to get user credentials is by doing the `login` HTTP request. So we can say that if we have any value of type `Cred`, then the user must have logged in.

Also, if any function takes a value of type `Cred` as an argument, then this must mean that the function can only be run when user is logged in.

So for example, if we have a social media site, and you can follow people, you want to render a "Follow"/"Unfollow" button that would allow you to do that. We could do it like this:

```
followButton : Author -> Html Msg
```

This would render a button saying "Follow John", which is great, but, wouldn't it only make sense to render such button if the user is logged in? Cause if the user is not logged in, it shouldn't be rendered at all. We can force that behavior **at compile time** by requiring the `Cred` argument:

```
followButton : Cred -> UnfollowedAuthor -> Html Msg
```

Even though this function doesn't actually use `Cred`, it's there just for the purpose that we can guarantee *at compile time* that this button is displayed only with logged in user credentials.

---

An example where having non-opaque type is still very good:

```
module Author exposing (Author(..), FollowedAuthor, UnfollowedAuthor)
type Author
    = IsFollowing FollowedAuthor
    | IsNotFollowing UnfollowedAuthor
    | IsViewer Cred Profile
```

Above, the `Author` type is not opaque, so a user of this module can create it at their will. However, what can they create? `IsFollowing` requires `FollowedAuthor`, which is opaque, so it must be aquired by using one of the functions in this module. `IsNotFollowing` requires `UnfollowedAuthor`, which is the same as previous and must be aquired using some of the functions in this module. `IsViewer` is the user themselves, so creating that is fine, and it also requires `Cred`, which can only be abtained by logging in successfully first.

So even though the type itself is transparent, the variants depend upon opaque types which come with certain guaratees.

Now when we actually use this in our `view`, this becomes super handy:

```
case Session.cred model.session of
    Just cred ->
        case author of
            IsViewer _ _ ->
                -- We can't follow ourselves!
                text ""
            
            IsFollowing followedAuthor ->
                Author.unfollowButton ClickedUnfollow cred followedAuthor

            IsNotFollowing unfollowedAuthor ->
                Author.followButton ClickedFollow cred unfollowedAuthor

    Nothing ->
        -- We can't follow if we're logged out
```

In this case, we can see that we can't create either of the buttons if we have ourselves (`IsViewer` variant) as author -- *the compiler won't compile that*, because we'd be missing either FollowedAuthor or UnfollowedAuthor values that are required.

This kind of code forces us to handle these edge cases and write the correct implementation, because it simply won't compile if it's wrong. This helps when you come back to the project after a long break, or if a new unexperienced developer comes along to do something.

---

Another example of an opaque type benefit: Let's say we have a `Cred` module that holds on to an authentication token that comes from a backend, which is used for authentication, such as JWT:

```
module Viewer.Cred exposing (Cred, ...)
type alias Cred =
    { username : Username
    , token : String
    }
```

Now the `token` is exposed to the outside world, which seems fine at first, because why not? However, if the backend team decides to switch authentication to something else than JWT in future, the token format might change, and we'll need to update our code. But, does any other code use the token and the old format? We don't know! It's a possibility, since we exposed it!

If we instead choose to hide the token, we could guarantee that if it ever changes in future, we only need to modify our `Cred.elm`, and all other code will still work. Because we never exposed token in the first place, there is no code that can possibly rely on it. Guaranteed.

```
module Viewer.Cred exposing (Cred, ...)
type Cred
    = Cred Username String
```

### Extensible data

- Constraing Unification
- Open and Closed Records
- Why Open Record Exist
- Extensible Custom Types

#### Constraining Unification

When Elm compiler is checking the types in the code, such as seeing if the type of passed argument matches the type required by the function. Here, the compiler is checking if the types match, and there are three scenarios that can possibly play out:

1. Let's say that `String` is passed and `String` is required -- they are *identical*, so all good.
2. Let's say that `String` is passed and `a` is required. `a` can be anything, so ok. The compiler will continue with a *more constrained* type, in this case `String`. It will also choose `number` over `a` in case you try to append `List. append [ 1, 2 ] []`, because `number` can be only either `Int` or a `Float`, while `a` can be anything.
3. Let's say that `String` is passed and `Int` is required -- they are *incompatible*, and this won't compiler.

#### Open & Closed Recods

**WARNING*: The future of open records is uncertain! They were intended for internal use, but people found ways to use them in their own code. However, they pose some performance optimization issues when compiling to web assembly, so they might actually be gone from the language in the future. BEWARE!

Closed record, means that this is exactly the same of the record. It's closed for extension, you can't make any variations on that:

```
type alias Model =
    { ... }
```

Open record, means that I have at least these fields, but possibly I have some more:

```
type alias Model r =
    { r | ... }
```

Examples!

Typing out a closed record, like the one below, gives us a record of type `{ firstName : String }`:

```
> { firstName = "Sam" }
{ firstName = "Sam" } : { firstName : String }
```

Typing out a period followed by field name, gives us a function that takes a record that at least has a field named `username` or any value, and returns its value. So in this case, the type of the record is `{ b | username : a }` and it's an open record, because we say that it has one field, but it can have more:

```
> .username
<function> : { b | username : a } -> a
```

Tying out a function that takes a record and returns the same record with field `name` set to `"Li"`, we imply that this type variable `record` can be any type that has a field named `name` which in turn is of type `String`:

```
> (\record -> { record | name = "Li" })
<function> : { a | name : String } -> { a | name : String }
```

Note that you can't actually create an open record. The only way to use them is to use a function like `.username` or modify an existing record.

In terms of constraint unification, like we saw with other values above, records work in the same way:

1. Using `{ x : Int }` and `{ x : Int }`, they are *identical*, so the resulting type is `{ x : Int }`.
2. Using `{ r | x : Int }` and `{ x : Int }`, they are *compoatible*, but the resulting type is going to be the one that is more constrained, in this case `{ x : Int }`.
3. Using `{ x : Int }` and `{ foo : Int }`, they are *incompatible*, even though they have the same number of fields and they are of the same type, but names are different, so that's not good, this won't compile.

When unifying two open records, as expected, the compiler picks the one that's more restrictive. For example, unifying `{ r | x : Int }` and `{ r | x : Int, y : Int }`, the resulting type will be `{ r | x : Int, y : Int }`, because it is more restrictive -- it defines that the record must have both fields, which means it's narrowing down the possible records that can be of this type.

Some more examples:

In the following function, we say that we take a record and sum it's `x` and `y` fields, which Elm interpretes as the record must be of type that contains `x` and `y` fields at least, and they must be of type `number`, because the addition operator `+` only works with `number` types:

```
> (\point -> point.x + point.y)
<function> : { a | x : number, y : number } -> number
```

What actually happened there, is Elm looked at `point.x` decided that it is of type `{ a | x : number }`, looked at `point.y` and decided that it must be of type `{ a | y : number }`, and this is a special case, where instead of picking one that's more restrictive than other, it's unifying them to produce `{ a | x : number, y : number }`.

---

#### Extensible Custom Types

Let's say we can get article preview (displayed on article list page) and a full article (displayed on the full article page) from the server. On the list of articles we only have access to the preview. How can we model this? One way is:

```
type Article extraInfo =
    Article
        { title : String
        , tags : List String
        }
        extraInfo

type Preview = Preview
type Full = Full Body
```

This would be an opaque type, so how do we get these articles? Two ways, both coming from the external source, like JSON from outside:

```
Decoder (Article Preview)
Decoder (Article Full)
```

Since this is an opaque type, the module user cannot access the fields directly, so we'd make accessors:

```
title : Article a -> String
tags : Article a -> List String
body : Article Full -> Body
```

Notice in the code above that we can't possible ask for `Body` when the article is not full.

Note that you don't have to user the type variable necessarily like we did with `extraInfo`. If you simply want it there to be for the sake of defining different kinds of types, and not actually holding any data, you can just use it like this:

```
type Length units =
    Length Float

type Cm = Cm
type In = In

let
    penLengthEur = Length 10 Cm
    penLengthUs = Length 3 In
in
...

add : Length units -> Length units -> Length units
add (Length num1) (Length num2) =
    Length (num1 + num2)
```

What we did above is made sure that length types can never be accidentally mixed by using the `units` type variable. But we never actually touch it anywhere in our custom type variant, since it doesn't carry any useful data.

In the `add` function above, we are making sure that the first and second argument types are the same. We could have written it also `Length a -> Length b` and compiler would be okay with that, but it would defeat the purpose of this whole idea.


### Type Parameter Design

`Never` is a type that can never be instantiated. Why would that be useful? We can use it to create some boundries. A good example of this is `accessible-html` package. Where as `elm/html` package has HTML tags, where each of them expects a List of `(Attribute msg)` as a second parameter:

```
p : List (Attribute msg) -> List (Html msg) -> Html msg
```

You can essentially pass even event handlers that are at odds with accessibility, such as `onClick`:

```
p [ onClick ParagraphClicked ] [ text "Click me!" ]
```

This is not good from the point of view of accessibility, even though HTML DOM allows it. So some people think that it's better to forbit this functionality altogether. How? Since we should still be ablet to take other kinds of attributes, and some controls should be able to take events. Well, one way would be to separate events from attributes. Another, if we wanted to stay close to HTML DOM and the original `elm/html` implementation, is to introduce `Never` in the type variable of Attributes in HTML tags that should not be doing any events:

```
p : List (Attribute Never) -> List (Html msg) -> Html msg
```

In this case, we can no longer pass it an attribute of type `Attribute Msg`, since it requires `Attribute Never`. We can never instantiate `Never` either, so the only kinds of attributes we can pass are those with types not yet defined, or also called "unbounded", such as any attribute that's not an event (e.g. `class "description"`, which is of type `Attribute msg`).

The original use for `Never` is in tasks that never fails. You can see this in `Task.perform` type:

```
Task.perform : (a -> msg) -> Task Never a -> Cmd msg
```

What this says is that the second argument taks in a `Task` with error argument set to `Never`, meaning that it cannot possibly produce an error. This is in contrast to tasks that do produce errors, for example for HTTP requests, you'd have `Http.Error` or something of that sort, and you'd use `Task.attempt` function to execute failing tasks.

An exaple of this kind of task is getting the size of the window:

```
getViewport : Task x Viewport
```

This can't fail, so the type of the error is still unbound. `getViewport` is a task, because it can potentially return different results depending on when you call it, so it cannot be a function in Elm, because functions by definition must return the same result given the same set of arguments. So we'd use it like:

```
type Msg =
    ViewportChanged Viewport

...

Task.perform ViewportChanged getViewport
```

Remember the `Task.perfor` function:`Task.perform : (a -> msg) -> Task Never a -> Cmd msg`. So in the code above, the `ViewportChanged` fits the type requirement `(a -> msg)`, and the second argument `getViewport` fits the type requirement of `Task Never a`, since unbound type `x` can be converted into `Never`, and `Viewport` can be used as unbound `a`. Essentially the second parameter type will be unified into `Task Never Viewport`.

The reason why `getViewport x Viewport` doesn't use `Never` to begin with, is that if you want to chain it with other tasks, then they must have compatible error types. So if another taks can produce an error, the `getViewport`'s unbound `x` will be compatible with that. If we defined it as `Never`, then we would be unable to use it together with failing tasks.