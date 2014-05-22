#Cloud Explorer, file picker for the cloud
Cloud Explorer enables your application or website users with picking their files from the cloud.

Cloud Explorer is a free and open source project [powered by Silex Labs](http://www.silexlabs.org/).

Authored by Thomas Fétiveau [@zab0jad](https://twitter.com/zab0jad) and Alexandre Hoyau [@lexoyo](https://twitter.com/lexoyo).

##About Cloud Explorer

Cloud Explorer aims to provide an open source client library that exposes the same API as the [Ink File Picker API](https://developers.inkfilepicker.com/docs/web/).

Cloud Explorer is the front end client of the [unifile](https://github.com/silexlabs/unifile) backend, a nodejs server which provides a unified access to cloud services. This project uses nodejs and those modules: express, dbox, express, googleapis, logger, node-oauth, oauth, path.

The backend is in node.js and the front end is in Javascript. Cloud Explorer is written with [Haxe](http://www.haxe.org), enabling a modern and elegant syntax as well as a strong typed and more reliable javascript source code.

The project is not mature yet and doesn't provide half of what is provided by Ink File Picker. It's however under constant development and will provide more and more of the IPF API every week plus some extra features we've found useful for our projects but that were not offered by IPF.

Cloud Explorer is also skinable with CSS and hostable in house.

###Discussions

* Facebook http://www.facebook.com/silexlabs
* Twitter https://twitter.com/silexlabs
* Google plus https://plus.google.com/communities/107373636457908189681

###Licensing

Cloud Explorer is licensed under the MIT license.

![Cloud explorer user interface](https://raw.github.com/silexlabs/cloud-explorer/haxe-refactoring/screenshot01.png)
![Cloud explorer user interface](https://raw.github.com/silexlabs/cloud-explorer/haxe-refactoring/screenshot02.png)
![Cloud explorer user interface](https://raw.github.com/silexlabs/cloud-explorer/haxe-refactoring/screenshot03.png)
![Cloud explorer user interface](https://raw.github.com/silexlabs/cloud-explorer/haxe-refactoring/screenshot04.png)
![Cloud explorer user interface](https://raw.github.com/silexlabs/cloud-explorer/haxe-refactoring/screenshot05.png)
![Cloud explorer user interface](https://raw.github.com/silexlabs/cloud-explorer/haxe-refactoring/screenshot06.png)

##Setup

### Development or Test

Prerequisite :

* [node.js](http://nodejs.org/) installed
* [NPM](https://npmjs.org/) installed
* [Haxe compiler](http://haxe.org/download) installed

Cloud Explorer default development environment uses [grunt](http://gruntjs.com/) (nodejs), [compass](http://compass-style.org/) and few other little tools that aim to make developping CE easier and faster.

For early testers and contributors, here are the setup steps to follow in order to run this version of CE:

* git clone this branch on your local file system,
```
git clone git@github.com:silexlabs/cloud-explorer.git cloud-explorer

git fetch

git checkout -b haxe-refactoring
```

* run the following command in a terminal to install the nodejs dependencies:
```
npm install
```

* run the following command in a terminal to start the local server:
```
grunt server
```

* compile the haxe js sources
```
haxe build.hxml
```

* open your favorite HTML5 browser on http://localhost:6805/ to have the test page displayed. From there, click the buttons corresponding to the API functions you want to test. Some of them are not yet implemented.

### Production

To install and use Cloud Explorer in your projects, follow those steps :

* compile the Cloud Explorer library out of this repository:
```
grunt
```
You will then find the full Cloud Explorer library under bin/web. Place the entire bin/web directory in a subdirectory of your web app project (you may rename web into cloud-explorer).

* include the Cloud Explorer javascript file in your web page:
```
<!DOCTYPE html>
<html>
    <head>
        <title>My project</title>
        <script src="cloud-explorer/scripts/cloud-explorer.js"></script>
    </head>
    <body>

    (...)

    </body>
</html>
```
We assume that you've pasted the Cloud Explorer lib files in the cloud-explorer sub directory.

* To use it from your project js code, first initialize a Cloud Explorer instance:
```
window.document.onload = function(e){

	window.cloudExplorer = ce.api.CloudExplorer.get();
}
```

Note that you can also precise the iframe element id that will be used by Cloud Explorer. If not specified, one will be automatically generated.
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

* You will then be able to call it like you would call Ink File Picker:
```
cloudExplorer.pick(function(b){

        console.log("my Blob: " + JSON.stringify(b));

    }, function(e){ console.log("error " + JSON.stringify(e)); });
```

#### Configuration

To pass configuration variables to Cloud Explorer, specify the iframe it will use as described earlier:
```
        <iframe id="ce-js"
                frameborder="no" 
                scrolling="no"
                allowfullscreen="yes"
                data-ce-unifile-url="http://cloud-explorer.herokuapp.com/api/1.0/">

        </iframe>
```
This will allow you to add the below supported configuration properties: 

* data-ce-unifile-url: the url of the unifile root endpoint your instance of Cloud Explorer will use.
* data-ce-path: path to the folder containing the cloud-explorer files on your server.

## Current implementation state and roadmap

### Currently supported cloud services

* hosting server (www), transfer files from and to your own unifile server
* [Dropbox](http://www.dropbox.com)

More to come soon...

### Currently supported features

The currently implemented part of the IPF API in Cloud Explorer consists of:

* [CEBlob](https://developers.inkfilepicker.com/docs/web/#inkblob)

Supported fields: url, filename, mimetype, size

Other fields will return null.

* [Pick Files](https://developers.inkfilepicker.com/docs/web/#pick)
```
cloudExplorer.pick(function(b){

        currentBlob = b;

        textarea.val(textarea.val() + "\ncurrentBlob: " + JSON.stringify(currentBlob));

    }, function(e){ console.log("error " + JSON.stringify(e)); });
```

No option supported yet. Will just pick a file from your favorite cloud service and give back a CEBlob instance.


* [Export](https://developers.inkfilepicker.com/docs/web/#export)
```
cloudExplorer.exportFile(currentBlob, { mimetype: "text/html" }, function(b){

        currentBlob = b;

        textarea.val(textarea.val() + "\ncurrentBlob is now: " + JSON.stringify(currentBlob));

    }, function(e){ console.log("error " + JSON.stringify(e)); });
```

Supported options are: mimetype, extension.

This function doesn't work exactly like the IFP yet as it will need a call to write() after the call to export() to actually write the file. For now, it will just generate a CEBlob instance corresponding to the new file you want to create/store.

* [Write back to a file](https://developers.inkfilepicker.com/docs/web/#write)
```
cloudExplorer.write(currentBlob, "write() test succeeded", function(ceb){

        currentBlob = ceb;

        textarea.val(textarea.val() + "\nwrite operation successful!");

    }, function(e){ console.log("error " + JSON.stringify(e)); });
```

No option supported yet.
* [Read Files](https://developers.inkfilepicker.com/docs/web/#read)

```
cloudExplorer.read(currentBlob, function(d){

        textarea.val(textarea.val() + "\nread data: " + d);

    }, function(e){ console.log("error " + JSON.stringify(e)); });
```

No option supported yet.

### Roadmap

Current version is 1.0. It is a complete refactoring of the previous 0.1 version that was dependant on JQuery and AngularJS. Version 1.0 has no client side dependency and is implemented with Haxe, allowing future ports of the basecode to native mobile/desktop, Flash/AIR, ...

The goals of version 1.1 are simple: implement the full Ink File Picker API (web version).

## Contributions

We love contributions and consider all kind of pull requests:

* new themes or improvments of existing default theme
* new components or functionnalities
* additions to the documentation
* bug reports, fixes
* any idea or suggestion


