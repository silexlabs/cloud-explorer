#Cloud explorer, your users pick their files

##About the cloud explorer

File manager for cloud services, which lets you manipulate your users files in the cloud.

> cloudExplorer.pick(function(result){
>   console.log(result.url);
> });

The backend is in node.js and the front end is in Javascript. This is a free and open source project [powered by Silex Labs](http://www.silexlabs.org/).

The project follows partially the API of the Ink File Picker project : https://developers.inkfilepicker.com/docs/web

At the moment, Cloud explorer partially implements the following methods :

* https://developers.inkfilepicker.com/docs/web/#pick
* https://developers.inkfilepicker.com/docs/web/#read
* https://developers.inkfilepicker.com/docs/web/#write
* https://developers.inkfilepicker.com/docs/web/#export

* the InkBlob prototype is not yet fully implemented in cloud explorer.

An example of cloud explorer integration in a web page can be found in /lib/app/index.html

Discussions

* Facebook http://www.facebook.com/silexlabs
* Twitter https://twitter.com/silexlabs
* Google plus https://plus.google.com/communities/107373636457908189681

GPL license

![Cloud explorer user interface](https://raw.github.com/silexlabs/cloud-explorer/v0.1.x/screenshot1.png)
![Cloud explorer user interface](https://raw.github.com/silexlabs/cloud-explorer/v0.1.x/screenshot2.png)
![Cloud explorer user interface](https://raw.github.com/silexlabs/cloud-explorer/v0.1.x/screenshot3.png)
![Cloud explorer user interface](https://raw.github.com/silexlabs/cloud-explorer/v0.1.x/screenshot4.png)

Main contributors

* [Thomas Fétiveau](http://www.tokom.fr/) [@zab0jad](https://twitter.com/zab0jad)
* Alex [lexoyo](http://lexoyo.me) Hoyau [@lexoyo](http://twitter.com/lexoyo)

Roadmap

If you plan to use cloud explorer in your current project, it is important for you to know the next big changes that will be performed in cloud explorer :

* cloud explorer will be ported to haxe (www.haxe.org) in a very soon refactoring and the angular js dependency will be removed.
* cloud explorer will always be compatible with the Ink File Picker API : https://developers.inkfilepicker.com/docs/web

##Installation on your local computer

### local installation on linux or macos

Prerequisite :

* [node.js](http://nodejs.org/) installed
* [NPM installed](https://npmjs.org/)

Clone this repository, and do not forget the sub modules (cloud-explorer and unifile)

Install node modules: npm install

Configure the unifile module. If you use Cloud-Explorer with a root path other than "/" like "/cloud-explorer" for example (by default), edit the node_modules/unifile/lib/default-config.js file like this :
```
/**
 * route name for unifile api
 */
exports.apiRoot = "/cloud-explorer/api"; // specify your root path before /api

/**
 * static folders
 */
exports.staticFolders = [
	// assets
	{
		name: "/cloud-explorer/unifile-assets", // specify your root path before /unifile-assets
		path: "../../unifile-assets/"
	}
];
```

Start the server: node server/api-server.js

Open http://localhost:6805/cloud-explorer/app/index.html in a browser and you'll see the example of cloud-explorer integration in a web page.

### local installation on Windows

> instructions provided by Régis RIGAUD :)

Prerequisite :

* [node.js](http://nodejs.org/) installed
* Git Client installed (e.g. [windows github client](http://windows.github.com/))
* [NPM installed](https://npmjs.org/)

Installation of the cloud explorer

* Launch the "Git Shell"
* Create a complete clone of Silex Project : git clone --recursive https://github.com/silexlabs/cloud-explorer.git
* Go to the cloud explorer's Directory.
* install depedencies  : npm install
* Configure the unifile module. If you use Cloud-Explorer with a root path other than "/" like "/cloud-explorer" for example (by default), edit the node_modules/unifile/lib/default-config.js file like this :
```
/**
 * route name for unifile api
 */
exports.apiRoot = "/cloud-explorer/api"; // specify your root path before /api

/**
 * static folders
 */
exports.staticFolders = [
	// assets
	{
		name: "/cloud-explorer/unifile-assets", // specify your root path before /unifile-assets
		path: "../../unifile-assets/"
	}
];
```
* Start the unifile server from a command prompt: node server/api-server.js
* Open your favorite browser on http://localhost:6805/cloud-explorer/app/index.html in a browser and you'll see the example of cloud-explorer integration in a web page.

##dependencies

These are the upstream projects we use in Silex

* [unifile](https://github.com/silexlabs/unifile), a nodejs server which provides a unified access to cloud services. This projects uses nodejs and these modules: express, dbox, express, googleapis, logger, node-oauth, oauth, path

