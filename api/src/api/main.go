package main

import (
	"encoding/json"
	"flag"
	"fmt"
	"github.com/jmoiron/sqlx"
	_ "github.com/lib/pq"
	"io/ioutil"
	"log"
	"net/http"
)

type (
	DbConfig struct {
		ConnString string `json:"db_connstring"`
		Port       int    `json:"http_port"`
	}

	Status struct {
		Count int64  `json:"count,omitempty"`
		Error string `json:"error,omitempty"`
	}
)

const VersionTemplate = "Git Commit Hash: %s\nUTC build time : %s\nBuilt by       : %s\n"

var (
	showVersion = flag.Bool("version", false, "Show binary version")
	configFile  = flag.String("config-file", "", "path to a configuration file")

	buildStamp, gitHash, builder string

	db       *sqlx.DB
	httpPort string
)

// SQL queries
const (
	createStatusTable = `CREATE TABLE IF NOT EXISTS status (
		id SERIAL PRIMARY KEY,
		ts TIMESTAMP NOT NULL DEFAULT now(),
		event TEXT NOT NULL
	)`

	getRowCount = `SELECT COUNT(*) FROM status`
)

func OpenConfig(filePath string) (config DbConfig, err error) {
	file, err := ioutil.ReadFile(filePath)
	if err != nil {
		return
	}

	json.Unmarshal(file, &config)

	return
}

func init() {
	flag.Parse()

	if configFile == nil || len(*configFile) == 0 {
		panic("path to config file is required")
	}

	conf, err := OpenConfig(*configFile)
	if err != nil {
		panic(fmt.Sprint("unable to open config file", err))
	}

	db = sqlx.MustConnect("postgres", conf.ConnString)

	httpPort = fmt.Sprintf(":%d", conf.Port)
}

func setupDatabase() {
	db.MustExec(createStatusTable)
	db.MustExec(`INSERT INTO status (event) VALUES ('create')`)
}

func someText(w http.ResponseWriter, _ *http.Request) {
	var failedInsert string

	_, err := db.Exec(`INSERT INTO status (event) VALUES ('text')`)
	if err != nil {
		failedInsert = "Inserting to table status: FAILED\n\n"
	}

	fmt.Fprintf(w, "%sHi there, this is a sample text", failedInsert)
}

func status(w http.ResponseWriter, _ *http.Request) {
	var rows int64
	err := db.Get(&rows, getRowCount)
	if err != nil {
		fmt.Fprint(w, "Unable to get status counter")
		return
	}

	fmt.Fprintf(w, "Text has been seen %d times", rows)
}

func statusJson(w http.ResponseWriter, _ *http.Request) {
	s := Status{}

	err := db.Get(&s.Count, getRowCount)
	if err != nil {
		s.Error = "Unable to get status counter"
	}

	w.Header().Set("Content-Type", "application/json")

	val, err := json.Marshal(s)
	if err != nil {
		w.Write([]byte(`{"error": "error while marshaling json -_-"}`))
		return
	}

	w.Write(val)
}

func main() {
	if *showVersion {
		fmt.Printf(VersionTemplate, gitHash, buildStamp, builder)
		return
	}

	log.Printf(VersionTemplate, gitHash, buildStamp, builder)

	setupDatabase()

	http.HandleFunc("/api/text", someText)
	http.HandleFunc("/api/status", status)
	http.HandleFunc("/api/status.json", statusJson)

	log.Printf("Serving on port %s\n", httpPort)

	http.ListenAndServe(httpPort, nil)
}
