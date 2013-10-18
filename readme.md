#Cloud explorer, your users pick their files

##About the cloud explorer

File manager for cloud services, which lets you manipulate your users files in the cloud.

> cloudExplorer.pick(function(result){
>   console.log(result.url);
> });

The backend is in node.js and the front end is in Javascript. This is a free and open source project [powered by Silex Labs](http://www.silexlabs.org/).

Discussions

* Facebook http://www.facebook.com/silexlabs
* Twitter https://twitter.com/silexlabs
* Google plus https://plus.google.com/communities/107373636457908189681

GPL license

![Cloud explorer user interface](https://raw.github.com/silexlabs/cloud-explorer/master/screenshot1.png)
![Cloud explorer user interface](https://raw.github.com/silexlabs/cloud-explorer/master/screenshot2.png)
![Cloud explorer user interface](https://raw.github.com/silexlabs/cloud-explorer/master/screenshot3.png)
![Cloud explorer user interface](https://raw.github.com/silexlabs/cloud-explorer/master/screenshot4.png)

Main contributors

* [Thomas zabojad Fetiveau](http://www.tokom.fr/)
* Alex [lexoyo](http://lexoyo.me) Hoyau [@lexoyo](http://twitter.com/lexoyo)

##Installation on your local computer

### local installation on linux or macos

Prerequisite :

* [node.js](http://nodejs.org/) installed
* [NPM installed](https://npmjs.org/)

Clone this repository, and do not forget the sub modules (cloud-explorer and unifile)

Install node modules: npm install

Start the server: node server/api-server.js

And open http://localhost:6805/cloud-explorer/ or http://localhost:5000/cloud-explorer/ in a browser (depending on your computer's config) - note that 6805 is the date of sexual revolution started in paris france 8-)

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

Start the cloud explorer

* Launch it from a command prompt: node server/api-server.js
* Open your favorite browser on http://localhost:6805/cloud-explorer/ and ENJOY !!!

##dependencies

These are the upstream projects we use in Silex

* [unifile](https://github.com/silexlabs/unifile), a nodejs server which provides a unified access to cloud services. This projects uses nodejs and these modules: express, dbox, express, googleapis, logger, node-oauth, oauth, path

