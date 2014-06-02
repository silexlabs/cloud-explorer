/**
 * A simple unifile server to expose unifile api and nothing else
 * https://github.com/silexlabs/unifile/
 * license: GPL v2
 */
// node modules
var express = require('express');
var app = express();
var unifile = require('unifile');

// config
var options = unifile.defaultConfig;

//enabled unifile services
options.services = [
    'dropbox',
    'www',
    'ftp'
];

// change www root
options.www.ROOT = __dirname + "/../bin/";

options.www.USERS = {
    "admin": "admin"
}

/**
 * Cloud Explorer's Dropbox app config
 */
options.dropbox.app_key = 'vqtcc89busxsb4q';
options.dropbox.app_secret = 'm5vzfg08a063gpt';

// add static folders
options.staticFolders.push(
    // file browser
    {
            name: "/",
            path: __dirname + "/../app/"
    },
    {
            name: "/styles/",
            path: __dirname + "/../.tmp/styles/"
    }
);

// use unifile as a middleware
app.use(unifile.middleware(express, app, options));

// server 'loop'
var port = process.env.PORT || 6805;
app.listen(port, function() {
  console.log('Listening on ' + port);
});

// catch all errors and prevent nodejs to crash, production mode
process.on('uncaughtException', function(err) {
    console.log  ('---------------------');
    console.error('---------------------', 'Caught exception: ', err, '---------------------');
    console.log  ('---------------------');
});
