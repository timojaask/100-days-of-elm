## Day 13

Quick review of day 12:

Learned about modules in Elm.

Exporting code as a module:

```
module MyModuleName1 exposing (..)
module MyModuleName2 exposing (MyModuleName2(..), someFuncName)
```

Importing modules:

```
import MyModuleName1
import MyModuleName1 exposing (..)
import MyModuleName1 exposing (MyModuleName1)
import MyModuleName1 exposing (MyModuleName1, someFuncName)
import MyModuleName1 as MMN
import MyModuleName1 as MMN exposing (someFuncName)
```

Building projects with multiple modules -- in `elm-package.json`:

```
{
  ...
  "source-directories": [
    "src",
    "anotherDir/src"
  ],
  "dependencies": {
    "elm-lang/core": "4.0.2 <= v < 5.0.0",
    "elm-lang/html": "1.1.0 <= v < 2.0.0"
  }
}
```

Important to remember when to break things up:

1. If you're repeating yourself, maybe break things out.
2. If a function gets too big, make a helper function.
3. If you see related things, maybe move them to a module.

Don't prematurely try to architect things too much.

---

Today I'm gonna try to build a landing page for my wife using Elm. It's very simple, but what I'm intending to learn is how to build a project from start to finish, put on github, setup CI on Netlify.com and have it publish to production on git push.

I've actually cheated a bit and have already started working on the site yesterday. So I'll continue from where I left off -- figuring out how to set the project up so that Netlify CI would be able to build it automatically. The repo is located at: https://github.com/timojaask/larisadeac.com

Yesterday I've bot the basic page content up, but styling is largely missing. I tried to set the CI on Netlify, but it failed. So now I'm going to see how do people do this with Elm. Perhaps using webpack.

---

Ok, managed to make it work on Netlify. Precise instructions on how to create an Elm project with a Webpack configuration and publish it on Netlify can be found at: https://github.com/timojaask/minimal-elm

Below I'll try to exaplain what some of the perhaps less obvious steps do.

In step 3, it's installing the following NPM packages:
```
yarn add webpack webpack-cli file-loader elm-webpack-loader --dev
```
`webpack` and `webpack-cli` are obvioudly required for using Webpack. `file-loader` is needed to copy `index.html` file from the `src` folder into the `dist` folder. `elm-webpack-loader` is the piece that tells Webpack how to handle Elm files, because Webpack doesn't know it out of the box.

Also in step 3 we're using `elm-package`:
```
elm-package install elm-lang/html
```
This is basically a shortcut to create `elm-package.json` file, where we configure out Elm project.

Next, in step 4 there are a few interesting things.

`webpack.config.js` looks scary, but in the end not that complicated. It starts off by telling Webpack which file contains the entry code for the application. In our case it's the `./src/index.js`. Next, it tells Webpack where to output stuff -- the `/dist` directory.

Then in `module.rules` it tells webpack to use `file-loader` to copy files whenever it encounters any `.html` files required. In our case it's going to be `index.html` file that it's going to copy. It also tells Webpack to user `elm-webpack-loader` to handle `.elm` files.

The `devServer` config slipped in accidentally, I'm guessing it's for running a local dev server, which will probably come handy. I'll just let it be there for now.

Next, we have `src/index.html` file. This is the HTML document that gets loaded into the browser. It loads the `app.js` file, which contains the app logic. This file gets copied into the `dist` folder as-is by `file-loader`.

Next, `src/index.js`. This is a piece of JS that initializes the Elm code and mounts it into the HTML. I don't know if this is the officially recommended way of doing things, but seems like this is how everybody does it, so I'm just rolling along.

Finally, we have `src/Main.elm`, which is your beloved Elm app. This time, it's declaring a `Main` module in the first line: `module Main exposing (..)`. Don't know if that's strictly necessary, but it was in some example, so again, looks good to me, and kind of makes sense.

In step 5, we're telling Elm what directories are used for strong our source code. In our case it's just the `src` directory. And then we use `package.json` to define the build command, which in this case is simply calling `webpack` without arguments.

---

After webpack is setup and project builds, it's super easy to publish it on Netlify. Just create a new site from your repo, set build command to `yarn build` and publish directory to `dist` and it should just work!

Awesome!