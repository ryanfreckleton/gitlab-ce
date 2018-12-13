export const testFile = {
  description: null,
  testPath: null,
};

export const jasmineReporter = {
  suiteStarted(result) {
    const { description, testPath } = result;
    if (testFile.testPath !== testPath) {
      Object.assign(testFile, { description, testPath });
    }
  },

  jasmineDone() {
    Object.assign(testFile, {
      description: null,
      testPath: null,
    });
  },
};
