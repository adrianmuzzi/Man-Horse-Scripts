/*
Content scripts run in the context of a web page.
In the manifest.json- the content_scripts key specifies an array of content script objects, 
each of which specifies a URL pattern to match and a list of JavaScript files to run on that page.
*/
console.log("Content script running!");
document.body.style.backgroundColor = "yellow";