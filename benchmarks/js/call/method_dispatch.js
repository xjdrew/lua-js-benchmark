// Method dispatch benchmark
// Tests prototype-based OOP: class creation, object instantiation, method calls
// Equivalent to Lua metatable-based dispatch

var print = typeof console !== 'undefined' ? console.log.bind(console) : globalThis.print;
var DEFAULT = 5000000;
var N = parseInt(typeof scriptArgs !== 'undefined' ? scriptArgs[1] : (typeof process !== 'undefined' ? process.argv[2] : '0')) || DEFAULT;

// Base class
function Animal(name, legs, sound) {
    this.name = name;
    this.legs = legs;
    this.sound = sound;
    this.energy = 100;
}

Animal.prototype.speak = function() {
    return this.sound;
};

Animal.prototype.move = function(dist) {
    this.energy = this.energy - dist;
    return this.energy;
};

Animal.prototype.rest = function(amount) {
    this.energy = this.energy + amount;
    return this.energy;
};

// Derived class: Dog
function Dog(name) {
    Animal.call(this, name, 4, "woof");
}
Dog.prototype = Object.create(Animal.prototype);
Dog.prototype.constructor = Dog;

Dog.prototype.fetch = function(dist) {
    this.move(dist);
    this.move(dist);
    return this.energy;
};

// Derived class: Bird
function Bird(name) {
    Animal.call(this, name, 2, "tweet");
}
Bird.prototype = Object.create(Animal.prototype);
Bird.prototype.constructor = Bird;

Bird.prototype.fly = function(dist) {
    this.move(dist * 2);
    return this.energy;
};

// Create objects and call methods polymorphically
var animals = [
    new Dog("Rex"),
    new Bird("Tweety"),
    new Dog("Buddy"),
    new Bird("Eagle"),
    new Animal("Cat", 4, "meow"),
];

var total = 0;
var nanimals = animals.length;

for (var i = 1; i <= N; i++) {
    var a = animals[i % nanimals];
    a.rest(10);
    a.move(3);
    total += a.energy;
    a.speak();
}

print(total);
