---
title: Beautiful Forms with Skeleton UI and SvelteKit
date: 2023-07-30 12:00:00 -0500
categories: [Software]
tags: [svelte, javascript, css, skeleton, tailwind, forms]
pin: true
---

Process of redesigning the booking form for Dream Capture Co website with Skeleton UI for greater customizability.

1. TOC
{:toc}

# Introduction
In [a previous article]({% post_url 2023-07-11-tw-elements-form-customization %}), I attempted to modify the tailwind elements UI components styling, and despite being (mostly) successful, I had a horrible developer experience, and was unable to accomplish a few of the things I was hoping too without sinking massive amounts of time into it. So in this article, I am going to chronicle my migration to the [Skeleton UI](https://www.skeleton.dev/) library. All of this work is for the booking page of the [Dream Capture Co](https://dreamcapture.co/) website I [have been working on]({% post_url 2023-06-22-dream-capture-co %}) for my girlfriends photography business.

# SkeletonUI
Since I already have a SvelteKit app using Tailwind CSS, I will need to follow the instructions for manual installation on the Skeleton website [getting started](https://www.skeleton.dev/docs/get-started) page.

Install Skeleton:
`npm i @skeletonlabs/skeleton --save-dev`

Install Tailwind Forms (required for form elements):
`npm install -D @tailwindcss/forms`

## Tailwing Config
tailwind.config.cjs:
```js
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

## Main layout
I created a custom theme using the [Skeleton theme generator](https://www.skeleton.dev/docs/generator) - `src/theme.postcss` - and added this in place of the default skeleton theme in the app layout: 


src/routes/+layout.svelte - added lines 3 and 4:
```html
<script>
	import Footer from '$lib/components/Footer.svelte';
	import '../theme.postcss';
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

# Implementation
There are a few different large features that were added as part of this update, including:
- **Skeleton UI** - The switch to skeleton UI for base styling of form components
- **Refactoring to Svelte Components** - restructuring of fields into svelte components rather than all HTML in the main booking page.
- **New Custom Components** custom dropdown menus and date/time selectors
  - **Select** - provides custom styling of option menu and complex layouts within option items
  - **DatePicker** - uses svelty-picker library to provide custom formatted and themed date picker
  - **TimePicker** - uses svelty-picker library to provide custom formatted and themed time picker
- **Form Validation** - Added the ability to validate form field values for both existence and format.

# Components
Each form field was broken out into a custom component. In this section I'll go over each of them and their various quirks and features.

When exploring the Skeleton UI form variants, I landed on the material variant for what I wanted to use. However, the Skeleton material variant does not have floating labels/placeholders like the tw-elements fields did, so this is something that I had to add manually, using [this tutorial](https://www.youtube.com/watch?v=nJzKi6oIvBA) to implement.

## Component: `Input`
The first custom component is the `Input` component, which provides a wrapper for HTML input components (this component is only for `type="text"` input elements, due to limitations with svelte two-way input binding - see [this issue](https://github.com/sveltejs/svelte/issues/3921) for more info). This component is very simple and just renders an input field with the supplied properties - it doesn't require any component-specific logic.

Properties:
- `id` **required** - id of the underlying `textarea` element
- `name` **required** - name of the underlying `textarea` element
- `label` **required** - placeholder and label text for field
- `value` **optional** - the value of the field, can also be bound to (default: `''`)
- `error` **optional** - the errors message to display on invalid value

File: `$lib/components/form-fields/Input.svelte`
{: .code-label }

```html
<script>
	import FieldError from '$lib/components/form-fields/FieldError.svelte';

	export let /** @type string */ name;
	export let /** @type string */ id;
	export let /** @type string */ label;
	export let /** @type string */ value = '';
	export let /** @type string */ error;
</script>

<!--
  @component
  This is a custom `input` component that provides a material design
  with a floating placeholder/label

  ...
-->
<div class="relative">
	<input
		class="peer input variant-form-material border-0 border-b-2 !border-blackcoffee-300 bg-surface-500/10 pb-1 pl-4 pt-3 placeholder-transparent outline-0 placeholder-shown:py-2"
		{id}
		{name}
		placeholder={label}
		bind:value
	/>
	<label
		for={name}
		class="peer-placeholder-shown:text-blackcoffee-500/60; absolute left-4 top-0 text-xs font-semibold text-blackcoffee-500/70 transition-all duration-200 peer-placeholder-shown:top-[0.55rem] peer-placeholder-shown:text-base peer-placeholder-shown:font-normal"
		>{label}</label
	>

	<FieldError {error} />
</div>

```

## Component: `TextArea`
This component is basically the same as the `Input` component, except that is uses the `textarea` element instead.

This component also does not include any display of validation errors, since none of the `TextArea` components on my form are required, but for consistency's sake this is something that should be added in the future if I want to work these components into a more standardized collection.

Properties:
- `id` **required** - id of the underlying `textarea` element
- `name` **required** - name of the underlying `textarea` element
- `label` **required** - placeholder and label text for field
- `value` **optional** - the value of the field, can also be bound to (default: `''`)

File: `$lib/components/form-fields/TextArea.svelte`
{: .code-label }

```html
<script>
	export let /** @type string */ id;
	export let /** @type string */ name;
	export let /** @type string */ label;
	export let /** @type string */ value = '';
</script>

<!--
  @component
  This is a custom `textarea` component that provides a material design
  with a floating placeholder/label

  ...
-->
<div class="relative mb-14 sm:mb-8 md:col-span-2">
	<textarea
		class="peer input variant-form-material border-0 border-b-2 !border-blackcoffee-300 bg-surface-500/10 pb-1 pl-4 pt-3 placeholder-transparent placeholder-shown:py-2"
		{id}
		{name}
		rows="4"
		placeholder={label}
		bind:value
	/>
	<label
		for={name}
		class="peer-placeholder-shown:text-blackcoffee-500/60; absolute left-4 top-0 text-xs font-semibold text-blackcoffee-500/70 transition-all duration-200 peer-placeholder-shown:top-[0.55rem] peer-placeholder-shown:text-base peer-placeholder-shown:font-normal"
		>{label}</label
	>
	<div class="absolute w-full text-sm text-blackcoffee/70 peer-focus:text-blackcoffee/70">
		Who will be taking part in the shoot? Include name, age, and any special accommodation info
	</div>
</div>

```

## Component: `Radio`
The radio component wraps a list of radio options and provides a way to set a default checked value, as well as bind to the value from outside of the component.

This component must watch for `change` events on the individual radio elements to update the selected value.

Like the `TextArea` component above, this component does nt include any validation message display as the radio will always have a default checked value in my use case. For standardization, it might be a good idea to add validation capabilities.

Properties:
- `name` **required** - name of the form field for each of the radio elements
- `label` **optional** - placeholder and label text for field (default: `Select`)
- `options` **required** - a list of `RadioOption` objects that will be used to render the options
- `value` **optional** - the value of the field - **ONLY USE FOR BINDING - initial selection should be specified using the `checked` property on the option item**

`RadioOption` properties:
- `id` **required** - `id` attribute for the specific radio item
- `value` **required** - `value` attribute for the specific radio item
- `display` **optional** - optional display text for the radio item, if not supplied `value` will be used
- `checked` **optional** - optional boolean value, if truthy value supplied the radio item will default to checked

File: `$lib/components/form-fields/Radio.svelte`
{: .code-label }

```html
<script>
	/**
	 * @typedef RadioOption
	 * @property {string} id
	 * @property {string} value
	 * @property {string} [display]
	 * @property {boolean} [checked]
	 */

	export let /** @type string */ label = 'Select';
	export let /** @type string */ name;
	export let /** @type RadioOption[] */ options;
	export let /** @type string */ value = '';

	// set default value
	options.forEach((option) => {
		if (option.checked) value = option.value;
	});

	/**
	 * @param event {Event & { currentTarget: EventTarget & HTMLInputElement }}
	 */
	function handleChange(event) {
		value = event.currentTarget.value;
	}
</script>

<!--
  @component
  This is a custom `radio` component that provides a material design
  with a floating placeholder/label.

  ...
-->
<div class="relative flex flex-wrap justify-between px-4">
	<label for={name} class="text-left text-blackcoffee/70">{label} </label>
	<div class="flex gap-8">
		{#each options as option}
			<label class="flex items-center space-x-2">
				<input
					type="radio"
					class="bg-blackcoffee-300 text-blackcoffee-300 checked:bg-blackcoffee-300 focus:outline-2 focus:outline-blackcoffee-300/90"
					{name}
					id={option.id}
					value={option.value}
					checked={option.checked}
					on:change={handleChange}
				/>
				<p>{option.display ? option.display : option.value}</p>
			</label>
		{/each}
	</div>
</div>

```

## Component: `DatePicker`
This component wraps a standard HTML input which is used to display the selected date, with an instance of [`svelty-picker`](https://www.npmjs.com/package/svelty-picker) which is used to select dates and times.

This component has to handle several events on the underlying `input` element to manage opening/closing the underlying `SveltyPicker` component. It also needs to watch for the `on:input` event from the `SveltyPicker` to update the value of the `input` element. There are some other event handlers that I won't go into the details of that were required just to make sure the picker opens and closes at the right times, and doesn't close while interacting with it.

It uses absolute positioning relative to the container `div` to display the picker in the proper location, and uses the tailwind `hidden` class to hide/show the picker.

Properties:
- `id` **required** - id of the underlying `input` element
- `name` **required** - name of the underlying `input` element
- `label` **optional** - placeholder and label text for field (default: `Select date`)
- `format` **optional** - Date format to use in the display field (default: `mm-dd-yyy`) - see **standard formats** section of [svelty-picker documentation](https://mskocik.github.io/svelty-picker/formatting) for more information
- `value` **optional** - the value of the field, can also be bound to (default: `''`)
- `error` **optional** - the errors message to display on invalid value

File: `$lib/components/form-fields/DatePicker.svelte`
{: .code-label }

```html
<script>
	import SveltyPicker from 'svelty-picker';
	import FieldError from '$lib/components/form-fields/FieldError.svelte';

	function handleOpen() {
		picker.classList.remove('invisible');
	}

	/**
	 * Handle input changed events from underlying svelty-picker
	 * @param {CustomEvent | {detail: string}} e
	 */
	function handleInput(e) {
		value = e.detail;
		handleClose();
	}

	function handleClose() {
		picker.classList.add('invisible');
	}

	export let /** @type string */ id;
	export let /** @type string */ name;
	export let /** @type string */ label = 'Select date';
	export let /** @type string */ format = 'mm-dd-yyyy';
	export let /** @type string */ value = '';
	export let /** @type string */ error;

	let /** @type {HTMLElement}*/ picker;
</script>

<!--
  @component
  This is a custom date picker component that provides a material design
  with a floating placeholder/label, by wrapping a normal `input` element
  and providing a floating date picker UI

  ...
-->
<div class="relative">
	<input
		type="text"
		{id}
		{name}
		class="peer input variant-form-material border-0 border-b-2 !border-blackcoffee-300 bg-surface-500/10 pb-1 pl-4 pt-3 placeholder-transparent placeholder-shown:py-2"
		placeholder={label}
		bind:value
		autocomplete="off"
		on:click={handleOpen}
		on:focus={handleOpen}
		on:focusout={handleClose}
		on:keypress|preventDefault
		on:keydown|preventDefault
	/>
	<label
		for={name}
		class="absolute left-4 top-0 text-xs font-semibold text-blackcoffee-500/70 transition-all duration-200 peer-placeholder-shown:top-[0.55rem] peer-placeholder-shown:text-base peer-placeholder-shown:font-normal peer-placeholder-shown:text-blackcoffee-500/60"
		>{label}</label
	>
	<span class="invisible absolute left-0 top-11 z-10" bind:this={picker}
		><SveltyPicker
			pickerOnly={true}
			mode="date"
			{format}
			on:input={handleInput}
			on:blur={handleClose}
			on:mousedown={handleOpen}
		/></span
	>

	<FieldError {error} />
</div>

```

## Component: `TimePicker`
This component functions in exactly the same way as the `DatePicker` component, but it uses the `time` mode of the `SveltyPicker` instead.

Props:
- `id` **required** - id of the underlying `input` element
- `name` **required** - name of the underlying `input` element
- `label` **optional** - placeholder and label text for field (default: `Select time`)
- `format` **optional** - Time format to use in the display field (default: `HH:ii P`) - see standard formats section of [svelty-picker documentation](https://mskocik.github.io/svelty-picker/formatting)
- `value` **optional** - the value of the field, can also be bound to (default: `''`)
- `error` **optional** - the errors message to display on invalid value

File: `$lib/components/form-fields/TimePicker.svelte`
{: .code-label }

```html
<script>
	import SveltyPicker from 'svelty-picker';
	import FieldError from '$lib/components/form-fields/FieldError.svelte';

	function handleOpen() {
		picker.classList.remove('invisible');
	}

	/**
	 * Handle input changed events from underlying svelty-picker
	 * @param {CustomEvent | {detail: string}} e
	 */
	function handleInput(e) {
		value = e.detail;
		handleClose();
	}

	function handleClose() {
		picker.classList.add('invisible');
	}

	export let /** @type string */ id;
	export let /** @type string */ name;
	export let /** @type string */ label = 'Select time';
	export let /** @type string */ format = 'HH:ii P';
	export let /** @type string */ value = '';
	export let /** @type string */ error;

	let /** @type {HTMLElement}*/ picker;
</script>

<!--
  @component
  This is a custom time picker component that provides a material design
  with a floating placeholder/label, by wrapping a normal `input` element
  and providing a floating time picker UI

  ...
-->
<div class="relative">
	<input
		type="text"
		{id}
		{name}
		class="peer input variant-form-material border-0 border-b-2 !border-blackcoffee-300 bg-surface-500/10 pb-1 pl-4 pt-3 placeholder-transparent placeholder-shown:py-2"
		placeholder={label}
		bind:value
		autocomplete="off"
		on:click={handleOpen}
		on:focus={handleOpen}
		on:focusout={handleClose}
		on:keypress|preventDefault
		on:keydown|preventDefault
	/>
	<label
		for={name}
		class="absolute left-4 top-0 text-xs font-semibold text-blackcoffee-500/70 transition-all duration-200 peer-placeholder-shown:top-[0.55rem] peer-placeholder-shown:text-base peer-placeholder-shown:font-normal peer-placeholder-shown:text-blackcoffee-500/60"
		>{label}</label
	>
	<span class="invisible absolute left-0 top-11 z-10" bind:this={picker}>
		<SveltyPicker
			pickerOnly={true}
			mode="time"
			{format}
			autocommit={false}
			on:input={handleInput}
			on:blur={handleClose}
			on:mousedown={handleOpen}
		/>
	</span>

	<FieldError {error} />
</div>

```

## Component: `Select`
The select component is the most complicated of the custom components, as it must track internal state as well as displaying a custom formatted select menu, and proxying actions on the displayed menu to the underlying `select` element.

Properties:
- `id` **required** - `id` attribute for the select element
- `name` **required** - `name` attribute of the select element
- `label` **optional** - placeholder and label text for field (default: `Select a value`)
- `options` **required** - a list of `SelectOption` objects that will be used to render the options list
- `value` **optional** - the value of the field, can also be bound to (default: `''`)
- `error` **optional** - the errors message to display on invalid value

`SelectOption` properties:
- `value` **required** - `value` attribute for the option item
- `display` **required** - display text for the option item
- `secondary` **optional** - secondary text for the option item. If supplied, this text will appear in semi-bold before the display text, and the display text will be bold
- `description` **optional** - This value can be used to provide a description that will show up below the display and secondary text, and can also accept raw HTML to allow for custom markup, like a list, grid, or table.

File: `$lib/components/form-fields/Select.svelte`
{: .code-label }

```html
<script>
	import FieldError from '$lib/components/form-fields/FieldError.svelte';
	import { clickOutside } from '$lib/actions';
	/**
	 * @typedef {Object} SelectOption
	 * @property {string} value
	 * @property {string} display
	 * @property {string} [secondary]
	 * @property {string} [description]
	 */

	function toggleOptionsShown() {
		isOpen = !isOpen;
	}

	function closeOptions() {
		isOpen = false;
	}

	/**
	 * @param {KeyboardEvent  & { currentTarget: EventTarget & HTMLDivElement }} event
	 */
	function handleSelectKeypress(event) {
		throw new Error('Function not implemented.');
	}

	/**
	 * @param {KeyboardEvent  & { currentTarget: EventTarget & HTMLDivElement }} event
	 */
	function handleOptionKeypress(event) {
		throw new Error('Function not implemented.');
	}

	let isOpen = false;
	export let /** @type string */ id;
	export let /** @type string */ name;
	export let /** @type string */ placeholder = 'Select a value';
	export let /** @type SelectOption[] */ options;
	export let /** @type string */ value = '';
	export let /** @type string */ error;

	$: isPlaceholderShown = value === '';
</script>

<!--
  @component
  This is a custom `select` component that provides a material design
  with a floating placeholder/label, and a customizable option list.

  ...
-->
<div class="relative" use:clickOutside on:click_outside={closeOptions}>
	<!-- Hidden select element that will store the selected item. -->
	<select {id} {name} {value} class="hidden">
		<option value="" />
		{#each options as option}
			<option value={option.value}>{option.display}</option>
		{/each}
	</select>

	<!-- Custom listbox implementation that will update the hidden select field. -->
	<div
		role="listbox"
		class="select variant-form-material border-blackcoffee-300 pb-1 pl-4 pt-3 text-left text-blackcoffee/70 after:absolute after:right-4 after:top-4 after:h-2 after:w-2 after:border-b-[0.175rem] after:border-r-[0.127rem] after:border-blackcoffee-300 after:content-[''] focus:border-blackcoffee-300 focus:outline-none"
		class:open={isOpen}
		class:selected={!isPlaceholderShown}
		on:click={toggleOptionsShown}
		on:keypress={handleSelectKeypress}
		tabindex="0"
	>
		{isPlaceholderShown ? placeholder : value}
	</div>

	<!-- Options list container -->
	<div
		class="options rounded-b-md border-[1px] border-t-0 border-blackcoffee-300 bg-surface-400"
		class:hide={!isOpen}
	>
		{#each options as option}
			<!-- Option item container -->
			<div
				class="border-b-[1px] border-blackcoffee-300 p-2 pl-4 text-left last:rounded-b-md last:border-none hover:bg-surface-500"
				role="option"
				tabindex="0"
				aria-selected={option.value === value}
				on:click={() => {
					value = option.value;
					toggleOptionsShown();
				}}
				on:keypress={handleOptionKeypress}
			>
				<!-- Secondary text, shown in semi-bold font weight-->
				{#if option.secondary}
					<span class="font-semibold">
						{option.secondary}
					</span>
				{/if}

				<!-- Primary display text, shown in bold ONLY IF there is secondary text -->
				<span class:font-bold={option.secondary}>
					{option.display}
				</span>

				<!-- Description Container, allows me to provide custom HTML. -->
				{#if option.description}
					<span class="block text-sm leading-3 tracking-tight text-blackcoffee/70"
						>{@html option.description}</span
					>
				{/if}
			</div>
		{/each}
	</div>

	<label
		for="session"
		class="absolute left-4 top-3 hidden text-base font-normal"
		class:floating={!isPlaceholderShown}>{placeholder}</label
	>

	<FieldError {error} />
</div>

<style lang="postcss">
	.select.selected {
		@apply text-primary-500;
	}

	/*chevron inside select box*/
	.select:after {
		transform: rotate(45deg);
	}

	/*point the chevron upwards when options list shown:*/
	.select.open:after {
		transform: translateY(0.25rem) rotate(-135deg);
	}

	/*prevent select of options and current selected*/
	.options div,
	.select {
		user-select: none;
	}

	.hide {
		display: none;
	}

	.options {
		position: absolute;
		top: 100%;
		left: 0;
		right: 0;
		z-index: 99;
	}

	label.floating {
		transition-property: all;
		transition-timing-function: cubic-bezier(0.4, 0, 0.2, 1);
		transition-duration: 200ms;
		@apply text-blackcoffee-500/70;
	}
</style>

```

# BookingForm
I extracted all of the form logic out to it's own component, and it's now in charge of:
- importing all of the data for the select options
- handling validation
- submitting form via ajax

## Data Import
To make future content management easier for package types and sessions (especially for package types which are referenced in multiple places on the site), I extracted these to their own javascript files where the data can be easily managed in one place.

### Session Types
This file exports a simple array containing the different session types offered.

File: `$lib/data/sessionTypes.js`
{: .code-label }

```js
const sessionTypes = [
	'Portrait',
	'Boudoir',
	'Couples/Wedding',
	'Family',
	'Maternity/Newborn',
	'Business',
	'Other',
];

export default sessionTypes;

```

To coalesce the data into the proper shape, I need to convert this `string[]` into an object compatible with the `SelectItem` type used by the `Select` component, using `Array.map()`.

```js
	...
	import sessionTypes from '$lib/data/sessionTypes';
	...
	const sessionTypeOptions = sessionTypes.map((type) => {
		return { value: type, display: type };
	});
	...
```

### Pricing
This file contains all of the packages and add-ons. The add-ons are used on the pricing page, but only the packages are needed for the booking form.

```js
const packages = [
	{
		name: 'Day Dream',
		price: 170,
		features: [
			'1 hour',
			'1 location',
			'up to 5 subjects',
			'20-30 edits',
			'access to client wardrobe',
			'3-4 week turnaround',
		],
	},
	{
		name: 'Sweet Dream',
		price: 270,
		features: [
			'1.5 hours',
			'1-2 locations',
			'up to 8 subjects',
			'30-40 edits',
			'access to client wardrobe',
			'2-3 week turnaround',
		],
	},
	{
		name: 'Dream Come True',
		price: 370,
		features: [
			'2 hours',
			'1-2 locations',
			'unlimited subjects',
			'40-50 edits',
			'access to client wardrobe',
			'1-2 week turnaround',
		],
	},
];

const addOns = [ ... ];

export default {
	packages,
	addOns,
};

```

Coalescing the package options into a `SelectOption` shape is a little more involved, since I have to generate the `secondary` property (price) and `description` (features), as well as including an additional option for event consultations that is not in the packages list.

Again, I use `Array.map()` to convert each package to the proper format. Inside the map callback, I use `Array.reduce()` to convert the `features` array into a string. I then use array destructuring to combine the result of this map call with the static option for event consultations.

```js
	...
	import pricing from '$lib/data/pricing';
	...
	const packageOptions = [
		...pricing.packages.map((p) => {
			const featureList = p.features.reduce((prev, curr) => {
				return prev + `<div class="p-0">${curr}</div>`;
			}, '');

			return {
				value: p.name,
				display: p.name,
				secondary: `$${p.price}`,
				description: `<div class="grid grid-cols-2">${featureList}</div>`,
			};
		}),
		{
			value: 'Event Consultation',
			display: 'Event Consultation',
			secondary: 'FREE',
			description: 'request a consultation for an upcoming event.',
		},
	];
	...
```

## Validation
For validation, each component provides a bindable `value` property which allows the `BookingForm` to access the value of each field. When the submit button is clicked, each field is checked for validity using the functions in the `validation.js` module.

File: `$lib/validation.js`
{: .code-label }

```js
// https://regex101.com/r/A53nPA/1
const phoneRegex = /\d{0,1}-*\d{3}-*\d{3}-*\d{4}/gm;

// https://regex101.com/r/6vK9rH/1
const emailRegex = /^[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}$/gim;

/**
 * Verify that a string is not empty
 * @param {string} value Value to validate
 * @returns {boolean} false if `value` is empty, true otherwise
 */
function notEmpty(value) {
	if (!value || value === '') {
		return false;
	}
	return true;
}

/**
 *  Verify that `value` is a valid phone number format
 * @param {string} value Value to validate
 * @returns {boolean} true if value is a valid phone number
 */
function validPhone(value) {
	return new RegExp(phoneRegex).test(value);
}

/**
 * Verify that `value` is a valid email address format
 * @param {string} value Value to validate
 * @returns {boolean} true if value is a valid email address
 */
function validEmail(value) {
	return new RegExp(emailRegex).test(value);
}

export { notEmpty, validPhone, validEmail };
```

Any fields that are not valid will have their `error` property set to an error message which will be displayed below the field on the form. Any invalid fields will cause the form to not be submitted.

## AJAX Form Submission
Once the fields are all validated, the form will be submitted with AJAX using the `fetch` api. Currently the form utilizes [Netlify's Serverless Form handling](https://docs.netlify.com/forms/setup), so I can just submit the request to the root of the website, and netlify will know what form is being submitted based on the supplied `form-name` field. If the form submission is successful, then a success modal is shown to the user. If not, alert the contents of the error message to the user.

AJAX Submission:
{: .code-label }

```js
/**
	 * Submit the form
	 */
	function submit() {
		const formData = new FormData();

		if (!validate()) {
			return;
		}

		formData.append('form-name', 'booking'); // for netlify forms
		formData.append('name', name);
		formData.append('phone', phone);
		formData.append('email', email);
		formData.append('preferredContact', preferredContact);
		formData.append('packageType', packageType);
		formData.append('sessionType', sessionType);
		formData.append('date', date);
		formData.append('time', time);
		formData.append('subjects', subjects);
		formData.append('additionalInfo', additionalInfo);

		fetch('/', {
			method: 'POST',
			headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
			body: new URLSearchParams(formData).toString(),
		})
			.then((response) => {
				if (response.ok) {
					if (successModal) {
						successModal.show();
					} else {
						alert('Thank you for your submission');
					}
				} else {
					console.log(response);
					alert(`${response.status} - ${response.statusText}`);
				}
			})
			.catch((error) => {
				console.log(error);
				alert(error);
			});
	}
```

Success Modal - `$lib/components/form-fields/SuccessModal.svelte`
{: .code-label }

The success modal is a modal that provides a method to show the modal, as well as a `name` property to personalize the text of the modal with the name of the person submitting the form.
{: .code-desc }

```html
<script>
	let shown = false;
	export function show() {
		shown = true;
	}

	export let /** @type string */ name;
</script>

<div class="fixed inset-0 bg-blackcoffee/60" class:hidden={!shown} />
<div
	class=" fixed left-0 right-0 z-50 mx-8 rounded-lg bg-gradient-to-b from-eggshell to-eggshell px-4 py-10 shadow-2xl shadow-black drop-shadow-2xl sm:mx-auto sm:max-w-lg sm:!px-20 sm:!py-20"
	class:hidden={!shown}
>
	<h3 class="text-4xl uppercase">Thank you</h3>
	{#if name}
		<h3 class="text-4xl uppercase">{name}</h3>
	{/if}
	<p class="mt-6 text-xl leading-8 tracking-tight text-blackcoffee/70">
		We have received your booking inquiry and will reach out soon to finalize!
	</p>
	<button
		class="btn variant-soft-success mt-8 text-lg"
		on:click={() => {
			shown = false;
		}}>Continue</button
	>
</div>

```