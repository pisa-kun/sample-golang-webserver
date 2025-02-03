# apigw + cloud run

```
    vpc_access {
      network_interfaces {
        network    = "private-network"
        subnetwork = "private-network"
      }
      egress = "PRIVATE_RANGES_ONLY"
    }
```

このcloud runに接続できるapigwをデプロイする

cloud-run-tfが肥大化してきたので、apigw+cloudrunのシンプル構成のサンプルはこちらに

### Cloud Run
直接curlするとpermission errorになる

### api gateway
Hello Worldが返ってくる