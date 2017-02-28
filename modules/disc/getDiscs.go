package disc

import (
	"os"
	"bufio"
	"regexp"
	"strings"
	"log"
	"sort"
)

func GetDiscsList() []string {
	discsInfo, err := os.Open("/proc/diskstats")
	if err != nil {
		log.Fatalln("Make sure you have correct rights to read /proc/diskstats and you are using unix")
	}
	defer discsInfo.Close()
	var discs = make([]string, 0, 5)
	nameRegexp := regexp.MustCompile(".*(sd\\w[^\\d]).*")
	scanner := bufio.NewScanner(discsInfo)
	for scanner.Scan() {
		discName := scanner.Text()
		submatch := nameRegexp.FindAllStringSubmatch(discName, 1)
		if len(submatch) == 0 {
			continue
		}
		discs = append(discs, "/dev/"+strings.TrimSpace(submatch[0][1]))
	}
	return discs
}
func GetPartitionList(deviceName string) []string {
	deviceName = strings.TrimPrefix(deviceName, "/dev/")
	deviceName = strings.TrimSuffix(deviceName, "/")
	dev, err := os.Open("/dev")

	if err != nil {
		log.Fatalln("cannot open the directory /dev are you sure you are on unix machine? ")
	}
	defer dev.Close()
	partitions := make([]string, 0, 5)
	names, _ := dev.Readdirnames(0)
	for _, name := range names {
		if !strings.HasPrefix(name, deviceName) {
			continue
		}
		partitions = append(partitions, name)
	}
	sort.Strings(partitions)
	return partitions
}
