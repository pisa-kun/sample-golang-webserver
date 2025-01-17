package main

import (
	"github.com/aws/aws-cdk-go/awscdk/awsapprunner"
	"github.com/aws/aws-cdk-go/awscdk/awsecr"
	"github.com/aws/aws-cdk-go/awscdk/awsiam"
	"github.com/aws/aws-cdk-go/awscdk/v2"
	"github.com/aws/constructs-go/constructs/v10"
	"github.com/aws/jsii-runtime-go"
)

type CdkStackProps struct {
	awscdk.StackProps
}

func NewAppRunnerStack(scope constructs.Construct, id string, props *AppRunnerStackProps) awscdk.Stack {
	stack := awscdk.NewStack(scope, &id, &props.StackProps)

	// ECRリポジトリからDockerイメージを取得
	repository := awsecr.NewRepository(stack, jsii.String("MyRepo"), &awsecr.RepositoryProps{
		RepositoryName: jsii.String("my-golang-webapp"),
	})

	// S3読み取り用のIAMロール
	role := awsiam.NewRole(stack, jsii.String("AppRunnerRole"), &awsiam.RoleProps{
		AssumedBy: awsiam.NewServicePrincipal(jsii.String("build.apprunner.amazonaws.com"), nil),
	})
	role.AddToPolicy(awsiam.NewPolicyStatement(&awsiam.PolicyStatementProps{
		Actions:   &[]*string{jsii.String("s3:GetObject")},
		Resources: &[]*string{bucket.ArnForObjects(jsii.String("*"))},
	}))

	// App Runnerサービスを作成
	awsapprunner.NewCfnService(stack, jsii.String("MyAppRunnerService"), &awsapprunner.CfnServiceProps{
		ServiceName: jsii.String("golang-webapp-service"),
		SourceConfiguration: &awsapprunner.CfnService_SourceConfigurationProperty{
			ImageRepository: &awsapprunner.CfnService_ImageRepositoryProperty{
				ImageIdentifier:     jsii.String("674172895730.dkr.ecr.ap-northeast-1.amazonaws.com/my-golang-webapp:latest"),
				ImageRepositoryType: jsii.String("ECR"),
			},
			AuthenticationConfiguration: &awsapprunner.CfnService_AuthenticationConfigurationProperty{
				// 認証設定が必要な場合は追加
			},
		},
		InstanceConfiguration: &awsapprunner.CfnService_InstanceConfigurationProperty{
			Cpu:             jsii.String("1024"), // 1 vCPU
			Memory:          jsii.String("2048"), // 2 GB
			InstanceRoleArn: role.RoleArn(),
		},
	})

	return stack
}

func main() {
	app := awscdk.NewApp(nil)

	NewAppRunnerStack(app, "AppRunnerStack", &AppRunnerStackProps{
		StackProps: awscdk.StackProps{
			Env: &awscdk.Environment{
				Region: jsii.String("ap-northeast-1"),
			},
		},
	})

	app.Synth(nil)
}

// env determines the AWS environment (account+region) in which our stack is to
// be deployed. For more information see: https://docs.aws.amazon.com/cdk/latest/guide/environments.html
func env() *awscdk.Environment {
	// If unspecified, this stack will be "environment-agnostic".
	// Account/Region-dependent features and context lookups will not work, but a
	// single synthesized template can be deployed anywhere.
	//---------------------------------------------------------------------------
	return nil

	// Uncomment if you know exactly what account and region you want to deploy
	// the stack to. This is the recommendation for production stacks.
	//---------------------------------------------------------------------------
	// return &awscdk.Environment{
	//  Account: jsii.String("123456789012"),
	//  Region:  jsii.String("us-east-1"),
	// }

	// Uncomment to specialize this stack for the AWS Account and Region that are
	// implied by the current CLI configuration. This is recommended for dev
	// stacks.
	//---------------------------------------------------------------------------
	// return &awscdk.Environment{
	//  Account: jsii.String(os.Getenv("CDK_DEFAULT_ACCOUNT")),
	//  Region:  jsii.String(os.Getenv("CDK_DEFAULT_REGION")),
	// }
}
