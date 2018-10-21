## Day 42

### Narrowing types

One way to find a bug is to look at the return types of the functions. For example, we know that the problem is with the `Form` data. `Form` is sitting inside of the `Model`. So any function affecting either `Form` or `Model` can potentially affect this. Basically, any function returning either `Form` or `Model`. And if function returns neither, then we can say for sure that it doesn't affect this data. This is one way of narrowing down potential culpits when looking for bugs.

No matter how long the function is, if it doesn't return the type that you're looking for, then you can safely rule that entire function out. This is because all functions are pure in Elm, and the only way they can affect the outside world is by returning a value. If they don't return the value you are looking for, then there's no way they can affect that somehow.

So it is good to have functions take the narrowest type that they need. So if a function is working on form data, it can take the whole `Model`, but if it only needs the `Form` part of it, then it should only take `Form`. This way it's a lot easier to reason about what this function does.

### Enforcement arguments

Sometimes we can use function arguments to force certain behaviors. For example, consider the following messages, especially the `ClickedSave` one:

```
type Msg
    = ClickedSave Credentials
    | EnteredBody String
    | EnteredTitle String
    | EnteredTags String
```

Here, when user clicks on "Save" button, the app would fire off a REST API request, and pass logged in user credentials for authentication. One thing is sure -- we can't do this if the user is not logged in. If we somehow ended up on this page without logging in first - that's a bug - and then what should we do when user clicks "Save" without credentials?

Well, in this particular case, the "Save" button can't even be displayed unless we do have credentials, because the message that the button sends requires it. So by designing our data this way, we make sure that the button is only displayed for logged in users, without even touching the UI layer.

Another example of the same concept. Let's say we have a user profile page. Anyone can view another user's profile page. Only logged in users can follow or unfollow. How do we enforce that on the data model level without writing any logic? Here's an example:

```
type Msg
    = ClickedTab FeedTab
    | ClickedFeedPage Int
    | ClickedFollow Credentials UnfollowedAuthor
    | ClickedUnfollow Credentials FollowedAuthor
    | ...
```

As you can see, without credentials the two lower messages cannot be created. This means that we can't display buttons that would send these message -- that is simply not possible given this data type.

The handlers of these messages don't even necessarily need to use the credentials. It's handy in this case for the HTTP authentication, but we could have just as well placed them there for the sake of enforcing the fact that only logged in users should be able to see them.

Here's another interesting example. Let's say that we have a site where we have different authors writing blog posts. A logged in user is also an author. So we could represent the author type like so:

```
type Author
    = IsFollowing FollowedAuthor
    | IsNotFollowing UnfollowedAuthor
    | IsViewer Credentials Profile
```

Here, we enforce that we have the correct author type for follow/unfollow actions seen in the previous examples, so we can't possibly follow an author that's already been followed, and vice versa -- this is enforced by the data model itself, no logic whatsoever. Then we have a third option, where the author is the user themself. In this case, it should only be possible if the user is acually logged in, so, `Credentials` is required there, perhaps because it's needed, or perhaps just to enforce the fact that only logged in user can be used here.