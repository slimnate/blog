# My Blog

Welcome! Visit the blog here: https://slimnate.github.io/

This repository contains my blog about Software Development, Machine Learning, and other interestes of mine.

- Jupyter Notebooks for the blog: http://www.fast.ai/2020/01/20/nb2md/ 

## Layout
**Files:**

- Config: *_config.yml*
- Homepage: *index.md*
- Converter.ipydev


**Folders:**

- `_nb` - Folder for articles in the form of Jupyter notebooks
- `_posts` - Folder for all blog posts, posts from `_nb` will be converted to markdown using nbdev and copied to this folder for publishing.
- `_includes` - Site templates, etc.
- `assets` - CSS and other web assets
- `images` - Images and other media

## Publishing Jupyter Notebooks
There is a Jupyter notebook included that provides functionality to automatically convert notebooks in the `_nb` directory to markdown format blog posts in the `_posts` directory for easy publishing. Open the file in Jupyter Notebooks and follow along with those instructions.

## Sample Post:

# This is the title

Here's the table of contents:

1. TOC
{:toc}

## Basic setup

Jekyll requires blog post files to be named according to the following format:

`YEAR-MONTH-DAY-filename.md`

Where `YEAR` is a four-digit number, `MONTH` and `DAY` are both two-digit numbers, and `filename` is whatever file name you choose, to remind yourself what this post is about. `.md` is the file extension for markdown files.

The first line of the file should start with a single hash character, then a space, then your title. This is how you create a "*level 1 heading*" in markdown. Then you can create level 2, 3, etc headings as you wish but repeating the hash character, such as you see in the line `## File names` above.

## Basic formatting

You can use *italics*, **bold**, `code font text`, and create [links](https://www.markdownguide.org/cheat-sheet/). Here's a footnote [^1]. Here's a horizontal rule:

---

## Lists

Here's a list:

- item 1
- item 2

And a numbered list:

1. item 1
1. item 2

## Boxes and stuff

> This is a quotation

{% include alert.html text="You can include alert boxes" %}

...and...

{% include info.html text="You can include info boxes" %}

## Images

![](/images/logo.png "fast.ai's logo")

## Code

General preformatted text:

    # Do a thing
    do_thing()

Python code and output:

```python
# Prints '2'
print(1+1)
```

    2

## Tables

| Column 1 | Column 2 |
|-|-|
| A thing | Another thing |

## Footnotes

[^1]: This is the footnote.

