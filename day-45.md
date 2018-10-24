## Day 45

Quick review of day 44:

- We can create helper function to facilitate code reuse where it makes sense.
- Not all similar looking code is good to be reused though. Sometimes trying to make something work in multiple scenarios is more trouble than it's worth. DRY, if it results in more complex code is not necessarily better. In JS, more code usually means you need to write more tests to prove that the code works. However, in Elm the compier does a lot of that automatically.
- There are three general approaches to reusing view functions which produce some sort of `Html msg`. When wanting to reuse or extract view functions into a separate module, it's good to try and do things in the simplest possible manner. If the simplest way doesn't cut it, then try a more complex approach:
1. Simplest: view doesn't send messages, so the `Html msg` stays unbounded.
2. Medium: view sends messages, and the caller provides the message, and takes care of handling the message in their `update` function.
3. Complex: message creation and handling are done inside of the module, so that the caller doesn't have to. Use this method only when there are too many messages for caller to take care of. Usually this would require the module to have it's own model, init, msg, update, and view. The caller must then wrap module's messages into something it can handle in bulk, using `Html.map`, `Cmd.map`, and possibly `Sub.map`.

------------------------------------------------------

### Sources of truth

Do I have agreement on where a particular piece of information lives?

Need a bloody obvious example?

```
type alias Model =
    { selectedTag : String
    , theSelectedTag : String
    , ...
    }
```

This would be bad -- we have two places that seem to be representing the same data. We have two possible sources of truth. This is a terrible, terrible situation ;-)

It's funny, but this is closer to the real world code than you might think. Unfortunately, in real world these sort of problems are more difficult to spot than in the example above, but they represent the same dangers nevertheless. For example, you might have a `currentUserName` in two different parts of the codebase. If they are always in sync with each other -- there shouldn't be any problems, but that won't necessarily always be the case, especially as multiple people work on the same codebase over time. And when they get out of sync, then we potentially have different pieces of software thinking they have the right data, while one of them does not.

#### Impossible states

Example -- image we have tabs in the UI. One tab can be selected at a time. We represent our tabs as a list of:

```
type alias Tab =
    { name: String
    , active: Bool
    }
```

So when user clicks on a tab, it becomes active, and we deactivate the previously active tab. However, through some sort of bug in our code, it is possible that multiple tabs will have `active` set to `True`. Then what? Who's right? Should we trust tabA or tabB? Someone's gotta be wrong! One way we could solve this is to use a custom type to represent all possible tabs:

```
type Tab
    = YourFeed
    | GlobalFeed
    | TagFeed Tag
```

This way, we just have one "variable" which represent the active tab, and it contains a value of type "Tab", and that's it. We have no other pieces of data holding the tabs.

#### Derived data

Let's say we download a post time edited timestamp:

1. Database timestamp: 2018-05-05 12:01:54 UTC
2. Sending/receiving JSON ISO-8601 string: "2018-05-05-T12:01.54Z"
3. Converting to Time.Posix at client: 1525521714
4. Converting posix to human redable: "May 5, 2018"
5. Producing `Html msg` with the time printed there

In this example, we have one source of truth -- the database on the server. However, probably more often than not, the UI of the client app will require us to cache the downloaded information. Because if every time we want to render the UI we'd have to go and download the timestap from the server, it would be impossibly slow. So we cache it, and thus, create a second source of truth, which migth become stale, if the timestamp on the server changes and we don't re-download. But this is something we must live with, because of the performance reasons.

So normally we'd store the Time.Posix value in our `Model`. It is a cache of what came from the database, and we have to live with that. But we shouldn't really be making it any worse, unless required. For example, we would need to transform this Posix representation to human readable format before displaying in the view. This logic should be done during render time in the view. It should not be done in update, stored in model, and then rendered, becuase then we are creating a second cache with the derived data. The only reason why we would want to cache the derived representation is if the computation takes a long time, too long for the rendering. That's the only reason we should be considering caching. The more caching layers we have, the more we have a chance of having outdated information.

#### Authentication & JavaScript

We almost always want to cache authentication information on the client side. By authentication we mean when user types username and password, then we authenticate that with a server, server says "all good" and gives us back a token, which we cache, and use for any future requests, until the token expires or user logs out, clearing the token cache.

Without caching the token, the user would have to login every time they need to make an authenticated request to the server, which in most scenarios would be a terrible user experience.

One way of caching a token, besides cookies, is in the browser's local storage. Now it looks like Elm doesn't have access to that directly, so we'd have to use JavaScript for that. How exactly that works, I don't now but according to Richard, we'd end up storing another cache of the session in our Model, and because I guess we don't wanna be getting it from JavaScript every time we need to use it. I guess that sorta makes the code significantly simpler.

But what's the problem here? If Elm updates the local storage via JS every time, there should be no problem. However, the issue is that user can open multiple tabs with the same Elm app running. If one of them would modify the local storage, the other tabs wouldn't know about it, and would end up with a stale cache.

There's a way to remedy this by subscribing each Elm app to local storage changes, so that if any of the tabs modifies the token in storage, each other tab would get notified about it and update their models.

This is something that's good to keep in mind -- the layers of caching that our app uses, what is the purpose of each layer, and how do they stay in sync. We also need to decide which cache is right in comparison to another. Usually we agree that the server is always right. Then if we still have multiple layers of cache on our client, such as local storage and the app code, then we have to decide again. In this case, local storage is likely the best candidate for being the one that's right, and client should just update its model any time it knows that local storage has changed.

To make this particular scenario more robust, it's a good idea to make updaing the toke in model possible *only* via local storage. So the only way to set a token is to get a notification that local storage has changed. Since the Elm app is the one that gets the token from the server, it then should write it to the local storage and that's it. Then wait for local storage JS code to notify the Elm app back that the token has changed and only then the Elm app would update its model. So our model would have only one source of truth for the token -- the local storage, not the HTTP response that we get -- because we don't want to have multiple sources of truth. If we updated model also from the HTTP response, then we can potentially end up in a situation where we have a different value in our model than in the local storage -- it's a bug waiting to happen!

It does feel silly to not update out model once we get the data from the HTTP response. It's like "hey, we got the data right here, why don't we just quickly update the model with it?" -- it is tempting! But don't get tempted, because then you'd create the potential of having conflicting state. Decide the one and only place from where the model gets the token, that would make sure that in all scenarios, including other tab and our own HTTP request, we'd be in sync with the local storage.