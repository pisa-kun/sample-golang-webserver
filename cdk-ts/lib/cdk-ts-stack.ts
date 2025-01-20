import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
// import * as sqs from 'aws-cdk-lib/aws-sqs';
import * as ecr from 'aws-cdk-lib/aws-ecr'
import { AppRunner } from './app-runner';

export class CdkTsStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);
        // ECR
        const repository = new ecr.Repository(this, 'AppRunnerExampleRepository',{
          repositoryName: "golang_sumisumi_repository",
          imageTagMutability: ecr.TagMutability.IMMUTABLE,
        })

        const backendApp = new AppRunner(this, 'GoBackend', {
          repository: repository
        })

        backendApp.node.addDependency(repository)
  }
}
