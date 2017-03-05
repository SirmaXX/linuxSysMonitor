package main

import (
	"github.com/pressly/chi"
	"net/http"
	"osList/render"
	"osList/ws"
)

func main() {
	r := chi.NewRouter()
	r.Mount("/", render.MainTemplate())
	r.Mount("/ws", ws.WebSocketHandler())
	http.ListenAndServe(":8080", r)
}
