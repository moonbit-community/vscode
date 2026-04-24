const smoke = require('./smoke.test');

async function run() {
  await smoke.run();
}

module.exports = { run };
