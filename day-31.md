## Day 31

Quick review of day 30:

Yesterday I fixed a bug where `selectedSetName` would be an empty string by default, and pressing "Restart" at that point would cause an error, since there's no set selected. I argued that we can't force it to have a string using data types. However, now I'm thinking that I could make a module that would provide a combo box view and surrounding logic that would avoid all the Maybes. Let's see.

Then I inteded to upgrade the code to use `Browser.document`, but run into complications and basically continued trying to reduce the user of maybe types.

So I wrote a couple of modules that I thought would ease the pain. One for the list of countries, which is a kind of list that is guaranteed to have at least one value, thus eleminating the need for some checks.

Then I started working on a module that would be used to represent the data for the combo box, but it turned out that getting data back from the HTML element and updating this data type is as error prone as before.

---

So now I'm going to try to isolate the whole combo box into its own module, where it would use the `SelectedItemList` to hold the state, and would take care of getting the updated state back from the HTML element, providing sensible defaults if there's an error, which *should not happen*. I am hoping this would allow me to write main application code to have less Maybe checks.

So I wrote this code that selects an item in `SelectedItemList` based on of a `CountrySet` passed in. This is a very odd piece of code and I'm not particularly happy with it:

```
setSelectedSet : String -> SelectedItemList CountrySet -> SelectedItemList CountrySet
setSelectedSet setName (SelectedItemList selectedItemList) =
    let
        maybeList =
            maybeSetSelectedSet setName (SelectedItemList selectedItemList)
    in
    case maybeList.selectedItem_ of
        Nothing ->
            -- If unable to set new selected item, then just do nothing. No errors generated, because this should never happen. LOL.
            SelectedItemList selectedItemList

        Just newSelectedItem_ ->
            SelectedItemList
                { firstItems_ = maybeList.firstItems_
                , selectedItem_ = newSelectedItem_
                , lastItems_ = maybeList.lastItems_
                }


type alias MaybeSelectedItemList =
    { firstItems_ : List CountrySet
    , selectedItem_ : Maybe CountrySet
    , lastItems_ : List CountrySet
    }


maybeSetSelectedSet :
    String
    -> SelectedItemList CountrySet
    -> MaybeSelectedItemList
maybeSetSelectedSet setName (SelectedItemList selectedItemList) =
    List.foldl
        (\set ->
            \acc ->
                case acc.selectedItem_ of
                    Nothing ->
                        if set.name == setName then
                            MaybeSelectedItemList acc.firstItems_ (Just set) acc.lastItems_

                        else
                            MaybeSelectedItemList (acc.firstItems_ ++ [ set ]) Nothing acc.lastItems_

                    Just prevSelectedItem ->
                        MaybeSelectedItemList acc.firstItems_ (Just prevSelectedItem) (acc.lastItems_ ++ [ set ])
        )
        (MaybeSelectedItemList [] Nothing [])
        (toList (SelectedItemList selectedItemList))
```

Myeah... Well, let's see how that helps me in the main app code.

So now I want to edit the Main app, and instead of having `selectedSetName : String`, I'd have something like `countrySets: SelectedItemList CountrySet`. This would be updated whenever user chooses a new item from the combo box. Also the combo box would be updated whenever this list changes. 

One thing I don't like about this setup is that I mixed `CountrySet` into seemingly generic `SelectedItemList` module.

Will continue with this tomorrow.