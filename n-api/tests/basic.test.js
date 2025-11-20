// n-api/tests/basic.test.js
const assert = require('assert');

// просто пример функции
function sum(a, b) {
  return a + b;
}

// примитивный тест
assert.strictEqual(sum(1, 2), 3, '1 + 2 должно быть 3');

console.log('✅ basic.test.js: all tests completed');
