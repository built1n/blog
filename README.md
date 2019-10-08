# Blog

This repo contains the source code of my [blog](https://fwei.tk/blog)
(in Markdown), and a collection of scripts I use to automate building
and deployment. I created this with solely my own use in mind -- if
you'd like to use this for your own use, feel free -- but you're on
your own.

## Overview

Markdown files reside in `posts/`. Each post should have a
corresponding entry in `index.csv` with `FILENAME.md:TITLE` as the
fields (note that `:` is the delimiter).

Assorted files (such as images) can be placed in `files/`.

### Building

Install pandoc.

Run `./build.sh` from the project root. This will produce the compiled
output in `out`.

### Deployment

Run `./deploy.sh`. It will try to log into my website. This will not
work. Edit it for your own needs.
