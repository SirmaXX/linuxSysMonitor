package render

import (
	"osList/modules/disc"
	"osList/modules/cpu"
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
