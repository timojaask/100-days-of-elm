I had a few days off, because of non-stop traveling, events, and jetlag. Yesterday, I started slowly getting back into programming, by playing around with Elm, building a 3D rendering "engine". Any tips on how to better spend a Sunday evening?

So today, I actually continued with that, and stumbled upon a library that helps with 3D transformations: [quaternion](https://github.com/kfish/quaternion), but unfortunately, it wasn't yet updated for Elm 0.19, and so I started trying to do that myself, which opened a huge can of worms.

Anyway, I learned about the existance of [elm-upgrade](https://github.com/avh4/elm-upgrade), a tool that helps greatly in converting old version apps to new. It does a lot, but not all, and the rest you have to do manually.

One of the Elm changes that affected [quaternion](https://github.com/kfish/quaternion) is removal of tuples of size larger than 2. In Elm 0.19, tuple can only contain two elements, but the library uses 3 and 4-tuples extensively. [elm-upgrade](https://github.com/avh4/elm-upgrade) was not able to fix all of these cases, so I had to do it manually, and I might have succeded, but was not able to verify it.

First of all, I learned that I can't just run a library using `elm reactor` (DUH!). I mean, I was able to compile the code and see the errors, but once there were no sytax or type errors, the compiler would time out, and then the browser would throw the following error:

```
A web handler threw an exception. Details:
thread killed
```

At first I had no idea what that means. However, then someone on elm-lang Slack channel suggested that perhaps dead code elimination removes all of the code from the library and then throws this error when there's literally no code to run. Of course the error is simply very bad, but perhaps we found the reason.

So how do I test the library? Well, it includes automated tests. So the next ordeal is to convert the automated tests to Elm 0.19. Again, I used [elm-upgrade](https://github.com/avh4/elm-upgrade) which seemed to have done a decent job of converting, but then I couldn't run the tests anyway. Running `elm-test` gives me this:

```
$ elm-test 
-- BAD JSON ----------------------------------------------------------- elm.json

The "source-directories" in your elm.json lists the following directory:

    /Users/timojaask/projects/temp/quatfix/tests/tests

I cannot find that directory though! Is it missing? Is there a typo?

Compilation failed while attempting to build /Users/timojaask/projects/temp/quatfix/tests/InternalTests.elm /Users/timojaask/projects/temp/quatfix/tests/QnExpect.elm /Users/timojaask/projects/temp/quatfix/tests/QnFuzz.elm /Users/timojaask/projects/temp/quatfix/tests/Tests.elm
```

I have no idea what is it talking about, since I don't have `quatfix/tests/tests` anywhere in the `"source-direcotires"`. In fact, the root `elm.json` doesn't have `source-directories` at all, and the one inside the `test` folder certainly doesn't contain anything like what the error suggests it might.

So right now I don't know how to run the tests.

Left an issue regarding this at the original project's github: https://github.com/kfish/quaternion/issues/2

For now I'll leave the quaternion issue for another day, and get back to learning Elm 0.19.

---

Going through the new [Elm guide](https://guide.elm-lang.org), I'm going to try to update the old code samples with new code and list the changes here.

First up, the [buttons example](./user-input/buttons.elm).

To begin with, the `Html.beginnerProgram` has been replaced with `Browser.sandbox`. In fact, all of the "programs" have been replaced by [Browser](https://package.elm-lang.org/packages/elm/browser/latest/).

Then, once I ran `elm reactor`, it told me that I need to initialize my project. So I went ahead and created [elm.json](./elm.json), and removed the old `elm-package.json`.

Finally, `Basics.toString` was replaced by `String.fromInt` and `String.fromFloat`, so I had to replace that as well.