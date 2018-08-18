## Day 12

Quick review of day 11:

Went through the [JSON chapter](https://guide.elm-lang.org/interop/json.html). The new things were decoding JSON lists, and the [elm-decode-pipeline](http://package.elm-lang.org/packages/NoRedInk/elm-decode-pipeline/latest) package that helps decoding more complex objects (saves some typing).

Then I skimmed through the [JavaScript Interop chapter](https://guide.elm-lang.org/interop/javascript.html), but didn't focus on it, as I want to focus on learning Elm right now, and dive into interop when I actually need it.

Finally did some exercises that demonstrated how to break functions down into smaller parts with [Labeled Checkboxes example](https://guide.elm-lang.org/reuse/checkboxes.html) and [Radio Buttons example](https://guide.elm-lang.org/reuse/radio_buttons.html). There was really nothing new there.

One advice is worth remembering:

> You should only reach for a fancier tool when you feel you *need* it.

I think that's a great advice. There's no reason to optimize prematurely and there's no reason to try to architect things prematurely. This means, write a function first, and if it gets too big, break it down. Write everything in one file, and only if it gets too big, then break it down into modules. Refactoring is easy in Elm, allegedly, so rather err on the side of "refactor later" than try to do too much too soon.

---

Today we're gonna get into [Modules](https://guide.elm-lang.org/reuse/modules.html).

### When to use modules?

> If you have a 400 line file and notice that a bunch of code is all related to showing radio buttons in a certain way, it may be a good idea to move all the relevant functions and types into their own module.

That's a sound advice.

### How to write a module?

```
module Optional exposing (..)

type Optional a = Some a | None

isNone : Optional a -> Bool
isNone optional =
  case optional of
    Some _ ->
      False
    
    None ->
      True
```

Should look familiar, except for the first line, which is a module declaration, I suppose. This is where you name your module, e.g. "Optional", and declare which parts of this file should be exposed, e.g. everything `(..)`. Exposing everything is fine for prototyping, or when you *really* must expose everything, but often you'd want to expose only select functions and types, and that's when you can write something like:

```
module Optinal exposing ( Optional(..), isNone )
```
So the code above says: the module is named "Optional" and it exposes type "Optional", with all of its constructors ("Some" and "None"), as well as "isNone" function.

Basically you can hide implementation details using modules, by not exposing everything.

Note that if you don't add module declaration, then Elm will expose everything. Sounds like a bad idea, but the reason for that, apparently, is so that beginners wouldn't need to write module statements on their first day.

### Using modules in other files

We're already familiar with the `import` statement:
```
import Optional

noService : Optional.Optional a -> Optional.Optional a -> Bool
noService shoes shirt =
  Optional.isNone shoes && Optional.isNone shirt
```

Another option is to change the name of the imported module, to make it shorter, for example. We've seen this used with `Json.Decode` example somewhere earlier, where it was renamed to simply `Decode` to save some typing. Here's the optional example:
```
import Optional as Opt

noService : Opt.Optional a -> Opt.Optional a -> Bool
noService shoes shirt =
  Opt.isNone shoes && Opt.isNone shirt
```

Yet another option is to expose certain parts, for example:
```
import Optional exposing (Optional)
```
Then you can write `Optional a` instead of `Optional.Optional a`. However, to access other functions you'd still need to write `Optional.isNone`. You can explicitely expose multiple things:
```
import Optional exposing (Optional, isNone)
```
Or everything:
```
import Optional exposing (..)
```

You can also mix:
```
import Optional as Opt exposing (Optional)

noService : Optional a -> Optional a -> Bool
noService shoes shirt =
  Opt.isNone shoes && Opt.isNone shirt
```
The code above might be a bit confusing thought, because of using both `Optional` and `Opt`.

### Building projects with multiple modules

How does `elm-make` know where to find your modules? This is where the `elm-package.json` comes in:
```
{
  "version": "1.0.0",
  "summary": "summary of the project, less than 80 characters",
  "repository": "https://github.com/user/project.git",
  "license": "BSD3",
  "source-directories": [
    "src",
    "benchmarks/src"
  ],
  "exposed-modules": [],
  "dependencies": {
    "elm-lang/core": "4.0.2 <= v < 5.0.0",
    "elm-lang/html": "1.1.0 <= v < 2.0.0"
  },
  "elm-version": "0.17.0 <= v < 0.18.0"
}
```

Two important parts:
* `source-directories` -- this is where Elm will look for your modules.
* `dependencies` -- this is where Elm will look for community packages.

To build, just run:
```
cd my-project
elm-make src/Main.elm
```
and Elm will know where to find the imported modules using `elm-package.json` file.


The author finished the book by saying:

> If you find yourself repeating yourself, maybe break things out. If a function gets too big, make a helper function. If you see related things, maybe move them to a module. But at the end of the day, it is not a huge deal if you let things get big. Elm is great at finding problems and making refactors easy, so it is not actually a huge deal if you have a bunch of entires in your `Model` because it does not seem better to break them out in some way.

---

So we're done with the Elm book! What's next? I think I want to take time off from reading, and do some tiny Elm apps for some time, just to let this all sink in and get some practice. I'm sure there will be a ton of questions and confusing parts, so it will be a learning experience.

Later on, I have some Elm related blog posts and youtube videos to read/watch on my list, so, more learning to come!