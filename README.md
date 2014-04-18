#Cloud Explorer, your users pick their files from the cloud
This is a free and open source project [powered by Silex Labs](http://www.silexlabs.org/).

Authored by Thomas Fétiveau [@zab0jad](https://twitter.com/zab0jad) and Alexandre Hoyau [@lexoyo](https://twitter.com/lexoyo).

##About the cloud explorer

Cloud Explorer aims to provide an open source client library that exposes the same API as [Ink File Picker API](https://developers.inkfilepicker.com/docs/web/).

Cloud Explorer is the front end client of the [unifile](https://github.com/silexlabs/unifile) backend, a nodejs server which provides a unified access to cloud services. This project uses nodejs and those modules: express, dbox, express, googleapis, logger, node-oauth, oauth, path.

The backend is in node.js and the front end is in Javascript. Cloud Explorer is written with [Haxe](http://www.haxe.org), enabling a modern and elegant syntax as well as a strong typed and more reliable javascript source code.

The project is not mature yet and doesn't provide half of what is provided by Ink File Picker. It's however under constant development and will provide more and more of the IPF API every week plus some extra features we've found useful for our projects but that were not offered by IPF.

###Discussions

* Facebook http://www.facebook.com/silexlabs
* Twitter https://twitter.com/silexlabs
* Google plus https://plus.google.com/communities/107373636457908189681

###Licensing

Cloud Explorer is licensed under the MIT license.

##Setup

### Development or Test

Prerequisite :

* [node.js](http://nodejs.org/) installed
* [NPM installed](https://npmjs.org/)
* [Haxe compiler installed](http://haxe.org/download)

Cloud Explorer default development environment uses (grunt)[http://gruntjs.com/] (nodejs), (compass)[http://compass-style.org/] and few other little tools that aim to make developping CE easier and faster.

For early testers and contributors, here are the setup steps to follow in order to run this version of CE:

 - git clone this branch on your local file system,
```
git clone git@github.com:silexlabs/cloud-explorer.git cloud-explorer

git fetch

git checkout -b haxe-refactoring
```

 - run the following command in a terminal to install the nodejs dependencies:
```
npm install
```

 - run the following command in a terminal to start the local server:
```
grunt server
```

 - compile the haxe js sources
```
haxe build.hxml
```

 - open your favorite HTML5 browser on http://localhost:6805/ to have the test page displayed. From there, click the buttons corresponding to the API functions you want to test. Some of them are not yet implemented.

### Production

To install and use Cloud Explorer in your projects, follow those steps :

 - include the Cloud Explorer javascript file in your web page:
```
<!DOCTYPE html>
<html>
    <head>
        <title>My project</title>
        <script src="scripts/cloud-explorer.js"></script>
    </head>
    <body>

    (...)

    </body>
</html>
```

 - To use it from your project js code, first initalize a Cloud Explorer instance:
```
window.document.onload = function(e){

	window.cloudExplorer = ce.api.CloudExplorer.get();
}
```

Note that you can also precise the iframe element id that will be used by Cloud Explorer:
```
(...)
		<iframe id="ce-js"
                frameborder="no" 
                scrolling="no"
                allowfullscreen="yes">

        </iframe>
(...)
<script type="text/javascript">
	window.document.onload = function(e){

		window.cloudExplorer = ce.api.CloudExplorer.get("ce-js");
	}
</script>
```

 - You then will be able to call it like you would call Ink File Picker:
```
cloudExplorer.pick(function(b){

        console.log("my Blob: " + JSON.stringify(b));

    }, function(e){ console.log("error " + JSON.stringify(e)); });
``` 


