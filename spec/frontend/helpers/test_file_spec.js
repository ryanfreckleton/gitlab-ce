import { jasmineReporter, testFile } from './test_file';

describe('testFile helper', () => {
  afterEach(() => {
    Object.assign(testFile, {
      description: null,
      testPath: null,
    });
  });

  it('contains the current test suite', () => {
    expect(testFile.description).toBe('testFile helper');
    expect(testFile.testPath).toMatch(/spec\/frontend\/helpers\/test_file_spec\.js$/);
  });

  describe('jasmineReporter', () => {
    const dummySuite = { description: 'some suite', testPath: 'some/path.js' };

    describe('suiteStarted', () => {
      it('stores the suite', () => {
        jasmineReporter.suiteStarted(dummySuite);

        expect(testFile).toEqual(dummySuite);
      });

      it('overwrites the suite', () => {
        const otherSuite = { description: 'some other suite', testPath: 'other/path.js' };
        Object.assign(testFile, dummySuite);

        jasmineReporter.suiteStarted(otherSuite);

        expect(testFile).toEqual(otherSuite);
      });

      it('does not overwrite the suite for same file', () => {
        const otherSuite = { description: 'some other suite', testPath: dummySuite.testPath };
        Object.assign(testFile, dummySuite);

        jasmineReporter.suiteStarted(otherSuite);

        expect(testFile).toEqual(dummySuite);
      });
    });

    describe('jasmineDone', () => {
      it('resets testFile', () => {
        Object.assign(testFile, dummySuite);

        jasmineReporter.jasmineDone();

        expect(testFile).toEqual({
          description: null,
          testPath: null,
        });
      });
    });
  });
});
