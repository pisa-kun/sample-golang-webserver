#!/usr/bin/env node
import * as cdk from 'aws-cdk-lib';
import { CdkFargateRdsStack  } from '../lib/cdk-stack';

const app = new cdk.App();

const ecrRepositoryUri = app.node.tryGetContext('ecrRepositoryUri');
if (!ecrRepositoryUri) {
  throw new Error('ECRリポジトリURIを context で指定してください (--context ecrRepositoryUri=...)');
}

new CdkFargateRdsStack(app, 'CdkFargateRdsStack', {
  ecrRepositoryUri,
});
