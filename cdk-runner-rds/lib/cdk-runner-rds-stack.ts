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
      natGateways: 0, // NATゲートウェイなし
      subnetConfiguration: [
        {
          name: 'PrivateSubnet',
          subnetType: ec2.SubnetType.PRIVATE_WITH_EGRESS, // プライベートサブネット
          cidrMask: 24,
        },
      ],
    });

    // RDSの接続情報の設定
    const dbInstanceName = 'your-db-instance';
    const dbName = 'your_db_name';
    const dbUser = 'your_user';
    const dbPassword = 'your_password';

    // RDSインスタンスの作成（プライベートサブネット）
    const rdsInstance = new rds.DatabaseInstance(this, 'MyRDSInstance', {
      instanceIdentifier: dbInstanceName,
      engine: rds.DatabaseInstanceEngine.postgres({
        version: rds.PostgresEngineVersion.VER_13,
      }),
      vpc,
      vpcSubnets: {
        subnetType: ec2.SubnetType.PRIVATE_WITH_EGRESS,
      },
      multiAz: false,
      credentials: rds.Credentials.fromPassword(dbUser, cdk.SecretValue.unsafePlainText(dbPassword)),
      databaseName: dbName,
      removalPolicy: cdk.RemovalPolicy.DESTROY,
      deletionProtection: false,
    });

    // App RunnerのVPC Connector作成
    const vpcConnector = new appRunner.CfnVpcConnector(this, 'MyVpcConnector', {
      vpcConnectorName: 'apprunner-vpc-connector',
      subnets: vpc.selectSubnets({
        subnetType: ec2.SubnetType.PRIVATE_WITH_EGRESS, // プライベートサブネット
      }).subnetIds,
    });

    // App Runnerに必要なIAMロール作成
    const appRunnerServiceRole = new iam.Role(this, 'AppRunnerServiceRole', {
      assumedBy: new iam.ServicePrincipal('build.apprunner.amazonaws.com'),
    });

    appRunnerServiceRole.addManagedPolicy(iam.ManagedPolicy.fromAwsManagedPolicyName('service-role/AWSAppRunnerServicePolicyForVpcAccess'));

    // App Runner Serviceの作成
    const ecrRepo = ecr.Repository.fromRepositoryName(this, 'MyECRRepo', 'sumika-repository');

    const appRunnerService = new appRunner.CfnService(this, 'MyAppRunnerService', {
      serviceName: 'my-app-runner-service',
      sourceConfiguration: {
        autoDeploymentsEnabled: false,
        imageRepository: {
          imageRepositoryType: 'ECR',
          imageIdentifier: `${ecrRepo.repositoryUri}:latest`,
          imageConfiguration: {
            runtimeEnvironmentVariables: [
              {
                name: 'DB_HOST',
                value: rdsInstance.dbInstanceEndpointAddress,  // RDSのエンドポイントを環境変数として設定
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
              },
            ],
          },
        },
        authenticationConfiguration: {
          accessRoleArn: appRunnerServiceRole.roleArn,
        },
      },
      networkConfiguration: {
        egressConfiguration: {
          egressType: 'VPC',
          vpcConnectorArn: vpcConnector.attrVpcConnectorArn,  // VPC Connectorを指定
        },
      },
    });

    // 出力
    new cdk.CfnOutput(this, 'AppRunnerServiceUrl', {
      exportName: 'AppRunnerServiceUrl',
      value: appRunnerService.attrServiceUrl,
    });
  }
}