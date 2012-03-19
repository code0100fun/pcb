/*
* memoize.js
* by @philogb and @addyosmani
* further optimizations by @mathias, @DmitryBaranovsk & @GotNoSugarBaby
* fixes by @AutoSponge
* perf tests: http://bit.ly/q3zpG3
* Released under an MIT license.
*/
(function (global) {
    "use strict";
    global.memoize = global.memoize || (typeof JSON === 'object' && typeof JSON.stringify === 'function' ?
        function (func) {
            var stringifyJson = JSON.stringify,
                cache = {};

            return function () {
                var hash = stringifyJson(arguments);
                return (hash in cache) ? cache[hash] : cache[hash] = func.apply(this, arguments);
            };
        } : function (func) {
            return func;
        });
        
    global.memoize1 = function (func) {
            var cache = {};

            return function (val) {
                return (val in cache) ? cache[val] : cache[val] = func.call(this, val);
            };
        };
    global.memoize2 = function (func) {
            var cache = {}; 
            return function (val1,val2) {
                var hash = val1.toString() + "," + val2.toString();
                return (hash in cache) ? cache[hash] : cache[hash] = func.call(this, val1,val2);
            };
        };
}(this));
