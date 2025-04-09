#!/bin/bash

# Cores para melhorar a visualização
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
LIGHT_CYAN='\033[1;36m'
NC='\033[0m' # No Color

# Funções de exibição
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

# Verifica privilégios de root
check_root() {
    [ "$EUID" -ne 0 ] && error "Execute como root (sudo)." && exit 1
}

# Localizar refind.conf
busca_refind_conf() {
    info "Buscando refind.conf em /boot..."
    REFIND_CONF=$(find /boot -type f -name refind.conf 2>/dev/null | head -n 1)
    if [ -z "$REFIND_CONF" ]; then
        warning "refind.conf não encontrado automaticamente."
        ask "Digite o caminho completo do arquivo refind.conf:" REFIND_CONF
    else
        success "Encontrado: $REFIND_CONF"
    fi
}

# Criar backup
cria_backup() {
    busca_refind_conf
    BACKUP_FILE="${REFIND_CONF}.bak"
    MARKER="# MODIFIED_BY_SCRIPT: refind.conf modificado pelo script"

    if grep -q "$MARKER" "$REFIND_CONF"; then
        warning "Arquivo já modificado anteriormente. Backup não recriado."
    else
        [ ! -f "$BACKUP_FILE" ] && cp "$REFIND_CONF" "$BACKUP_FILE" && success "Backup em $BACKUP_FILE"
        echo -e "\n$MARKER" >> "$REFIND_CONF"
        info "Marcador adicionado ao $REFIND_CONF"
    fi
}

# Restaurar backup
restaurar_backup_refind() {
    busca_refind_conf
    BACKUP_FILE="${REFIND_CONF}.bak"
    [ -f "$BACKUP_FILE" ] && cp "$BACKUP_FILE" "$REFIND_CONF" && success "Backup restaurado com sucesso!" || error "Backup não encontrado."
    info "Voltando ao menu principal..."
    return
}

# PARTUUIDs
show_partuuids() {
    header "PARTUUIDs Disponíveis"
    echo -e "${YELLOW}Dispositivo\t\tPARTUUID${NC}"
    echo "----------------------------------------"
    blkid | grep PARTUUID | awk -F: '{printf "%-24s", $1; sub(/.*PARTUUID="/,"",$2); sub(/".*/,"",$2); print $2}'
    echo
}

# Mostrar partição root
mostra_particao_raiz() {
    header "Partição do sistema atual"
    root_device=$(findmnt -n -o SOURCE / | sed 's/\[.*\]//')
    root_partuuid=$(blkid -s PARTUUID -o value "$root_device")
    echo -e "${YELLOW}Dispositivo montado em /: ${NC}$root_device"
    echo -e "${YELLOW}PARTUUID correspondente:   ${NC}$root_partuuid"
    echo
}

# Mostrar arquivos em /boot
show_boot_files() {
    header "Arquivos no diretório /boot"
    echo -e "${YELLOW}Kernels disponíveis:${NC}"
    ls -1 /boot | grep -E '^vmlinuz' | sed 's/^/  /'
    echo
    echo -e "${YELLOW}Initrds disponíveis:${NC}"
    ls -1 /boot | grep -E '^initramfs' | sed 's/^/  /'
    echo
}

# Funções relacionadas a ícones
listar_ícones() {
    local pasta=""
    if [[ -d "/boot/EFI/refind" ]]; then
        pasta="/boot/EFI/refind"
    elif [[ -d "/boot/efi/EFI/refind" ]]; then
        pasta="/boot/efi/EFI/refind"
    else
        echo -e "\nA pasta do rEFInd não foi encontrada em /boot."
        return
    fi

    header "Ícones encontrados na pasta refind (caminho relativo a EFI/):"
    find "$pasta" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.icns" \) | \
        sed -E 's|^.*/(EFI/.*)|\1|' | sort
    echo
}

# Listar icones para refind-btrfs
listar_ícones_refind_btrfs() {
    local pasta=""
    if [[ -d "/boot/EFI/refind" ]]; then
        pasta="/boot/EFI/refind"
    elif [[ -d "/boot/efi/EFI/refind" ]]; then
        pasta="/boot/efi/EFI/refind"
    else
        echo -e "\nA pasta do rEFInd não foi encontrada em /boot."
        return
    fi
    echo -e "${CYAN}Ícones encontrados na pasta refind (caminho relativo a refind/):${NC}"
    find "$pasta" -type f -iname "*.png" | sed -E "s|^$pasta/||" | sort
    echo
}

# Funções relacionadas a subvolumes Btrfs
listar_subvolumes() {
    header "Subvolumes Btrfs encontrados"
    btrfs subvolume list / | awk '{print $NF}' | sed 's/^/  /'
    echo
}

# Detectar subvolume atual
detecta_subvolume_atual() {
    header "Subvolume atual da raiz do sistema"
    SUBVOLUME_ATUAL=$(grep " / " /etc/fstab | grep btrfs | sed -n 's/.*subvol=\/\([^,]*\).*/\1/p')
    if [ -n "$SUBVOLUME_ATUAL" ]; then
        if [[ "$SUBVOLUME_ATUAL" == "@" ]]; then
            echo -e "${CYAN}[INFO]${NC} O sistema está usando o subvolume '@' como raiz (/)."
            echo -e "${YELLOW}[AVISO]${NC} Em alguns sistemas, deixar o campo de subvolume em branco funciona melhor (subvolid=5)."
        else
            echo -e "${CYAN}[INFO]${NC} O sistema está usando o subvolume '/$SUBVOLUME_ATUAL' como raiz (/)."
        fi
    else
        echo -e "${CYAN}[INFO]${NC} O sistema pode estar usando o subvolume padrão (subvolid=5) como raiz (/)."
    fi
    echo
}

# Adicionar boot
adiciona_boot_stanza() {
    reset
    cria_backup
    show_partuuids
    mostra_particao_raiz
    ask "Digite a PARTUUID da partição Btrfs:" PARTUUID_BTRFS
    listar_subvolumes
    detecta_subvolume_atual
    ask "Digite o nome do subvolume (ex: @ ou deixe em branco se usar subvolid=5): " SUBVOLUME
    show_boot_files
    ask "Digite o nome do arquivo do kernel:" KERNEL_FILE
    ask "Digite o nome do arquivo do initrd:" INITRD_FILE
    LOADER_PATH="${KERNEL_FILE}"
    INITRD_PATH="${INITRD_FILE}"

    if [ -f /boot/refind_linux.conf ]; then
        header "Conteúdo de refind_linux.conf"
        sed 's/^/  /' /boot/refind_linux.conf
    else
        warning "Arquivo /boot/refind_linux.conf não encontrado."
        echo
        read -p "Deseja criar um novo arquivo com o comando mkrlconf? [s/N]: " resposta
        case "$resposta" in
            [sS]|[sS][iI][mM])
                mkrlconf
                if [ -f /boot/refind_linux.conf ]; then
                    success "Arquivo criado com sucesso!"
                    header "Conteúdo de refind_linux.conf"
                    sed 's/^/  /' /boot/refind_linux.conf
                else
                    error "Falha ao criar o arquivo refind_linux.conf."
                    echo -e "${YELLOW}Você deverá digitar os parâmetros do kernel manualmente.${NC}"
                fi
                ;;
            *)
                echo -e "${YELLOW}Você deverá digitar os parâmetros do kernel manualmente.${NC}"
                ;;
        esac
    fi

    echo
    echo -e "${YELLOW}Exemplo: quiet zswap.enabled=0 root=PARTUUID=xxxx-xxxx rw rootflags=subvol=@ quiet splash${NC}"
    echo
    ask "Digite os parâmetros do kernel sem aspas:" KERNEL_OPTIONS
    listar_ícones
    ask "Digite o caminho do ícone (ex: EFI/refind/icons/os_linux.png):" ICON_PATH
    ask "Digite o nome do sistema operacional (menuentry):" MENU_NAME

    # Monta a boot stanza
    BOOT_STANZA="menuentry \"${MENU_NAME}\" {\n"
    BOOT_STANZA+="    icon    ${ICON_PATH}\n"
    BOOT_STANZA+="    volume  ${PARTUUID_BTRFS}\n"
    BOOT_STANZA+="    loader  ${LOADER_PATH}\n"
    BOOT_STANZA+="    initrd  ${INITRD_PATH}\n"
    BOOT_STANZA+="    graphics on\n"
    BOOT_STANZA+="    options \"${KERNEL_OPTIONS}\"\n"
    BOOT_STANZA+="}\n"
    header "Boot Stanza Gerada"
    echo -e "$BOOT_STANZA" | sed 's/^/  /'
    ask "Deseja adicionar ao refind.conf? (s/n):" CONFIRM
    if [[ "$CONFIRM" =~ ^[sS]$ ]]; then
        echo -e "\n$BOOT_STANZA" >> "$REFIND_CONF"
        success "Entrada adicionada ao $REFIND_CONF."
    else
        info "Operação cancelada. Nada foi alterado."
    fi
    info "Voltando ao menu principal..."
    return
}

# Funções relacionadas ao refind-btrfs
configure_refind_btrfs() {
    reset
    local REFIND_BTRFS_CONF="/etc/refind-btrfs.conf"
    local BACKUP_RB="/etc/refind-btrfs.conf.bak"

    header "Configurar refind-btrfs"

    # Cria backup, se necessário
    if [ ! -f "$BACKUP_RB" ]; then
        cp "$REFIND_BTRFS_CONF" "$BACKUP_RB"
        success "Backup criado em $BACKUP_RB"
    else
        warning "Backup já existe em $BACKUP_RB. Continuando..."
    fi

    # --- Configurações Gerais ---
    info "Configurações Gerais:"
    echo -e "${CYAN}[Atual]${NC} $(grep '^esp_uuid' "$REFIND_BTRFS_CONF")"
    read -p "Digite o novo esp_uuid (ou Enter para manter): " new_esp_uuid
    if [ -n "$new_esp_uuid" ]; then
        sed -i "s/^esp_uuid = .*/esp_uuid = \"$new_esp_uuid\"/" "$REFIND_BTRFS_CONF"
        success "esp_uuid atualizado."
    fi

    local current_val=$(grep '^exit_if_root_is_snapshot' "$REFIND_BTRFS_CONF" | awk -F '=' '{print $2}' | tr -d ' ')
    echo -e "${CYAN}[Atual]${NC} exit_if_root_is_snapshot = $current_val"
    read -p "Digite 'true' ou 'false' para exit_if_root_is_snapshot (Enter para manter): " new_exit_root
    if [ -n "$new_exit_root" ]; then
        sed -i "s/^exit_if_root_is_snapshot = .*/exit_if_root_is_snapshot = $new_exit_root/" "$REFIND_BTRFS_CONF"
        success "exit_if_root_is_snapshot atualizado."
    fi

    current_val=$(grep '^exit_if_no_changes_are_detected' "$REFIND_BTRFS_CONF" | awk -F '=' '{print $2}' | tr -d ' ')
    echo -e "${CYAN}[Atual]${NC} exit_if_no_changes_are_detected = $current_val"
    read -p "Digite 'true' ou 'false' para exit_if_no_changes_are_detected (Enter para manter): " new_exit_no_changes
    if [ -n "$new_exit_no_changes" ]; then
        sed -i "s/^exit_if_no_changes_are_detected = .*/exit_if_no_changes_are_detected = $new_exit_no_changes/" "$REFIND_BTRFS_CONF"
        success "exit_if_no_changes_are_detected atualizado."
    fi

    # --- snapshot-search ---
    header "Configurar snapshot-search"
    local current_dir=$(sed -n '/^\[\[snapshot-search\]\]/,/\[\[/p' "$REFIND_BTRFS_CONF" | grep '^directory' | head -n1 | awk -F '=' '{print $2}' | sed 's/"//g' | tr -d ' ')
    echo -e "${CYAN}[Atual]${NC} directory = $current_dir"
    read -p "Digite o novo diretório para snapshot-search (Enter para manter): " new_snapshot_dir
    if [ -n "$new_snapshot_dir" ]; then
        sed -i "/^\[\[snapshot-search\]\]/,/^\[/{s|^directory = .*|directory = \"$new_snapshot_dir\"|}" "$REFIND_BTRFS_CONF"
        success "Diretório snapshot-search atualizado."
    fi

    local current_nested=$(sed -n '/^\[\[snapshot-search\]\]/,/\[\[/p' "$REFIND_BTRFS_CONF" | grep '^is_nested' | head -n1 | awk -F '=' '{print $2}' | tr -d ' ')
    echo -e "${CYAN}[Atual]${NC} is_nested = $current_nested"
    read -p "Digite 'true' ou 'false' para is_nested (Enter para manter): " new_is_nested
    if [ -n "$new_is_nested" ]; then
        sed -i "/^\[\[snapshot-search\]\]/,/^\[/{s|^is_nested = .*|is_nested = $new_is_nested|}" "$REFIND_BTRFS_CONF"
        success "is_nested atualizado."
    fi

    local current_max_depth=$(sed -n '/^\[\[snapshot-search\]\]/,/\[\[/p' "$REFIND_BTRFS_CONF" | grep '^max_depth' | head -n1 | awk -F '=' '{print $2}' | tr -d ' ')
    echo -e "${CYAN}[Atual]${NC} max_depth = $current_max_depth"
    read -p "Digite o novo max_depth (número inteiro, Enter para manter): " new_max_depth
    if [ -n "$new_max_depth" ]; then
        sed -i "/^\[\[snapshot-search\]\]/,/^\[/{s|^max_depth = .*|max_depth = $new_max_depth|}" "$REFIND_BTRFS_CONF"
        success "max_depth atualizado."
    fi

    # --- snapshot-manipulation ---
    header "Configurar snapshot-manipulation"
    local current_selection=$(sed -n '/^\[snapshot-manipulation\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^selection_count' | head -n1 | awk -F '=' '{print $2}' | tr -d ' "')
    echo -e "${CYAN}[Atual]${NC} selection_count = $current_selection"
    read -p "Digite o novo selection_count (número ou 'inf', Enter para manter): " new_selection_count
    if [ -n "$new_selection_count" ]; then
        sed -i "/^\[snapshot-manipulation\]/,/\[/ {s|^selection_count = .*|selection_count = $new_selection_count|}" "$REFIND_BTRFS_CONF"
        success "selection_count atualizado."
    fi

    local current_modify=$(sed -n '/^\[snapshot-manipulation\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^modify_read_only_flag' | head -n1 | awk -F '=' '{print $2}' | tr -d ' ')
    echo -e "${CYAN}[Atual]${NC} modify_read_only_flag = $current_modify"
    read -p "Digite 'true' ou 'false' para modify_read_only_flag (Enter para manter): " new_modify_flag
    if [ -n "$new_modify_flag" ]; then
        sed -i "/^\[snapshot-manipulation\]/,/\[/ {s|^modify_read_only_flag = .*|modify_read_only_flag = $new_modify_flag|}" "$REFIND_BTRFS_CONF"
        success "modify_read_only_flag atualizado."
    fi

    local current_dest=$(sed -n '/^\[snapshot-manipulation\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^destination_directory' | head -n1 | awk -F '=' '{print $2}' | sed 's/"//g' | tr -d ' ')
    echo -e "${CYAN}[Atual]${NC} destination_directory = $current_dest"
    read -p "Digite o novo destination_directory (Enter para manter): " new_dest
    if [ -n "$new_dest" ]; then
        sed -i "/^\[snapshot-manipulation\]/,/\[/ {s|^destination_directory = .*|destination_directory = \"$new_dest\"|}" "$REFIND_BTRFS_CONF"
        success "destination_directory atualizado."
    fi

    local current_cleanup=$(sed -n '/^\[snapshot-manipulation\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^cleanup_exclusion' | head -n1)
    echo -e "${CYAN}[Atual]${NC} $current_cleanup"
    read -p "Digite os UUIDs para cleanup_exclusion (separados por vírgula, Enter para manter): " new_cleanup
    if [ -n "$new_cleanup" ]; then
        formatted=$(echo "$new_cleanup" | sed 's/,/","/g')
        formatted="[\"$formatted\"]"
        sed -i "/^\[snapshot-manipulation\]/,/\[/ {s|^cleanup_exclusion = .*|cleanup_exclusion = $formatted|}" "$REFIND_BTRFS_CONF"
        success "cleanup_exclusion atualizado."
    fi

    # --- boot-stanza-generation ---
    header "Configurar boot-stanza-generation"
    local current_refind_config=$(sed -n '/^\[boot-stanza-generation\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^refind_config' | head -n1 | awk -F '=' '{print $2}' | sed 's/"//g' | tr -d ' ')
    echo -e "${CYAN}[Atual]${NC} refind_config = $current_refind_config"
    read -p "Digite o novo refind_config (Enter para manter): " new_refind_config
    if [ -n "$new_refind_config" ]; then
        sed -i "/^\[boot-stanza-generation\]/,/\[/ {s|^refind_config = .*|refind_config = \"$new_refind_config\"|}" "$REFIND_BTRFS_CONF"
        success "refind_config atualizado."
    fi

    local current_include_paths=$(sed -n '/^\[boot-stanza-generation\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^include_paths' | head -n1 | awk -F '=' '{print $2}' | tr -d ' ')
    echo -e "${CYAN}[Atual]${NC} include_paths = $current_include_paths"
    read -p "Digite 'true' ou 'false' para include_paths (Enter para manter): " new_include_paths
    if [ -n "$new_include_paths" ]; then
        sed -i "/^\[boot-stanza-generation\]/,/\[/ {s|^include_paths = .*|include_paths = $new_include_paths|}" "$REFIND_BTRFS_CONF"
        success "include_paths atualizado."
    fi

    local current_include_sub=$(sed -n '/^\[boot-stanza-generation\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^include_sub_menus' | head -n1 | awk -F '=' '{print $2}' | tr -d ' ')
    echo -e "${CYAN}[Atual]${NC} include_sub_menus = $current_include_sub"
    read -p "Digite 'true' ou 'false' para include_sub_menus (Enter para manter): " new_include_sub
    if [ -n "$new_include_sub" ]; then
        sed -i "/^\[boot-stanza-generation\]/,/\[/ {s|^include_sub_menus = .*|include_sub_menus = $new_include_sub|}" "$REFIND_BTRFS_CONF"
        success "include_sub_menus atualizado."
    fi

    # --- boot-stanza-generation.icon ---
    header "Configurar boot-stanza-generation.icon"
    local current_mode=$(sed -n '/^\[boot-stanza-generation.icon\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^mode' | head -n1 | awk -F '=' '{print $2}' | sed 's/"//g' | tr -d ' ')
    echo -e "${CYAN}[Atual]${NC} mode = $current_mode"
    echo -e "${YELLOW}Opções: default, custom, embed_btrfs_logo${NC}"
    read -p "Digite o novo mode (Enter para manter): " new_mode
    if [ -n "$new_mode" ]; then
        sed -i "/^\[boot-stanza-generation.icon\]/,/\[/ {s|^mode = .*|mode = \"$new_mode\"|}" "$REFIND_BTRFS_CONF"
        success "mode atualizado."
        current_mode="$new_mode"
    fi

    if [ "$current_mode" == "custom" ]; then
        local current_path=$(sed -n '/^\[boot-stanza-generation.icon\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^path' | head -n1 | awk -F '=' '{print $2}' | sed 's/"//g' | tr -d ' ')
        echo -e "${CYAN}[Atual]${NC} path = $current_path"
        echo -e "${YELLOW}Ícones disponíveis:${NC}"
        listar_ícones_refind_btrfs
        read -p "Digite o novo caminho do ícone (Enter para manter): " new_path
        if [ -n "$new_path" ]; then
            sed -i "/^\[boot-stanza-generation.icon\]/,/\[/ {s|^path = .*|path = \"$new_path\"|}" "$REFIND_BTRFS_CONF"
            success "path atualizado."
        fi
    elif [ "$current_mode" == "embed_btrfs_logo" ]; then
        header "Configurar embed_btrfs_logo"
        local current_variant=$(sed -n '/^\[boot-stanza-generation.icon.btrfs-logo\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^variant' | head -n1 | awk -F '=' '{print $2}' | sed 's/"//g' | tr -d ' ')
        echo -e "${CYAN}[Atual]${NC} variant = $current_variant"
        echo -e "${YELLOW}Opções: original, inverted${NC}"
        read -p "Digite o novo variant (Enter para manter): " new_variant
        if [ -n "$new_variant" ]; then
            sed -i "/^\[boot-stanza-generation.icon.btrfs-logo\]/,/\[/ {s|^variant = .*|variant = \"$new_variant\"|}" "$REFIND_BTRFS_CONF"
            success "variant atualizado."
        fi

        local current_size=$(sed -n '/^\[boot-stanza-generation.icon.btrfs-logo\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^size' | head -n1 | awk -F '=' '{print $2}' | sed 's/"//g' | tr -d ' ')
        echo -e "${CYAN}[Atual]${NC} size = $current_size"
        echo -e "${YELLOW}Opções: small, medium, large${NC}"
        read -p "Digite o novo size (Enter para manter): " new_size
        if [ -n "$new_size" ]; then
            sed -i "/^\[boot-stanza-generation.icon.btrfs-logo\]/,/\[/ {s|^size = .*|size = \"$new_size\"|}" "$REFIND_BTRFS_CONF"
            success "size atualizado."
        fi

        local current_halign=$(sed -n '/^\[boot-stanza-generation.icon.btrfs-logo\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^horizontal_alignment' | head -n1 | awk -F '=' '{print $2}' | sed 's/"//g' | tr -d ' ')
        echo -e "${CYAN}[Atual]${NC} horizontal_alignment = $current_halign"
        echo -e "${YELLOW}Opções: left, center, right${NC}"
        read -p "Digite o novo horizontal_alignment (Enter para manter): " new_halign
        if [ -n "$new_halign" ]; then
            sed -i "/^\[boot-stanza-generation.icon.btrfs-logo\]/,/\[/ {s|^horizontal_alignment = .*|horizontal_alignment = \"$new_halign\"|}" "$REFIND_BTRFS_CONF"
            success "horizontal_alignment atualizado."
        fi

        local current_valign=$(sed -n '/^\[boot-stanza-generation.icon.btrfs-logo\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^vertical_alignment' | head -n1 | awk -F '=' '{print $2}' | sed 's/"//g' | tr -d ' ')
        echo -e "${CYAN}[Atual]${NC} vertical_alignment = $current_valign"
        echo -e "${YELLOW}Opções: top, center, bottom${NC}"
        read -p "Digite o novo vertical_alignment (Enter para manter): " new_valign
        if [ -n "$new_valign" ]; then
            sed -i "/^\[boot-stanza-generation.icon.btrfs-logo\]/,/\[/ {s|^vertical_alignment = .*|vertical_alignment = \"$new_valign\"|}" "$REFIND_BTRFS_CONF"
            success "vertical_alignment atualizado."
        fi
    fi

    # --- Finalização ---
    header "Finalizar Configuração"
    read -p "Deseja carregar os snapshots agora? (s/n): " load_snapshots
    if [[ "$load_snapshots" =~ ^[sS]$ ]]; then
        info "Carregando os snapshots..."
        refind-btrfs refresh && success "Snapshots carregados com sucesso." || error "Falha ao carregar os snapshots."
    else
        info "Snapshots não carregados."
    fi
    info "Voltando ao menu principal..."
    return
}

restaurar_backup_refind_btrfs() {
    reset
    local REFIND_BTRFS_CONF="/etc/refind-btrfs.conf"
    local BACKUP_FILE="${REFIND_BTRFS_CONF}.bak"

    info "Buscando refind-btrfs.conf em /etc..."
    [ -f "$REFIND_BTRFS_CONF" ] && success "Encontrado: $REFIND_BTRFS_CONF" || { error "Arquivo não encontrado."; return; }
    [ -f "$BACKUP_FILE" ] && sudo cp "$BACKUP_FILE" "$REFIND_BTRFS_CONF" && success "Backup restaurado com sucesso!" || error "Backup não encontrado: $BACKUP_FILE"
    info "Voltando ao menu principal..."
    return
}

# Funções de edição manual
editar_refind_conf() {
    reset
    busca_refind_conf
    info "Abrindo $REFIND_CONF no nano..."
    nano "$REFIND_CONF"
    info "Voltando ao menu principal..."
    return
}

# Editar refind-btrfs com nano
editar_refind_btrfs_conf() {
    reset
    local CONF="/etc/refind-btrfs.conf"
    if [ -f "$CONF" ]; then
        info "Abrindo $CONF no nano..."
        nano "$CONF"
    else
        error "Arquivo $CONF não encontrado."
    fi
    info "Voltando ao menu principal..."
    return
}

# Função para criar snapshot usando snapper e atualizar o rEFInd via refind-btrfs
criar_snapshot_btrfs() {
    reset
    header "Criar Snapshot BTRFS"

    # Solicita o nome do snapshot ao usuário
    ask "Digite o nome do snapshot:" snapshot_name

    # Verifica se o nome foi informado
    if [ -z "$snapshot_name" ]; then
        error "Nome do snapshot não pode ser vazio. Operação abortada."
        return 1
    fi

    info "Criando snapshot '${snapshot_name}' usando o snapper..."

    # Criação do snapshot usando snapper com a descrição informada
    snapper create --description "${snapshot_name}"

    if [ $? -eq 0 ]; then
        snapper list
        success "Snapshot '${snapshot_name}' criado com sucesso!"

        info "Atualizando refind-btrfs..."
        # Executa o comando para atualizar o rEFInd com o novo snapshot
        refind-btrfs
        if [ $? -eq 0 ]; then
            success "O rEFInd foi atualizado com o novo snapshot!"
        else
            error "Falha ao atualizar o rEFInd. Verifique se o comando 'refind-btrfs' está correto e configurado."
        fi
    else
        error "Falha ao criar o snapshot. Verifique se o snapper está instalado e se você possui as permissões necessárias."
        return 1
    fi
}

# Menu principal
menu_principal() {
    header "Assistente de configuração do rEFInd"
    echo -e "${GREEN}1)${NC} Adicionar nova boot stanza"
    echo -e "${GREEN}2)${NC} Configurar refind-btrfs"
    echo -e "${GREEN}3)${NC} Editar manualmente refind.conf (nano)"
    echo -e "${GREEN}4)${NC} Editar manualmente refind-btrfs.conf (nano)"
    echo -e "${GREEN}5)${NC} Restaurar backup do refind.conf"
    echo -e "${GREEN}6)${NC} Restaurar backup do refind-btrfs.conf"
    echo -e "${GREEN}7)${NC} Criar Snapshot BTRFS com Snapper"
    echo -e "${RED}8)${NC} Sair"
    echo -e "${LIGHT_CYAN}==========================================================${NC}"
    ask "Escolha uma opção [1-8]:" opcao
}

# Execução principal
check_root
while true; do
    reset
    menu_principal
    case $opcao in
        1) adiciona_boot_stanza ;;
        2) configure_refind_btrfs ;;
        3) editar_refind_conf ;;
        4) editar_refind_btrfs_conf ;;
        5) restaurar_backup_refind ;;
        6) restaurar_backup_refind_btrfs ;;
        7) criar_snapshot_btrfs ;;
        8) info "Saindo..."; exit 0 ;;
        *) error "Opção inválida!" ;;
    esac
    echo
    read -p "Pressione Enter para continuar..." dummy
done
