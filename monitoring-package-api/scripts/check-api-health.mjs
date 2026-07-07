import http from 'node:http';

const base = 'http://localhost:5067';
const path = '/api/support/health';

function request(url) {
  return new Promise((resolve, reject) => {
    const req = http.request(url, { method: 'GET', timeout: 5000 }, (res) => {
      const chunks = [];
      res.on('data', (chunk) => chunks.push(chunk));
      res.on('end', () => {
        const body = Buffer.concat(chunks).toString('utf-8');
        resolve({ status: res.statusCode, headers: res.headers, body });
      });
    });
    req.on('error', reject);
    req.on('timeout', () => {
      req.destroy();
      reject(new Error('Request timeout'));
    });
    req.end();
  });
}

function assert(truth, message) {
  if (!truth) {
    console.error(`VERIFY FAILED: ${message}`);
    process.exitCode = 1;
    return false;
  }
  console.log(`VERIFY OK: ${message}`);
  return true;
}

(async () => {
  try {
    const { status, body } = await request(new URL(path, base));
    assert(status === 200, `Expected HTTP 200 for ${path}, got ${status}`);

    let parsed;
    try {
      parsed = JSON.parse(body || '{}');
    } catch (err) {
      assert(false, `Response is not valid JSON: ${err.message}`);
      process.exit(1);
    }

    assert(typeof parsed?.status === 'string' && parsed.status.length > 0, `Expected non-empty status string; got ${JSON.stringify(parsed?.status)}`);
    assert(parsed?.timestamp, 'Expected timestamp in response');
    assert(parsed?.checks && typeof parsed.checks === 'object', 'Expected checks object in response');
    assert(typeof parsed?.uptime === 'number' || typeof parsed?.uptime === 'undefined', 'Uptime field should be numeric if present; got ' + typeof parsed?.uptime);
  } catch (err) {
    assert(false, `Health endpoint not reachable at ${base}${path}: ${err.message}`);
  }

  if (process.exitCode && process.exitCode !== 0) {
    process.exit(process.exitCode);
  }
})();
