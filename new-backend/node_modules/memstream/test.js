var MemoryStream = require('memstream').MemoryStream,
    assert = require('assert');


function basicTest() {
	
	var stream = new MemoryStream();
	
	stream.on('data', function(data) {
		assert.equal(data.toString(), 'foo');
	});
	
	stream.write('foo');
	process.exit();
}

function delayTest() {
	
	var stream = new MemoryStream();
	
	process.nextTick(function() {
		
		stream.on('data', function(data) {
			assert.equal(data.toString(), 'foo');
		});
		
		stream.resume();
		process.exit();
	});
	
	stream.pause();
	stream.write('foo');
};