// Add auto formatting of everything between .code-label and .highlighter-rogue elements

function formatCodeDesc() {
  function isCodeBlock(elem) {
    // Skip processing if the next sibling is a code block.
    const isHighlightedCodeBlock = elem.hasClass('highlighter-rouge');
    // when a language is not recognized, it is wrapped in a pre block,
    // which causes the upcoming loop to run forever and stall the page.
    const isPreBlock = elem.prop('tagName') === 'PRE';

    return isPreBlock || isHighlightedCodeBlock;
  }

  $('.code-label').each((i, label) => {
    // console.log(label);
    let sibling = $(label).next();
    let previousSibling = sibling;

    // Skip if next element is already a code block
    if (isCodeBlock(sibling)) {
      return;
    }

    // Add code-dec-first class to first sibling, before loop
    sibling.addClass('code-desc-first');

    while (!isCodeBlock(sibling)) {
      // Add code-desc class to every sibling, including first and last
      sibling.addClass('code-desc');

      previousSibling = sibling;
      sibling = sibling.next();
    }

    // Add code-desc-last class to previous sibling after loop
    previousSibling.addClass('code-desc-last');
  });
}

// Add ability to make code blocks collapsible with a class .code-collapse

// Add ability to highlight code lines

$(() => {
  formatCodeDesc();
});
