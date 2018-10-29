## Development environment setup

```
yarn install
```

## Building

**For development:**

```
yarn build-dev
```

**For production:**

```
yarn build
```

## Running locally

```
yarn build-dev
yarn start
```

Open in your browser of choice using one of the links provided by the last command.

## Deploying

Build command:

```
yarn build
```

Deploy folder:

```
public
```

## Git

The `public` folder should be committed to git. However, `public/index.js` can be git-ignored, because it's built by `yarn build`.