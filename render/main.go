package render

import (
	"github.com/pressly/chi"
	"net/http"
	"text/template"
	"log"
	"osList/modules/disc"
	"fmt"
	"osList/modules/cpu"
)

func MainTemplate() *chi.Mux {
	rt := chi.NewRouter()
	rt.Get("/", func(w http.ResponseWriter, r *http.Request) {
		t, err := template.ParseFiles("templates/index.html")
		if err != nil {
			log.Fatalln("cannot parse template", err)
		}
		var tvar = new(MainPageVars)
		var mounts *Mounts
		tvar.Discs = make([]Mounts, 0)
		tmpMnts, err := disc.GetMounts()
		if err != nil {
			fmt.Println(err)
			tmpMnts = []disc.MountInfo{}
		}
		for _, mount := range tmpMnts {
			stats := disc.GetDiscStats(mount.MountPath)
			freeSpace := disc.BYTE(stats.Bavail * uint64(stats.Bsize))
			total := disc.BYTE(stats.Blocks * uint64(stats.Bsize))
			used := total - freeSpace
			freeSpace = freeSpace / disc.GB
			used = used / disc.GB
			mounts = &Mounts{mount, fmt.Sprintf("%.3fGB", freeSpace), fmt.Sprintf("%.3fGB", used), fmt.Sprintf("%.3fGB", total/disc.GB) }
			tvar.Discs = append(tvar.Discs, *mounts)
		}
		tvar.Cpu, err = cpu.GetCpuInfo()
		if err != nil {
			fmt.Println(err)
		}
		tvar.Cpu.LoadAvg, err = cpu.GetCpuLoad()
		if err != nil {
			fmt.Println(err)
		}
		err = t.Execute(w, *tvar)
		if err != nil {
			fmt.Println(err)
		}
	})
	return rt
}
