---
title: Text and Typography
date: 2021-04-01 12:00:00 -0500
categories: [Blogging]
tags: [template]
mermaid: true # enable mermaid charts
pin: false
---

Description of what will be discussed in article, will show on article preview

1. TOC
{:toc}

# Introduction
In [a previous article]({% post_url 2023-07-11-tw-elements-form-customization %}), I attempted to modify the tailwind elements UI components styling, and despite being (mostly) successful, I had a horrible developer experience. So in this article, I am going to chronicle my migration to the [Skeleton UI](https://www.skeleton.dev/) library. All of this work is for the booking page of the [Dream Capture Co](https://dreamcapture.co/) website I [have been working on]({% post_url 2023-06-22-dream-capture-co %}) for my girlfriends photography business. 

# Installation
Since I already have a SvelteKit app using Tailwind CSS, I will need to follow the instructions for manual installation on the Skeleton website [getting started](https://www.skeleton.dev/docs/get-started) page.

Install Skeleton:
`npm i @skeletonlabs/skeleton --save-dev`

Install Tailwind Forms (required for form elements):
`npm install -D @tailwindcss/forms`

tailwind.config.cjs:
```cjs
/** @type {import('tailwindcss').Config} */
module.exports = {
	darkMode: 'class',
	content: [
		'./src/**/*.{html,js,svelte,ts}',
		// './node_modules/tw-elements/dist/js/**/*.js',
		require('path').join(require.resolve('@skeletonlabs/skeleton'), '../**/*.{html,js,svelte,ts}'),
	],
	theme: {
		extend: {
			...
		},
	},
	plugins: [
		// require('tw-elements/dist/plugin'),
		require('@tailwindcss/forms'),
		...require('@skeletonlabs/skeleton/tailwind/skeleton.cjs')(),
	],
};
```

src/routes/+layout.svelte - added lines 2 and 3:
```svelte
<script>
	import Footer from '$lib/components/Footer.svelte';
	import '@skeletonlabs/skeleton/themes/theme-skeleton.css';
	import '@skeletonlabs/skeleton/styles/skeleton.css';
	import '../app.css';
	import Navbar from './Navbar.svelte';
	import 'tw-elements/dist/css/tw-elements.min.css';
	// import '@fortawesome/fontawesome-free/css/fontawesome.min.css';
	// import '@fortawesome/fontawesome-free/css/solid.css';
</script>

<Navbar />

<div class="mx-auto text-center">
	<slot />
</div>

<Footer />

```

designing floating input labels: https://www.youtube.com/watch?v=nJzKi6oIvBA