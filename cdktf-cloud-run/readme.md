## ステップ 1: CDKTFのインストール

npm install -g cdktf-cli
インストールが完了したら、cdktf コマンドが使えるようになります。

## ステップ 2: 新しいCDKTFプロジェクトを作成

プロジェクトのディレクトリを作成し、初期化します。

```bash

mkdir my-cloudrun-app
cd my-cloudrun-app
cdktf init --template=typescript --project-name=my-cloudrun-app
```

## ステップ 3: Google Cloud Providerの設定

次に、Google Cloudのプロバイダを設定します。main.ts に以下のように記述します。

まず、Google Cloudのプロバイダをインストールします。

```bash
npm install @cdktf/provider-google
npm install --save-dev @types/node
```

<https://github.com/hashicorp/terraform-cdk/tree/main/examples/typescript/google-cloudrun>

## デプロイコマンド

```
cdktf Deploy
```
