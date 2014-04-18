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

// change www root
options.www.ROOT = "../../../../bin/";

options.www.USERS = {
    "admin": "admin"
}

// add static folders
options.staticFolders.push(
    // file browser
    {
            name: "/",
            path: "../../../../app/"
    },
    {
            name: "/styles/",
            path: "../../../../.tmp/styles/"
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
