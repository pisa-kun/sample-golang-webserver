package main

import (
	"database/sql"
	"fmt"
	"log"
	"os"

	_ "github.com/lib/pq"
)

func main() {
	// 環境変数からデータベースの接続情報を取得
	dbHost := os.Getenv("DB_HOST")
	dbPort := os.Getenv("DB_PORT")
	dbUser := os.Getenv("DB_USER")
	dbPassword := os.Getenv("DB_PASSWORD")
	dbName := os.Getenv("DB_NAME")
	// PostgreSQL接続情報（必要に応じて変更）
	connStr := fmt.Sprintf("postgres://%s:%s@%s:%s/%s?sslmode=disable", dbUser, dbPassword, dbHost, dbPort, dbName)
	db, err := sql.Open("postgres", connStr)
	if err != nil {
		log.Fatal(err)
	}
	defer db.Close()

	// テーブルが存在しない場合に作成（存在する場合はスキップ）
	createTableSQL := `
	CREATE TABLE IF NOT EXISTS users (
		"name" VARCHAR(100),
		age INT
	);`
	_, err = db.Exec(createTableSQL)
	if err != nil {
		log.Fatal("Failed to create table:", err)
	}

	// データの挿入
	insertSQL := `
	INSERT INTO users ("name", age) VALUES
		('shiun sumika', 16),
		('arisugawa natsuha', 20);`
	_, err = db.Exec(insertSQL)
	if err != nil {
		log.Fatal("Failed to insert data:", err)
	}

	fmt.Println("Data inserted successfully!")
}
