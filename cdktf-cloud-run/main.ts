import { Construct } from "constructs";
import { App, TerraformOutput, TerraformStack } from "cdktf";
import * as google from '@cdktf/provider-google'
import { GoogleProvider } from "@cdktf/provider-google/lib/provider";
import { DataGoogleIamPolicy } from "@cdktf/provider-google/lib/data-google-iam-policy";

class MyStack extends TerraformStack {
  constructor(scope: Construct, id: string) {
    super(scope, id);
    // Google Cloud Providerの設定を追加
    new GoogleProvider(this, "Google", {
      region: "us-central1",
      project: "Project-ID", // 必要に応じてプロジェクトIDを設定
    });

      const cloudRunService = new google.cloudRunService.CloudRunService(this, 'my-cloud-run-service', {
        name: 'my-cloud-run-service',
        location: 'us-central1',
        template: {
          spec: {
            containers: [
              {
                image: 'gcr.io/cloudrun/hello', // GoogleのHello Worldイメージ
              },
            ],
          },
        }
      }
    )
      // Cloud RunサービスにallUsersに対してアクセス権を付与
      new google.cloudRunServiceIamPolicy.CloudRunServiceIamPolicy(this, 'allow-all-users', {
        service: cloudRunService.name,
        location: 'us-central1',
        policyData: new DataGoogleIamPolicy(this, 'noAuth',{
          binding:[
            {
              role: 'roles/run.invoker',
              members: ['allUsers'], // allUsersに対してアクセス権を付与
            }
          ]
        }).policyData
      });
      
      new TerraformOutput(this, 'outputUrl', {
        value: cloudRunService.status.get(0).url,
      })
  }
}

const app = new App();
new MyStack(app, "cdktf-cloud-run");
app.synth();
