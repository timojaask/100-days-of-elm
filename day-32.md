## Day 32

Quick review of day 31:

Yesterday I implemented `setSelectedSet` function, which did some rather complicated logic of setting the `SelectedItemList CountrySet` selected item. I know, the names are kinda bad, and the code is kinda hairy, and also I placed this `CountrySet` related logic into `SelectedItemList` module, whis is probably wrong.

So maybe I'll try and sort that out, but before I do that, I want to make this game work again, now using this new function.

---

So now instead of using `List.map` to create the `<option>` elements, I should use `SelectedItemList.map`, because it will give me the `isSelected : Bool`, that I can use to set `selected` on one of the options:

```
viewCountrySetOptions : List (Html Msg)
viewCountrySetOptions =
    SelectedItemList.map
        (\isSelected ->
            \set ->
                option [ value set.name, selected isSelected ] [ text set.name ]
        )
        countrySets
```

Now the combo box selection is tied to our model. Which is good, I suppose.

Then I asked myself, why do I have `countrySets` in my `PlayingModel`, when I already have it available in the file? Well, the answer to this question is that they are only the same at first load. Once user selects a different set, we will write that into our `PlayingModel.countrySets`, where another set is going to be selected.

Okay, so now I fixed the game, making use of `SelectedItemList` nad the `init` is now a lot simpler, which is good. There's no more error on restarting the game, which is also good.

There's still a bug though. If I first select "Asia", then I restart the game, the Asia is still selected in DOM, but internally, the selected set has been reset, and is set to "All". So if I click restart again, I'll get all the countries, even though "Asia" is selectd in DOM. So the UI gets out of sync with the model.

So I fixed this by not resetting the `countrySets` in our PlayingModel, but preserving it from the previous time. 