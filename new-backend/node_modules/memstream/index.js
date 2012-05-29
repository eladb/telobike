var util = require('util'),
	sys = require('sys'),
	events = require('events');

module.exports.createMemoryStream = function() {
	
	return new MemoryStream();
}

var MemoryStream = module.exports.MemoryStream = function(ondata) {
	
	events.EventEmitter.call(this);
	
	if (ondata)
	  this.on('data', ondata);
	
	this.queue = [];
	this.paused = false;
	
	this.readable = true;
	this.writable = true;
	
	var self = this;
	
	function tick() {
		
		self.flush();
		self.readable && process.nextTick(tick);
	}
	
	tick();
}

util.inherits(MemoryStream, events.EventEmitter);

MemoryStream.prototype.pipe = function(destination, options) {
	
	var pump = sys.pump || util.pump;
	
	pump(this, destination);
};

MemoryStream.prototype.pause = function() {
		
	this.paused = true;
};
	
MemoryStream.prototype.resume = function() {
		
	this.paused = false;
		
	this.flush();
};
	
MemoryStream.prototype.end = function(chunk, encoding) {
	
	if (typeof chunk !== 'undefined') {
		
		this.write(chunk, encoding);
	}	
	
	this.writable = false;
	
	if (this.queue.length === 0) {
		
		this.readable = false;
	}
	
	this.emit('end');
};
	
MemoryStream.prototype.flush = function() {
	
	var self = this;
	
	if ( ! this.paused && this.readable && this.queue.length > 0) {
		
		this.emit('data', this.queue.shift());
		
		return true;
	}
	
	return false;
};
	
MemoryStream.prototype.write = function(chunk, encoding, callback) {
	
	if ( ! this.writable) {
	
		throw new Error('The memory stream is no longer writable.');
	}
	
	if (typeof encoding === 'function') {
		
		callback = encoding;
		encoding = undefined;
	}
	
	if ( ! chunk instanceof Buffer) {
		
		chunk = new Buffer(chunk, encoding);
	}
	
	if ( ! this.paused) {
		
		this.emit('data', chunk);
	}
	else {
		
		this.queue.push(chunk);
	}
	
	if (typeof callback === 'function') {
		
		callback.call(this);
	}
	
	return true;
};

MemoryStream.prototype.destroy = function() {
	
	this.end();
	
	this.queue = [];
	
	this.readable = false;
	this.writable = false;
}

