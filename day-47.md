## Day 47

Today I decided to take a break from the Frontend Masters course, because it started getting a bit boring, and do something fun instead. So I started working on a 2048 game, which can be found under [src/game-2048](./src/game-2048).

It's hacked together pretty fast, so I'm not sure about the structure of the code. There's a lot of seeminly similar functions, but I'm not sure if there's a good way to combine them to not be so repetitive, or if that's even necessary.

I want to write integration tests for this using Cypress. There's nothing special about using Cypress, because normally you just fire it up and test away, but in this case, I want to test on pre-configured boards with specific values set, because otherwise the board generation is completely random, which makes writing tests impossible. To be able to pass the board configuration from Cypress to Elm, I think I need to pass it as an argument from JavaScript.

Actually, I think I could have a feature where the board configuration could be passed as a URL parameter.

For example, let's say we want the board to look like:

```
128 64  8   4
64  8   2   0
2   2   0   0
4   0   0   0
```

The parameter for that would be:

```
128_64_8_4-64-8_2_0-2-2_0_0-4-0_0_0
```

For this to work I need I can parse the URL either in JavaScript in Elm directly. Since I'm learning Elm, might as well do the latter. So I'll use `Browser.application` to be able to work with URLs in the app. Now I have access to the current URL of the app and also on URL changed event.

Next time I'll try and implement parsing the URL and initializing a board based on the parsed value.