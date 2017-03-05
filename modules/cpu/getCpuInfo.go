package cpu

import (
	"os"
	"bufio"
	"strings"
	"runtime"
	"fmt"
	"encoding/csv"
)

func GetCpuInfo() (*CpuInfo, error) {
	cpus, err := os.Open("/proc/cpuinfo")
	if err != nil {
		return nil, fmt.Errorf("Cannot open /proc/cpuinfo")
	}
	defer cpus.Close()
	s := bufio.NewScanner(cpus)
	cpuCores := make(CpuCores, 0)
	core := map[string]string{}
	for s.Scan() {
		txt := s.Text()
		fields := strings.Split(txt, ":")
		if len(fields) < 2 {
			if len(txt) == 0 {
				cpuCores = append(cpuCores, core)
				core = map[string]string{}
			}
			continue
		}
		k, v := fields[0], fields[1]
		k, v = strings.TrimSpace(k), strings.TrimSpace(v)
		core[k] = v
	}
	return &CpuInfo{
		Cores:    cpuCores,
		CpuCount: uint(runtime.NumCPU()),
		Brand:    cpuCores[0]["vendor_id"],
		Model:    cpuCores[0]["model name"],
	}, nil
}
func GetCpuLoad() (*CpuLoad, error) {
	loadFile, err := os.Open("/proc/loadavg")
	if err != nil {
		return nil, fmt.Errorf("cannot open /proc/loadAvg")
	}
	defer loadFile.Close()
	r := csv.NewReader(loadFile)
	const (
		min1  = iota
		min5
		min15
	)
	r.Comma = ' '
	data, err := r.Read()
	if err != nil {
		return nil, fmt.Errorf("cannot read loadavg")
	}
	return &CpuLoad{
		Minute:   data[min1],
		Minute5:  data[min5],
		Minute15: data[min15],
	}, nil
}
