// ==UserScript==
// @name 				🔗LinkChecker
// @version  		1.0.0
// @namespace 	TELUS
// @description Test links on the page and report errors to user (before they try to click them)
// @match       http://localhost/*
// @run-at   		document-end
// @grant GM_registerMenuCommand
// @grant GM_getValue
// @grant GM_setValue
// @grant GM_deleteValue
// @grant GM_addStyle
// @grant GM_xmlhttpRequest
// @require https://code.jquery.com/jquery-2.2.1.js
// @require https://code.jquery.com/ui/1.11.4/jquery-ui.js
// @require https://raw.githubusercontent.com/TerryCross/code/master/GM4_registerMenuCommand_Submenu_JS_Module.js
// @require      https://gist.github.com/raw/2625891/waitForKeyElements.js
// @resource jqueryuiCss https://code.jquery.com/ui/1.11.4/themes/vader/jquery-ui.css
// ==/UserScript==

console.log('🔗 LinkCkecker init...')

// Set the interval for testing links (in milliseconds)
const interval = 5000;

// Get all links and buttons on the page
const selectElements = 'a, button';

// Set the Valid HTTP response codes to check for
const validCodes = [200, 201, 202, 203, 204, 205, 206, 207, 208, 226];

// Set the icon to display for broken links
const icon = 'https://www.svgrepo.com/download/206435/alert.svg';
const iconAlert = 'https://www.svgrepo.com/download/206435/alert.svg';
const errorIconClass = 'link-error-detected';
const iconHeight = '20px';
const iconWidth = '20px';

function createImage(text, src, elmClass) {
  const img = document.createElement('img');
  img.src = src;
  img.alt = text;
  img.style.verticalAlign = 'middle';
  img.style.width = iconHeight;
  img.style.height = iconWidth;
  img.classList.add(elmClass);
  return img;
}

function clearLinks() {
  const errorIcons = document.getElementsByClassName(errorIconClass);

  console.log('🔗 Error icons: ', errorIcons);

  for (const icon of errorIcons) {
    console.log('🔗 Error icon: ', icon);
  }
}

function testLinks() {
  const linkCount = $(selectElements).length;
  let validLinks = 0;

  $(selectElements).each(function() {

    // console.log('🔗 Test link: ', $(this));

    let error = false;
    // Disable the element
    $(this).prop('disabled', true);

    // Test the link or button
    const url = $(this).attr('href') || $(this).attr('action');

    // console.log('🔗 Test url: \n\n', url, '\n\nindexOf: ', url.indexOf('#'));

    if (url != null && url.indexOf('#') !== 0 && $(this).is(":visible") === true) {
			linkCount++;
      // Add an icon (testing...)
      const img = createImage('Error', icon, errorIconClass);
      $(this).parent().insertBefore(img);

      console.log('🔗 Test element, link: \n\n', $(this), '\n\nvisible: ',$(this).is(":visible"),'\nurl: ', url, '\n\n');

      fetch(url)
        .then(response => {
          // Check if the response code is valid
          if (!validCodes.includes(response.status)) {
            // Display an error message
            const message = `Error ${response.status}: ${response.statusText}`;

            console.log('🔗 Error: Invalid response code: ', message);

            $(this).attr('title', message);
            img.title = message;
            img.src = iconAlert;

          } else {
            // Remove the error message and icon

            console.log('🔗 Link OK');

            $(this).attr('title', '');
            img.title = '';
            img.remove();
            $(this).prop('disabled', false);
          }
        })
        .catch(error => {
          // Display an error message
          const message = `Error: ${error.message}`;
          $(this).attr('title', message);
          img.title = message;
        	img.src = iconAlert;

          console.log('🔗 Caught error: ', message);
        });
    } else {
      // console.log('🔗 empty link - OK: ', element);
    }
  });

  console.log('Links: ',linkCount, '\nvalid links: ', validLinks)
}

// Set the interval for re-testing links
setInterval(() => {
  testLinks()
}, interval);
