#!/usr/bin/env node

const fs = require("fs");
const { exec } = require("child_process");
const path = require("path");

const packageJson = {
  "name": "typed-css-classes",
  "description": "Type-safe css modules for ReScript",
  "version": "0.2.0",
  "repository": {
    "type": "git",
    "url": "https://github.com/ribeirotomas1904/typed-css-classes.git"
  },
  "keywords": ["rescript", "ppx", "css modules"],
  "author": "Nathanael Ribeiro <ribeirotomas1904@gmail.com> (https://github.com/ribeirotomas1904)",
  "license": "MIT",
  "bugs": {
    "url": "https://github.com/ribeirotomas1904/typed-css-classes/issues"
  },
  "homepage": "https://github.com/ribeirotomas1904/typed-css-classes"
};

const distPath = path.join(__dirname, "dist");
const licensePath = path.join(__dirname, "LICENSE");
const binPath = path.join(__dirname, "_esy/default/build/default/src/bin/main.exe");
const parserPath = path.join(__dirname, "src/lib/parser.bundle.js");

fs.rmSync(distPath, { recursive: true, force: true });
fs.rmSync(path.join(__dirname, "_esy"), { recursive: true, force: true });
fs.rmSync(path.join(__dirname, "node_modules"), { recursive: true, force: true });

fs.mkdirSync(distPath);

// TODO: add and run tests
exec("esy", (error) => {
  if (error) {
    console.error(`Error running "esy": ${error}`);
    return;
  }

  exec("npm i && npm run build", (error) => {
    if (error) {
      console.error(`Error running "npm": ${error}`);
      return;
    }

    const packageJsonDestPath = path.join(distPath, "package.json");
    fs.writeFileSync(packageJsonDestPath, JSON.stringify(packageJson, null, 2));

    const licenseDestPath = path.join(distPath, path.basename(licensePath));
    fs.copyFileSync(licensePath, licenseDestPath);

    const parserDestPath = path.join(distPath, path.basename(parserPath));
    fs.renameSync(parserPath, parserDestPath);

    const binDestPath = path.join(distPath, "ppx");
    fs.copyFileSync(binPath, binDestPath);
  });
});
