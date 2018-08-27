## Day 14

Quick review of day 13:

Yesterday I started working on [larisadeac.com](https://github.com/timojaask/larisadeac.com) -- a website for my wife, written in Elm.

One of the biggest challenges was getting it up and running on Netlify. Netlify doesn't seem to have a direct support for pure Elm projects, and I'm guessing that Elm isn't mature enough to be fully usable without some wrapping. Actually, I don't know 100%, but that's the idea I got.

So I created two more files: `index.html` and `index.js` to bootstrap the Elm app, and added webpack to the project to configure the build process.

The build process copies over the HTML file, builds the JavaScript file and the Elm code into a single compressed JavaScript file and places all of that into a `dist` folder.

Build can be triggered by simply running `npx webpack`. But I also added an NPM script that does the same, which you can call with `yarn build`.

So to configure Netlify, I set it up to trigger build whenever I push to the master branch of the git repository, run the `yarn build` command, and publish the output from the `dist` folder.

All of this took a few hours of learning, and I made an example project with precise instructions and sample code at: https://github.com/timojaask/minimal-elm.

---

Today I'm going to continue to work on [larisadeac.com](https://github.com/timojaask/larisadeac.com). Currently there's an obvious problem -- webpack doesn't have a configuration to copy over the image assets. Let's fix that first.

Now, the problem is, there is no "best practice" way of bundling your images in Elm. There are a few solutions that I've seen in the wild, but they all feel a bit off. In fact, this is so frustrating for me right now, that I felt like writing a small rant on [issues-with-elm.md](./issues-with-elm.md). Hopefully it's all just my own incompetence and lack of experience, and there are actually good solutions to the challenges that I faced so far.

So that this wouldn't sound like a completely useless rant, next I'm going to write about all the different solutions to the issues that I listed in the document above. This will require seeking various solutions, trying them out, comparing, and writing about them. Looking forward to doing that tomorrow!
