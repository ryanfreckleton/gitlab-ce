// ECMAScript polyfills
// core-js is replaced by babel-preset-env with the polyfills we actually need:
// https://babeljs.io/docs/en/babel-preset-env#usebuiltins
import 'core-js';

// Browser polyfills
import 'formdata-polyfill';
import './polyfills/custom_event';
import './polyfills/element';
import './polyfills/event';
import './polyfills/nodelist';
import './polyfills/request_idle_callback';
import './polyfills/svg';
