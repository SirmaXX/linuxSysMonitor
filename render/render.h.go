package render

import (
	"linuxSysMonitor/modules/disc"
	"linuxSysMonitor/modules/cpu"
)

type Mounts struct {
	disc.MountInfo
	Free  string
	Used  string
	Total string
}
type MainPageVars struct {
	Discs []Mounts
	Cpu   *cpu.CpuInfo
}
