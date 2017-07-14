package ws

import (
	"github.com/pressly/chi"
	"net/http"
	"github.com/gorilla/websocket"
	"encoding/json"
	"log"
	"os"
	"time"
	"sync"
	"fmt"
)

func WebSocketHandler() *chi.Mux {
	var lock sync.RWMutex
	rt := chi.NewRouter()
	var upgrader = websocket.Upgrader{}
	rt.Get("/", func(w http.ResponseWriter, r *http.Request) {
		con, err := upgrader.Upgrade(w, r, nil)
		if err != nil {
			log.SetOutput(os.Stderr)
			log.Println(err)
			errorWriter := json.NewEncoder(w)
			err = errorWriter.Encode(map[string]string{
				"error": "cannot create websocket connection",
			})
			if err != nil {
				log.Println("cannot send error message somethign is wrong with this server :D well look at the good part anyway it was errored so it makes no sense for the user to see errors")
				log.Println(err)
			}
			log.SetOutput(os.Stdout)
		}
		go func() {
			for {
				_, msg, err := con.ReadMessage()
				if err != nil {
					return
				}
				fmt.Println(string(msg))
			}
		}()
		go func() {
			for {
				lock.Lock()
				err = con.WriteMessage(websocket.TextMessage, []byte("test"))
				if err != nil {
					return
				}
				lock.Unlock()
				time.Sleep(time.Second * 3)
			}
		}()
		go func() {
			for {
				lock.Lock()
				err = con.WriteMessage(websocket.TextMessage, []byte("test1"))
				if err != nil {
					return
				}
				lock.Unlock()
				time.Sleep(time.Second * 3)
			}
		}()
		go func() {
			for {
				lock.Lock()
				err = con.WriteMessage(websocket.TextMessage, []byte("test2"))
				if err != nil {
					return
				}
				lock.Unlock()
				time.Sleep(time.Second * 3)
			}
		}()
		go func() {
			for {
				lock.Lock()
				err = con.WriteMessage(websocket.TextMessage, []byte("test3"))
				if err != nil {
					return
				}
				lock.Unlock()
				time.Sleep(time.Second * 3)
			}
		}()
	})
	return rt
}
