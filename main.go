package main

import (
	"fmt"
	"net/http"

	"github.com/aws/aws-sdk-go/aws"
	"github.com/aws/aws-sdk-go/aws/session"
	"github.com/aws/aws-sdk-go/service/s3"
)

func handler(w http.ResponseWriter, r *http.Request) {
	// クエリパラメータ 'name' を取得
	name := r.URL.Query().Get("name")
	if name == "" {
		// パラメータがない場合は "Hello World!" を返す
		fmt.Fprintf(w, "Hello World!\n")
	} else {
		// パラメータがあれば "Hello World!, <name>" を返す
		fmt.Fprintf(w, "Hello World!, %s\n", name)
	}

	// S3からバケット名一覧を取得
	sess, err := session.NewSession(&aws.Config{
		Region: aws.String("ap-northeast-1"), // 必要に応じて変更
	})
	if err != nil {
		fmt.Fprintf(w, "S3セッション作成エラー: %v\n", err)
		return
	}
	svc := s3.New(sess)

	// バケット一覧を取得
	resp, err := svc.ListBuckets(&s3.ListBucketsInput{})
	if err != nil {
		fmt.Fprintf(w, "S3バケット一覧取得エラー: %v\n", err)
		return
	}

	// バケット名の一覧を表示
	if len(resp.Buckets) > 0 {
		fmt.Fprintf(w, "AWSアカウント内のS3バケット一覧:\n")
		for _, bucket := range resp.Buckets {
			fmt.Fprintf(w, "* %s\n", *bucket.Name)
		}
	} else {
		fmt.Fprintf(w, "S3バケットはありません\n")
	}
}

func main() {
	// ルートパスに対するハンドラを設定
	http.HandleFunc("/", handler)

	// サーバーをポート3000で起動
	fmt.Println("サーバーがポート8080で起動しました...")
	err := http.ListenAndServe(":8080", nil)
	if err != nil {
		fmt.Println("サーバー起動エラー:", err)
	}
}
