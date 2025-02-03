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