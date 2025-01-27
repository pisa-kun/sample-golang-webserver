package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"

	_ "github.com/lib/pq" // PostgreSQL ドライバ
)

func main() {
	// 環境変数からデータベースの接続情報を取得
	dbHost := os.Getenv("DB_HOST")
	dbPort := os.Getenv("DB_PORT")
	dbUser := os.Getenv("DB_USER")
	dbPassword := os.Getenv("DB_PASSWORD")
	dbName := os.Getenv("DB_NAME")

	// PostgreSQLへの接続
	connStr := fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable", dbUser, dbPassword, dbHost, dbPort, dbName)
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		fmt.Println("DB接続エラー:", err)
		return
	}
	defer db.Close()

	// PostgreSQLのバージョンを取得
	var version string
	err = db.QueryRow("SELECT version();").Scan(&version)
	if err != nil {
		log.Fatal(err)
	}

	// HTTP ハンドラ
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		var user string
		var age int
		err := db.QueryRow("SELECT * FROM users WHERE age = 16").Scan(&user, &age)
		if err != nil {
			log.Fatal(err)
		}
		fmt.Fprintf(w, "Hello World!, Cloud SQL Version %s\n", version)
		fmt.Fprintf(w, "User: %s, Age: %d\n", user, age)
	})

	http.HandleFunc("/user", func(w http.ResponseWriter, r *http.Request) {
		// クエリパラメータを取得
		ageParam := r.URL.Query().Get("age")

		// ageパラメータの検証
		var age int
		if ageParam != "" {
			_, err := fmt.Sscanf(ageParam, "%d", &age)
			if err != nil {
				http.Error(w, "ageパラメータは整数でなければなりません", http.StatusBadRequest)
				return
			}
		}

		// SQLクエリ作成
		query := "SELECT * FROM users"
		var args []interface{}
		if ageParam != "" {
			query += " WHERE age = $1"
			args = append(args, age)
		}

		// クエリ実行
		rows, err := db.Query(query, args...)
		if err != nil {
			http.Error(w, fmt.Sprintf("ユーザー検索中にエラーが発生しました: %v", err), http.StatusInternalServerError)
			return
		}
		defer rows.Close()

		// 結果を表示
		fmt.Fprintf(w, "Hello World!, Cloud SQL Version %s\n", version)
		for rows.Next() {
			var userName string
			var userAge int
			err = rows.Scan(&userName, &userAge)
			if err != nil {
				http.Error(w, fmt.Sprintf("データの読み込みエラー: %v", err), http.StatusInternalServerError)
				return
			}
			fmt.Fprintf(w, "User: %s, Age: %d\n", userName, userAge)
		}

		if err := rows.Err(); err != nil {
			http.Error(w, fmt.Sprintf("結果の読み込みエラー: %v", err), http.StatusInternalServerError)
			return
		}
	})

	log.Println("Server starting on port 8080...")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
