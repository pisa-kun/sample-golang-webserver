import * as cdk from 'aws-cdk-lib';
import { Construct } from 'constructs';
import * as ec2 from "aws-cdk-lib/aws-ec2";
import * as ecr from "aws-cdk-lib/aws-ecr";
import * as ecs from "aws-cdk-lib/aws-ecs";
import * as ecs_patterns from "aws-cdk-lib/aws-ecs-patterns";

export class CdkFargateStack extends cdk.Stack {
  constructor(scope: Construct, id: string, props?: cdk.StackProps) {
    super(scope, id, props);

    // ECR
    const repository = new ecr.Repository(this, 'AppRunnerExampleRepository',{
      repositoryName: "typescript_lilja_repository",
      imageTagMutability: ecr.TagMutability.IMMUTABLE,
    })

    const vpc = new ec2.Vpc(this, 'MyVpc', { maxAzs: 2});
    const cluster = new ecs.Cluster(this, 'Cluster', {vpc});

    const fargateService = new ecs_patterns.ApplicationLoadBalancedFargateService(this,"FargateService",{
      cluster: cluster,
      taskImageOptions: {
        image: ecs.ContainerImage.fromEcrRepository(repository),
        containerPort: 8080, // default 80, 8080をALBのターゲットに指定
      },
      publicLoadBalancer: true,
    })

    // ターゲットグループのヘルスチェックの設定
    fargateService.targetGroup.configureHealthCheck({
      path: '/health', // ヘルスチェック用のエンドポイント（アプリケーションに応じて変更）
      interval: cdk.Duration.seconds(30), // ヘルスチェック間隔（30秒）
      timeout: cdk.Duration.seconds(5),   // ヘルスチェックのタイムアウト（5秒）
      healthyThresholdCount: 3,           // 健康と見なされるヘルスチェックの成功回数
      unhealthyThresholdCount: 2,         // 不健康と見なされる失敗回数
    });
  }
}
