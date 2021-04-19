---
title: Displaying 3D models in Jekyll blog
categories: [Blogging, Tutorial]
tags: [tutorial, jekyll, 3d-models]
pin: true
---
1. TOC
{:toc}

## What + Why?
As part of my [Snake Tank Humidifier](/2021/04/14/snake-tank-humidity-controller.html) post, I wanted to include 3D models of the parts I designed for this project. This is the story of how I accomplished it, and here's an example of how the finished preview looks with a fan/hose mount from that project:

{% include stlviewer.html src="Fan_Mount_v8.stl" %}

## How?
In order to accomplish this task, we need two things:
1) An embeddable 3D model viewer
2) A way to embed code snippets into our blog posts

### Embeddable 3d Viewer options
There are several options for embeddable 3D model viewers. I want to display objects in the STL format if possible, since that is the format my files are already in before they get sent to the Slicer and 3D printer. Some options that I examined:

- [model-viewer](https://modelviewer.dev/) - Free, looks really simple and easy to use, but only supports `.glb` files.
- [Sketchfab](https://sketchfab.com/) - Looks easy to use, and appears to support `.stl`, but free plan only allows one upload per month... **lame**.
- [Modelo.io](https://modelo.io/pricing.html) - Free version seems to support multiple models, (500mb storage max) and embedding of iframe viewer - not sure about `.stl` support
- [viewstl.com plugin](https://www.viewstl.com/plugin/) - Simple, free, javascript based library. No need to host externally, can simply add to local assets. **Can do everything in code!** This is what I'm looking for

I decided to go with the viewstl javascript library to entirely eliminate the need to embed a viewer from another website. This solution is much more technical to implement, but once implemented will actually save time in the long run on uploading files to other sites, copying embed links, etc. Let's get started...

### 1. Installing ViewSTL plugin
To set up the Stl Viewer javascript plugin I simply copied it to my assets from the repo. In the future I may create a Jekyll plugin for this whole process...

##### Download files
Clone the github repo from: `https://github.com/omrips/viewstl.git`

##### Copy files to assets
Copy the `build` folder from viewstl repo to the `assets/js` folder and rename it to `viewstl`. Should leave you with a folder `assets/js/viewstl` containing several javascript files, including `stl_viewer.min.js`

##### Create directory for stl files
Create a new folder `stl` inside of the `assets` folder, that will contain all of our `.stl` files. Optionally copy files there now if you have them.

### 2. Liquid and Includes
Now that we have the necessary javascript files in our assets, time to get started on modifying our [_includes](https://jekyllrb.com/docs/includes/). In Jekyll, includes are a way to insert content from another file into your pages using the [Liquid](https://jekyllrb.com/docs/liquid/) templating language. We are going to use this feature to create a custom include tag that will provide the properly formatted HTML to display our 3D file inside a markdown blog post (or anywhere on the site that has access to Liquid).

##### Import the main javascript library in html head tag
First step in implementing the library is to make sure that the library is loaded in the HTMl document head. TO do this, we'll modify an existing includes file: `_includes/head.html`.  Add the following lines to the `<!-- JavaScripts -->` section, just below the jquery script tag:


{% highlight html linenos %}
  <script src="/assets/js/viewstl/stl_viewer.min.js"></script>
  <script src="/assets/js/viewstl/init.js"></script>
{% endhighlight %}

##### Create custom `_includes` tag
Now that the library is imported on every page, it's time to set up the custom include tag. Create a new file, `_includes/stlviewer.html`, with the following content:

{% highlight ruby linenos %}
{% raw %}
{% assign width=800 %}
{% assign height=350 %}

{% if include.width %}
{% assign width = include.width %}
{% endif %}

{% if include.height %}
{% assign height = include.height %}
{% endif %}

{% capture url %}/assets/stl/{{include.src}}{% endcapture %}

{% capture style %}width: {{width}}px; height: {{height}}px;
-webkit-box-shadow: 3px 0px 10px 0px #000000; 
box-shadow: 3px 0px 10px 0px #000000;
{% if include.extrastyle %}{{include.extrastyle}}{% endif %}
{% endcapture %}

<div class="3d-model col-12" data-src="{{url}}" style="{{style}}"></div>
{% endraw %}
{% endhighlight %}

Lines 1-10 initialize the sizing arguments provided to the include statement. Line 12 initializes the src argument. Lines 14-18 initialize the style string for the element. Line 20 outputs the actual element.

Note that we use an HTML5 data-* attribute to store the source url on the element for our script to access in the next step. This new tag will be used like this:

{% highlight ruby linenos %}
{% raw %}
{% include stlviewer.html src="Fan_Mount_v8.stl" width=500 height=300 extrastyle="" %}
{% endraw %}
{% endhighlight %}

_Note, the path provided to the `src` argument is relative to the `assets/stl` directory, so you only need to provide the file name. The above example would give an element with the attribute `data-src="assets/stl/3d-file.stl"`. The `extrastyle` attribute allows for adding additional custom styling to the element. Be sure this is properly formatted with unit labels and semi-colons where necessary to avoid issues._

##### Add javascript to load the 3D viewer
Next we need to add some javascript code to read in the file and initialize the elements. This code will find any `div` elements with the `3d-model` class, and display the model from the file provided in `data-src` attribute.

Create a new file `assets/js/viewstl/init.js` with the following contents:

{% highlight javascript linenos %}
function initStlViewer() {
    //get each 3d-model element on the page
    var $modelElements = $("div.3d-model");
    $modelElements.each(function (i, elem) {
        //get file path attribute from element
        var filePath = $(elem).data('src');
        console.log('Initing 3D File: ' + filePath);
        //create new viewer
        new StlViewer(elem, { models: [{ filename: filePath }] });
    });
}

$().ready(initStlViewer);
{% endhighlight %}

### Final thoughts
The process of implementing a custom include tag and script in Jekyll has been very beneficial and allowed me to learn a lot about how the Jekyll framework operates, and how to customize it. The [viewstl documentation](https://www.viewstl.com/plugin/) lists many other available methods with the viewer, so some future improvements would be to add additional functionality such as control buttons, animations, colors, wireframe view, etc to the viewer

I'm super excited to get to work on writing posts to show off some of the 3D models I've been working on! Hopefully you found this informative, and be sure to check out some of my other posts below!