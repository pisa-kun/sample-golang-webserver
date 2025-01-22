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
		log.Fatal(err)
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

	log.Println("Server starting on port 8080...")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
