# To get started

To get started, clone the repository and install the dependencies for the uijs app:

    $ git clone https://github.com/eladb/telobike.git
    $ cd telobike/uijs/src
    $ npm install

Now, install uijs and uijs-controls from the local filesystem:

    $ cd telobike/uijs/src
    $ npm install <path-to-your-uijs-core-repository>
    $ npm install <path-to-your-uijs-controls-repository>

On Unix systems, you can use `npm link` instead of `npm install` and the libraries will be linked to their source repository (Shay, it's your turn to get a Mac dude!).

# Building

To build the app, make sure you have the uijs devtools installed and type:

    $ cd telobike/uijs/src
    $ uijs build app.js

The output goes to `dist/app.uijs.html`. Use `-w` to watch for changes.
If you open it via a browser, you will not see any UI because the native map requires the phonegap plugin. However, you can open the browser console and you should see the update cycle.

# References

 * Assets are under [telobike/uijs/assets](https://github.com/eladb/telobike/tree/master/uijs/src/assets).
 * The [model](https://github.com/eladb/telobike/blob/master/uijs/src/model.js) allows listening to changes on backend station list.
   See [app.js:99](https://github.com/eladb/telobike/blob/master/uijs/src/app.js#L99) for an example on how to use it.

