package disc

import "testing"

func TestGetDiscList(t *testing.T) {
	t.Log(GetDiscsList())
}
func TestGetPartitionList(t *testing.T) {
	for _, dev := range GetDiscsList() {
		t.Log(GetPartitionList(dev))
	}
}
func TestGetDiscStats(t *testing.T) {
	var stats = GetDiscStats("/")
	t.Log(BYTE(stats.Bavail * uint64(stats.Bsize))/GB)
	t.Log(BYTE(stats.Blocks * uint64(stats.Bsize))/GB)
}
