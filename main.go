package main

import (
	"fmt"
	"net/http"
)

func handler(w http.ResponseWriter, r *http.Request) {
	// クエリパラメータ 'name' を取得
	name := r.URL.Query().Get("name")
	if name == "" {
		// パラメータがない場合は "Hello World!" を返す
		fmt.Fprintf(w, "Hello World!")
	} else {
		// パラメータがあれば "Hello World!, <name>" を返す
		fmt.Fprintf(w, "Hello World!, %s", name)
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
