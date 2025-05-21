const { SecretsManager } = require('aws-sdk');
const { Client } = require('pg');
const fs = require('fs');
const path = require('path');

// bundle時にtscしたいが、面倒だったのでjsファイルでいく
exports.handler = async function (event) {
  // CloudFormationカスタムリソースのリクエストタイプを確認
  if (event?.RequestType === 'Delete') {
    console.log('Delete request received. Skipping DB init.');
    return {
      PhysicalResourceId: event.PhysicalResourceId || Date.now().toString(),
    };
  }

  const secretName = process.env.SECRET_NAME;
  const dbName = process.env.DB_NAME;
  const host = process.env.DB_HOST;
  const port = parseInt(process.env.DB_PORT, 10);

  const secretsManager = new SecretsManager();
  const secret = await secretsManager.getSecretValue({ SecretId: secretName }).promise();
  const credentials = JSON.parse(secret.SecretString);

  const client = new Client({
    user: credentials.username,
    password: credentials.password,
    host,
    port,
    database: dbName,
    ssl: { rejectUnauthorized: false }, // SSLを有効にする
  });

  // 同梱された init.sql を読み込む
  const sqlFilePath = path.join(__dirname, 'init.sql');
  const initSql = fs.readFileSync(sqlFilePath, 'utf8');

  try {
    console.log('Connecting to the database...');
    await client.connect();
    console.log('Connected to the database.');

    console.log('Executing init.sql...');
    const result = await client.query(initSql);
    console.log('init.sql executed successfully.', { rowCount: result.rowCount });

    // 追加で必要なら、result.rows もログ出力できます
    // console.log('Query result:', result.rows);
  } finally {
    await client.end();
  }

  return {
    PhysicalResourceId: Date.now().toString(),
  };
};
