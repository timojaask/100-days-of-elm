## Day 51

Today I started by fixing a bug in 2048, adding colors for each number in the game, and refactoring the code a bit.

Now I want to add keyboard support, so the player can use keyboard arrow keys to play the game.

Elm `Browser` package provides `onKeyDown` subscription. Then we can create a decoder that decodes `"key"` field from the payload.

This all sounds good in theory, and it works just fine when I tried to create a minimal example of it in [Ellie](https://ellie-app.com/3LtkLCdrPCYa1), but didn't work in my 2048.

What actually happened was that the key down events did not propagate after loading the page. Then, if any of the buttons on the page get focus, then suddenly the keyboard events start working. Why does it work on Ellie then? Perhaps Ellie does something to bring focus to the part of the screen where the code is running, because it also starts working only after you click on it.

So I did a kind of hacky workaround -- during the `init`, I send `Task.attempt (\_ -> NoOp) (Browser.Dom.focus "board")` as one of the initial commands, which sets focus on some element on this page (I just picked a div). This way the keyboard events start propagating. Weird.

I added Cypress tests that make sure the arrow keys do the correct movements. However, I couldn't figure out hot to test that the `<body>` element has focus. The reason this is important, is because Cypress fires off the keydown events on `<body>`, so it works, even if body doesn't have focus at first. But if user opens the app in their browser and presses an arrow key, it won't fire on the body until it, or one of its children gets focused.

I decided I could use a unit test to make sure that body gets focus. It's not bullet proof, but at least something. So I installed `elm-test` into this project.

Now there's an issue with testing the `init` function -- it takes `Nav.Key` as a parameter, and as of now, there's no way to instantiate it yourself in the test. There's an open issue regarding this: https://github.com/elm-explorations/test/issues/24.

Actually, it turns out there's also no way to compare `Program.Cmd`, so there is simply no way to unit test this.

The best solution seems to be to have `Main.elm` be a very small file that only has `main` and exports it. Then it takes `init` and other needed parts from somewhere else. Also, to make commands testable, they could be abstracted by using some custom type to represent them. Then `Main.elm` would also have the logic to translate that custom type to `Program.Cmd`. This logic wouldn't be unit testable, but we can still test the functionality of the app by using tools like Cypress. I'm not  going to do this with 2048, but good to know the limitations and possibilities here.