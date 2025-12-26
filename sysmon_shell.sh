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
    echo "  7) Docker Containers"
    echo "  8) Log Dosyalari"
    echo "  9) All"
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

show_docker() {
    echo ""
    echo ">> DOCKER CONTAINERS"
    
    if ! command -v docker >/dev/null 2>&1; then
        echo "Docker yuklu degil"
        return
    fi
    
    if ! docker info >/dev/null 2>&1; then
        echo "Docker calismiyior veya yetki yok (sudo ile dene)"
        return
    fi
    
    running=$(docker ps -q 2>/dev/null | wc -l)
    stopped=$(docker ps -aq --filter "status=exited" 2>/dev/null | wc -l)
    total=$(docker ps -aq 2>/dev/null | wc -l)
    
    echo "Toplam: $total  |  Calisan: $running  |  Durmus: $stopped"
    echo ""
    
    if [ "$total" -gt 0 ]; then
        echo "NAME                 STATUS          CPU%    MEM         PORTS"
        echo "-------------------  -------------  ------  ----------  -----"
        docker ps -a --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 2>/dev/null | tail -n +2 | head -15 | while read line; do
            name=$(echo "$line" | awk '{print $1}')
            status=$(echo "$line" | awk '{print $2, $3}')
            ports=$(echo "$line" | awk '{$1=$2=$3=""; print $0}' | sed 's/^ *//')
            
            # CPU ve RAM bilgisi (sadece calisan containerlar icin)
            stats=$(docker stats --no-stream --format "{{.CPUPerc}}\t{{.MemUsage}}" "$name" 2>/dev/null)
            if [ -n "$stats" ]; then
                cpu=$(echo "$stats" | awk -F'\t' '{print $1}')
                mem=$(echo "$stats" | awk -F'\t' '{print $1}')
            else
                cpu="-"
                mem="-"
            fi
            
            printf "%-20s %-14s %6s  %-10s  %s\n" "$name" "$status" "$cpu" "$mem" "$ports"
        done
    fi
}

show_logs() {
    echo ""
    echo ">> LOG DOSYALARI (/var/log)"
    
    if [ ! -d /var/log ]; then
        echo "/var/log dizini bulunamadi"
        return
    fi
    
    # Toplam log boyutu
    total_size=$(du -sh /var/log 2>/dev/null | awk '{print $1}')
    echo "Toplam log boyutu: $total_size"
    echo ""
    
    # Disk kullanim yuzdesi
    log_disk=$(df /var/log 2>/dev/null | awk 'NR==2 {print $5}')
    echo "Log disk kullanimi: $log_disk"
    echo ""
    
    echo ">> EN BUYUK 15 LOG DOSYASI"
    echo "BOYUT      DOSYA"
    echo "---------  -----"
    find /var/log -type f 2>/dev/null | xargs du -h 2>/dev/null | sort -rh | head -15 | awk '{printf "%-10s %s\n", $1, $2}'
    
    echo ""
    echo ">> SON 24 SAATTE DEGISEN LOGLAR"
    echo "BOYUT      DOSYA"
    echo "---------  -----"
    find /var/log -type f -mtime -1 2>/dev/null | xargs du -h 2>/dev/null | sort -rh | head -10 | awk '{printf "%-10s %s\n", $1, $2}'
    
    # Uyari: Buyuk log dosyalari
    echo ""
    big_logs=$(find /var/log -type f -size +100M 2>/dev/null | wc -l)
    if [ "$big_logs" -gt 0 ]; then
        echo "!! UYARI: $big_logs adet 100MB ustu log dosyasi var!"
        find /var/log -type f -size +100M 2>/dev/null | xargs du -h 2>/dev/null | sort -rh
    fi
}

show_all() {
    show_cpu
    show_ram
    show_disk
    show_processes
    show_ports
    show_users
    show_docker
    show_logs
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
        7) show_docker ;;
        8) show_logs ;;
        9) show_all ;;
        0|q|Q) echo "Cikis..."; exit 0 ;;
        *) echo "Gecersiz secim!" ;;
    esac
    
    wait_enter
done
