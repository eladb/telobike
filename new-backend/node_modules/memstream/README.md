# Memstream Introduction
The memstream module is designed to bridge the gap between two data/network streams of variable rates. It can also be used as a buffer for incoming data that you want to pipe to another stream at a later date. The API is meant to follow node's Stream implementation as closely as possible.

## Installation
If you have npm installed, you can simply type:

	npm install memstream
	
Or you can clone this repository using the git command:

	git clone git://github.com/ollym/memstream.git
	
## Documentation
The memory stream adopts all the same methods and events as node's Stream implementation. Including:

* readable
* writable
* write()
* pause()
* resume()
* destroy()
* end()
* pipe()
* Event: 'end'
* Event: 'data'

### Examples
Below are some very basic examples of how the memory stream works.

#### Basic IO Operation
In this example i illustrate the basic IO operations of the memory stream.

	var MemoryStream = require('memstream').MemoryStream;
	
	var stream = new MemoryStream(function(buffer) {
		console.log(buffer.toString());
	});
	
	stream.write('HelloWorld!');
	
	
#### Delayed Response
In the example below, we first pause the stream before writing the data to it. The stream is then resumed after 1 second, and the data is written to the console.

	var MemoryStream = require('memstream').MemoryStream;

	var stream = new MemoryStream(function(buffer) {
		console.log(buffer.toString());
	});
	
	stream.pause();
	stream.write('HelloWorld!');
	
	setTimeout(function() {
		stream.resume();
	}, 1000);
	
#### Piping Data
In this example i'm piping all data from the memory stream to the process' stdout stream.

	var MemoryStream = require('memstream').MemoryStream;
	
	var stream = new MemoryStream();
	stream.pipe(process.stdout, { end: false });
	
	stream.write('Hello World!');