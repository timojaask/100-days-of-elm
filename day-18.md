## Day 18

Quick review of day 17:

Updated some more Elm guide code examples to Elm version 0.19. There were a few interesting bits, like that `Browser` API, the new `Html.Attributes.style` format, "Human time", "POSIX time", "Time zones", and `Url.Builder` API.

One thing I learned is that you still can't change `<body>` tag attributes in Elm, even though the new `Browser.document` function allows us to embed Elm code directly into the body of the document and set a page title.

However, there are ways to set body background color using `elm-css`, if so desired. However, the library is not yet released for 0.19.

---

Today I was waching some very interesting YouTube videos from Elm Conf and Elm Europe conferences.

First one is [The life of a file by Evan Czaplicki](https://www.youtube.com/watch?v=XpDsk374LDE).

Evan starts off by observing two things that he thinks people in JavaScript community do:
- "Prefer shorter files"
- "Get architecture right from the start or you're doomed"

And then he tries to see why are these the case. In case of shorter files, he says that as a JavaScript file grows in size, the probability of having one thing sneakily mutating something else grows, until the point when it eventually happens. So to avoid that, it's a good idea to write short files. In case of getting the architecture right, he claims that this should be obvious if we're into JS world, because from his experience and experience of some other people, refactoring JavaScript to use a different architecture is very brittle, and sometimes it's even easier to start from scratch than to attempt it.

But in Elm, these two points are no longer valid. There is obviously no probability of any mutation happening ever, so that's easy to rule out. And Elm allegedly makes it very easy to do big refactors safely, hence, you don't need to worry about getting the architecture right upfront. This is interesting, because in [another talk](https://www.youtube.com/watch?v=x1FU3e0sT1I), Richard Feldman says that it's still better to get the data models right from the start, because even though the refactoring is not as terrifying as in JS, it is still not free, and you'd rather think about the data model structure before building the rest of the app.

Then Evan goes throguh a life of a file example, where he starts off with a relatively small file, 200 lines of code. Then it grows to 400, at which point many people would start panicking. Then it grows to 600, at which point people might say "Okay, this is crazy, we need to break it down", but Evan claims that it's not the case with Elm or many other functional programming languages. In fact, this is a pretty regular file size.

Then, at some point, he would find that he can split his data stricture into two pieces and his code would grow around those two data structures. At this point, he might decide to split it into two files, one for each data structure and the code related to it. This is the usual way he does things.

He suggests that if you're writing code and you start having a feeling that it's too long, just stop and look into it. Is it really a problem, or is it something you got used to from other languages?

His thought process of choosing the right data structure to represent a piece of UI is very nice. There's an example of a "Settings" view, with three checkboxes:
* Email Notifications
* Video Autoplay
* Use Location
The way he approaches figuring out a data structure is by first listing all the possible ways he can represent this as data. He came up with four:
- A record `{ email: Bool, autoplay: Bool, location: Bool }`
- A list of tuples `List (String, Bool)`
- A dictionary `Dict String Bool`
- A list and a set `(List String, Set String)`
Next, he went thoguht each and listed pros & cons of each:
- A record `{ email: Bool, autoplay: Bool, location: Bool }`
  - Typed (Good)
  - Order determined by view (Good)
- A list of tuples `List (String, Bool)`
  - Stringly typed (Bad)
  - Order is stable (Neutral)
- A dictionary `Dict String Bool`
  - Stringly typed (Bad)
  - Order depends on keys (Bad)
- A list and a set `(List String, Set String)`
  - Stringly typed (Bad)
  - Order is stable (Neutral)

So from here we can see a clear winner -- the record.

Another nice part is on how to make it impossible to put your model into some weird state. Let's say that the new requirement is to show two new checkboxes when "Video Autoplay" is checked:
* Email Notifications
* Video Autoplay
  * Play Audio
  * Wifi Only
* Use Location
We could build it into the model like this:
```
type alias Model =
  { email : Bool
  , autoplay : Bool
  , autoplayAudio : Bool
  , autoplayWithoutWifi : Bool
  , location : Bool
  }
```
But then your state could potentially be in a weird state, where `autoplay` is `False` and `autoplayAudio` is `True`, which should not be allowed. Basically, you'd have to make sure in your logic and the UI that this wouldn't ever happen. However, instead, we could build our data model so that this would never be possible:
```
type alias Model =
  { email : Bool
  , autoplay : Autoplay
  , location : Bool
  }

type Autoplay = Off | On { audio : Bool, withoutWifi : Bool }
```
A lot nicer! Now it's basically impossible, and whoever is using this code is forced to make it work right.
However, this comes with a usability issue, where if user first checks `audio`, but then toggles `autoplay` off and on, they will lose the `audio` state, and will have to check it again. So in this case, we'd probably better keeping the state of all checkboxes anyway:
```
type alias Model =
  { email : Bool
  , autoplay : Autoplay
  , location : Bool
  }

type Autoplay = Off AutoplaySettings | On AutoplaySettings

type alias AutoplaySettings = { audio : Bool, withoutWifi : Bool }
```
Now, while it's technically possible to display the autoplay settings when it's in `Off` state, it would kinda make no sense, and we'd probably not do that mistake, since we would explicitely handle the `Off` and `On` states in our view code.
We would also probably build some functions around this model to help working with it, so this piece of data and the related functions could potentially go into their own module eventually. This is the idea of organizing your code around data structures.

Then Evan goes through another checkbox example, which is visually very similar, it's just a list of checkboxes with fruit names on them, for a fruit delivery service. However, the requirements are different. This time, the fruits might change based on daily availability, so using a record to represent each item is ruled out, since we don't wanna ship a new record every time the fruits change. This is why it's wise to consider different data structures for each case, even if the UI looks the same! This time he went with `(List String, Set String)` instead. So the model looks like this:
```
type alias Model =
  { fruits : List String
  , selected : Set String
  }

initialModel =
  { fruits = [ "Apple", "Banan", "Mango", "Apricot" ] -- Can be loaded from a server
  , selected = Set.empty
  }
```

Another interesting problem comes when the requirements change to restrict number of selections to maximum two fruits -- or some other number! And it has to be so that if user keeps clicking on different fruits, it would check the newest one, and uncheck the oldest checked (FIFO). In this case, it would be not possible to keep track of the order of selection using `Set`, becauae it simply doesn't have the information on which fruit was added first and which second. Again, it's good to look at possible data structures we can use to represent this:
- `(String, String)`: this is ok if we have two fruits, but if we have none selected yet, this doesn't work. And obviously not for more than two, if requirements change.
- `(Maybe String, Maybe String)`: this is better, becuse it allows us to represent less than two, but other issue still applies, and if only one is selected, we don't know if it's first or second.
- `type Two a = Zero | One a | Two a a`: Here if only one is selected, it's now clear, which one is it (`One a`), but the problem with changing requirements still applies.
- `List String`: Here the problem is that you can just add 20 things to it when only two was allowed, but "it has potential, so let's explore that route". Ok.

So how would selection actually be implemented, given we can only select up to two fruits? This is a neat solution:
```
update msg model =
  case msg of
    Select fruit ->
      { model | selected = List.take 2 (fruit :: model.selected) }
    
    Deselect fruit ->
      { model | selected = List.filter (\f -> f /= fruit) model.selected }
```
We can also simplify that a little bit with helper functions:
```
insert fruit list =
  List.take 2 (fruit :: list)

remove fruit list =
  List.filter (\f -> f /= fruit) list
```

So we can start breaking this into its own thing:
```
type alias SelectedFruit = List String

insert fruit list =
  List.take 2 (fruit :: list)

remove fruit list =
  List.filter (\f -> f /= fruit) list
```

---

My time for today has run out, so I'll continue with this tomorrow.