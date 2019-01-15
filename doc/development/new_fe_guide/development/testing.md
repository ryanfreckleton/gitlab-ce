# Overview of Frontend Testing

Tests relevant for frontend development can be found at the following places:

- `spec/javascripts/` which are run by [Karma](#karma) and contain
  - [frontend unit tests](#frontend-unit-tests)
  - [frontend component tests](#frontend-component-tests)
  - [frontend integration tests](#frontend-integration-tests)
- `spec/frontend/` which are run by Jest (command: `yarn jest`) and contain
  - [frontend unit tests](#frontend-unit-tests)
  - [frontend component tests](#frontend-component-tests)
  - [frontend integration tests](#frontend-integration-tests)
- `spec/features/` which are run by RSpec and contain
  - [feature tests](#feature-tests)

All tests in `spec/javascripts/` will eventually be migrated to `spec/frontend/` (see also [#52483](https://gitlab.com/gitlab-org/gitlab-ce/issues/52483)).

In addition there were feature tests in `features/` run by Spinach in the past.
These have been removed from our codebase in May 2018 ([#23036](https://gitlab.com/gitlab-org/gitlab-ce/issues/23036)).

See also:

- [Old testing guide](../../testing_guide/frontend_testing.html).
- [Notes on testing Vue components](../../fe_guide/vue.html#testing-vue-components).

## Frontend unit tests

Unit tests are on the lowest abstraction level and typically test functionality that is not directly perceivable by a user.

### When to use unit tests

<details>
  <summary>exported functions and classes</summary>
  Anything that is exported can be reused at various places in a way you have no control over.
  Therefore it is necessary to document the expected behavior of the public interface with tests.
</details>

<details>
  <summary>Vuex actions</summary>
  Any Vuex action needs to work in a consistent way independent of the component it is triggered from.
</details>

<details>
  <summary>Vuex mutations</summary>
  For complex Vuex mutations it helps to identify the source of a problem by separating the tests from other parts of the Vuex store.
</details>

### When *not* to use unit tests

<details>
  <summary>non-exported functions or classes</summary>
  Anything that is not exported from a module can be considered private or an implementation detail and doesn't need to be tested.
</details>

<details>
  <summary>constants</summary>
  Testing the value of a constant would mean to copy it.
  This results in extra effort without additional confidence that the value is correct.
</details>

<details>
  <summary>Vue components</summary>
  Computed properties, methods, and lifecycle hooks can be considered an implementation detail of components and don't need to be tested.
  They are implicitly covered by component tests.
  The <a href="https://vue-test-utils.vuejs.org/guides/#getting-started">official Vue guidelines</a> suggest the same.
</details>

### What to mock in unit tests

<details>
  <summary>state of the class under test</summary>
  Modifying the state of the class under test directly rather than using methods of the class avoids side-effects in test setup.
</details>

<details>
  <summary>other exported classes</summary>
  Every class needs to be tested in isolation to prevent test scenarios from growing exponentially.
</details>

<details>
  <summary>single DOM elements if passed as parameters</summary>
  For tests that only operate on single DOM elements rather than a whole page, creating these elements is cheaper than loading a whole HTML fixture.
</details>

<details>
  <summary>all server requests</summary>
  When running frontend unit tests, the backend may not be reachable.
  Therefore all outgoing requests need to be mocked.
</details>

<details>
  <summary>asynchronous background operations</summary>
  Background operations cannot be stopped or waited on, so they will continue running in the following tests and cause side effects.
</details>

### What *not* to mock in unit tests

<details>
  <summary>non-exported functions or classes</summary>
  Everything that is not exported can be considered private to the module and will be implicitly tested via the exported classes / functions.
</details>

<details>
  <summary>methods of the class under test</summary>
  By mocking methods of the class under test, the mocks will be tested and not the real methods.
</details>

<details>
  <summary>utility functions (pure functions, or those that only modify parameters)</summary>
  If a function has no side effects because it has no state, it is safe to not mock it in tests.
</details>

<details>
  <summary>full HTML pages</summary>
  Loading the HTML of a full page slows down tests, so it should be avoided in unit tests.
</details>

## Frontend component tests

Component tests cover the state of a single component that is perceivable by a user depending on external signals such as user input, events fired from other components, or application state.

### When to use component tests

- Vue components

### When *not* to use component tests

<details>
  <summary>Vue applications</summary>
  Vue applications may contain many components.
  Testing them on a component level requires too much effort.
  Therefore they are tested on frontend integration level.
</details>

<details>
  <summary>HAML templates</summary>
  HAML templates contain only Markup and no frontend-side logic.
  Therefore they are not complete components.
</details>

### What to mock in component tests

<details>
  <summary>DOM</summary>
  Operating on the real DOM is significantly slower than on the virtual DOM.
</details>

<details>
  <summary>properties and state of the component under test</summary>
  Similarly to testing classes, modifying the properties directly (rather than relying on methods of the component) avoids side-effects.
</details>

<details>
  <summary>Vuex store</summary>
  To avoid side effects and keep component tests simple, Vuex stores are replaced with mocks.
</details>

<details>
  <summary>all server requests</summary>
  Similar to unit tests, when running component tests, the backend may not be reachable.
  Therefore all outgoing requests need to be mocked.
</details>

<details>
  <summary>asynchronous background operations</summary>
  Similar to unit tests, background operations cannot be stopped or waited on, so they will continue running in the following tests and cause side effects.
</details>

<details>
  <summary>child components</summary>
  Every component is tested individually, so child components are mocked.
  See also <a href="https://vue-test-utils.vuejs.org/api/#shallowmount">shallowMount()</a>
</details>

### What *not* to mock in component tests

<details>
  <summary>methods or computed properties of the component under test</summary>
  By mocking part of the component under test, the mocks will be tested and not the real component.
</details>

<details>
  <summary>functions and classes independent from Vue</summary>
  All plain JavaScript code is already covered by unit tests and needs not to be mocked in component tests.
</details>

## Frontend integration tests

Integration tests cover the interaction between all components on a single page.
Their abstraction level is comparable to how a user would interact with the UI.

### When to use integration tests

<details>
  <summary>page bundles (<code>index.js</code> files in <code>app/assets/javascripts/pages/</code>)</summary>
  Testing the page bundles ensures the corresponding frontend components integrate well.
</details>

<details>
  <summary>Vue applications outside of page bundles</summary>
  Testing Vue applications as a whole ensures the corresponding frontend components integrate well.
</details>

### What to mock in integration tests

<details>
  <summary>HAML views (use fixtures instead)</summary>
  Rendering HAML views requires a Rails environment including a running database which we cannot rely on in frontend tests.
</details>

<details>
  <summary>all server requests</summary>
  Similar to unit and component tests, when running component tests, the backend may not be reachable.
  Therefore all outgoing requests need to be mocked.
</details>

<details>
  <summary>asynchronous background operations that are not perceivable on the page</summary>
  Background operations that affect the page need to be tested on this level.
  All other background operations cannot be stopped or waited on, so they will continue running in the following tests and cause side effects.
</details>

### What *not* to mock in integration tests

<details>
  <summary>DOM</summary>
  Testing on the real DOM ensures our components work in the environment they are meant for.
  Part of this will be delegated to <a href="https://gitlab.com/gitlab-org/quality/team-tasks/issues/45">cross-browser testing</a>.
</details>

<details>
  <summary>properties or state of components</summary>
  On this level, all tests can only perform actions a user would do.
  For example to change the state of a component, a click event would be fired.
</details>

<details>
  <summary>Vuex stores</summary>
  When testing the frontend code of a page as a whole, the interaction between Vue components and Vuex stores is covered as well.
</details>

## Feature tests

In contrast to [frontend integration tests](#frontend-integration-tests), feature tests make requests against the real backend instead of using fixtures.
This also implies that database queries are executed which makes this category significantly slower.

See also the [RSpec testing guidelines](../../testing_guide/best_practices.md#rspec).

### When to use feature tests

- use cases that require a backend and cannot be tested using fixtures
- behavior that is not part of a page bundle but defined globally

### Relevant notes

A `:js` flag is added to the test to make sure the full environment is loaded.

```
scenario 'successfully', :js do
  sign_in(create(:admin))
end
```

The steps of each test are written using capybara methods ([documentation](http://www.rubydoc.info/gems/capybara/2.15.1)).

Bear in mind <abbr title="XMLHttpRequest">XHR</abbr> calls might require you to use `wait_for_requests` in between steps, like so:

```rspec
find('.form-control').native.send_keys(:enter)

wait_for_requests

expect(page).not_to have_selector('.card')
```

## Karma

GitLab uses the [Karma](http://karma-runner.github.io/) test runner with [Jasmine](https://jasmine.github.io/) as its test
framework for our JavaScript unit and integration tests. For integration tests,
we generate HTML files using RSpec (see `spec/javascripts/fixtures/*.rb` for examples).
Some fixtures are still HAML templates that are translated to HTML files using the same mechanism (see `static_fixtures.rb`).
Adding these static fixtures should be avoided as they are harder to keep up to date with real views.
The existing static fixtures will be migrated over time.
Please see [gitlab-org/gitlab-ce#24753](https://gitlab.com/gitlab-org/gitlab-ce/issues/24753) to track our progress.
Fixtures are served during testing by the [jasmine-jquery](https://github.com/velesin/jasmine-jquery) plugin.

JavaScript tests live in `spec/javascripts/`, matching the folder structure
of `app/assets/javascripts/`: `app/assets/javascripts/behaviors/autosize.js`
has a corresponding `spec/javascripts/behaviors/autosize_spec.js` file.

Keep in mind that in a CI environment, these tests are run in a headless
browser and you will not have access to certain APIs, such as
[`Notification`](https://developer.mozilla.org/en-US/docs/Web/API/notification),
which will have to be stubbed.

`rake karma` runs the frontend-only (JavaScript) tests.
It consists of two subtasks:

- `rake karma:fixtures` (re-)generates fixtures
- `rake karma:tests` actually executes the tests

As long as the fixtures don't change, `rake karma:tests` (or `yarn karma`)
is sufficient (and saves you some time).

### Live testing and focused testing

While developing locally, it may be helpful to keep karma running so that you
can get instant feedback on as you write tests and modify code. To do this
you can start karma with `yarn run karma-start`. It will compile the javascript
assets and run a server at `http://localhost:9876/` where it will automatically
run the tests on any browser which connects to it. You can enter that url on
multiple browsers at once to have it run the tests on each in parallel.

While karma is running, any changes you make will instantly trigger a recompile
and retest of the entire test suite, so you can see instantly if you've broken
a test with your changes. You can use [jasmine focused](https://jasmine.github.io/2.5/focused_specs.html) or
excluded tests (with `fdescribe` or `xdescribe`) to get karma to run only the
tests you want while you're working on a specific feature, but make sure to
remove these directives when you commit your code.

It is also possible to only run karma on specific folders or files by filtering
the run tests via the argument `--filter-spec` or short `-f`:

```bash
# Run all files
yarn karma-start
# Run specific spec files
yarn karma-start --filter-spec profile/account/components/update_username_spec.js
# Run specific spec folder
yarn karma-start --filter-spec profile/account/components/
# Run all specs which path contain vue_shared or vie
yarn karma-start -f vue_shared -f vue_mr_widget
```

You can also use glob syntax to match files. Remember to put quotes around the
glob otherwise your shell may split it into multiple arguments:

```bash
# Run all specs named `file_spec` within the IDE subdirectory
yarn karma -f 'spec/javascripts/ide/**/file_spec.js'
```

## Best practices

### Naming unit tests

When writing describe test blocks to test specific functions/methods,
please use the method name as the describe block name.

```javascript
// Good
describe('methodName', () => {
  it('passes', () => {
    expect(true).toEqual(true);
  });
});

// Bad
describe('#methodName', () => {
  it('passes', () => {
    expect(true).toEqual(true);
  });
});

// Bad
describe('.methodName', () => {
  it('passes', () => {
    expect(true).toEqual(true);
  });
});
```

### Testing promises

When testing Promises you should always make sure that the test is asynchronous and rejections are handled.
Your Promise chain should therefore end with a call of the `done` callback and `done.fail` in case an error occurred.

```javascript
// Good
it('tests a promise', done => {
  promise
    .then(data => {
      expect(data).toBe(asExpected);
    })
    .then(done)
    .catch(done.fail);
});

// Good
it('tests a promise rejection', done => {
  promise
    .then(done.fail)
    .catch(error => {
      expect(error).toBe(expectedError);
    })
    .then(done)
    .catch(done.fail);
});

// Bad (missing done callback)
it('tests a promise', () => {
  promise.then(data => {
    expect(data).toBe(asExpected);
  });
});

// Bad (missing catch)
it('tests a promise', done => {
  promise
    .then(data => {
      expect(data).toBe(asExpected);
    })
    .then(done);
});

// Bad (use done.fail in asynchronous tests)
it('tests a promise', done => {
  promise
    .then(data => {
      expect(data).toBe(asExpected);
    })
    .then(done)
    .catch(fail);
});

// Bad (missing catch)
it('tests a promise rejection', done => {
  promise
    .catch(error => {
      expect(error).toBe(expectedError);
    })
    .then(done);
});
```

### Stubbing and Mocking

Jasmine provides useful helpers `spyOn`, `spyOnProperty`, `jasmine.createSpy`,
and `jasmine.createSpyObject` to facilitate replacing methods with dummy
placeholders, and recalling when they are called and the arguments that are
passed to them. These tools should be used liberally, to test for expected
behavior, to mock responses, and to block unwanted side effects (such as a
method that would generate a network request or alter `window.location`). The
documentation for these methods can be found in the [jasmine introduction page](https://jasmine.github.io/2.0/introduction.html#section-Spies).

Sometimes you may need to spy on a method that is directly imported by another
module. GitLab has a custom `spyOnDependency` method which utilizes
[babel-plugin-rewire](https://github.com/speedskater/babel-plugin-rewire) to
achieve this. It can be used like so:

```javascript
// my_module.js
import { visitUrl } from '~/lib/utils/url_utility';

export default function doSomething() {
  visitUrl('/foo/bar');
}

// my_module_spec.js
import doSomething from '~/my_module';

describe('my_module', () => {
  it('does something', () => {
    const visitUrl = spyOnDependency(doSomething, 'visitUrl');

    doSomething();
    expect(visitUrl).toHaveBeenCalledWith('/foo/bar');
  });
});
```

Unlike `spyOn`, `spyOnDependency` expects its first parameter to be the default
export of a module who's import you want to stub, rather than an object which
contains a method you wish to stub (if the module does not have a default
export, one is be generated by the babel plugin). The second parameter is the
name of the import you wish to change. The result of the function is a Spy
object which can be treated like any other jasmine spy object.

Further documentation on the babel rewire pluign API can be found on
[its repository Readme doc](https://github.com/speedskater/babel-plugin-rewire#babel-plugin-rewire).

### Waiting in tests

If you cannot avoid using [`setTimeout`](https://developer.mozilla.org/en-US/docs/Web/API/WindowOrWorkerGlobalScope/setTimeout) in tests, please use the [Jasmine mock clock](https://jasmine.github.io/api/2.9/Clock.html).

## Test helpers

### Vuex Helper: `testAction`

We have a helper available to make testing actions easier, as per [official documentation](https://vuex.vuejs.org/en/testing.html):

```
testAction(
  actions.actionName, // action
  { }, // params to be passed to action
  state, // state
  [
    { type: types.MUTATION},
    { type: types.MUTATION_1, payload: {}},
  ], // mutations committed
  [
    { type: 'actionName', payload: {}},
    { type: 'actionName1', payload: {}},
  ] // actions dispatched
  done,
);
```

Check an example in [spec/javascripts/ide/stores/actions_spec.jsspec/javascripts/ide/stores/actions_spec.js](https://gitlab.com/gitlab-org/gitlab-ce/blob/master/spec/javascripts/ide/stores/actions_spec.js).

### Vue Helper: `mountComponent`

To make mounting a Vue component easier and more readable, we have a few helpers available in `spec/helpers/vue_mount_component_helper`.

- `createComponentWithStore`
- `mountComponentWithStore`

Examples of usage:

```
beforeEach(() => {
  vm = createComponentWithStore(Component, store);

  vm.$store.state.currentBranchId = 'master';

  vm.$mount();
},
```

```
beforeEach(() => {
  vm = mountComponentWithStore(Component, {
    el: '#dummy-element',
    store,
    props: { badge },
  });
},
```

Don't forget to clean up:

```
afterEach(() => {
  vm.$destroy();
});
```

## Testing with older browsers

Some regressions only affect a specific browser version. We can install and test in particular browsers with either Firefox or Browserstack using the following steps:


### Browserstack

[Browserstack](https://www.browserstack.com/) allows you to test more than 1200 mobile devices and browsers.
You can use it directly through the [live app](https://www.browserstack.com/live) or you can install the [chrome extension](https://chrome.google.com/webstore/detail/browserstack/nkihdmlheodkdfojglpcjjmioefjahjb) for easy access.
You can find the credentials on 1Password, under `frontendteam@gitlab.com`.

### Firefox

#### macOS

You can download any older version of Firefox from the releases FTP server, https://ftp.mozilla.org/pub/firefox/releases/

1. From the website, select a version, in this case `50.0.1`.
1. Go to the mac folder.
1. Select your preferred language, you will find the dmg package inside, download it.
1. Drag and drop the application to any other folder but the `Applications` folder.
1. Rename the application to something like `Firefox_Old`.
1. Move the application to the `Applications` folder.
1. Open up a terminal and run `/Applications/Firefox_Old.app/Contents/MacOS/firefox-bin -profilemanager` to create a new profile specific to that Firefox version.
1. Once the profile has been created, quit the app, and run it again like normal. You now have a working older Firefox version.

## Gotchas

### Errors due to use of unsupported JavaScript features

Similar errors will be thrown if you're using JavaScript features not yet
supported by the PhantomJS test runner which is used for both Karma and RSpec
tests. We polyfill some JavaScript objects for older browsers, but some
features are still unavailable:

- Array.from
- Array.first
- Async functions
- Generators
- Array destructuring
- For..Of
- Symbol/Symbol.iterator
- Spread

Until these are polyfilled appropriately, they should not be used. Please
update this list with additional unsupported features.

### RSpec errors due to JavaScript

By default RSpec unit tests will not run JavaScript in the headless browser
and will simply rely on inspecting the HTML generated by rails.

If an integration test depends on JavaScript to run correctly, you need to make
sure the spec is configured to enable JavaScript when the tests are run. If you
don't do this you'll see vague error messages from the spec runner.

To enable a JavaScript driver in an `rspec` test, add `:js` to the
individual spec or the context block containing multiple specs that need
JavaScript enabled:

```ruby
# For one spec
it 'presents information about abuse report', :js do
  # assertions...
end

describe "Admin::AbuseReports", :js do
  it 'presents information about abuse report' do
    # assertions...
  end
  it 'shows buttons for adding to abuse report' do
    # assertions...
  end
end
```
