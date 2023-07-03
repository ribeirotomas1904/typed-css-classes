## Installation

```bash
npm install --save typed-css-classes
```

Then add the ppx in your `bsconfig.json` file:

```json
"ppx-flags": [
  "typed-css-classes/ppx"
]
```

## Usage

### CSS Modules

```res
%%css.module(let css = "./styles.module.css")

@react.component
let make = () => {
  <h1 className={css["title"]}> {"Hello World!"->React.string} </h1>
}
```

### Importing global CSS

```res
%%css.import(let css = "./styles.css")

@react.component
let make = () => {
  <h1 className={css["title"]}> {"Hello World!"->React.string} </h1>
}
```
