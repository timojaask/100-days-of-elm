## Day 30

Quick review of day 29:

Yesterday I added "Reastart" and area selection functionality, to the Border Quiz game. I learned how to use the HTML <select><option> elements. And then I had some difficulties dealing with different states in the `update` function, but I think I came up with a decent solution for now.

However, the restart functionality has a bug, where once the game is won, and you try to restart, the app shows an init error message. Today I'm going to start by fixing it (hopefully).

---

The bug turned out to be fairly simple: when the game is first loaded or just after restart, the `selectedSetName` is set to `""` (an empty string). If user pressed "Restart" at this point, the game would try to find a set with no name and fail. Essentially we made an impossible state, where the set name is empty, when this should not happen, because the select box always has at least one option selected.

I don't know if there's a way for us to force ourselves to have a non-empty string using the type system, probably not. I mean, we could use the same technique that was used for Lists, but that doesn't really make sense here, because we'd have to provide at least one character, meaning breaking word into characters, which just sounds stupid.

Now I can conclude this game to be "feature complete"! Next, I'd like to turn it into a proper web application, and deploy to Netlify. So I'm going to read through the new Elm guide section on [web apps](https://guide.elm-lang.org/webapps/).

First, I wanted to upgrade the app to `Browser.document`, which would allow Elm to take control of the entire page, not just one DOM node. I know this is currently not needed for this simple app, but I'll just go with it.

Then I realized how deep in the forest I am with all the Maybes surrounding the initialization of the game, even though, I *know* I have a List of countries and it's not empty, but I still have to write logic to check if it's empty or not.

So I wrote a `NonEmptyList` module, that guarantees that when you create it, it has to have at least one entry at all times. It cannot be empty. So I changed my `countries : List Country` to `countries : NonEmptyList Country`. This way, I no longer need to check if there's something in this list -- there has to be.

Then I was also bothered by the same problem with `countrySets : List CountrySet`, where I also needed one item to be always selected, in addition to list never being empty. So I made a `SelectedItemList`.

Next I need to make sure that the `<select><options>` always reflects the state of `countrySets`...

Maybe I could actually make a `<select><options>` component in a module that always returns non-maybe results, because it's pretty much guaranteed to work well internally.