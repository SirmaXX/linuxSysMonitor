package disc

type BYTE float64

const (
	_       = iota
	KB BYTE = 1 << (10 * iota)
	MB
	GB
	TB
)

type MountInfo struct {
	Device    string
	MountPath string
	FSType    string
	Options   string
}
