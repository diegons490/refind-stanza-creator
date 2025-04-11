#!/bin/bash
# AUTHOR: diegons490
# Colors for better visualization
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
LIGHT_CYAN='\033[1;36m'
NC='\033[0m' # No Color

# Display functions
header() {
    echo -e "${LIGHT_CYAN}\n=========================================================="
    echo " $1"
    echo -e "==========================================================${NC}"
}

info() {
    echo -e "${CYAN}[INFO]${NC} $1";
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1";
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1";
}

error() {
    echo -e "${RED}[ERROR]${NC} $1";
}

ask() {
    echo -e "${YELLOW}[INPUT]${NC} $1"
    read -p "> " "$2"
}

# Check privileges
check_root() {
    [ "$EUID" -ne 0 ] && error "Run as root (sudo)." && exit 1
}

# Find refind.conf
find_refind_conf() {
    info "Searching for refind.conf in /boot..."
    REFIND_CONF=$(find /boot -type f -name refind.conf 2>/dev/null | head -n 1)
    if [ -z "$REFIND_CONF" ]; then
        warning "refind.conf not found automatically."
        ask "Enter full path to refind.conf:" REFIND_CONF
    else
        success "Found: $REFIND_CONF"
    fi
}

# Create backup
create_backup() {
    find_refind_conf
    BACKUP_FILE="${REFIND_CONF}.bak"
    MARKER="# MODIFIED_BY_SCRIPT: refind.conf modified by this script"
    if grep -q "$MARKER" "$REFIND_CONF"; then
        warning "File was previously modified. Backup not recreated."
    else
        [ ! -f "$BACKUP_FILE" ] && cp "$REFIND_CONF" "$BACKUP_FILE" && success "Backup at $BACKUP_FILE"
        echo -e "\n$MARKER" >> "$REFIND_CONF"
        info "Marker added to $REFIND_CONF"
    fi
}

# Restore backup
restore_refind_backup() {
    find_refind_conf
    BACKUP_FILE="${REFIND_CONF}.bak"
    [ -f "$BACKUP_FILE" ] && cp "$BACKUP_FILE" "$REFIND_CONF" && success "Backup restored!" || error "Backup not found."
    info "Returning to main menu..."
    return
}

# PARTUUIDs
show_partuuids() {
    header "Available PARTUUIDs"
    echo -e "${YELLOW}Device\t\t\tPARTUUID${NC}"
    echo "----------------------------------------"
    blkid | grep PARTUUID | awk -F: '{printf "%-24s", $1; sub(/.*PARTUUID="/,"",$2); sub(/".*/,"",$2); print $2}'
    echo
}

# Show root partition
show_root_partition() {
    header "Current System Partition"
    root_device=$(findmnt -n -o SOURCE / | sed 's/\[.*\]//')
    root_partuuid=$(blkid -s PARTUUID -o value "$root_device")
    echo -e "${YELLOW}Device mounted at /: ${NC}$root_device"
    echo -e "${YELLOW}Corresponding PARTUUID:   ${NC}$root_partuuid"
    echo
}

# Show /boot files
show_boot_files() {
    header "Files in /boot directory"
    echo -e "${YELLOW}Available kernels:${NC}"
    ls -1 /boot | grep -E '^vmlinuz' | sed 's/^/  /'
    echo
    echo -e "${YELLOW}Available initrds:${NC}"
    ls -1 /boot | grep -E '^initramfs' | sed 's/^/  /'
    echo
}

# List icons for refind.conf
list_icons() {
    local dir=""
    if [[ -d "/boot/EFI/refind" ]]; then
        dir="/boot/EFI/refind"
    elif [[ -d "/boot/efi/EFI/refind" ]]; then
        dir="/boot/efi/EFI/refind"
    else
        echo -e "\nThe rEFInd directory was not found in /boot."
        return
    fi
    header "Icons found in the refind folder (relative to EFI/ path):"
    find "$dir" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.icns" \) | \
        sed -E 's|^.*/(EFI/.*)|\1|' | sort
    echo
}

# List icons for refind-btrfs
list_refind_btrfs_icons() {
    local folder=""
    if [[ -d "/boot/EFI/refind" ]]; then
        folder="/boot/EFI/refind"
    elif [[ -d "/boot/efi/EFI/refind" ]]; then
        folder="/boot/efi/EFI/refind"
    else
        echo -e "\nThe rEFInd folder was not found under /boot."
        return
    fi
    echo -e "${CYAN}Icons found in the refind folder (path relative to refind/):${NC}"
    find "$folder" -type f -iname "*.png" | sed -E "s|^$folder/||" | sort
    echo
}

# Subvolumes
list_subvolumes() {
    header "Found Btrfs Subvolumes"
    btrfs subvolume list / | awk '{print $NF}' | sed 's/^/  /'
    echo
}

# Detect current subvolume
detect_current_subvolume() {
    header "Current Root Subvolume"
    CURRENT_SUBVOLUME=$(grep " / " /etc/fstab | grep btrfs | sed -n 's/.*subvol=\/\([^,]*\).*/\1/p')
    if [ -n "$CURRENT_SUBVOLUME" ]; then
        if [[ "$CURRENT_SUBVOLUME" == "@" ]]; then
            echo -e "${CYAN}[INFO]${NC} System is using subvolume '@' as root (/)."
            echo -e "${YELLOW}[NOTE]${NC} On some systems, leaving subvolume blank works better (subvolid=5)."
        else
            echo -e "${CYAN}[INFO]${NC} System is using subvolume '/$CURRENT_SUBVOLUME' as root (/)."
        fi
    else
        echo -e "${CYAN}[INFO]${NC} System might be using default subvolume (subvolid=5) as root (/)."
    fi
    echo
}

# Add boot entry
add_boot_stanza() {
    reset
    create_backup
    show_partuuids
    show_root_partition
    ask "Enter the PARTUUID of the Btrfs partition:" PARTUUID_BTRFS
    list_subvolumes
    detect_current_subvolume
    ask "Enter the subvolume name (e.g., @ or leave blank if using subvolid=5): " SUBVOLUME
    show_boot_files
    ask "Enter the kernel file name:" KERNEL_FILE
    ask "Enter the initrd file name:" INITRD_FILE
    LOADER_PATH="${KERNEL_FILE}"
    INITRD_PATH="${INITRD_FILE}"
    if [ -f /boot/refind_linux.conf ]; then
        header "Contents of refind_linux.conf"
        sed 's/^/  /' /boot/refind_linux.conf
    else
        warning "File /boot/refind_linux.conf not found."
        echo
        read -p "Would you like to create a new file using the mkrlconf command? [y/N]: " response
        case "$response" in
            [yY]|[yY][eE][sS])
                mkrlconf
                if [ -f /boot/refind_linux.conf ]; then
                    success "File created successfully!"
                    header "Contents of refind_linux.conf"
                    sed 's/^/  /' /boot/refind_linux.conf
                else
                    error "Failed to create refind_linux.conf file."
                    echo -e "${YELLOW}You will need to manually enter the kernel parameters.${NC}"
                fi
                ;;
            *)
                echo -e "${YELLOW}You will need to manually enter the kernel parameters.${NC}"
                ;;
        esac
    fi
    echo
    echo -e "${YELLOW}Example: quiet zswap.enabled=0 root=PARTUUID=xxxx-xxxx rw rootflags=subvol=@ quiet splash${NC}"
    echo
    ask "Enter the kernel parameters without quotes:" KERNEL_OPTIONS
    list_icons
    ask "Enter the icon path (e.g., EFI/refind/icons/os_linux.png):" ICON_PATH
    ask "Enter the name of the operating system (menuentry):" MENU_NAME

    # Build boot stanza
    BOOT_STANZA="menuentry \"${MENU_NAME}\" {\n"
    BOOT_STANZA+="    icon    ${ICON_PATH}\n"
    BOOT_STANZA+="    volume  ${PARTUUID_BTRFS}\n"
    BOOT_STANZA+="    loader  ${LOADER_PATH}\n"
    BOOT_STANZA+="    initrd  ${INITRD_PATH}\n"
    BOOT_STANZA+="    graphics on\n"
    BOOT_STANZA+="    options \"${KERNEL_OPTIONS}\"\n"
    BOOT_STANZA+="}\n"
    header "Generated Boot Stanza"
    echo -e "$BOOT_STANZA" | sed 's/^/  /'
    ask "Add to refind.conf? (y/n):" CONFIRM
    if [[ "$CONFIRM" =~ ^[yY]$ ]]; then
        echo -e "\n$BOOT_STANZA" >> "$REFIND_CONF"
        success "Entry added to $REFIND_CONF."
    else
        info "Operation canceled. No changes made."
    fi
    info "Returning to main menu..."
    pause
}

# Configure refind-btrfs
configure_refind_btrfs() {
    reset
    local REFIND_BTRFS_CONF="/etc/refind-btrfs.conf"
    local BACKUP_RB="/etc/refind-btrfs.conf.bak"
    header "Configure refind-btrfs"

    # Create backup if needed
    if [ ! -f "$BACKUP_RB" ]; then
        cp "$REFIND_BTRFS_CONF" "$BACKUP_RB"
        success "Backup created at $BACKUP_RB"
    else
        warning "Backup already exists at $BACKUP_RB. Continuing..."
    fi

    # --- General Settings ---
    info "General Settings:"
    echo -e "${CYAN}[Current]${NC} $(grep '^esp_uuid' "$REFIND_BTRFS_CONF")"
    read -p "Enter new esp_uuid (or Enter to keep): " new_esp_uuid
    if [ -n "$new_esp_uuid" ]; then
        sed -i "s/^esp_uuid = .*/esp_uuid = \"$new_esp_uuid\"/" "$REFIND_BTRFS_CONF"
        success "esp_uuid updated."
    fi

    local current_val=$(grep '^exit_if_root_is_snapshot' "$REFIND_BTRFS_CONF" | awk -F '=' '{print $2}' | tr -d ' ')
    echo -e "${CYAN}[Current]${NC} exit_if_root_is_snapshot = $current_val"
    read -p "Enter 'true' or 'false' for exit_if_root_is_snapshot (Enter to keep): " new_exit_root
    if [ -n "$new_exit_root" ]; then
        sed -i "s/^exit_if_root_is_snapshot = .*/exit_if_root_is_snapshot = $new_exit_root/" "$REFIND_BTRFS_CONF"
        success "exit_if_root_is_snapshot updated."
    fi

    current_val=$(grep '^exit_if_no_changes_are_detected' "$REFIND_BTRFS_CONF" | awk -F '=' '{print $2}' | tr -d ' ')
    echo -e "${CYAN}[Current]${NC} exit_if_no_changes_are_detected = $current_val"
    read -p "Enter 'true' or 'false' for exit_if_no_changes_are_detected (Enter to keep): " new_exit_no_changes
    if [ -n "$new_exit_no_changes" ]; then
        sed -i "s/^exit_if_no_changes_are_detected = .*/exit_if_no_changes_are_detected = $new_exit_no_changes/" "$REFIND_BTRFS_CONF"
        success "exit_if_no_changes_are_detected updated."
    fi

    # --- Snapshot Search ---
    header "Configure snapshot-search"
    local current_dir=$(sed -n '/^\[\[snapshot-search\]\]/,/\[\[/p' "$REFIND_BTRFS_CONF" | grep '^directory' | head -n1 | awk -F '=' '{print $2}' | sed 's/"//g' | tr -d ' ')
    echo -e "${CYAN}[Current]${NC} directory = $current_dir"
    read -p "Enter new snapshot-search directory (Enter to keep): " new_snapshot_dir
    if [ -n "$new_snapshot_dir" ]; then
        sed -i "/^\[\[snapshot-search\]\]/,/^\[/{s|^directory = .*|directory = \"$new_snapshot_dir\"|}" "$REFIND_BTRFS_CONF"
        success "snapshot-search directory updated."
    fi

    local current_nested=$(sed -n '/^\[\[snapshot-search\]\]/,/\[\[/p' "$REFIND_BTRFS_CONF" | grep '^is_nested' | head -n1 | awk -F '=' '{print $2}' | tr -d ' ')
    echo -e "${CYAN}[Current]${NC} is_nested = $current_nested"
    read -p "Enter 'true' or 'false' for is_nested (Enter to keep): " new_is_nested
    if [ -n "$new_is_nested" ]; then
        sed -i "/^\[\[snapshot-search\]\]/,/^\[/{s|^is_nested = .*|is_nested = $new_is_nested|}" "$REFIND_BTRFS_CONF"
        success "is_nested updated."
    fi

    local current_max_depth=$(sed -n '/^\[\[snapshot-search\]\]/,/\[\[/p' "$REFIND_BTRFS_CONF" | grep '^max_depth' | head -n1 | awk -F '=' '{print $2}' | tr -d ' ')
    echo -e "${CYAN}[Current]${NC} max_depth = $current_max_depth"
    read -p "Enter new max_depth (integer, Enter to keep): " new_max_depth
    if [ -n "$new_max_depth" ]; then
        sed -i "/^\[\[snapshot-search\]\]/,/^\[/{s|^max_depth = .*|max_depth = $new_max_depth|}" "$REFIND_BTRFS_CONF"
        success "max_depth updated."
    fi

    # --- Snapshot Manipulation ---
    header "Configure snapshot-manipulation"
    local current_selection=$(sed -n '/^\[snapshot-manipulation\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^selection_count' | head -n1 | awk -F '=' '{print $2}' | tr -d ' "')
    echo -e "${CYAN}[Current]${NC} selection_count = $current_selection"
    read -p "Enter new selection_count (number or 'inf', Enter to keep): " new_selection_count
    if [ -n "$new_selection_count" ]; then
        sed -i "/^\[snapshot-manipulation\]/,/\[/ {s|^selection_count = .*|selection_count = $new_selection_count|}" "$REFIND_BTRFS_CONF"
        success "selection_count updated."
    fi

    local current_modify=$(sed -n '/^\[snapshot-manipulation\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^modify_read_only_flag' | head -n1 | awk -F '=' '{print $2}' | tr -d ' ')
    echo -e "${CYAN}[Current]${NC} modify_read_only_flag = $current_modify"
    read -p "Enter 'true' or 'false' for modify_read_only_flag (Enter to keep): " new_modify_flag
    if [ -n "$new_modify_flag" ]; then
        sed -i "/^\[snapshot-manipulation\]/,/\[/ {s|^modify_read_only_flag = .*|modify_read_only_flag = $new_modify_flag|}" "$REFIND_BTRFS_CONF"
        success "modify_read_only_flag updated."
    fi

    local current_dest=$(sed -n '/^\[snapshot-manipulation\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^destination_directory' | head -n1 | awk -F '=' '{print $2}' | sed 's/"//g' | tr -d ' ')
    echo -e "${CYAN}[Current]${NC} destination_directory = $current_dest"
    read -p "Enter new destination_directory (Enter to keep): " new_dest
    if [ -n "$new_dest" ]; then
        sed -i "/^\[snapshot-manipulation\]/,/\[/ {s|^destination_directory = .*|destination_directory = \"$new_dest\"|}" "$REFIND_BTRFS_CONF"
        success "destination_directory updated."
    fi

    local current_cleanup=$(sed -n '/^\[snapshot-manipulation\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^cleanup_exclusion' | head -n1)
    echo -e "${CYAN}[Current]${NC} $current_cleanup"
    read -p "Enter UUIDs for cleanup_exclusion (comma-separated, Enter to keep): " new_cleanup
    if [ -n "$new_cleanup" ]; then
        formatted=$(echo "$new_cleanup" | sed 's/,/","/g')
        formatted="[\"$formatted\"]"
        sed -i "/^\[snapshot-manipulation\]/,/\[/ {s|^cleanup_exclusion = .*|cleanup_exclusion = $formatted|}" "$REFIND_BTRFS_CONF"
        success "cleanup_exclusion updated."
    fi

    # --- Boot Stanza Generation ---
    header "Configure boot-stanza-generation"
    local current_refind_config=$(sed -n '/^\[boot-stanza-generation\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^refind_config' | head -n1 | awk -F '=' '{print $2}' | sed 's/"//g' | tr -d ' ')
    echo -e "${CYAN}[Current]${NC} refind_config = $current_refind_config"
    read -p "Enter new refind_config (Enter to keep): " new_refind_config
    if [ -n "$new_refind_config" ]; then
        sed -i "/^\[boot-stanza-generation\]/,/\[/ {s|^refind_config = .*|refind_config = \"$new_refind_config\"|}" "$REFIND_BTRFS_CONF"
        success "refind_config updated."
    fi

    local current_include_paths=$(sed -n '/^\[boot-stanza-generation\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^include_paths' | head -n1 | awk -F '=' '{print $2}' | tr -d ' ')
    echo -e "${CYAN}[Current]${NC} include_paths = $current_include_paths"
    read -p "Enter 'true' or 'false' for include_paths (Enter to keep): " new_include_paths
    if [ -n "$new_include_paths" ]; then
        sed -i "/^\[boot-stanza-generation\]/,/\[/ {s|^include_paths = .*|include_paths = $new_include_paths|}" "$REFIND_BTRFS_CONF"
        success "include_paths updated."
    fi

    local current_include_sub=$(sed -n '/^\[boot-stanza-generation\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^include_sub_menus' | head -n1 | awk -F '=' '{print $2}' | tr -d ' ')
    echo -e "${CYAN}[Current]${NC} include_sub_menus = $current_include_sub"
    read -p "Enter 'true' or 'false' for include_sub_menus (Enter to keep): " new_include_sub
    if [ -n "$new_include_sub" ]; then
        sed -i "/^\[boot-stanza-generation\]/,/\[/ {s|^include_sub_menus = .*|include_sub_menus = $new_include_sub|}" "$REFIND_BTRFS_CONF"
        success "include_sub_menus updated."
    fi

    # --- Icon Configuration ---
    header "Configure boot-stanza-generation.icon"
    local current_mode=$(sed -n '/^\[boot-stanza-generation.icon\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^mode' | head -n1 | awk -F '=' '{print $2}' | sed 's/"//g' | tr -d ' ')
    echo -e "${CYAN}[Current]${NC} mode = $current_mode"
    echo -e "${YELLOW}Options: default, custom, embed_btrfs_logo${NC}"
    read -p "Enter new mode (Enter to keep): " new_mode
    if [ -n "$new_mode" ]; then
        sed -i "/^\[boot-stanza-generation.icon\]/,/\[/ {s|^mode = .*|mode = \"$new_mode\"|}" "$REFIND_BTRFS_CONF"
        success "mode updated."
        current_mode="$new_mode"
    fi

    if [ "$current_mode" == "custom" ]; then
        local current_path=$(sed -n '/^\[boot-stanza-generation.icon\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^path' | head -n1 | awk -F '=' '{print $2}' | sed 's/"//g' | tr -d ' ')
        echo -e "${CYAN}[Current]${NC} path = $current_path"
        echo -e "${YELLOW}Available icons:${NC}"
        list_refind_btrfs_icons
        read -p "Enter new icon path (Enter to keep): " new_path
        if [ -n "$new_path" ]; then
            sed -i "/^\[boot-stanza-generation.icon\]/,/\[/ {s|^path = .*|path = \"$new_path\"|}" "$REFIND_BTRFS_CONF"
            success "path updated."
        fi
    elif [ "$current_mode" == "embed_btrfs_logo" ]; then
        header "Configure embed_btrfs_logo"
        local current_variant=$(sed -n '/^\[boot-stanza-generation.icon.btrfs-logo\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^variant' | head -n1 | awk -F '=' '{print $2}' | sed 's/"//g' | tr -d ' ')
        echo -e "${CYAN}[Current]${NC} variant = $current_variant"
        echo -e "${YELLOW}Options: original, inverted${NC}"
        read -p "Enter new variant (Enter to keep): " new_variant
        if [ -n "$new_variant" ]; then
            sed -i "/^\[boot-stanza-generation.icon.btrfs-logo\]/,/\[/ {s|^variant = .*|variant = \"$new_variant\"|}" "$REFIND_BTRFS_CONF"
            success "variant updated."
        fi

        local current_size=$(sed -n '/^\[boot-stanza-generation.icon.btrfs-logo\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^size' | head -n1 | awk -F '=' '{print $2}' | sed 's/"//g' | tr -d ' ')
        echo -e "${CYAN}[Current]${NC} size = $current_size"
        echo -e "${YELLOW}Options: small, medium, large${NC}"
        read -p "Enter new size (Enter to keep): " new_size
        if [ -n "$new_size" ]; then
            sed -i "/^\[boot-stanza-generation.icon.btrfs-logo\]/,/\[/ {s|^size = .*|size = \"$new_size\"|}" "$REFIND_BTRFS_CONF"
            success "size updated."
        fi

        local current_halign=$(sed -n '/^\[boot-stanza-generation.icon.btrfs-logo\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^horizontal_alignment' | head -n1 | awk -F '=' '{print $2}' | sed 's/"//g' | tr -d ' ')
        echo -e "${CYAN}[Current]${NC} horizontal_alignment = $current_halign"
        echo -e "${YELLOW}Options: left, center, right${NC}"
        read -p "Enter new horizontal_alignment (Enter to keep): " new_halign
        if [ -n "$new_halign" ]; then
            sed -i "/^\[boot-stanza-generation.icon.btrfs-logo\]/,/\[/ {s|^horizontal_alignment = .*|horizontal_alignment = \"$new_halign\"|}" "$REFIND_BTRFS_CONF"
            success "horizontal_alignment updated."
        fi

        local current_valign=$(sed -n '/^\[boot-stanza-generation.icon.btrfs-logo\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^vertical_alignment' | head -n1 | awk -F '=' '{print $2}' | sed 's/"//g' | tr -d ' ')
        echo -e "${CYAN}[Current]${NC} vertical_alignment = $current_valign"
        echo -e "${YELLOW}Options: top, center, bottom${NC}"
        read -p "Enter new vertical_alignment (Enter to keep): " new_valign
        if [ -n "$new_valign" ]; then
            sed -i "/^\[boot-stanza-generation.icon.btrfs-logo\]/,/\[/ {s|^vertical_alignment = .*|vertical_alignment = \"$new_valign\"|}" "$REFIND_BTRFS_CONF"
            success "vertical_alignment updated."
        fi
    fi

    # --- Finalization ---
    header "Final Configuration"
    read -p "Load snapshots now? (y/n): " load_snapshots
    if [[ "$load_snapshots" =~ ^[yY]$ ]]; then
        info "Loading snapshots..."
        refind-btrfs refresh && success "Snapshots loaded successfully." || error "Failed to load snapshots."
    else
        info "Snapshots not loaded."
    fi
    info "Returning to main menu..."
    return
}

# Restore refind-btrfs backup
restore_refind_btrfs_backup() {
    local REFIND_BTRFS_CONF="/etc/refind-btrfs.conf"
    local BACKUP_FILE="${REFIND_BTRFS_CONF}.bak"
    info "Searching for refind-btrfs.conf in /etc..."
    [ -f "$REFIND_BTRFS_CONF" ] && success "Found: $REFIND_BTRFS_CONF" || { error "File not found."; return; }
    [ -f "$BACKUP_FILE" ] && sudo cp "$BACKUP_FILE" "$REFIND_BTRFS_CONF" && success "Backup restored!" || error "Backup not found: $BACKUP_FILE"
    info "Returning to main menu..."
    pause
}

# Single pause function
pause() {
    echo
    read -r -p "Press Enter to return to the menu..." < /dev/tty
    clear
}

# Function to choose the editor
choose_editor() {
    echo
    echo "Choose a text editor to open the file:"
    echo "1) nano"
    echo "2) micro"
    echo "3) vim"
    echo "4) vi"
    echo "5) ne"
    echo "6) joe"
    echo "7) emacs (terminal mode)"
    echo "8) other (type the name)"
    read -rp "Option [1-8]: " choice

    case "$choice" in
        1) editor_cmd="nano" ;;
        2) editor_cmd="micro" ;;
        3) editor_cmd="vim" ;;
        4) editor_cmd="vi" ;;
        5) editor_cmd="ne" ;;
        6) editor_cmd="joe" ;;
        7)
            echo
            echo "[INFO] Emacs in graphical mode may cause unexpected behavior when run via sudo."
            echo "Use only if you know what you're doing."
            editor_cmd="emacs -nw"
            ;;
        8)
            read -rp "Enter the editor name: " editor_cmd
            ;;
        *)
            echo "Invalid option. Using nano as default."
            editor_cmd="nano"
            ;;
    esac

    local editor_bin
    editor_bin=$(awk '{print $1}' <<< "$editor_cmd")

    if ! command -v "$editor_bin" >/dev/null 2>&1; then
        echo
        echo "[ERROR] The editor '$editor_bin' is not installed on the system."
        echo "Install it before trying again."
        echo
        return 1
    fi
}

# Edit refind.conf with the chosen editor
edit_refind_conf() {
    reset
    find_refind_conf
    choose_editor || { info "Returning to the main menu..."; pause; return; }
    info "Opening $REFIND_CONF with the editor: $editor_cmd"
    $editor_cmd "$REFIND_CONF"
    info "Returning to the main menu..."
    pause
}

# Edit refind-btrfs.conf with the chosen editor
edit_refind_btrfs_conf() {
    reset
    local CONF="/etc/refind-btrfs.conf"
    if [ ! -f "$CONF" ]; then
        error "File $CONF not found."
        pause
        return
    fi
    choose_editor || { info "Returning to the main menu..."; pause; return; }
    info "Opening $CONF with the editor: $editor_cmd"
    $editor_cmd "$CONF"
    info "Returning to the main menu..."
    pause
}

# Function to create a BTRFS snapshot using snapper and update rEFInd via refind-btrfs
create_btrfs_snapshot() {
    reset
    header "Create BTRFS Snapshot"

    # Ask the user for the snapshot name
    ask "Enter the snapshot name:" snapshot_name

    # Check if a name was provided
    if [ -z "$snapshot_name" ]; then
        error "Snapshot name cannot be empty. Operation aborted."
        return 1
    fi
    info "Creating snapshot '${snapshot_name}' using snapper..."

    # Create the snapshot using snapper with the provided description
    snapper create --description "${snapshot_name}"
    if [ $? -eq 0 ]; then
        snapper list
        success "Snapshot '${snapshot_name}' created successfully!"
        info "Updating refind-btrfs..."
        refind-btrfs
        if [ $? -eq 0 ]; then
            success "rEFInd was updated with the new snapshot!"
        else
            error "Failed to update rEFInd. Check if the 'refind-btrfs' command is correct and properly configured."
        fi
    else
        error "Failed to create the snapshot. Verify that snapper is installed and that you have the necessary permissions."
        return 1
    fi
}

# Main Menu in English
main_menu() {
    header "rEFInd Configuration Assistant"
    echo -e "${GREEN}1)${NC} Add new boot stanza"
    echo -e "${GREEN}2)${NC} Configure refind-btrfs"
    echo -e "${GREEN}3)${NC} Manually edit refind.conf"
    echo -e "${GREEN}4)${NC} Manually edit refind-btrfs.conf"
    echo -e "${GREEN}5)${NC} Restore refind.conf backup"
    echo -e "${GREEN}6)${NC} Restore refind-btrfs.conf backup"
    echo -e "${GREEN}7)${NC} Create BTRFS Snapshot with Snaper"
    echo -e "${RED}8)${NC} Exit"
    echo -e "${LIGHT_CYAN}==========================================================${NC}"
    ask "Choose an option [1-8]:" option
}

# Main execution loop
check_root
while true; do
    reset
    main_menu
    case $option in
        1) add_boot_stanza ;;
        2) configure_refind_btrfs ;;
        3) edit_refind_conf ;;
        4) edit_refind_btrfs_conf ;;
        5) restore_backup_refind ;;
        6) restore_backup_refind_btrfs ;;
        7) create_btrfs_snapshot ;;
        8) info "Exiting..."; exit 0 ;;
        *) error "Invalid option!" ;;
    esac
done