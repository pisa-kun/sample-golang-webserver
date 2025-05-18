package main

import (
    "database/sql"
    "fmt"
    "log"
    "net/http"
    _ "github.com/lib/pq"
)

func main() {
    connStr := "host=db user=postgres password=postgres dbname=postgres sslmode=disable"
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