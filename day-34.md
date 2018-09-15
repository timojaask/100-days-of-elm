## Day 34

Quick review of day 33:

Yesterday I fixed a small UI bug where it was showing countries left instead of total countries.

Then I found another bug, where after typing a correct answer, you'd press Enter and some other key immediately after, the answer would be registered, but the input text box not cleared. This is a race condition. However, I decided to let it go for now.

Then I decided it would be good to make the countries appear in a random order. That opened a new can of worms. It's kind of annoying to deal with the maybe values.

So I thought it might be interesting to place all country data and related functionality in its own module, which would provide an error-free interface.

---

What are the actions I want to do with the countries and country sets?

- Get a non-empty list of countries filtered by a country set -- at init, and at reset -- this can fail
- Get a non-empty list of country sets
- Return a new country sets list on `SetSelectedCountrySet` update, because potentially a new country set was selected, so we need to update our state to reflect that.

I think that's pretty much all there is to it. Well, we'd also need to give it the name or ID of a country set to filter on, which is the part that can fail. What to do then? Make a module that provides that functionality built-in, meaning the actual UI element would sit in the module, and there would be something handling the update? How would that look?

Since all of the messages are being routed though the main `update` function, they'd have to be then passed down to this module. What messages would this module need? At least `SetSelectedCountrySet`. It could also have the Restart, but that's not necessary. Would it handle shuffling? Doesn't have to, because shuffling cannot fail, so we can do it in the Main module, after getting the filtered list.

So the only message that this module would care about is `SetSelectedCountrySet String`, however, it doesn't need to be a typical `update` function taking a message, it can just take a string.

Regaring `view`, which will also be called from the parent, what does it need? To display a combo box we need two things: The message that it should send and a list of country sets. The message should be coming down from the parent, because parent is also going to handle it. Country sets should also come from the parent, since it needs to keep the "selected item" state, and the module cannot keep its own state.

Now that I think about it, there seems to be no obvious way to make this foolproof. Passing the value of `SetSelectedCountrySet String` down to this module can fail, like, if the main code tampers with the string, haha. So this is one week spot I have in this app -- failing at filtering the countries by a country set ID. Maybe I should try to just live with that and try to handle it gracefully in the Main app.

So where would I need to do that? I need to filter the countries in two scenarios:

- init
- restart

Now that I look at my code, and where all the `Nothing`s live, I can see that I've ignored some other potential erros in my code. For example, `countryFirstNameById` simply returns an empty string if it can't find a country with a given ID. I'm doing the same thing in `answerToNeighborId`, `countryFirstName`. I do that even in `update`, but there, it's kind of understandable, because having a model in `LoadingError` state is not possible. But then again, we're in an impossible state situation.

I think I could try to handle my Maybes better, give them a proper treatment instead of ignoring. Unfortunately, this is all I had time to do today, so I'll get back to this tomorrow.