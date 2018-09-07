module Main exposing (Country, CountrySet)

import Browser
import Debug
import Html exposing (Attribute, Html, button, div, form, input, option, select, text)
import Html.Attributes exposing (style, type_, value)
import Html.Events exposing (onInput, onSubmit)


main =
    Browser.sandbox { init = init, view = view, update = update }


type Model
    = LoadingCountries
    | LoadingCountriesError String
    | LoadedCountries (List Country)
    | ParsingCountriesError String
    | Playing PlayingModel


type alias Country =
    { id : Int
    , names : List String
    , continents : List Int
    , neighbors : List Int
    }


type alias CountrySet =
    { id : Int
    , name : String
    }


type alias PlayingModel =
    { quiz : Quiz
    , answerInputValue : String
    }


type alias Quiz =
    { playedCountries : List Country
    , currentCountry : Country
    , nextCountries : List Country
    , neighborsGuessed : List Int
    , neighborsLeft : List Int
    }


init : Model
init =
    let
        maybeQuiz =
            initQuizWithCountries countries
    in
    case maybeQuiz of
        Nothing ->
            ParsingCountriesError "Failed to parse countries"

        Just quiz ->
            Playing (PlayingModel quiz "")


initQuiz : Country -> List Country -> Quiz
initQuiz firstCountry nextCountries =
    Quiz [] firstCountry nextCountries [] firstCountry.neighbors


initQuizWithCountries : List Country -> Maybe Quiz
initQuizWithCountries countriesList =
    let
        result =
            ( List.head countriesList, List.tail countriesList )
    in
    case result of
        ( Nothing, _ ) ->
            Nothing

        ( _, Nothing ) ->
            Nothing

        ( Just first, Just rest ) ->
            Just (initQuiz first rest)


type Msg
    = AnswerInputFormSubmitted
    | AnswerInputTextChanged String


answerToNeighborId : Quiz -> String -> Maybe Int
answerToNeighborId quiz answer =
    List.head
        (List.filter
            (\neighborId ->
                let
                    maybeCountry =
                        countryById neighborId
                in
                case maybeCountry of
                    Nothing ->
                        False

                    Just country ->
                        List.any
                            (\countryName ->
                                String.toLower countryName
                                    == String.toLower answer
                            )
                            country.names
            )
            quiz.neighborsLeft
        )


removeIdFromList : List Int -> Int -> List Int
removeIdFromList list id =
    List.filter
        (\neighborId ->
            neighborId /= id
        )
        list


update : Msg -> Model -> Model
update msg model =
    case model of
        LoadingCountries ->
            LoadedCountries countries

        LoadingCountriesError errorMessage ->
            model

        LoadedCountries countriesList ->
            let
                maybeQuiz =
                    initQuizWithCountries countriesList
            in
            case maybeQuiz of
                Nothing ->
                    ParsingCountriesError "Failed to parse countries"

                Just quiz ->
                    Playing (PlayingModel quiz "")

        ParsingCountriesError errorMessage ->
            model

        Playing playingModel ->
            case msg of
                AnswerInputTextChanged str ->
                    Playing { playingModel | answerInputValue = str }

                AnswerInputFormSubmitted ->
                    let
                        answerNeighborId =
                            answerToNeighborId playingModel.quiz playingModel.answerInputValue
                    in
                    case answerNeighborId of
                        Nothing ->
                            -- Incorrect guess
                            Playing playingModel

                        Just neighborId ->
                            -- Correct guess
                            let
                                oldQuiz =
                                    playingModel.quiz

                                updatedNeighborsLeft =
                                    removeIdFromList oldQuiz.neighborsLeft neighborId
                            in
                            if List.length updatedNeighborsLeft == 0 then
                                -- Guessed all the neighbors of current country
                                let
                                    updatedPlayedCountries =
                                        oldQuiz.currentCountry :: oldQuiz.playedCountries

                                    maybeUpdatedCurrentCountry =
                                        List.head oldQuiz.nextCountries

                                    maybeUpdatedNextCountries =
                                        List.tail oldQuiz.nextCountries
                                in
                                case ( maybeUpdatedCurrentCountry, maybeUpdatedNextCountries ) of
                                    ( Just updatedCurrentCountry, Just updatedNextCountries ) ->
                                        -- Still countries to play
                                        let
                                            updatedQuiz =
                                                { oldQuiz
                                                    | playedCountries = updatedPlayedCountries
                                                    , currentCountry = updatedCurrentCountry
                                                    , nextCountries = updatedNextCountries
                                                    , neighborsGuessed = []
                                                    , neighborsLeft = updatedCurrentCountry.neighbors
                                                }
                                        in
                                        Playing
                                            { playingModel
                                                | quiz = updatedQuiz
                                                , answerInputValue = ""
                                            }

                                    ( _, _ ) ->
                                        -- Game over! No more countries
                                        let
                                            updatedQuiz =
                                                { oldQuiz
                                                    | neighborsGuessed = neighborId :: oldQuiz.neighborsGuessed
                                                    , neighborsLeft = updatedNeighborsLeft
                                                }
                                        in
                                        Playing
                                            { playingModel
                                                | quiz = updatedQuiz
                                                , answerInputValue = ""
                                            }

                            else
                                -- Still neighbors left to guess
                                let
                                    updatedQuiz =
                                        { oldQuiz
                                            | neighborsGuessed = neighborId :: oldQuiz.neighborsGuessed
                                            , neighborsLeft = updatedNeighborsLeft
                                        }
                                in
                                Playing
                                    { playingModel
                                        | quiz = updatedQuiz
                                        , answerInputValue = ""
                                    }



{-
   type alias Quiz =
       { playedCountries : List Country
       , currentCountry : Country
       , nextCountries : List Country
       , neighborsGuessed : List Int
       , neighborsLeft : List Int
       }
-}


view : Model -> Html Msg
view model =
    case model of
        LoadingCountries ->
            viewLoading "LoadingCountries"

        LoadingCountriesError errorMessage ->
            viewError errorMessage

        LoadedCountries _ ->
            viewLoading "LoadedCountries"

        ParsingCountriesError errorMessage ->
            viewError errorMessage

        Playing playingModel ->
            viewQuiz playingModel


viewLoading : String -> Html msg
viewLoading loadingMessage =
    div [] [ text loadingMessage ]


viewError : String -> Html msg
viewError errorMessage =
    div [] [ text errorMessage ]


viewQuiz : PlayingModel -> Html Msg
viewQuiz { quiz, answerInputValue } =
    let
        styleQuizDiv =
            [ style "display" "flex"
            , style "flex-direction" "column"
            ]
    in
    div styleQuizDiv
        [ text ("Neighbors of " ++ currentCountryName quiz.currentCountry)
        , viewCheat quiz
        , viewAnswerInput answerInputValue
        , viewCurrentCountryProgress quiz
        , viewOverallProgress quiz
        , viewMenu
        ]


stringListToCommaSeparated : List String -> String
stringListToCommaSeparated list =
    List.foldl
        (\strVal ->
            \acc ->
                acc
                    ++ (if acc == "" then
                            ""

                        else
                            ", "
                       )
                    ++ strVal
        )
        ""
        list


idListToCountryNameList : List Int -> List String
idListToCountryNameList idList =
    List.map
        (\id ->
            countryFirstNameById id
        )
        idList


viewCheat : Quiz -> Html msg
viewCheat quiz =
    div []
        [ text
            ("("
                ++ stringListToCommaSeparated (idListToCountryNameList quiz.neighborsLeft)
                ++ ")"
            )
        ]


viewAnswerInput : String -> Html Msg
viewAnswerInput val =
    form [ onSubmit AnswerInputFormSubmitted ]
        [ input [ type_ "text", onInput AnswerInputTextChanged, value val ] []
        ]


viewCurrentCountryProgress : Quiz -> Html msg
viewCurrentCountryProgress quiz =
    div []
        [ text
            ("( "
                ++ String.fromInt (List.length quiz.neighborsGuessed)
                ++ " / "
                ++ String.fromInt (List.length quiz.neighborsLeft)
                ++ " ) "
                ++ countryIdsToString quiz.neighborsGuessed
            )
        ]


viewOverallProgress : Quiz -> Html msg
viewOverallProgress quiz =
    let
        numCompleted =
            List.length quiz.playedCountries

        numLeft =
            List.length quiz.nextCountries + 1
    in
    div []
        [ text
            ("Overall progress: "
                ++ String.fromInt numCompleted
                ++ " / "
                ++ String.fromInt numLeft
            )
        ]


viewMenu : Html Msg
viewMenu =
    div []
        [ button [] [ text "Restart" ]
        , select []
            viewCountrySetOptions
        ]


viewCountrySetOptions : List (Html Msg)
viewCountrySetOptions =
    List.map
        (\set ->
            option [] [ text set.name ]
        )
        continents


currentCountryName : Country -> String
currentCountryName country =
    case List.head country.names of
        Nothing ->
            ""

        Just name ->
            name


continentById : Int -> Maybe CountrySet
continentById id =
    List.head
        (List.filter
            (\continent -> continent.id == id)
            continents
        )


countryById : Int -> Maybe Country
countryById id =
    List.head
        (List.filter
            (\country -> country.id == id)
            countries
        )


continentNameById : Int -> String
continentNameById id =
    case continentById id of
        Nothing ->
            ""

        Just continent ->
            continent.name


countryFirstNameById : Int -> String
countryFirstNameById id =
    case countryById id of
        Nothing ->
            ""

        Just country ->
            case List.head country.names of
                Nothing ->
                    ""

                Just name ->
                    name


continentIdsToString : List Int -> String
continentIdsToString idList =
    List.foldl
        (\id ->
            \acc ->
                acc ++ continentNameById id ++ ", "
        )
        ""
        idList


countryIdsToString : List Int -> String
countryIdsToString idList =
    List.foldl
        (\id ->
            \acc ->
                acc ++ countryFirstNameById id ++ ", "
        )
        ""
        idList


countryToHtml : Country -> Html msg
countryToHtml country =
    let
        id =
            country.id

        maybeName =
            List.head country.names

        countryContinents =
            continentIdsToString country.continents

        countryNeighbors =
            countryIdsToString country.neighbors
    in
    case maybeName of
        Nothing ->
            div [] [ text "LOL" ]

        Just name ->
            div []
                [ div []
                    [ text
                        (String.fromInt id
                            ++ " "
                            ++ name
                        )
                    , div
                        []
                        [ text
                            ("Continents: "
                                ++ countryContinents
                            )
                        ]
                    , div
                        []
                        [ text
                            ("Neighbors: "
                                ++ countryNeighbors
                            )
                        ]
                    ]
                ]


allCountriesToHtml : List Country -> Html msg
allCountriesToHtml countryList =
    div []
        (List.map
            (\country ->
                div
                    [ style "margin" "15px" ]
                    [ countryToHtml country ]
            )
            countryList
        )


continents : List CountrySet
continents =
    [ CountrySet 0 "Asia"
    , CountrySet 1 "Africa"
    , CountrySet 2 "Antarctica"
    , CountrySet 3 "Oceania"
    , CountrySet 4 "Europe"
    , CountrySet 5 "North America"
    , CountrySet 6 "South America"
    ]


countries : List Country
countries =
    [ Country 0 [ "Afghanistan" ] [ 0 ] [ 31, 70, 112, 142, 148, 155 ]
    , Country 1 [ "Albania" ] [ 4 ] [ 92, 101, 60, 80 ]
    , Country 2 [ "Algeria" ] [ 1 ] [ 88, 95, 96, 102, 108, 146, 159 ]
    , Country 3 [ "Andorra" ] [ 4 ] [ 53, 134 ]
    , Country 4 [ "Angola" ] [ 1 ] [ 34, 35, 104, 161 ]
    , Country 5 [ "Argentina" ] [ 6 ] [ 15, 18, 30, 116, 154 ]
    , Country 6 [ "Armenia" ] [ 0, 4 ] [ 8, 57, 70, 147 ]
    , Country 7 [ "Austria" ] [ 4 ] [ 40, 58, 67, 74, 89, 129, 130, 139 ]
    , Country 8 [ "Azerbaijan" ] [ 0, 4 ] [ 6, 57, 70, 122, 147 ]
    , Country 9 [ "Bangladesh" ] [ 0 ] [ 22, 68 ]
    , Country 10 [ "Belarus" ] [ 4 ] [ 84, 90, 118, 122, 150 ]
    , Country 11 [ "Belgium" ] [ 4 ] [ 53, 58, 91, 106 ]
    , Country 12 [ "Belize" ] [ 5 ] [ 61, 97 ]
    , Country 13 [ "Benin" ] [ 1 ] [ 21, 108, 109, 145 ]
    , Country 14 [ "Bhutan" ] [ 0 ] [ 31, 68 ]
    , Country 15 [ "Bolivia" ] [ 6 ] [ 5, 18, 30, 116, 117 ]
    , Country 16 [ "Bosnia", "Bosnia and Herzegovina", "Bosnia & Herzegovina" ] [ 4 ] [ 38, 101, 127 ]
    , Country 17 [ "Botswana" ] [ 1 ] [ 104, 132, 161, 162 ]
    , Country 18 [ "Brazil" ] [ 6 ] [ 5, 15, 32, 64, 116, 117, 136, 154, 157 ]
    , Country 19 [ "Brunei Darussalam", "Brunei" ] [ 0 ] [ 94 ]
    , Country 20 [ "Bulgaria" ] [ 4 ] [ 60, 92, 121, 127, 147 ]
    , Country 21 [ "Burkina Faso" ] [ 1 ] [ 13, 37, 59, 95, 108, 145 ]
    , Country 22 [ "Burma", "Myanmar" ] [ 0 ] [ 9, 31, 68, 83, 144 ]
    , Country 23 [ "Burundi" ] [ 1 ] [ 34, 123, 143 ]
    , Country 24 [ "Cambodia" ] [ 0 ] [ 83, 144, 158 ]
    , Country 25 [ "Cameroon" ] [ 1 ] [ 28, 29, 35, 48, 54, 109 ]
    , Country 26 [ "Canada" ] [ 5 ] [ 153 ]
    , Country 28 [ "Central African Republic", "CAR" ] [ 1 ] [ 25, 29, 34, 35, 133, 135 ]
    , Country 29 [ "Chad" ] [ 1 ] [ 25, 28, 88, 108, 109, 135 ]
    , Country 30 [ "Chile" ] [ 6 ] [ 5, 15, 117 ]
    , Country 31 [ "China" ] [ 0 ] [ 0, 14, 22, 68, 76, 78, 82, 83, 100, 105, 112, 122, 142, 158 ]
    , Country 32 [ "Colombia" ] [ 6 ] [ 18, 45, 114, 117, 157 ]
    , Country 34 [ "Democratic Republic of the Congo", "DRC", "DR Congo" ] [ 1 ] [ 4, 23, 28, 35, 123, 133, 149, 161 ]
    , Country 35 [ "Republic of the Congo", "Congo" ] [ 1 ] [ 4, 25, 28, 34, 54 ]
    , Country 36 [ "Costa Rica" ] [ 5 ] [ 107, 114 ]
    , Country 37 [ "Ivory Coast", "Cote d'Ivoire", "CÃ´te d'Ivoire" ] [ 1 ] [ 21, 59, 62, 87, 95 ]
    , Country 38 [ "Croatia" ] [ 4 ] [ 16, 67, 101, 127, 130 ]
    , Country 40 [ "Czech Republic" ] [ 4 ] [ 7, 58, 118, 129 ]
    , Country 41 [ "Denmark" ] [ 4 ] [ 58 ]
    , Country 42 [ "Djibouti" ] [ 1 ] [ 49, 51, 131 ]
    , Country 43 [ "Dominican Republic" ] [ 5 ] [ 65 ]
    , Country 44 [ "East Timor", "Timor-Leste", "Democratic Republic of Timor-Leste" ] [ 0 ] [ 69 ]
    , Country 45 [ "Ecuador" ] [ 6 ] [ 32, 117 ]
    , Country 46 [ "Egypt" ] [ 0, 1 ] [ 73, 88, 135 ]
    , Country 47 [ "El Salvador" ] [ 5 ] [ 61, 66 ]
    , Country 48 [ "Equatorial Guinea" ] [ 1 ] [ 25, 54 ]
    , Country 49 [ "Eritrea" ] [ 1 ] [ 42, 51, 135 ]
    , Country 50 [ "Estonia" ] [ 4 ] [ 84, 122 ]
    , Country 51 [ "Ethiopia" ] [ 1 ] [ 42, 49, 77, 131, 133, 135 ]
    , Country 52 [ "Finland" ] [ 4 ] [ 110, 138, 122 ]
    , Country 53 [ "France" ] [ 4 ] [ 3, 11, 58, 74, 91, 99, 134, 139 ]
    , Country 54 [ "Gabon" ] [ 1 ] [ 25, 35, 48 ]
    , Country 55 [ "The Gambia", "Republic of the Gambia" ] [ 1 ] [ 126 ]
    , Country 57 [ "Georgia" ] [ 0, 4 ] [ 6, 8, 122, 147 ]
    , Country 58 [ "Germany" ] [ 4 ] [ 7, 11, 40, 41, 53, 91, 106, 118, 139 ]
    , Country 59 [ "Ghana" ] [ 1 ] [ 21, 37, 145 ]
    , Country 60 [ "Greece" ] [ 4 ] [ 1, 20, 147, 92 ]
    , Country 61 [ "Guatemala" ] [ 5 ] [ 12, 47, 66, 97 ]
    , Country 62 [ "Guinea" ] [ 1 ] [ 37, 63, 87, 95, 126, 128 ]
    , Country 63 [ "Guinea-Bissau" ] [ 1 ] [ 62, 126 ]
    , Country 64 [ "Guyana" ] [ 6 ] [ 18, 136, 157 ]
    , Country 65 [ "Haiti" ] [ 5 ] [ 43 ]
    , Country 66 [ "Honduras" ] [ 5 ] [ 61, 47, 107 ]
    , Country 67 [ "Hungary" ] [ 4 ] [ 7, 38, 121, 127, 129, 130, 150 ]
    , Country 68 [ "India" ] [ 0 ] [ 0, 9, 14, 22, 31, 105, 112 ]
    , Country 69 [ "Indonesia" ] [ 0 ] [ 44, 94, 115 ]
    , Country 70 [ "Iran" ] [ 0 ] [ 0, 6, 8, 71, 112, 147, 148 ]
    , Country 71 [ "Iraq" ] [ 0 ] [ 70, 75, 81, 125, 140, 147 ]
    , Country 72 [ "Ireland" ] [ 4 ] [ 152 ]
    , Country 73 [ "Israel" ] [ 0 ] [ 46, 75, 85, 140 ]
    , Country 74 [ "Italy" ] [ 4 ] [ 7, 53, 124, 130, 139, 156 ]
    , Country 75 [ "Jordan" ] [ 0 ] [ 71, 73, 125, 140 ]
    , Country 76 [ "Kazakhstan" ] [ 0, 4 ] [ 31, 82, 122, 148, 155 ]
    , Country 77 [ "Kenya" ] [ 1 ] [ 51, 131, 133, 143, 149 ]
    , Country 78 [ "North Korea" ] [ 0 ] [ 31, 79, 122 ]
    , Country 79 [ "South Korea" ] [ 0 ] [ 78 ]
    , Country 80 [ "Kosovo" ] [ 4 ] [ 1, 92, 101, 127 ]
    , Country 81 [ "Kuwait" ] [ 0 ] [ 71, 125 ]
    , Country 82 [ "Kyrgyzstan" ] [ 0 ] [ 31, 76, 142, 155 ]
    , Country 83 [ "Laos" ] [ 0 ] [ 22, 24, 31, 144, 158 ]
    , Country 84 [ "Latvia" ] [ 4 ] [ 10, 50, 90, 122 ]
    , Country 85 [ "Lebanon" ] [ 0 ] [ 73, 140 ]
    , Country 86 [ "Lesotho" ] [ 1 ] [ 132 ]
    , Country 87 [ "Liberia" ] [ 1 ] [ 62, 37, 128 ]
    , Country 88 [ "Libya" ] [ 1 ] [ 2, 29, 46, 108, 135, 146 ]
    , Country 89 [ "Liechtenstein" ] [ 4 ] [ 7, 139 ]
    , Country 90 [ "Lithuania" ] [ 4 ] [ 10, 84, 118, 122 ]
    , Country 91 [ "Luxembourg" ] [ 4 ] [ 11, 53, 58 ]
    , Country 92 [ "Macedonia" ] [ 4 ] [ 1, 20, 60, 80, 127 ]
    , Country 93 [ "Malawi" ] [ 1 ] [ 103, 143, 161 ]
    , Country 94 [ "Malaysia" ] [ 0 ] [ 19, 69, 144 ]
    , Country 95 [ "Mali" ] [ 1 ] [ 2, 21, 62, 37, 96, 108, 126 ]
    , Country 96 [ "Mauritania" ] [ 1 ] [ 2, 95, 126, 159 ]
    , Country 97 [ "Mexico" ] [ 5 ] [ 12, 61, 153 ]
    , Country 98 [ "Moldova" ] [ 4 ] [ 121, 150 ]
    , Country 99 [ "Monaco" ] [ 4 ] [ 53 ]
    , Country 100 [ "Mongolia" ] [ 0 ] [ 31, 122 ]
    , Country 101 [ "Montenegro" ] [ 4 ] [ 1, 16, 38, 80, 127 ]
    , Country 102 [ "Morocco" ] [ 1 ] [ 2, 159, 134 ]
    , Country 103 [ "Mozambique" ] [ 1 ] [ 93, 132, 137, 143, 161, 162 ]
    , Country 104 [ "Namibia" ] [ 1 ] [ 4, 17, 132, 161 ]
    , Country 105 [ "Nepal" ] [ 0 ] [ 31, 68 ]
    , Country 106 [ "Netherlands" ] [ 4 ] [ 11, 58 ]
    , Country 107 [ "Nicaragua" ] [ 5 ] [ 36, 66 ]
    , Country 108 [ "Niger" ] [ 1 ] [ 2, 13, 21, 29, 88, 95, 109 ]
    , Country 109 [ "Nigeria" ] [ 1 ] [ 13, 25, 29, 108 ]
    , Country 110 [ "Norway" ] [ 4 ] [ 52, 138, 122 ]
    , Country 111 [ "Oman" ] [ 0 ] [ 125, 151, 160 ]
    , Country 112 [ "Pakistan" ] [ 0 ] [ 0, 31, 68, 70 ]
    , Country 114 [ "Panama" ] [ 5 ] [ 32, 36 ]
    , Country 115 [ "Papua New Guinea" ] [ 3 ] [ 69 ]
    , Country 116 [ "Paraguay" ] [ 6 ] [ 5, 15, 18 ]
    , Country 117 [ "Peru" ] [ 6 ] [ 15, 18, 30, 32, 45 ]
    , Country 118 [ "Poland" ] [ 4 ] [ 10, 40, 58, 90, 122, 129, 150 ]
    , Country 119 [ "Portugal" ] [ 4 ] [ 134 ]
    , Country 120 [ "Qatar" ] [ 0 ] [ 125 ]
    , Country 121 [ "Romania" ] [ 4 ] [ 20, 67, 98, 127, 150 ]
    , Country 122 [ "Russia" ] [ 0, 4 ] [ 8, 10, 31, 50, 52, 57, 76, 78, 84, 90, 100, 110, 118, 150 ]
    , Country 123 [ "Rwanda" ] [ 1 ] [ 23, 34, 143, 149 ]
    , Country 124 [ "San Marino" ] [ 4 ] [ 74 ]
    , Country 125 [ "Saudi Arabia" ] [ 0 ] [ 71, 75, 81, 111, 120, 151, 160 ]
    , Country 126 [ "Senegal" ] [ 1 ] [ 55, 62, 63, 95, 96 ]
    , Country 127 [ "Serbia" ] [ 4 ] [ 16, 20, 38, 67, 80, 92, 101, 121 ]
    , Country 128 [ "Sierra Leone" ] [ 1 ] [ 62, 87 ]
    , Country 129 [ "Slovakia" ] [ 4 ] [ 7, 40, 67, 118, 150 ]
    , Country 130 [ "Slovenia" ] [ 4 ] [ 7, 38, 74, 67 ]
    , Country 131 [ "Somalia" ] [ 1 ] [ 42, 51, 77 ]
    , Country 132 [ "South Africa" ] [ 1 ] [ 17, 86, 103, 104, 137, 162 ]
    , Country 133 [ "South Sudan" ] [ 1 ] [ 28, 34, 51, 77, 135, 149 ]
    , Country 134 [ "Spain" ] [ 4 ] [ 3, 53, 119, 102 ]
    , Country 135 [ "Sudan" ] [ 1 ] [ 28, 29, 46, 49, 51, 88, 133 ]
    , Country 136 [ "Suriname" ] [ 6 ] [ 18, 64 ]
    , Country 137 [ "Swaziland" ] [ 1 ] [ 103, 132 ]
    , Country 138 [ "Sweden" ] [ 4 ] [ 52, 110 ]
    , Country 139 [ "Switzerland" ] [ 4 ] [ 7, 53, 74, 89, 58 ]
    , Country 140 [ "Syria" ] [ 0 ] [ 71, 73, 75, 85, 147 ]
    , Country 142 [ "Tajikistan" ] [ 0 ] [ 0, 31, 82, 155 ]
    , Country 143 [ "Tanzania" ] [ 1 ] [ 23, 34, 77, 93, 103, 123, 149, 161 ]
    , Country 144 [ "Thailand" ] [ 0 ] [ 22, 24, 83, 94 ]
    , Country 145 [ "Togo" ] [ 1 ] [ 13, 21, 59 ]
    , Country 146 [ "Tunisia" ] [ 1 ] [ 2, 88 ]
    , Country 147 [ "Turkey" ] [ 0, 4 ] [ 6, 8, 20, 57, 60, 70, 71, 140 ]
    , Country 148 [ "Turkmenistan" ] [ 0 ] [ 0, 70, 76, 155 ]
    , Country 149 [ "Uganda" ] [ 1 ] [ 34, 77, 123, 133, 143 ]
    , Country 150 [ "Ukraine" ] [ 4 ] [ 10, 67, 98, 118, 121, 122, 129 ]
    , Country 151 [ "United Arab Emirates" ] [ 0 ] [ 111, 125 ]
    , Country 152 [ "United Kingdom", "UK" ] [ 4 ] [ 72 ]
    , Country 153 [ "United States", "USA", "US", "United States of America" ] [ 5 ] [ 26, 97 ]
    , Country 154 [ "Uruguay" ] [ 6 ] [ 5, 18 ]
    , Country 155 [ "Uzbekistan" ] [ 0 ] [ 0, 76, 82, 142, 148 ]
    , Country 156 [ "Vatican City", "Vatican" ] [ 4 ] [ 74 ]
    , Country 157 [ "Venezuela" ] [ 6 ] [ 18, 32, 64 ]
    , Country 158 [ "Vietnam" ] [ 0 ] [ 24, 31, 83 ]
    , Country 159 [ "Western Sahara" ] [ 1 ] [ 2, 96, 102 ]
    , Country 160 [ "Yemen" ] [ 0 ] [ 111, 125 ]
    , Country 161 [ "Zambia" ] [ 1 ] [ 4, 17, 34, 93, 103, 104, 143, 162 ]
    , Country 162 [ "Zimbabwe" ] [ 1 ] [ 17, 103, 132, 161 ]
    ]
