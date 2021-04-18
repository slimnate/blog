---
title: Hosting a Blog with Jekyll and Github Pages
categories: [Blogging, Tutorial]
tags: [tutorial, jekyll, ruby]
pin: true
---
1. TOC
{:toc}

## Why?
So, I have been a software developer for some years now, and several times set up websites that never really went too far, I tend to focus more on working on projects than keeping a site up to date. However, as I was going through the [Fast.AI Practical Deep Learning for Coders](https://course.fast.ai/) course online, I decided to make a blog to keep track of progress on this.

Well, after getting the blog set up initially, I inevitably got distracted on other projects and never really wrote any articles for it. After about a year of not adding anything, I finally decided to get my ass together, reboot this project, and get my blog up and running. I've been working on some very interesting projects lately (see my [Snake Tank Humidifier](/2021/04/14/snake-tank-humidity-controller.html) post), and wanted to have a place to show them off and finally get a proper portfolio set up.

## How?

### Getting started with fast_template
So here we are, setting up a blog - I originally followed a tutorial from the Fast AI course to set up the [fast_template](https://www.fast.ai/2020/01/16/fast_template/), a blog powered by [Jekyll](https://jekyllrb.com/), and [Github Pages](https://pages.github.com/), and with the added benefit of being able to compile [Jupyter Notebooks](https://jupyter.org/) into a blog post as well.

I really enjoyed how simple it was to get started, as my main focus at the time was on Machine Learning, not spending a ton of time setting up a blog. Though simple to start with, it turns out that Jekyll is an extremely powerful tool, with tons of themes and basically unlimited customizability across the site.

### A note on Jekyll with Ruby 3
Though the template form FastAI displayed properly when served by github pages, I had some issues to resolve in order to get the local preview running. Jekyll does not work with Ruby 3 

### Adding the Chirpy theme
After getting Jekyll to successfully build on my Macbook, I was looking for a way to spice up the default look and feel of the site. Reading through the Jekyll documentation on [themes](https://jekyllrb.com/docs/themes/) I came across the [chirpy](https://github.com/cotes2020/jekyll-theme-chirpy) theme, and decided that was the one for me.

I followed the instructions in the theme's README to install it and it's dependencies. Unfortunately, since I was converting an existing project, not starting a new site from their template, I had to clone the theme repo and manually copy over all the necessary files to make it run:
- everthing in the `_data`, `_includes`, `_layouts`, `_plugins`, `_posts`, `_sass`, `_tabs`, and `assets` folders
- `404.html`
- `app.js`
- `feed.xml`
- `index.html`
- `sw.js`
- any missing defaults from the `_config.yml` file (noted [here](https://github.com/cotes2020/jekyll-theme-chirpy#configuration) on their readme)
- the github workflow deployment hooks: `.github/workflows/pages-deploy.yaml.hook`


After all this, there was only one more step to make sure that the Github Pages server was able to properly build the site. Alas there was still an issue - github recognized the new theme, but was still having an "[Unknown tag](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/troubleshooting-jekyll-build-errors-for-github-pages-sites#unknown-tag-error)" build error. Since github [only supports some plugins by default](https://docs.github.com/en/pages/setting-up-a-github-pages-site-with-jekyll/about-github-pages-and-jekyll#plugins), we have to [add the `jekyll-seo-tag` gem](https://github.com/Starefossen/docker-github-pages/issues/16) explicitly. This required adding another line to the `plugins` section in `_config.yml`:

```yaml
plugins:
  ...
  - jekyll-seo-tag
```

After that, the build worked like a dream, and after a minute or two the Github Pages site was serving up a brand spankin new beautiful website: [slimnate.github.io](https://slimnate.github.io/)

Hope you enjoyed this post and/or found it useful, be sure to check out some of my other posts below: