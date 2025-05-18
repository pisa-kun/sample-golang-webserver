import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as ec2 from 'aws-cdk-lib/aws-ec2';
import * as ecs from 'aws-cdk-lib/aws-ecs';
import * as ecsPatterns from 'aws-cdk-lib/aws-ecs-patterns';
import * as rds from 'aws-cdk-lib/aws-rds';
import * as secretsmanager from 'aws-cdk-lib/aws-secretsmanager';

interface CdkFargateRdsStackProps extends cdk.StackProps {
  readonly ecrRepositoryUri: string;
}

export class CdkFargateRdsStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props: CdkFargateRdsStackProps) {
    super(scope, id, props);

    // 1. VPC 作成
    const vpc = new ec2.Vpc(this, 'AppVpc', {
      maxAzs: 2,
    });

    // 2. DB認証情報（Secrets Manager）
    const dbSecret = new secretsmanager.Secret(this, 'DbSecret', {
      generateSecretString: {
        secretStringTemplate: JSON.stringify({ username: 'admin' }),
        generateStringKey: 'password',
        excludeCharacters: '\"@/\\',
      },
    });

    // 3. RDS PostgreSQL インスタンス
    const dbInstance = new rds.DatabaseInstance(this, 'AppPostgres', {
      engine: rds.DatabaseInstanceEngine.postgres({
        version: rds.PostgresEngineVersion.VER_15
      }),
      vpc,
      vpcSubnets: {
        subnetType: ec2.SubnetType.PRIVATE_WITH_EGRESS,
      },
      credentials: rds.Credentials.fromSecret(dbSecret),
      instanceType: ec2.InstanceType.of(
        ec2.InstanceClass.BURSTABLE2,
        ec2.InstanceSize.MICRO
      ),
      multiAz: false,
      allocatedStorage: 20,
      maxAllocatedStorage: 100,
      publiclyAccessible: false,
      removalPolicy: cdk.RemovalPolicy.DESTROY,
      deletionProtection: false,
    });

    // 4. ECS クラスター作成
    const cluster = new ecs.Cluster(this, 'AppCluster', {
      vpc,
    });

    // 5. Fargate サービス
    new ecsPatterns.ApplicationLoadBalancedFargateService(this, 'AppFargateService', {
      cluster,
      cpu: 256,
      memoryLimitMiB: 512,
      desiredCount: 1,
      taskImageOptions: {
        image: ecs.ContainerImage.fromRegistry(props.ecrRepositoryUri),
        environment: {
          DB_HOST: dbInstance.dbInstanceEndpointAddress,
          DB_PORT: dbInstance.dbInstanceEndpointPort,
          DB_NAME: 'postgres',
          DB_USER: 'admin',
          DB_PASSWORD: dbSecret.secretValueFromJson('password').unsafeUnwrap(), // 簡易用。※本番は避ける
        },
      },
      publicLoadBalancer: true,
    });
  }
}
