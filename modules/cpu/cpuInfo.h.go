package cpu

type CpuCores []map[string]string
type CpuLoad struct {
	Minute   string
	Minute5  string
	Minute15 string
}
type CpuInfo struct {
	Cores    CpuCores
	CpuCount uint
	Brand    string
	Model    string
	LoadAvg  *CpuLoad
}
