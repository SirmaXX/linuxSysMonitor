package disc

import "syscall"

func GetDiscStats(device string) syscall.Statfs_t {
	var stats syscall.Statfs_t
	syscall.Statfs(device, &stats)
	return stats
}
