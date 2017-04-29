package main

import (
	"net/http"
	"github.com/pressly/chi"
	"linuxSysMonitor/render"
	"linuxSysMonitor/ws"
)

func main() {
	r := chi.NewRouter()
	r.Mount("/", render.MainTemplate())
	r.Mount("/ws", ws.WebSocketHandler())
	http.ListenAndServe(":8080", r)
}
