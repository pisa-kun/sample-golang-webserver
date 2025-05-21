package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"

	_ "github.com/lib/pq"
)

func main() {
	// デフォルト値
	host := "db"
	port := "5432"
	dbname := "postgres"
	user := "postgres"
	password := "postgres"

	// 環境変数があれば上書き
	if v := os.Getenv("DB_HOST"); v != "" {
		host = v
	}
	if v := os.Getenv("DB_PORT"); v != "" {
		port = v
	}
	if v := os.Getenv("DB_NAME"); v != "" {
		dbname = v
	}
	if v := os.Getenv("DB_USER"); v != "" {
		user = v
	}
	if v := os.Getenv("DB_PASSWORD"); v != "" {
		password = v
	}

	connStr := fmt.Sprintf(
		"host=%s port=%s user=%s password=%s dbname=%s sslmode=disable",
		host, port, user, password, dbname,
	)

	db, err := sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		rows, err := db.Query("SELECT name, age FROM users")
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}
		defer rows.Close()

		fmt.Fprintln(w, "Users:")
		for rows.Next() {
			var name string
			var age int
			err := rows.Scan(&name, &age)
			if err != nil {
				http.Error(w, err.Error(), http.StatusInternalServerError)
				return
			}
			fmt.Fprintf(w, "- %s (%d)\n", name, age)
		}
	})

	log.Println("Server is running on :8080")
	log.Fatal(http.ListenAndServe(":8080", nil))
}
