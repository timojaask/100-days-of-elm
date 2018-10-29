## Day 48

Continuing work on 2048.

To recap, yesterday I decided to allow loading game boards via URL query parameter. So a board like this:

```
128 64  8   4
64  8   2   0
2   2   0   0
4   0   0   0
```

Could be represented in an URL like this:

```
http://localhost:8080/?board=128_64_8_4_64_8_2_0_2_2_0_0_4_0_0_0
```

This would allow sharing boards, as well as running Cypress tests.

Yesterday I have set up `main = Browser.application` and now have access to the URL and URL changes.

Next I need to be able to parse the URL and turn it into a board.

For this I use the `Url.Parser` and `Url.Parser.Query` packages. Using those I parse the query value as a string, and then use String.split to transform it into an array or rows, and each having an array of cell values.

Then I convert the string values to int, and merge with `emptyBoard` using `List.map2`.

Now a board can be initialized to any state using URL.

I have also added `package.json` and started using NPM repository to install elm, http-server, and run scripts. This way the entire app can be built anywhere by just running `yarn && yarn build`. This will install Elm locally and run the `elm make` command.