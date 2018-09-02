type alias User =
  { name : String
  , age : Maybe Int
  }

sue : User
sue = { name = "Sue", age = Nothing }

tom : User
tom = { name = "Tom", age = Just 24 }

alice = User "Alice" (Just 14)
bob = User "Bob" (Just 16)

canBuyAlcohol : User -> Bool
canBuyAlcohol user =
  case user.age of
    Nothing ->
      False

    Just age -> 
      age > 21

getTeenAge : User -> Maybe Int
getTeenAge user =
  case user.age of
    Nothing -> Nothing
    Just age ->
      if 13 <= age && age <= 18 then
        Just age
      else
        Nothing

teenAges = List.filterMap getTeenAge [sue, tom, alice, bob]