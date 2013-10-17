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

// add static folders
options.staticFolders.push(
    // file browser
    {
            name: "/cloud-explorer",
            path: "../../lib/"
    },
    // file browser tests
    {
            name: "/cetest",
            path: "../../lib/app/"
    }
);

// use unifile as a middleware
app.use(unifile.middleware(express, app, options));

// wait for requests
app.listen(6805);


/*
process.on('uncaughtException', function(err) {
    console.log  ('---------------------');
    console.error('---------------------', 'Caught exception: ', err, '---------------------');
    console.log  ('---------------------');
});
*/
