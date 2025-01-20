import * as cdk from 'aws-cdk-lib/core'
import * as iam from 'aws-cdk-lib/aws-iam'
import * as apprunner from 'aws-cdk-lib/aws-apprunner'
import { Construct } from 'constructs';
import * as ecr from 'aws-cdk-lib/aws-ecr'

interface AppRunnerProps {
    repository: ecr.Repository
}

export class AppRunner extends cdk.Stack {
    constructor(scope: Construct, id: string, props: AppRunnerProps) {
    super(scope, id)
        
    const { repository } = props
        
    const instanceRole = new iam.Role(scope, 'AppRunnerInstanceRole',{
        assumedBy:new iam.ServicePrincipal('tasks.apprunner.amazonaws.com'),
    })

    const accessRole = new iam.Role(scope, 'AppRunnerAccessRole',{
        assumedBy: new iam.ServicePrincipal('build.apprunner.amazonaws.com')
    })
    // ECR からのイメージ取得を許可するポリシーを追加
    accessRole.addManagedPolicy(iam.ManagedPolicy.fromAwsManagedPolicyName('service-role/AWSAppRunnerServicePolicyForECRAccess'));

    // AmazonS3FullAccess ポリシーのアタッチ
    instanceRole.addManagedPolicy(iam.ManagedPolicy.fromAwsManagedPolicyName('AmazonS3FullAccess'));

    // AppRunner
    new apprunner.CfnService(scope, 'AppRunnerExampleService', {
        serviceName: 'sumisumi-runner',
        instanceConfiguration: {
            instanceRoleArn: instanceRole.roleArn,
            // cpu: '1024', memory: '2048',
        },
        sourceConfiguration: {
            authenticationConfiguration: {
                accessRoleArn: accessRole.roleArn,
            },
            autoDeploymentsEnabled: false,
            imageRepository:{
                imageRepositoryType: 'ECR',
                imageIdentifier:`${repository.repositoryUri}:latest`,
                imageConfiguration:{
                    port:'8080',
                    runtimeEnvironmentVariables:[
                        // AppRunner用環境変数を定義
                        // 使わないけど例として
                        {
                            name: 'DB_HOST',
                            value: 'test',
                        },
                        {
                            name: 'DB_PORT',
                            value: 'test',
                        },
                    ]
                }
            }
        }
    })
    }
}