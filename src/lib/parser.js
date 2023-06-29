#!/usr/bin/env node

const fs = require("fs");
const postcss = require("postcss");
const postcssModules = require("postcss-modules")({
  getJSON: (_, json) => {
    const cssClassNames = Object.keys(json);
    fs.writeFileSync(outputPath, cssClassNames.join());
  },
});

// TODO: validate cli args
const inputPath = process.argv[2];
const outputPath = process.argv[3];

const css = fs.readFileSync(inputPath);

// TODO: improve error handling, maybe via exit codes
postcss([postcssModules])
  .process(css, { from: inputPath, to: outputPath })
  .then();
