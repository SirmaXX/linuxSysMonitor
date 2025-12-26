#!/bin/sh

# sysmon.sh - Interactive Linux Server Monitor (POSIX uyumlu)

show_header() {
    clear
    echo "═══════════════════════════════════════════════════════════════"
    echo "  SYSTEM MONITOR - $(hostname) - $(date '+%Y-%m-%d %H:%M:%S')"
    echo "═══════════════════════════════════════════════════════════════"
}

show_menu() {
    echo ""
    echo "MENU:"
    echo "  1) RAM"
    echo "  2) Disk"
    echo "  3) CPU & Load"
    echo "  4) Processes"
    echo "  5) Open Ports"
    echo "  6) Logged Users"
    echo "  7) All"
    echo "  0) Cikis"
    echo ""
    printf "Seciminiz: "
}

show_ram() {
    echo ""
    echo ">> MEMORY"
    free -h
    echo ""
    mem_percent=$(free | awk 'NR==2 {printf "%.0f", $3/$2*100}')
    bar_len=40
    filled=$((mem_percent * bar_len / 100))
    empty=$((bar_len - filled))
    printf "Usage: ["
    i=0; while [ $i -lt $filled ]; do printf "#"; i=$((i+1)); done
    i=0; while [ $i -lt $empty ]; do printf "-"; i=$((i+1)); done
    printf "] %d%%\n" "$mem_percent"
}

show_disk() {
    echo ""
    echo ">> DISK"
    df -h | grep -v tmpfs | grep -v devtmpfs | head -15
}

show_cpu() {
    echo ""
    echo ">> CPU & LOAD"
    echo "Uptime: $(uptime -p 2>/dev/null || uptime)"
    load=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
    cores=$(nproc 2>/dev/null || grep -c processor /proc/cpuinfo 2>/dev/null || echo 1)
    echo "Load (1/5/15 min): $load"
    echo "CPU Cores: $cores"
}

show_processes() {
    echo ""
    echo ">> PROCESSES"
    total_proc=$(ps aux | wc -l)
    total_proc=$((total_proc - 1))
    echo "Total: $total_proc"
    echo ""
    echo ">> TOP 10 (by RAM)"
    echo "PID      USER       CPU%   RAM%   COMMAND"
    echo "-------  --------  -----  -----  -------"
    ps aux --sort=-%mem | awk 'NR>1 && NR<=11 {printf "%-8s %-10s %5.1f%% %5.1f%%  %s\n", $2, $1, $3, $4, $11}'
}

show_ports() {
    echo ""
    echo ">> LISTENING PORTS"
    if command -v ss >/dev/null 2>&1; then
        echo "PORT     ADDRESS              PROCESS"
        echo "-------  -----------------    -------"
        ss -tlnp 2>/dev/null | awk 'NR>1 {
            addr=$4
            proc=$6
            gsub(/.*"/, "", proc)
            gsub(/".*/, "", proc)
            split(addr, a, ":")
            port=a[length(a)]
            ip=addr
            gsub(/:[^:]*$/, "", ip)
            if (port != "") printf "%-8s %-20s %s\n", port, ip, proc
        }' | sort -n | uniq
    elif command -v netstat >/dev/null 2>&1; then
        netstat -tlnp 2>/dev/null | tail -n +3 | head -15
    else
        echo "ss veya netstat bulunamadi"
    fi
}

show_users() {
    echo ""
    echo ">> LOGGED IN USERS"
    count=$(who 2>/dev/null | wc -l)
    if [ "$count" -gt 0 ]; then
        echo "USER         TTY        LOGIN TIME         FROM"
        echo "-----------  --------  -----------------  ------"
        who 2>/dev/null | awk '{printf "%-12s %-10s %-18s %s\n", $1, $2, $3" "$4, $5}'
    else
        echo "Aktif oturum yok"
    fi
    echo ""
    echo "Toplam: $count kullanici"
}

show_all() {
    show_cpu
    show_ram
    show_disk
    show_processes
    show_ports
    show_users
}

wait_enter() {
    echo ""
    printf "Devam etmek icin Enter'a basin..."
    read dummy
}

# Ana program
while true; do
    show_header
    show_menu
    read choice
    
    show_header
    case $choice in
        1) show_ram ;;
        2) show_disk ;;
        3) show_cpu ;;
        4) show_processes ;;
        5) show_ports ;;
        6) show_users ;;
        7) show_all ;;
        0|q|Q) echo "Cikis..."; exit 0 ;;
        *) echo "Gecersiz secim!" ;;
    esac
    
    wait_enter
done
