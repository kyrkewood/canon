// Starter handler: replace with your app. Reads TABLE_NAME from the environment.
exports.handler = async () => ({
  statusCode: 200,
  headers: { 'content-type': 'application/json' },
  body: JSON.stringify({ ok: true, table: process.env.TABLE_NAME }),
});
