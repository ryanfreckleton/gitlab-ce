# Frontend testing standards and style guidelines

There are two types of test suites you'll encounter while developing frontend code
at GitLab. We use Karma and Jasmine for JavaScript unit and integration testing,
and RSpec feature tests with Capybara for e2e (end-to-end) integration testing.

Unit and feature tests need to be written for all new features.
Most of the time, you should use [RSpec] for your feature tests.

Regression tests should be written for bug fixes to prevent them from recurring
in the future.

See the [Testing Standards and Style Guidelines](index.md) page for more
information on general testing practices at GitLab.

### Vue.js unit tests

See this [section][vue-test].

## RSpec feature integration tests

Information on setting up and running RSpec integration tests with
[Capybara] can be found in the [Testing Best Practices](best_practices.md).

[vue-test]: https://docs.gitlab.com/ce/development/fe_guide/vue.html#testing-vue-components
[rspec]: https://github.com/rspec/rspec-rails#feature-specs
[capybara]: https://github.com/teamcapybara/capybara

---

[Return to Testing documentation](index.md)
