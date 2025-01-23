import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as rds from 'aws-cdk-lib/aws-rds';
import * as appRunner from 'aws-cdk-lib/aws-apprunner';
import * as ecr from 'aws-cdk-lib/aws-ecr';
import * as iam from 'aws-cdk-lib/aws-iam';

export class CdkRunnerRdsStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);
    
    // VPCの作成
    const vpc = new ec2.Vpc(this, 'MyVpc', {
      maxAzs: 1, // single AZ
    });

    // RDSの接続情報の設定
    const dbInstanceName = 'your-db-instance';
    const dbName = 'your-db-name';
    const dbUser = 'your-user';
    const dbPassword = 'your-password';

    // RDSインスタンスの作成（private subnet）
    const rdsInstance = new rds.DatabaseInstance(this, 'MyRDSInstance', {
      instanceIdentifier: dbInstanceName,
      engine: rds.DatabaseInstanceEngine.postgres({
        version: rds.PostgresEngineVersion.VER_13,
      }),
      vpc,
      vpcSubnets: {
        subnetType: ec2.SubnetType.PRIVATE_ISOLATED,
      },
      multiAz: false,
      credentials: rds.Credentials.fromPassword(dbUser, cdk.SecretValue.plainText(dbPassword)),
      databaseName: dbName,
      removalPolicy: cdk.RemovalPolicy.DESTROY,
      deletionProtection: false,
    });

    // App RunnerのVPC Connector
    const vpcConnector = new appRunner.CfnVpcConnector(this, 'MyVpcConnector', {
      vpcConnectorName: "apprunner-demo-vpc-connector",
      subnets: vpc.selectSubnets({
        subnetType: ec2.SubnetType.PRIVATE_WITH_EGRESS
      }).subnetIds,
    });
    // App Runnerに必要なIAMロールを作成
    const appRunnerRole = new iam.Role(this, 'AppRunnerRole', {
      assumedBy: new iam.ServicePrincipal('build.apprunner.amazonaws.com'),
    });
    appRunnerRole.addManagedPolicy(iam.ManagedPolicy.fromAwsManagedPolicyName('service-role/AWSAppRunnerServicePolicyForVpcAccess'));

    // App Runner
    const ecrRepo = ecr.Repository.fromRepositoryName(this, "SumikaRepo", "sumika-repository");

    const appRunnerService = new appRunner.CfnService(this, 'MyAppRunnerService', {
      serviceName: 'my-app-runner-service',
      networkConfiguration: {
        egressConfiguration:{
          egressType: 'VPC',
          vpcConnectorArn: vpcConnector.attrVpcConnectorArn,
        }
      },
      sourceConfiguration: {
        autoDeploymentsEnabled: false,
        authenticationConfiguration: {
          accessRoleArn: appRunnerRole.roleArn,
      },
        imageRepository: {
          imageRepositoryType: 'ECR',
          imageIdentifier: `${ecrRepo.repositoryUri}:latest`,
          imageConfiguration: {
            port: '8080', // アプリがリスンするポート
            runtimeEnvironmentVariables:[
              // AppRunner用環境変数を定義
              // SecretManager経由が好ましい
              {
                name: 'DB_HOST',
                value: rdsInstance.dbInstanceEndpointAddress,
              },
              {
                name: 'DB_NAME',
                value: dbName,
              },
              {
                name: 'DB_USER',
                value: dbUser,
              },
              {
                name: 'DB_PASSWORD',
                value: dbPassword,
              }
          ]
          },
        },
      },
    });
  }
}
