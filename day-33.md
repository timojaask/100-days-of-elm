## Day 33

Quick review of day 32:

Yesterday I moved the app code to use SelectedItemList for combo box options and it seemd to have simplified some things. I also fixed the app, and it now uses `Browser.document` and seems to work without bugs.

---

I found a small bug. The overall progress total value is not showing total, it's showing how many are left:

```
Overall progress: 0 / 157
Overall progress: 1 / 156
Overall progress: 2 / 155
...
```

And same for number of neighbors guessed. The bug is simple -- I was printing number left, instead of total number. Easy fix.

Then I found another bug:

1. Type corret answer
2. Press Enter and any other key almost at the same instant, with Enter slighly before

What will happen is the correct answer will be submitted by Enter hitting first, then the next letter will be registered and the text field will not be cleared for some reason. It's probably some kind of race condition, where the text field is cleared after Enter, but then the next value with the new letter is already queued to be set, so it gets set after the clearing. This sucks, but it's pretty edge case, so I don't want to spend time with it now.

Next I want to make the countries appear in random order instead of alphabetical.

I decided to use [elm-community/random-extra package](https://package.elm-lang.org/packages/elm-community/random-extra/latest/) for list shuffling.

```
$ elm install elm-community/random-extra
```

So I'm facing a problem here. The chain of actions for restarting (and starting, with the exception of the first step) a game is something like this:

1. Reset message sent
2. Filter countries by selected set
3. Shuffle countries
4. Initialize a new game Model

The problem here is that step 2 can potentially fail, if we have an error in a set, and there are no countries found by filtering. What should I do here? The easiest way out is to simply ignore it and produce some default value, such as "all countries". But then we end up with potential errors in production. A little bit more involved way it to show an error message, which is a little bit easier to spot when testing new content, but still can potentially end up in production if not tested.

But even better way could be to write a module which handles all the country and set data. This module would take the countries, and the sets as in input, but expose only the country sets that are actually known to be valid for the country data that it has.

This way, this module could provide filtering functionality, where it can ignore any error cases, because they would be "guaranteed" to never occur. To make sure, this module should have automated tests.

Basically, even though this module ignores the potential errors, we still have tests that say that the logic of the module works, and the errors should never occur, so our app can trust it and get non-Maybe values out of it after filtering, etc.

This is an interesting idea I want to explore tomorrow.