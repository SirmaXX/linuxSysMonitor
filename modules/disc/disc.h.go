package disc

type BYTE float64

const (
	_       = iota
	KB BYTE = 1 << (10 * iota)
	MB
	GB
	TB
)
