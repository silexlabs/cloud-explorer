Cloud Explorer refactoring in Progress
--------------------------------------
by Thomas Fétiveau [@zab0jad](https://twitter.com/zab0jad) and Alexandre Hoyau [@lexoyo](https://twitter.com/lexoyo)

Cloud Explorer is being ported to Haxe to make it available in HTML5, Flash, native iOS and native Android.

As soon as the HTML5 target becomes stable, this branch will become the master branch of the repository.

The Cloud Explorer API will remained unchanged and will still stick to the Ink File Picker API : https://developers.inkfilepicker.com/docs/web/

##Setup

For early testers and contributors, here are the setup steps to follow in order to run this version of CE:

 - git clone this branch on your local file system,

 - run the following command in a terminal to install the dependencies:
```
npm install
```

 - run the following command in a terminal to start the local server:
```
grunt server
``