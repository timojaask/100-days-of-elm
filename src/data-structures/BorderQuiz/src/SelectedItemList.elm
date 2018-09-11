module SelectedItemList exposing (CountrySet, SelectedItemList, init, map, selectedItem, setSelectedSet, toList)


type alias CountrySet =
    { id : Int
    , name : String
    }


type SelectedItemList a
    = SelectedItemList
        { firstItems_ : List a
        , selectedItem_ : a
        , lastItems_ : List a
        }


init : List a -> a -> List a -> SelectedItemList a
init firstItems_ selectedItem_ lastItems_ =
    SelectedItemList
        { firstItems_ = firstItems_
        , selectedItem_ = selectedItem_
        , lastItems_ = lastItems_
        }


selectedItem : SelectedItemList a -> a
selectedItem (SelectedItemList selectedItemList) =
    selectedItemList.selectedItem_


toList : SelectedItemList a -> List a
toList (SelectedItemList { firstItems_, selectedItem_, lastItems_ }) =
    firstItems_ ++ (selectedItem_ :: lastItems_)


map : (Bool -> a -> b) -> SelectedItemList a -> List b
map fn (SelectedItemList { firstItems_, selectedItem_, lastItems_ }) =
    List.map (fn False) firstItems_
        ++ (fn True selectedItem_
                :: List.map (fn False) lastItems_
           )


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
