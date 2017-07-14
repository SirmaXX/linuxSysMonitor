package cpu

import "testing"

//Output : test
func TestGetCpuInfo(t *testing.T) {

	inf, err := GetCpuInfo()
	if err {
		t.Fail()
	}
	for _, i := range inf.Cores {
		t.Log(i["processor"])
	}
}
