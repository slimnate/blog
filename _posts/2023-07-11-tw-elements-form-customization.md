---
title: Customizing Tailwind Elements Form Field Colors
date: 2023-07-11 00:00:00 -0500
categories: [Software]
tags: [javascript, tailwind, tw-elements, forms]
mermaid: false # enable mermaid charts
pin: false
---

How to customize colors of Tailwind Elements (tw-elements) form fields

1. TOC
{:toc}

# Introduction
In the [Dream Capture Co]({% post_url 2023-06-22-dream-capture-co %}) project, I used [Tailwind Elements](https://tailwind-elements.com/) to build the booking form. By default, all the form elements use a blue color for borders, button colors, etc. This doesn't fit wll with the color schema of the site, so I wanted to change these colors from the default. However, I couldn't find any good information online about how to change these colors, so I spent some time playing around and figured it out, and wanted to share that information in hopes it might make someone else's life easier.

## Disclaimer
Midway through working on this article I decided to entirely scrap tw-elements and opt for a different SvelteKit UI library with better customization. Trying to modify the color theme of these elements was one of the worst developer experiences I have had lately, and I recently came across some more promising libraries of UI components that I want to use instead. I am still publishing this article as a learning experience, but I would not recommend anyone to try doing this the way that I did. It was not fun, and in the end I wasn't able to get the correct styling for the `select` elements anyway. Instead, I will be using the [Skeleton UI](https://www.skeleton.dev/) library instead, follow the journey in my [article on that subject]({% post_url 2023-07-22-skeleton-ui-svelte %})

# Input
This was the trickiest part to figure out, and you'll soon see why. Here's the code I started with for one of the input elements, based on the [Basic Example in their documentation](https://tailwind-elements.com/docs/standard/forms/inputs/#basic):

```html
<!-- NAME -->
<div
class="relative md:col-span-2"
data-te-input-wrapper-init
>
   <input
   	type="text"
   	class="peer block min-h-[auto] w-full rounded border-0 bg-transparent px-3 py-[0.32rem] leading-[2.15] outline-none transition-all duration-200 ease-linear focus:placeholder:opacity-100 peer-focus:text-primary data-[te-input-state-active]:placeholder:opacity-100 motion-reduce:transition-none dark:text-neutral-200 dark:placeholder:text-neutral-200 dark:peer-focus:text-primary [&:not([data-te-input-placeholder-active])]:placeholder:opacity-0"
   	id="name"
   	name="name"
   	placeholder="Name"
   />
   <label
   	for="name"
   	class="pointer-events-none absolute left-3 top-0 mb-0 max-w-[90%] origin-[0_0] truncate pt-[0.37rem] leading-[2.15] text-primary transition-all duration-200 ease-out peer-focus:-translate-y-[1.15rem] peer-focus:scale-[0.8] peer-focus:text-primary peer-data-[te-input-state-active]:-translate-y-[1.15rem] peer-data-[te-input-state-active]:scale-[0.8] motion-reduce:transition-none dark:text-neutral-200 dark:peer-focus:text-primary"
   	>Name</label
   >
</div>
```

## Label Color
Updating the label color was easy enough, simply replace the `text-primary` class on the `label` element with the new color, in this case `text-blackcoffee/70`.

## Border color
However, updating the border color that shows when the `input` element is active was not as straight-forward, and is the one I had the most trouble with. This is because the border is made up of three separate elements, which all have a color, as well as a 1px shadow around them that also needs to be re-colored.

To solve this issue, we need to look at the [Custom Classes](https://tailwind-elements.com/docs/standard/forms/inputs/#api-section-classes) section of the tw-elements documentation, and change the colors using the different `notch` classes. There are three custom classes involved in this process:

- `notchLeadingNormal`
- `notchMiddleNormal`
- `notchTrailingNormal`

Each of these classes will need to be updated in the same way to achieve the desired effect, so I will only focus on one of the classes, and then give an example at the end of the final implementation.

The default value for the `notchLeadingNormal` class is:
```
border-neutral-300 dark:border-neutral-600 group-data-[te-input-focused]:shadow-[-1px_0_0_#3b71ca,_0_1px_0_0_#3b71ca,_0_-1px_0_0_#3b71ca] group-data-[te-input-focused]:border-primary
```

There are two items that will need to be changed:
- First, we need to update the `group-data-[te-input-focused]:border-primary` to `group-data-[te-input-focused]:border-blackcoffee/70`. This changes the border color when the input is focused.
- Next, we need to update the `group-data-[te-input-focused]:shadow-[-1px_0_0_#3b71ca,_0_1px_0_0_#3b71ca,_0_-1px_0_0_#3b71ca]` and change the colors of the shadow. IF you are not using opacity, this is as easy as changing the hex values for each of the three shadows. If you need opacity, you'll have to convert the hex value of your color to RGBA so we can specify opacity. In my case, this looks like: `group-data-[te-input-focused]:shadow-[1px_0_0_rgb(58_45_50_/_0.7),_0_-1px_0_0_rgb(58_45_50_/_0.7),_0_1px_0_0_rgb(58_45_50_/_0.7)]`

Note that you cannot simply copy and paste this to the other notch classes, as they each have different configurations for the shadow; you will have to copy the defaults for each from the documentation, and then update the colors for each individually.

To actually implement these in our HTML, we have to use data attributes on the parent `div` of the input and it's label, like so:
```html
<div
	class="relative md:col-span-2"
	data-te-input-wrapper-init
	data-te-class-notch-leading-normal="border-neutral-300 dark:border-neutral-600 group-data-[te-input-focused]:shadow-[-1px_0_0_rgb(58_45_50_/_0.7),_0_1px_0_0_rgb(58_45_50_/_0.7),_0_-1px_0_0_rgb(58_45_50_/_0.7)] group-data-[te-input-focused]:border-blackcoffee/80"
	data-te-class-notch-middle-normal="border-neutral-300 dark:border-neutral-600 group-data-[te-input-focused]:shadow-[0_1px_0_0_rgb(58_45_50_/_0.7)] group-data-[te-input-focused]:border-blackcoffee/80"
	data-te-class-notch-trailing-normal="border-neutral-300 dark:border-neutral-600  group-data-[te-input-focused]:border-blackcoffee/80"
>
	<input
		type="text"
		class="peer block min-h-[auto] w-full rounded border-0 bg-transparent px-3 py-[0.32rem] leading-[2.15] outline-none transition-all duration-200 ease-linear focus:placeholder:opacity-100 peer-focus:text-primary data-[te-input-state-active]:placeholder:opacity-100 motion-reduce:transition-none dark:text-neutral-200 dark:placeholder:text-neutral-200 dark:peer-focus:text-primary [&:not([data-te-input-placeholder-active])]:placeholder:opacity-0"
		id="name"
		name="name"
		placeholder="Name"
	/>
	<label
		for="name"
		class="pointer-events-none absolute left-3 top-0 mb-0 max-w-[90%] origin-[0_0] truncate pt-[0.37rem] leading-[2.15] text-blackcoffee/70 transition-all duration-200 ease-out peer-focus:-translate-y-[1.15rem] peer-focus:scale-[0.8] peer-focus:text-blackcoffee/60 peer-data-[te-input-state-active]:-translate-y-[1.15rem] peer-data-[te-input-state-active]:scale-[0.8] motion-reduce:transition-none dark:text-neutral-200 dark:peer-focus:text-primary"
		>Name</label
	>
</div>
```

## Code Reuse

Since it would be very annoying, and bad development practice to copy and paste these classes onto every single element, I decided to extract their values into strings in the code for my page, and then apply those strings to each element that needs them, so they can all be updated in one place. For further ease of updating, I decided to extract each color string to it's own variable and apply them to these notch styles. Since I am using Svelte for this project, all I have to do is add the following to my script tag at the top of the file:

```js
/** Notch styles */
const notchColorString = 'blackcoffee/80';
const notchColorRGB = 'rgb(58_45_50_/_0.7)';
const notchLeading = `border-neutral-300 dark:border-neutral-600 group-data-[te-input-focused]:shadow-[-1px_0_0_${notchColorRGB},_0_1px_0_0_${notchColorRGB},_0_-1px_0_0_${notchColorRGB}] group-data-[te-input-focused]:border-${notchColorString}`;
const notchMiddle = `border-neutral-300 dark:border-neutral-600 group-data-[te-input-focused]:shadow-[0_1px_0_0_${notchColorRGB}] group-data-[te-input-focused]:border-${notchColorString}`;
const notchTrailing = `border-neutral-300 dark:border-neutral-600 group-data-[te-input-focused]:shadow-[1px_0_0_${notchColorRGB},_0_-1px_0_0_${notchColorRGB},_0_1px_0_0_${notchColorRGB}] group-data-[te-input-focused]:border-${notchColorString}`;
```

and then specify the data attributes from these constant values:

```html
<!-- NAME -->
<div
	class="relative md:col-span-2"
	data-te-input-wrapper-init
	data-te-class-notch-leading-normal={notchLeading}
	data-te-class-notch-middle-normal={notchMiddle}
	data-te-class-notch-trailing-normal={notchTrailing}
>
  ...
```

# Radio
To modify the radio option colors, I again extracted the css classes to a string constant, and applied them to each of the select input elements, changing any instance of `primary` to `blackcoffe`, as well as updating the hex values of `#3b71ca` (the primary blue color) to `#3a2d32` (my custom color blackcoffee)

```js
	/** radio styles */
	const radioClass = `relative float-left -ml-[1.5rem] mr-1 mt-0.5 h-5 w-5 appearance-none rounded-full border-2 border-solid border-neutral-300 before:pointer-events-none before:absolute before:h-4 before:w-4 before:scale-0 before:rounded-full before:bg-transparent before:opacity-0 before:shadow-[0px_0px_0px_13px_transparent] before:content-[''] after:absolute after:z-[1] after:block after:h-4 after:w-4 after:rounded-full after:content-[''] checked:border-blackcoffee checked:before:opacity-[0.16] checked:after:absolute checked:after:left-1/2 checked:after:top-1/2 checked:after:h-[0.625rem] checked:after:w-[0.625rem] checked:after:rounded-full checked:after:border-blackcoffee checked:after:bg-blackcoffee checked:after:content-[''] checked:after:[transform:translate(-50%,-50%)] hover:cursor-pointer hover:before:opacity-[0.04] hover:before:shadow-[0px_0px_0px_13px_rgba(0,0,0,0.6)] focus:shadow-none focus:outline-none focus:ring-0 focus:before:scale-100 focus:before:opacity-[0.12] focus:before:shadow-[0px_0px_0px_13px_rgba(0,0,0,0.6)] focus:before:transition-[box-shadow_0.2s,transform_0.2s] checked:focus:border-blackcoffee checked:focus:before:scale-100 checked:focus:before:shadow-[0px_0px_0px_13px_#3a2d32] checked:focus:before:transition-[box-shadow_0.2s,transform_0.2s] dark:border-neutral-600 dark:checked:border-primary dark:checked:after:border-primary dark:checked:after:bg-primary dark:focus:before:shadow-[0px_0px_0px_13px_rgba(255,255,255,0.4)] dark:checked:focus:border-primary dark:checked:focus:before:shadow-[0px_0px_0px_13px_#3a2d32]`;
```

```html
  <input
		class={radioClass}
		type="radio"
		name="preferredContact"
		id="radioEmail"
		value="Email"
	/>
	<label class="mt-px inline-block pl-[0.15rem] hover:cursor-pointer" for="radioEmail">
		Email
	</label>
```

# Select
For the select elements, I already modified the style of the dropdown menu itself, so all I'm doing in this article is updating the border colors. I was hoping that despite not being documented on the tw-elements [documentation for the select element](https://tailwind-elements.com/docs/standard/forms/select/#api-section-classes), it would also accept the same data-class attributes as the [input element](https://tailwind-elements.com/docs/standard/forms/inputs/#api-section-classes) - at least the notch related ones.. However, this did not work and I am still yet to figure out how to change border colors for select element. I'm sure with some more work I could figure it out, but by this point in the article, I am ready to move on to an entirely different UI library for this form, so no point sinking mor energy into this. I have included the code that I tried below anyway:

```js
/** select styles */
const selectOption = `!h-auto !py-1 flex flex-row items-center bg-transparent justify-between w-full px-4 text-blackcoffee select-none cursor-pointer data-[te-input-multiple-active]:bg-blackcoffee/10 hover:[&:not([data-te-select-option-disabled])]:bg-blackcoffee/10 data-[te-input-state-active]:bg-blackcoffee/10 data-[te-select-option-selected]:data-[te-input-state-active]:bg-blackcoffee/10 data-[te-select-selected]:data-[te-select-option-disabled]:cursor-default data-[te-select-selected]:data-[te-select-option-disabled]:text-gray-400 data-[te-select-selected]:data-[te-select-option-disabled]:bg-transparent data-[te-select-option-selected]:bg-black/[0.02] data-[te-select-option-disabled]:text-gray-400 data-[te-select-option-disabled]:cursor-default group-data-[te-select-option-group-ref]/opt:pl-7 dark:text-gray-200 dark:hover:[&:not([data-te-select-option-disabled])]:bg-white/30 dark:data-[te-input-state-active]:bg-white/30 dark:data-[te-select-option-selected]:data-[te-input-state-active]:bg-white/30 dark:data-[te-select-option-disabled]:text-gray-400 dark:data-[te-input-multiple-active]:bg-white/30`;
```

```html
<!-- SESSION TYPE -->
<div class="relative">
	<select
		id="session"
		name="session"
		data-te-select-init
		data-te-select-size="lg"
		data-te-class-notch-leading-normal={notchLeading}
		data-te-class-notch-middle-normal={notchMiddle}
		data-te-class-notch-trailing-normal={notchTrailing}
		data-te-class-select-option={selectOption}
		data-te-class-options-list="!py-1 bg-eggshell/70"
		data-te-class-options-wrapper="!max-h-[40vh]"
	>
		<option value="" hidden selected />
		<option value="portrait">Portrait</option>
		<option value="Boudoir">Boudoir</option>
		<option value="Couples/Wedding">Couples/Wedding</option>
		<option value="Family">Family</option>
		<option value="Maternity/Newborn">Maternity/Newborn</option>
		<option value="Business">Business</option>
		<option value="Other">Other</option>
	</select>
	<label data-te-select-label-ref for="session" class="!text-blackcoffee/70">Session Type</label
	>
</div>
```

# Date/Time Pickers
Since the date and time picker is already an input element, we can use the same data attributes from the normal inputs to change the border. Then we just need ot update the label by changing any instance of `text-primary` to `text-blackcoffee/70`:

```html
<!-- DATE -->
<div
	class="relative"
	data-te-datepicker-init
	data-te-format="mm/dd/yyyy"
	data-te-disable-past="true"
	data-te-confirm-date-on-select="true"
	data-te-input-wrapper-init
	data-te-class-notch-leading-normal={notchLeading}
	data-te-class-notch-middle-normal={notchMiddle}
	data-te-class-notch-trailing-normal={notchTrailing}
	data-te-input-size="lg"
>
	<input
		type="text"
		id="date"
		name="date"
		class="peer block min-h-[auto] w-full rounded border-0 bg-transparent px-3 py-[.37rem] leading-[2.15] outline-none transition-all duration-200 ease-linear focus:placeholder:opacity-100 peer-focus:text-primary data-[te-input-state-active]:placeholder:opacity-100 motion-reduce:transition-none [&:not([data-te-input-placeholder-active])]:placeholder:opacity-0"
		placeholder="Select a date"
	/>
	<label
		for="date"
		class="pointer-events-none absolute left-3 top-0 mb-0 max-w-[90%] origin-[0_0] truncate pt-[0.37rem] leading-[2.15] text-blackcoffee/70 transition-all duration-200 ease-out peer-focus:-translate-y-[0.9rem] peer-focus:scale-[0.8] peer-focus:text-blackcoffee/70 peer-data-[te-input-state-active]:-translate-y-[0.9rem] peer-data-[te-input-state-active]:scale-[0.8] motion-reduce:transition-none dark:text-neutral-200 dark:peer-focus:text-blackcoffee/70"
		>Select a date</label
	>
</div>
```

# Text Areas
For `textarea` tags we can follow the same process as for inputs, with an extra step to change the color of the input helper div:
1. Add the notch data attributes to the containing `div`
2. Change the color on the label by replacing all `text-primary` with `text-blackcoffee/70`
3. Change the color on the input helper by replacing all `text-primary` with `text-blackcoffee/70`

```html
<!-- SUBJECTS -->
<div
	class="relative mb-14 sm:mb-8 md:col-span-2"
	data-te-input-wrapper-init
	data-te-class-notch-leading-normal={notchLeading}
	data-te-class-notch-middle-normal={notchMiddle}
	data-te-class-notch-trailing-normal={notchTrailing}
>
	<textarea
		class="peer block min-h-[auto] w-full rounded border-0 bg-transparent px-3 py-[0.32rem] leading-[1.6] outline-none transition-all duration-200 ease-linear focus:placeholder:opacity-100 peer-focus:text-primary data-[te-input-state-active]:placeholder:opacity-100 motion-reduce:transition-none dark:text-neutral-200 dark:placeholder:text-neutral-200 dark:peer-focus:text-primary [&:not([data-te-input-placeholder-active])]:placeholder:opacity-0"
		id="subjects"
		name="subjects"
		rows="4"
		placeholder="Tell us about your subjects"
	/>
	<label
		for="subjects"
		class="pointer-events-none absolute left-3 top-0 mb-0 max-w-[90%] origin-[0_0] truncate pt-[0.37rem] leading-[1.6] text-blackcoffee/70 transition-all duration-200 ease-out peer-focus:-translate-y-[0.9rem] peer-focus:scale-[0.8] peer-focus:text-blackcoffee/70 peer-data-[te-input-state-active]:-translate-y-[0.9rem] peer-data-[te-input-state-active]:scale-[0.8] motion-reduce:transition-none dark:text-neutral-200 dark:peer-focus:text-blackcoffee/70"
		>Subjects
	</label>
	<div
		class="absolute w-full text-sm text-blackcoffee/70 peer-focus:text-primary dark:text-neutral-200 dark:peer-focus:text-primary"
		data-te-input-helper-ref
	>
		Who will be taking part in the shoot? Include name, age, and any special accommodation info
	</div>
</div>
```

# Button
To modify the button colors, I had to change the button background color, and change the shadows applied to it.

For the background color, I just changed the base `bg-primary` to `!bg-blackcoffee/95` (the important modifier is needed because without it, there is a style further up in the tree that forces it to be white). For the `hover`, `focus`, and `active` states, I changed them to `!bg-blackcoffee` to make them darker than the default state.

For shadows, there were a few that needed changing. I changed `#3b71ca` to `rgba(58,45,50,0.8)`, and then changed `rgba(59,113,202,0.3)` to `rgba(59,113,202,0.2)`
