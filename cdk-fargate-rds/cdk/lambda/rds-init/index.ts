import { SecretsManager } from 'aws-sdk';
import { Client } from 'pg';
import * as fs from 'fs';
import * as path from 'path';

exports.handler = async function () {
  const secretName = process.env.SECRET_NAME!;
  const dbName = process.env.DB_NAME!;
  const host = process.env.DB_HOST!;
  const port = parseInt(process.env.DB_PORT!, 10);

  const secretsManager = new SecretsManager();
  const secret = await secretsManager.getSecretValue({ SecretId: secretName }).promise();
  const credentials = JSON.parse(secret.SecretString!);

  const client = new Client({
    user: credentials.username,
    password: credentials.password,
    host,
    port,
    database: dbName,
  });

  // 同梱された init.sql を読み込む
  const sqlFilePath = path.join(__dirname, 'init.sql');
  const initSql = fs.readFileSync(sqlFilePath, 'utf8');

  try {
    await client.connect();
    await client.query(initSql);
  } finally {
    await client.end();
  }

  return {
    PhysicalResourceId: Date.now().toString(),
  };
};
