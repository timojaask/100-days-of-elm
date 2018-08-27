## Day 15

Quick review of day 14:

Yesterday I spent time trying to figure out how to bundle images in an Elm project, but realized it was not all that straight forward. So I decided to write a document covering [the issues I had with building an Elm project](./issues-with-elm.md). The issues I listed were:

- Styling the `body` element of the document, because it was not directly accessible by Elm.
- Build and deployment tools -- challenges using Elm with third part CI, looked at various Elm starter scripts, none if which appealed to me at the time.
- Bundling images -- there was no clear way of doing it.

And I concluded the day by saying that next time I'm going to go through each issue and find different solutions to them.

---

Now today, something incredible happened. Elm 0.19 came out, the official docs were revamped, and it looks like some of my issues were at least indirectly addressed.

There seems to be now examples of managing the `body` element in the official docs.

One of [create-elm-app](https://www.github.com/halfzebra/create-elm-app) contributors responded to my question regarding deploying the project on Netlify with a solution that seems pretty good, making [create-elm-app](https://www.github.com/halfzebra/create-elm-app) the best candidate for bundling Elm projects, if it works.

[create-elm-app](https://www.github.com/halfzebra/create-elm-app) also has their own solition on bundling images, which doesn't seem perfect, but hey, at least they've acknowledged the problem and provided a documented solution, which is better than anything else I've seen so far.

Another great update is to do with `elm-package.json`, which has now been renamed to `elm.json`. I didn't list this as one of the issues mentioned above, but with `elm-package.json` you had to add fields that are irrelevant to a regular Elm application, and were quite limiting, such as a rule that a repository name cannot start with a number (Hello `100-days-of-elm`). This update fixes this issue.

That's all awesome! So today I am not going to go through the issues and try to find solutions, instead I'm going to scan the new offical [Elm guide](https://guide.elm-lang.org) updated for version 0.19 and see what's new.

Note: Here's a useful document on how to [upgrade to Elm 0.19](https://github.com/elm/compiler/blob/master/upgrade-docs/0.19.md)

---


