#!/bin/bash
# AUTOR: diegons490
# Suporte multilíngue completo (pt_BR/en_US)

# Detecta idioma base do sistema
get_base_lang() {
    # Prioriza a variável LANG do usuário original, ou do sudo, ou LC_ALL, ou LANGUAGE
    local sys_lang="${SUDO_LANG:-$LANG}"
    sys_lang="${sys_lang:-${LC_ALL:-${LANGUAGE}}}"

    # remove .UTF-8 e pega só o prefixo
    sys_lang="${sys_lang%.*}"
    local base="${sys_lang%%_*}"

    # fallback: pt se vazio ou "C"
    [[ -z "$base" || "$base" == "C" ]] && base="pt"

    echo "$base"
}

# Carregar strings de acordo com o idioma
load_strings() {
    local base_lang
    base_lang="$(get_base_lang)"

    case "$base_lang" in
    pt)
        # Strings em português (padrão)
        MSG_WELCOME="Assistente de configuração do rEFInd"
        MSG_ADD_BOOT="Adicionar nova boot stanza"
        MSG_CONFIG_BTRFS="Configurar refind-btrfs"
        MSG_EDIT_REFIND="Editar manualmente refind.conf"
        MSG_EDIT_BTRFS_CONF="Editar manualmente refind-btrfs.conf"
        MSG_RESTORE_REFIND="Restaurar backup do refind.conf"
        MSG_RESTORE_BTRFS="Restaurar backup do refind-btrfs.conf"
        MSG_CREATE_SNAPSHOT="Criar Snapshot BTRFS com Snapper"
        MSG_EXIT="Sair"
        MSG_INVALID_OPT="Opção inválida!"
        MSG_ROOT_REQUIRED="Execute como root (sudo)."
        MSG_SEARCH_REFIND="Buscando refind.conf em /boot..."
        MSG_REFIND_FOUND="Encontrado:"
        MSG_REFIND_NOT_FOUND="refind.conf não encontrado automaticamente."
        MSG_REFIND_PROMPT="Digite o caminho completo do arquivo refind.conf:"
        MSG_BACKUP_CREATED="Backup criado em:"
        MSG_BACKUP_EXISTS="Backup já existe:"
        MSG_BACKUP_RESTORED="Backup restaurado com sucesso!"
        MSG_BACKUP_FAILED="Falha ao criar backup. Permissões insuficientes?"
        MSG_BACKUP_NOT_FOUND="Backup não encontrado:"
        MSG_AVAIL_PARTUUIDS="PARTUUIDs Disponíveis"
        MSG_CURRENT_ROOT="Partição do sistema atual"
        MSG_MOUNTED_DEV="Dispositivo montado em /:"
        MSG_PARTUUID="PARTUUID correspondente:"
        MSG_BOOT_FILES="Arquivos no diretório /boot"
        MSG_KERNELS="Kernels disponíveis:"
        MSG_INITRDS="Initrds disponíveis:"
        MSG_ICONS_FOUND="Ícones encontrados na pasta refind (caminho relativo a EFI/):"
        MSG_ICONS_BTRFS="Ícones encontrados na pasta refind (caminho relativo a refind/):"
        MSG_SUBVOLUMES="Subvolumes Btrfs encontrados"
        MSG_CURRENT_SUBVOL="Subvolume atual da raiz do sistema"
        MSG_SUBVOL_INFO="O sistema está usando o subvolume"
        MSG_SUBVOL_WARNING="Em alguns sistemas, deixar o campo de subvolume em branco funciona melhor (subvolid=5)."
        MSG_SUBVOL_DEFAULT="O sistema pode estar usando o subvolume padrão (subvolid=5) como raiz (/)."
        MSG_ENTER_PARTUUID="Digite a PARTUUID da partição Btrfs:"
        MSG_ENTER_SUBVOL="Digite o nome do subvolume (ex: @ ou deixe em branco se usar subvolid=5):"
        MSG_ENTER_KERNEL="Digite o nome do arquivo do kernel:"
        MSG_ENTER_INITRD="Digite o nome do arquivo do initrd:"
        MSG_ENTER_ICON="Digite o caminho do ícone (ex: EFI/refind/icons/os_linux.png):"
        MSG_ENTER_MENUNAME="Digite o nome do sistema operacional (menuentry):"
        MSG_ENTER_KERNEL_OPTS="Digite os parâmetros do kernel sem aspas:"
        MSG_EXAMPLE_OPTS="Exemplo:"
        MSG_ADD_SUBMENU="Deseja adicionar um submenu? (s/n):"
        MSG_SUBMENU_NAME="Digite o nome do submenu:"
        MSG_SUBMENU_KERNEL="Digite o kernel para o submenu:"
        MSG_SUBMENU_INITRD="Digite o initrd para o submenu:"
        MSG_SUBMENU_OPTS="Digite as opções do kernel para o submenu ou tecle Enter para usar o mesmo do menu principal:"
        MSG_STANZA_CONFIRM="Deseja adicionar ao refind.conf? (s/n):"
        MSG_STANZA_ADDED="Entrada adicionada ao"
        MSG_OPERATION_CANCELED="Operação cancelada. Nada foi alterado."
        MSG_CONFIG_REFIND_BTRFS="Configurar refind-btrfs"
        MSG_EDITOR_CHOICE="Escolha um editor de texto:"
        MSG_EDITOR_INVALID="Opção inválida. Usando nano como padrão."
        MSG_EDITOR_NOT_FOUND="Editor não instalado. Instale-o antes de usar."
        MSG_SNAPSHOT_NAME="Digite o nome do snapshot:"
        MSG_SNAPSHOT_EMPTY="Nome do snapshot não pode ser vazio. Operação abortada."
        MSG_SNAPSHOT_CREATED="Snapshot criado com sucesso!"
        MSG_SNAPSHOT_FAILED="Falha ao criar snapshot. Verifique as permissões."
        MSG_PRESS_ENTER="Pressione Enter..."
        MSG_RETURN_MAIN="Voltando ao menu principal..."
        MSG_GENERAL_SETTINGS="Configurações Gerais:"
        MSG_CURRENT_VALUE="[Atual]"
        MSG_NEW_ESP_UUID="Digite o novo esp_uuid (ou Enter para manter): "
        MSG_NEW_EXIT_ROOT="Digite 'true' ou 'false' para exit_if_root_is_snapshot (Enter para manter): "
        MSG_NEW_EXIT_NO_CHANGES="Digite 'true' ou 'false' para exit_if_no_changes_are_detected (Enter para manter): "
        MSG_SNAPSHOT_SEARCH="Configurar snapshot-search"
        MSG_NEW_SNAPSHOT_DIR="Digite o novo diretório para snapshot-search (Enter para manter): "
        MSG_NEW_IS_NESTED="Digite 'true' ou 'false' para is_nested (Enter para manter): "
        MSG_NEW_MAX_DEPTH="Digite o novo max_depth (número inteiro, Enter para manter): "
        MSG_SNAPSHOT_MANIPULATION="Configurar snapshot-manipulation"
        MSG_NEW_SELECTION_COUNT="Digite o novo selection_count (número ou 'inf', Enter para manter): "
        MSG_NEW_MODIFY_FLAG="Digite 'true' ou 'false' para modify_read_only_flag (Enter para manter): "
        MSG_NEW_DEST_DIR="Digite o novo destination_directory (Enter para manter): "
        MSG_NEW_CLEANUP_EXCLUSION="Digite os UUIDs para cleanup_exclusion (separados por vírgula, Enter para manter): "
        MSG_BOOT_STANZA_GENERATION="Configurar boot-stanza-generation"
        MSG_NEW_REFIND_CONFIG="Digite o novo refind_config (Enter para manter): "
        MSG_NEW_INCLUDE_PATHS="Digite 'true' ou 'false' para include_paths (Enter para manter): "
        MSG_NEW_INCLUDE_SUB_MENUS="Digite 'true' ou 'false' para include_sub_menus (Enter para manter): "
        MSG_BOOT_STANZA_ICON="Configurar boot-stanza-generation.icon"
        MSG_NEW_ICON_MODE="Digite o novo mode (Enter para manter): "
        MSG_ICON_MODE_OPTIONS="Opções: default, custom, embed_btrfs_logo"
        MSG_NEW_ICON_PATH="Digite o novo caminho do ícone (Enter para manter): "
        MSG_BTRFS_LOGO_SETTINGS="Configurar embed_btrfs_logo"
        MSG_NEW_VARIANT="Digite o novo variant (Enter para manter): "
        MSG_VARIANT_OPTIONS="Opções: original, inverted"
        MSG_NEW_SIZE="Digite o novo size (Enter para manter): "
        MSG_SIZE_OPTIONS="Opções: small, medium, large"
        MSG_NEW_HALIGN="Digite o novo horizontal_alignment (Enter para manter): "
        MSG_HALIGN_OPTIONS="Opções: left, center, right"
        MSG_NEW_VALIGN="Digite o novo vertical_alignment (Enter para manter): "
        MSG_VALIGN_OPTIONS="Opções: top, center, bottom"
        MSG_FINISH_CONFIG="Finalizar Configuração"
        MSG_LOAD_SNAPSHOTS="Deseja carregar os snapshots agora? (s/n): "
        MSG_LOADING_SNAPSHOTS="Carregando os snapshots..."
        MSG_SNAPSHOTS_LOADED="Snapshots carregados com sucesso."
        MSG_SNAPSHOTS_FAILED="Falha ao carregar os snapshots."
        MSG_SNAPSHOTS_NOT_LOADED="Snapshots não carregados."
        MSG_CREATE_BACKUP="Criar Backup do rEFInd"
        MSG_RESTORE_BACKUP="Restaurar Backup do rEFInd"
        MSG_REFIND_NOT_FOUND="refind.conf não encontrado:"
        MSG_MARKER_EXISTS="Arquivo já modificado anteriormente. Backup não recriado."
        MSG_MARKER_ADDED="Marcador adicionado ao arquivo:"
        MSG_ADD_MARKER_FAILED="Falha ao adicionar marcador. Permissões insuficientes?"
        MSG_OPERATION_COMPLETE="Operação concluída."
        MSG_RESTORE_BTRFS_BACKUP="Restaurar Backup do refind-btrfs"
        MSG_SEARCH_CONFIG="Buscando arquivo de configuração:"
        MSG_CONFIG_FOUND="Arquivo de configuração encontrado:"
        MSG_CONFIG_NOT_FOUND="Arquivo de configuração não encontrado:"
        MSG_REFIND_FOLDER_NOT_FOUND="A pasta do rEFInd não foi encontrada em /boot."
        MSG_REFIND_CONF_CONTENT="Conteúdo de refind_linux.conf"
        MSG_REFIND_CONF_NOT_FOUND="Arquivo /boot/refind_linux.conf não encontrado."
        MSG_CREATE_CONF_PROMPT="Deseja criar um novo arquivo com o comando mkrlconf? [s/N]: "
        MSG_FILE_CREATED="Arquivo criado com sucesso!"
        MSG_FILE_CREATION_FAILED="Falha ao criar o arquivo."
        MSG_MANUAL_PARAMS="Você deverá digitar os parâmetros do kernel manualmente."
        MSG_GENERATED_STANZA="Boot Stanza Gerada"
        MSG_UPDATED="atualizado."
        MSG_CREATE_SNAPSHOT_HEADER="Criar Snapshot BTRFS"
        MSG_CREATING_SNAPSHOT="Criando snapshot"
        MSG_REFIND_UPDATED="O rEFInd foi atualizado com o novo snapshot!"
        MSG_REFIND_UPDATE_FAILED="Falha ao atualizar o rEFInd. Verifique a configuração do refind-btrfs."
        MSG_EDITOR_OTHER="Digite o nome do editor:"
        MSG_EDITOR_OPTIONS="1) nano\n2) micro\n3) vim\n4) vi\n5) ne\n6) joe\n7) emacs (modo terminal)\n8) outro (digitar nome)"
        MSG_CONTINUING="Continuando..."
        MSG_EDITOR_PROMPT="Opção [1-8]: "
        MSG_OPENING_FILE="Abrindo %s com o editor: %s"
        MSG_OPENING_CONFIG="Abrindo arquivo de configuração %s com o editor: %s"
        MSG_FILE_NOT_FOUND="Arquivo não encontrado: %s"
        MSG_UPDATING_REFIND="Atualizando refind-btrfs..."
        MSG_CHOOSE_OPTION="Escolha uma opção [1-8]:"
        MSG_EXITING="Saindo..."
        MSG_DEVICE_COLUMN="Dispositivo"
        MSG_CONFIGURING_SUBMENU="Configurando Submenu #%d"
        ;;
    *)
        # Strings em inglês (fallback)
        MSG_WELCOME="rEFInd Configuration Wizard"
        MSG_ADD_BOOT="Add new boot stanza"
        MSG_CONFIG_BTRFS="Configure refind-btrfs"
        MSG_EDIT_REFIND="Edit refind.conf manually"
        MSG_EDIT_BTRFS_CONF="Edit refind-btrfs.conf manually"
        MSG_RESTORE_REFIND="Restore refind.conf backup"
        MSG_RESTORE_BTRFS="Restore refind-btrfs.conf backup"
        MSG_CREATE_SNAPSHOT="Create BTRFS Snapshot with Snapper"
        MSG_EXIT="Exit"
        MSG_INVALID_OPT="Invalid option!"
        MSG_ROOT_REQUIRED="Run as root (sudo)."
        MSG_SEARCH_REFIND="Searching for refind.conf in /boot..."
        MSG_REFIND_FOUND="Found:"
        MSG_REFIND_NOT_FOUND="refind.conf not found automatically."
        MSG_REFIND_PROMPT="Enter full path to refind.conf file:"
        MSG_BACKUP_CREATED="Backup created at:"
        MSG_BACKUP_EXISTS="Backup already exists:"
        MSG_BACKUP_RESTORED="Backup restored successfully!"
        MSG_BACKUP_FAILED="Failed to create backup. Insufficient permissions?"
        MSG_BACKUP_NOT_FOUND="Backup not found:"
        MSG_AVAIL_PARTUUIDS="Available PARTUUIDs"
        MSG_CURRENT_ROOT="Current root partition"
        MSG_MOUNTED_DEV="Device mounted on /:"
        MSG_PARTUUID="PARTUUID:"
        MSG_BOOT_FILES="Files in /boot directory"
        MSG_KERNELS="Available kernels:"
        MSG_INITRDS="Available initrds:"
        MSG_ICONS_FOUND="Icons found in refind folder (relative to EFI/):"
        MSG_ICONS_BTRFS="Icons found in refind folder (relative to refind/):"
        MSG_SUBVOLUMES="Btrfs subvolumes found"
        MSG_CURRENT_SUBVOL="Current root system subvolume"
        MSG_SUBVOL_INFO="System is using subvolume"
        MSG_SUBVOL_WARNING="On some systems, leaving subvolume field blank works better (subvolid=5)."
        MSG_SUBVOL_DEFAULT="System might be using default subvolume (subvolid=5) as root (/)."
        MSG_ENTER_PARTUUID="Enter Btrfs partition PARTUUID:"
        MSG_ENTER_SUBVOL="Enter subvolume name (ex: @ or leave blank if using subvolid=5):"
        MSG_ENTER_KERNEL="Enter kernel filename:"
        MSG_ENTER_INITRD="Enter initrd filename:"
        MSG_ENTER_ICON="Enter icon path (ex: EFI/refind/icons/os_linux.png):"
        MSG_ENTER_MENUNAME="Enter operating system name (menuentry):"
        MSG_ENTER_KERNEL_OPTS="Enter kernel parameters (without quotes):"
        MSG_EXAMPLE_OPTS="Example:"
        MSG_ADD_SUBMENU="Add a submenu? (y/n):"
        MSG_SUBMENU_NAME="Enter submenu name:"
        MSG_SUBMENU_KERNEL="Enter kernel for submenu:"
        MSG_SUBMENU_INITRD="Enter initrd for submenu:"
        MSG_SUBMENU_OPTS="Enter kernel options for the submenu or press Enter to use the same as the main menu:"
        MSG_STANZA_CONFIRM="Add to refind.conf? (y/n):"
        MSG_STANZA_ADDED="Entry added to"
        MSG_OPERATION_CANCELED="Operation canceled. Nothing changed."
        MSG_CONFIG_REFIND_BTRFS="Configure refind-btrfs"
        MSG_EDITOR_CHOICE="Choose a text editor:"
        MSG_EDITOR_INVALID="Invalid option. Using nano as default."
        MSG_EDITOR_NOT_FOUND="Editor not installed. Install it before using."
        MSG_SNAPSHOT_NAME="Enter snapshot name:"
        MSG_SNAPSHOT_EMPTY="Snapshot name cannot be empty. Operation aborted."
        MSG_SNAPSHOT_CREATED="Snapshot created successfully!"
        MSG_SNAPSHOT_FAILED="Failed to create snapshot. Check permissions."
        MSG_PRESS_ENTER="Press Enter..."
        MSG_RETURN_MAIN="Returning to main menu..."
        MSG_GENERAL_SETTINGS="General Settings:"
        MSG_CURRENT_VALUE="[Current]"
        MSG_NEW_ESP_UUID="Enter new esp_uuid (or Enter to keep): "
        MSG_NEW_EXIT_ROOT="Enter 'true' or 'false' for exit_if_root_is_snapshot (Enter to keep): "
        MSG_NEW_EXIT_NO_CHANGES="Enter 'true' or 'false' for exit_if_no_changes_are_detected (Enter to keep): "
        MSG_SNAPSHOT_SEARCH="Configure snapshot-search"
        MSG_NEW_SNAPSHOT_DIR="Enter new directory for snapshot-search (Enter to keep): "
        MSG_NEW_IS_NESTED="Enter 'true' or 'false' for is_nested (Enter to keep): "
        MSG_NEW_MAX_DEPTH="Enter new max_depth (integer, Enter to keep): "
        MSG_SNAPSHOT_MANIPULATION="Configure snapshot-manipulation"
        MSG_NEW_SELECTION_COUNT="Enter new selection_count (number or 'inf', Enter to keep): "
        MSG_NEW_MODIFY_FLAG="Enter 'true' or 'false' for modify_read_only_flag (Enter to keep): "
        MSG_NEW_DEST_DIR="Enter new destination_directory (Enter to keep): "
        MSG_NEW_CLEANUP_EXCLUSION="Enter UUIDs for cleanup_exclusion (comma separated, Enter to keep): "
        MSG_BOOT_STANZA_GENERATION="Configure boot-stanza-generation"
        MSG_NEW_REFIND_CONFIG="Enter new refind_config (Enter to keep): "
        MSG_NEW_INCLUDE_PATHS="Enter 'true' or 'false' for include_paths (Enter to keep): "
        MSG_NEW_INCLUDE_SUB_MENUS="Enter 'true' or 'false' for include_sub_menus (Enter to keep): "
        MSG_BOOT_STANZA_ICON="Configure boot-stanza-generation.icon"
        MSG_NEW_ICON_MODE="Enter new mode (Enter to keep): "
        MSG_ICON_MODE_OPTIONS="Options: default, custom, embed_btrfs_logo"
        MSG_NEW_ICON_PATH="Enter new icon path (Enter to keep): "
        MSG_BTRFS_LOGO_SETTINGS="Configure embed_btrfs_logo"
        MSG_NEW_VARIANT="Enter new variant (Enter to keep): "
        MSG_VARIANT_OPTIONS="Options: original, inverted"
        MSG_NEW_SIZE="Enter new size (Enter to keep): "
        MSG_SIZE_OPTIONS="Options: small, medium, large"
        MSG_NEW_HALIGN="Enter new horizontal_alignment (Enter to keep): "
        MSG_HALIGN_OPTIONS="Options: left, center, right"
        MSG_NEW_VALIGN="Enter new vertical_alignment (Enter to keep): "
        MSG_VALIGN_OPTIONS="Options: top, center, bottom"
        MSG_FINISH_CONFIG="Finish Configuration"
        MSG_LOAD_SNAPSHOTS="Load snapshots now? (y/n): "
        MSG_LOADING_SNAPSHOTS="Loading snapshots..."
        MSG_SNAPSHOTS_LOADED="Snapshots loaded successfully."
        MSG_SNAPSHOTS_FAILED="Failed to load snapshots."
        MSG_SNAPSHOTS_NOT_LOADED="Snapshots not loaded."
        MSG_CREATE_BACKUP="Create rEFInd Backup"
        MSG_RESTORE_BACKUP="Restore rEFInd Backup"
        MSG_REFIND_NOT_FOUND="refind.conf not found:"
        MSG_MARKER_EXISTS="File already modified previously. Backup not recreated."
        MSG_MARKER_ADDED="Marker added to file:"
        MSG_ADD_MARKER_FAILED="Failed to add marker. Insufficient permissions?"
        MSG_OPERATION_COMPLETE="Operation complete."
        MSG_RESTORE_BTRFS_BACKUP="Restore refind-btrfs Backup"
        MSG_SEARCH_CONFIG="Searching configuration file:"
        MSG_CONFIG_FOUND="Configuration file found:"
        MSG_CONFIG_NOT_FOUND="Configuration file not found:"
        MSG_REFIND_FOLDER_NOT_FOUND="rEFInd folder not found in /boot."
        MSG_REFIND_CONF_CONTENT="Content of refind_linux.conf"
        MSG_REFIND_CONF_NOT_FOUND="/boot/refind_linux.conf not found."
        MSG_CREATE_CONF_PROMPT="Create new file with mkrlconf? [y/N]: "
        MSG_FILE_CREATED="File created successfully!"
        MSG_FILE_CREATION_FAILED="Failed to create file."
        MSG_MANUAL_PARAMS="You will need to enter kernel parameters manually."
        MSG_GENERATED_STANZA="Generated Boot Stanza"
        MSG_UPDATED="updated."
        MSG_CREATE_SNAPSHOT_HEADER="Create BTRFS Snapshot"
        MSG_CREATING_SNAPSHOT="Creating snapshot"
        MSG_REFIND_UPDATED="rEFInd updated with new snapshot!"
        MSG_REFIND_UPDATE_FAILED="Failed to update rEFInd. Check refind-btrfs configuration."
        MSG_EDITOR_OTHER="Enter editor name:"
        MSG_EDITOR_OPTIONS="1) nano\n2) micro\n3) vim\n4) vi\n5) ne\n6) joe\n7) emacs (terminal mode)\n8) other (enter name)"
        MSG_CONTINUING="Continuing..."
        MSG_EDITOR_PROMPT="Option [1-8]: "
        MSG_OPENING_FILE="Opening %s with editor: %s"
        MSG_OPENING_CONFIG="Opening configuration file %s with editor: %s"
        MSG_FILE_NOT_FOUND="File not found: %s"
        MSG_UPDATING_REFIND="Updating refind-btrfs..."
        MSG_CHOOSE_OPTION="Choose an option [1-8]:"
        MSG_EXITING="Exiting..."
        MSG_DEVICE_COLUMN="Device"
        MSG_CONFIGURING_SUBMENU="Configuring Submenu #%d"
        ;;
    esac
}

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
    echo -e "${CYAN}[INFO]${NC} $1"
}

success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

ask() {
    echo -e "${YELLOW}[INPUT]${NC} $1"
    read -p "> " "$2"
}

# Verifica privilégios de root
check_root() {
    [ "$EUID" -ne 0 ] && error "$MSG_ROOT_REQUIRED" && exit 1
}

# Localizar refind.conf
busca_refind_conf() {
    info "$MSG_SEARCH_REFIND"
    REFIND_CONF=$(find /boot -type f -name refind.conf 2>/dev/null | head -n 1)
    if [ -z "$REFIND_CONF" ]; then
        warning "$MSG_REFIND_NOT_FOUND"
        ask "$MSG_REFIND_PROMPT" REFIND_CONF
    else
        success "$MSG_REFIND_FOUND $REFIND_CONF"
    fi
}

# Criar backup
cria_backup() {
    reset
    header "$MSG_CREATE_BACKUP"

    busca_refind_conf

    if [ ! -f "$REFIND_CONF" ]; then
        error "$MSG_REFIND_NOT_FOUND $REFIND_CONF"
        pausar
        return 1
    fi

    BACKUP_FILE="${REFIND_CONF}.bak"
    MARKER="# refind.conf by refind_stanza_creator."

    if grep -q "$MARKER" "$REFIND_CONF"; then
        warning "$MSG_MARKER_EXISTS"
        info "$MSG_MARKER_ADDED $REFIND_CONF"
    else
        if [ ! -f "$BACKUP_FILE" ]; then
            cp "$REFIND_CONF" "$BACKUP_FILE"
            if [ $? -eq 0 ]; then
                success "$MSG_BACKUP_CREATED $BACKUP_FILE"
            else
                error "$MSG_BACKUP_FAILED"
                pausar
                return 1
            fi
        else
            info "$MSG_BACKUP_EXISTS $BACKUP_FILE"
        fi

        echo -e "\n$MARKER" >>"$REFIND_CONF"
        if [ $? -eq 0 ]; then
            info "$MSG_MARKER_ADDED $REFIND_CONF"
        else
            error "$MSG_ADD_MARKER_FAILED"
            pausar
            return 1
        fi
    fi

    info "$MSG_OPERATION_COMPLETE"
    return 0
}

# Restaurar backup
restaurar_backup_refind() {
    reset
    header "$MSG_RESTORE_BACKUP"

    busca_refind_conf
    BACKUP_FILE="${REFIND_CONF}.bak"

    if [ -f "$BACKUP_FILE" ]; then
        cp "$BACKUP_FILE" "$REFIND_CONF"
        if [ $? -eq 0 ]; then
            success "$MSG_BACKUP_RESTORED"
        else
            error "$MSG_BACKUP_FAILED"
        fi
    else
        error "$MSG_BACKUP_NOT_FOUND $BACKUP_FILE"
    fi

    info "$MSG_RETURN_MAIN"
    pausar
    return
}

# PARTUUIDs
show_partuuids() {
    header "$MSG_AVAIL_PARTUUIDS"
    echo -e "${YELLOW}${YELLOW}$MSG_DEVICE_COLUMN\t\tPARTUUID${NC}"
    echo "----------------------------------------"
    blkid | grep PARTUUID | awk -F: '{printf "%-24s", $1; sub(/.*PARTUUID="/,"",$2); sub(/".*/,"",$2); print $2}'
    echo
}

# Mostrar partição root
mostra_particao_raiz() {
    header "$MSG_CURRENT_ROOT"
    root_device=$(findmnt -n -o SOURCE / | sed 's/\[.*\]//')
    root_partuuid=$(blkid -s PARTUUID -o value "$root_device")
    echo -e "${YELLOW}$MSG_MOUNTED_DEV ${NC}$root_device"
    echo -e "${YELLOW}$MSG_PARTUUID   ${NC}$root_partuuid"
    echo
}

# Mostrar arquivos em /boot
show_boot_files() {
    header "$MSG_BOOT_FILES"
    echo -e "${YELLOW}$MSG_KERNELS${NC}"
    ls -1 /boot | grep -E '^vmlinuz' | sed 's/^/  /'
    echo
    echo -e "${YELLOW}$MSG_INITRDS${NC}"
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
        echo -e "\n$MSG_REFIND_FOLDER_NOT_FOUND"
        return
    fi
    header "$MSG_ICONS_FOUND"
    find "$pasta" -type f \( -iname "*.png" -o -iname "*.jpg" -o -iname "*.icns" \) |
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
        echo -e "\n$MSG_REFIND_FOLDER_NOT_FOUND"
        return
    fi
    echo -e "${CYAN}$MSG_ICONS_BTRFS${NC}"
    find "$pasta" -type f -iname "*.png" | sed -E "s|^$pasta/||" | sort
    echo
}

# Funções relacionadas a subvolumes Btrfs
listar_subvolumes() {
    header "$MSG_SUBVOLUMES"
    btrfs subvolume list / | awk '{print $NF}' | sed 's/^/  /'
    echo
}

# Detectar subvolume atual
detecta_subvolume_atual() {
    header "$MSG_CURRENT_SUBVOL"
    SUBVOLUME_ATUAL=$(grep " / " /etc/fstab | grep btrfs | sed -n 's/.*subvol=\/\([^,]*\).*/\1/p')
    if [ -n "$SUBVOLUME_ATUAL" ]; then
        if [[ "$SUBVOLUME_ATUAL" == "@" ]]; then
            echo -e "${CYAN}[INFO]${NC} $MSG_SUBVOL_INFO '@'."
            echo -e "${YELLOW}[AVISO]${NC} $MSG_SUBVOL_WARNING"
        else
            echo -e "${CYAN}[INFO]${NC} $MSG_SUBVOL_INFO '/$SUBVOLUME_ATUAL'."
        fi
    else
        echo -e "${CYAN}[INFO]${NC} $MSG_SUBVOL_DEFAULT"
    fi
    echo
}

# Adicionar boot
adiciona_boot_stanza() {
    reset
    cria_backup
    show_partuuids
    mostra_particao_raiz
    ask "$MSG_ENTER_PARTUUID" PARTUUID_BTRFS
    listar_subvolumes
    detecta_subvolume_atual
    ask "$MSG_ENTER_SUBVOL" SUBVOLUME
    show_boot_files
    ask "$MSG_ENTER_KERNEL" KERNEL_FILE
    ask "$MSG_ENTER_INITRD" INITRD_FILE
    LOADER_PATH="${KERNEL_FILE}"
    INITRD_PATH="${INITRD_FILE}"

    if [ -f /boot/refind_linux.conf ]; then
        header "$MSG_REFIND_CONF_CONTENT"
        sed 's/^/  /' /boot/refind_linux.conf
    else
        warning "$MSG_REFIND_CONF_NOT_FOUND"
        echo
        read -p "$MSG_CREATE_CONF_PROMPT" resposta
        case "$resposta" in
        [sS] | [sS][iI][mM])
            mkrlconf
            if [ -f /boot/refind_linux.conf ]; then
                success "$MSG_FILE_CREATED"
                header "$MSG_REFIND_CONF_CONTENT"
                sed 's/^/  /' /boot/refind_linux.conf
            else
                error "$MSG_FILE_CREATION_FAILED"
                echo -e "${YELLOW}$MSG_MANUAL_PARAMS${NC}"
            fi
            ;;
        *)
            echo -e "${YELLOW}$MSG_MANUAL_PARAMS${NC}"
            ;;
        esac
    fi
    echo
    echo -e "${YELLOW}$MSG_EXAMPLE_OPTS quiet zswap.enabled=0 root=PARTUUID=xxxx-xxxx rw rootflags=subvol=@ quiet splash${NC}"
    echo
    ask "$MSG_ENTER_KERNEL_OPTS" KERNEL_OPTIONS
    listar_ícones
    ask "$MSG_ENTER_ICON" ICON_PATH
    ask "$MSG_ENTER_MENUNAME" MENU_NAME

    BOOT_STANZA="menuentry \"${MENU_NAME}\" {\n"
    BOOT_STANZA+="    icon    ${ICON_PATH}\n"
    BOOT_STANZA+="    volume  ${PARTUUID_BTRFS}\n"
    BOOT_STANZA+="    loader  ${LOADER_PATH}\n"
    BOOT_STANZA+="    initrd  ${INITRD_PATH}\n"
    BOOT_STANZA+="    graphics on\n"
    BOOT_STANZA+="    options \"${KERNEL_OPTIONS}\"\n"

    SUBMENU_COUNT=0
    SUBMENUS=""
    while true; do
        ask "$MSG_ADD_SUBMENU" ADD_SUBMENU
        if [[ "$ADD_SUBMENU" =~ ^[sSyY]$ ]]; then
            SUBMENU_COUNT=$((SUBMENU_COUNT + 1))
            echo -e "${CYAN}$(printf "$MSG_CONFIGURING_SUBMENU" "$SUBMENU_COUNT")${NC}"

            ask "$MSG_SUBMENU_NAME" SUBMENU_NAME
            show_boot_files
            ask "$MSG_SUBMENU_KERNEL" SUBMENU_KERNEL
            ask "$MSG_SUBMENU_INITRD" SUBMENU_INITRD

            if [ -f /boot/refind_linux.conf ]; then
                header "$MSG_REFIND_CONF_CONTENT"
                sed 's/^/  /' /boot/refind_linux.conf
            else
                warning "$MSG_REFIND_CONF_NOT_FOUND"
                echo
                read -p "$MSG_CREATE_CONF_PROMPT" resposta
                case "$resposta" in
                [sS] | [sS][iI][mM])
                    mkrlconf
                    if [ -f /boot/refind_linux.conf ]; then
                        success "$MSG_FILE_CREATED"
                        header "$MSG_REFIND_CONF_CONTENT"
                        sed 's/^/  /' /boot/refind_linux.conf
                    else
                        error "$MSG_FILE_CREATION_FAILED"
                        echo -e "${YELLOW}$MSG_MANUAL_PARAMS${NC}"
                    fi
                    ;;
                *)
                    echo -e "${YELLOW}$MSG_MANUAL_PARAMS${NC}"
                    ;;
                esac
            fi
            echo
            echo -e "${YELLOW}$MSG_EXAMPLE_OPTS quiet zswap.enabled=0 root=PARTUUID=xxxx-xxxx rw rootflags=subvol=@ quiet splash${NC}"
            echo
            ask "$MSG_SUBMENU_OPTS" SUBMENU_OPTIONS

            [ -z "$SUBMENU_OPTIONS" ] && SUBMENU_OPTIONS="$KERNEL_OPTIONS"

            SUBMENUS+="\n    submenuentry \"${SUBMENU_NAME}\" {\n"
            SUBMENUS+="        loader  ${SUBMENU_KERNEL}\n"
            SUBMENUS+="        initrd  ${SUBMENU_INITRD}\n"
            SUBMENUS+="        options \"${SUBMENU_OPTIONS}\"\n"
            SUBMENUS+="    }"
        else
            break
        fi
    done

    BOOT_STANZA+="${SUBMENUS}\n}\n"

    header "$MSG_GENERATED_STANZA"
    echo -e "$BOOT_STANZA" | sed 's/^/  /'
    ask "$MSG_STANZA_CONFIRM" CONFIRM
    if [[ "$CONFIRM" =~ ^[sSyY]$ ]]; then
        echo -e "\n$BOOT_STANZA" >>"$REFIND_CONF"
        success "$MSG_STANZA_ADDED $REFIND_CONF."
    else
        info "$MSG_OPERATION_CANCELED"
    fi
    info "$MSG_RETURN_MAIN..."
    pausar
}

# Funções relacionadas ao refind-btrfs
configure_refind_btrfs() {
    reset
    local REFIND_BTRFS_CONF="/etc/refind-btrfs.conf"
    local BACKUP_RB="/etc/refind-btrfs.conf.bak"
    header "$MSG_CONFIG_REFIND_BTRFS"

    if [ ! -f "$BACKUP_RB" ]; then
        cp "$REFIND_BTRFS_CONF" "$BACKUP_RB"
        success "$MSG_BACKUP_CREATED $BACKUP_RB"
    else
        warning "$MSG_BACKUP_EXISTS $BACKUP_RB. $MSG_CONTINUING"
    fi

    # --- Configurações Gerais ---
    info "$MSG_GENERAL_SETTINGS"
    echo -e "${CYAN}$MSG_CURRENT_VALUE $(grep '^esp_uuid' "$REFIND_BTRFS_CONF")${NC}"
    read -p "$MSG_NEW_ESP_UUID" new_esp_uuid
    if [ -n "$new_esp_uuid" ]; then
        sed -i "s/^esp_uuid = .*/esp_uuid = \"$new_esp_uuid\"/" "$REFIND_BTRFS_CONF"
        success "esp_uuid $MSG_UPDATED"
    fi

    local current_val=$(grep '^exit_if_root_is_snapshot' "$REFIND_BTRFS_CONF" | awk -F '=' '{print $2}' | tr -d ' ')
    echo -e "${CYAN}$MSG_CURRENT_VALUE exit_if_root_is_snapshot = $current_val${NC}"
    read -p "$MSG_NEW_EXIT_ROOT" new_exit_root
    if [ -n "$new_exit_root" ]; then
        sed -i "s/^exit_if_root_is_snapshot = .*/exit_if_root_is_snapshot = $new_exit_root/" "$REFIND_BTRFS_CONF"
        success "exit_if_root_is_snapshot $MSG_UPDATED"
    fi

    current_val=$(grep '^exit_if_no_changes_are_detected' "$REFIND_BTRFS_CONF" | awk -F '=' '{print $2}' | tr -d ' ')
    echo -e "${CYAN}$MSG_CURRENT_VALUE exit_if_no_changes_are_detected = $current_val${NC}"
    read -p "$MSG_NEW_EXIT_NO_CHANGES" new_exit_no_changes
    if [ -n "$new_exit_no_changes" ]; then
        sed -i "s/^exit_if_no_changes_are_detected = .*/exit_if_no_changes_are_detected = $new_exit_no_changes/" "$REFIND_BTRFS_CONF"
        success "exit_if_no_changes_are_detected $MSG_UPDATED"
    fi

    # --- snapshot-search ---
    header "$MSG_SNAPSHOT_SEARCH"
    local current_dir=$(sed -n '/^\[\[snapshot-search\]\]/,/\[\[/p' "$REFIND_BTRFS_CONF" | grep '^directory' | head -n1 | awk -F '=' '{print $2}' | sed 's/"//g' | tr -d ' ')
    echo -e "${CYAN}$MSG_CURRENT_VALUE directory = $current_dir${NC}"
    read -p "$MSG_NEW_SNAPSHOT_DIR" new_snapshot_dir
    if [ -n "$new_snapshot_dir" ]; then
        sed -i "/^\[\[snapshot-search\]\]/,/^\[/{s|^directory = .*|directory = \"$new_snapshot_dir\"|}" "$REFIND_BTRFS_CONF"
        success "directory $MSG_UPDATED"
    fi

    local current_nested=$(sed -n '/^\[\[snapshot-search\]\]/,/\[\[/p' "$REFIND_BTRFS_CONF" | grep '^is_nested' | head -n1 | awk -F '=' '{print $2}' | tr -d ' ')
    echo -e "${CYAN}$MSG_CURRENT_VALUE is_nested = $current_nested${NC}"
    read -p "$MSG_NEW_IS_NESTED" new_is_nested
    if [ -n "$new_is_nested" ]; then
        sed -i "/^\[\[snapshot-search\]\]/,/^\[/{s|^is_nested = .*|is_nested = $new_is_nested|}" "$REFIND_BTRFS_CONF"
        success "is_nested $MSG_UPDATED"
    fi

    local current_max_depth=$(sed -n '/^\[\[snapshot-search\]\]/,/\[\[/p' "$REFIND_BTRFS_CONF" | grep '^max_depth' | head -n1 | awk -F '=' '{print $2}' | tr -d ' ')
    echo -e "${CYAN}$MSG_CURRENT_VALUE max_depth = $current_max_depth${NC}"
    read -p "$MSG_NEW_MAX_DEPTH" new_max_depth
    if [ -n "$new_max_depth" ]; then
        sed -i "/^\[\[snapshot-search\]\]/,/^\[/{s|^max_depth = .*|max_depth = $new_max_depth|}" "$REFIND_BTRFS_CONF"
        success "max_depth $MSG_UPDATED"
    fi

    # --- snapshot-manipulation ---
    header "$MSG_SNAPSHOT_MANIPULATION"
    local current_selection=$(sed -n '/^\[snapshot-manipulation\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^selection_count' | head -n1 | awk -F '=' '{print $2}' | tr -d ' "')
    echo -e "${CYAN}$MSG_CURRENT_VALUE selection_count = $current_selection${NC}"
    read -p "$MSG_NEW_SELECTION_COUNT" new_selection_count
    if [ -n "$new_selection_count" ]; then
        sed -i "/^\[snapshot-manipulation\]/,/\[/ {s|^selection_count = .*|selection_count = $new_selection_count|}" "$REFIND_BTRFS_CONF"
        success "selection_count $MSG_UPDATED"
    fi

    local current_modify=$(sed -n '/^\[snapshot-manipulation\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^modify_read_only_flag' | head -n1 | awk -F '=' '{print $2}' | tr -d ' ')
    echo -e "${CYAN}$MSG_CURRENT_VALUE modify_read_only_flag = $current_modify${NC}"
    read -p "$MSG_NEW_MODIFY_FLAG" new_modify_flag
    if [ -n "$new_modify_flag" ]; then
        sed -i "/^\[snapshot-manipulation\]/,/\[/ {s|^modify_read_only_flag = .*|modify_read_only_flag = $new_modify_flag|}" "$REFIND_BTRFS_CONF"
        success "modify_read_only_flag $MSG_UPDATED"
    fi

    local current_dest=$(sed -n '/^\[snapshot-manipulation\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^destination_directory' | head -n1 | awk -F '=' '{print $2}' | sed 's/"//g' | tr -d ' ')
    echo -e "${CYAN}$MSG_CURRENT_VALUE destination_directory = $current_dest${NC}"
    read -p "$MSG_NEW_DEST_DIR" new_dest
    if [ -n "$new_dest" ]; then
        sed -i "/^\[snapshot-manipulation\]/,/\[/ {s|^destination_directory = .*|destination_directory = \"$new_dest\"|}" "$REFIND_BTRFS_CONF"
        success "destination_directory $MSG_UPDATED"
    fi

    local current_cleanup=$(sed -n '/^\[snapshot-manipulation\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^cleanup_exclusion' | head -n1)
    echo -e "${CYAN}$MSG_CURRENT_VALUE $current_cleanup${NC}"
    read -p "$MSG_NEW_CLEANUP_EXCLUSION" new_cleanup
    if [ -n "$new_cleanup" ]; then
        formatted=$(echo "$new_cleanup" | sed 's/,/","/g')
        formatted="[\"$formatted\"]"
        sed -i "/^\[snapshot-manipulation\]/,/\[/ {s|^cleanup_exclusion = .*|cleanup_exclusion = $formatted|}" "$REFIND_BTRFS_CONF"
        success "cleanup_exclusion $MSG_UPDATED"
    fi

    # --- boot-stanza-generation ---
    header "$MSG_BOOT_STANZA_GENERATION"
    local current_refind_config=$(sed -n '/^\[boot-stanza-generation\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^refind_config' | head -n1 | awk -F '=' '{print $2}' | sed 's/"//g' | tr -d ' ')
    echo -e "${CYAN}$MSG_CURRENT_VALUE refind_config = $current_refind_config${NC}"
    read -p "$MSG_NEW_REFIND_CONFIG" new_refind_config
    if [ -n "$new_refind_config" ]; then
        sed -i "/^\[boot-stanza-generation\]/,/\[/ {s|^refind_config = .*|refind_config = \"$new_refind_config\"|}" "$REFIND_BTRFS_CONF"
        success "refind_config $MSG_UPDATED"
    fi

    local current_include_paths=$(sed -n '/^\[boot-stanza-generation\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^include_paths' | head -n1 | awk -F '=' '{print $2}' | tr -d ' ')
    echo -e "${CYAN}$MSG_CURRENT_VALUE include_paths = $current_include_paths${NC}"
    read -p "$MSG_NEW_INCLUDE_PATHS" new_include_paths
    if [ -n "$new_include_paths" ]; then
        sed -i "/^\[boot-stanza-generation\]/,/\[/ {s|^include_paths = .*|include_paths = $new_include_paths|}" "$REFIND_BTRFS_CONF"
        success "include_paths $MSG_UPDATED"
    fi

    local current_include_sub=$(sed -n '/^\[boot-stanza-generation\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^include_sub_menus' | head -n1 | awk -F '=' '{print $2}' | tr -d ' ')
    echo -e "${CYAN}$MSG_CURRENT_VALUE include_sub_menus = $current_include_sub${NC}"
    read -p "$MSG_NEW_INCLUDE_SUB_MENUS" new_include_sub
    if [ -n "$new_include_sub" ]; then
        sed -i "/^\[boot-stanza-generation\]/,/\[/ {s|^include_sub_menus = .*|include_sub_menus = $new_include_sub|}" "$REFIND_BTRFS_CONF"
        success "include_sub_menus $MSG_UPDATED"
    fi

    # --- boot-stanza-generation.icon ---
    header "$MSG_BOOT_STANZA_ICON"
    local current_mode=$(sed -n '/^\[boot-stanza-generation.icon\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^mode' | head -n1 | awk -F '=' '{print $2}' | sed 's/"//g' | tr -d ' ')
    echo -e "${CYAN}$MSG_CURRENT_VALUE mode = $current_mode${NC}"
    echo -e "${YELLOW}$MSG_ICON_MODE_OPTIONS${NC}"
    read -p "$MSG_NEW_ICON_MODE" new_mode
    if [ -n "$new_mode" ]; then
        sed -i "/^\[boot-stanza-generation.icon\]/,/\[/ {s|^mode = .*|mode = \"$new_mode\"|}" "$REFIND_BTRFS_CONF"
        success "mode $MSG_UPDATED"
        current_mode="$new_mode"
    fi

    if [ "$current_mode" == "custom" ]; then
        local current_path=$(sed -n '/^\[boot-stanza-generation.icon\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^path' | head -n1 | awk -F '=' '{print $2}' | sed 's/"//g' | tr -d ' ')
        echo -e "${CYAN}$MSG_CURRENT_VALUE path = $current_path${NC}"
        echo -e "${YELLOW}${MSG_ICONS_BTRFS}${NC}"
        listar_ícones_refind_btrfs
        read -p "$MSG_NEW_ICON_PATH" new_path
        if [ -n "$new_path" ]; then
            sed -i "/^\[boot-stanza-generation.icon\]/,/\[/ {s|^path = .*|path = \"$new_path\"|}" "$REFIND_BTRFS_CONF"
            success "path $MSG_UPDATED"
        fi
    elif [ "$current_mode" == "embed_btrfs_logo" ]; then
        header "$MSG_BTRFS_LOGO_SETTINGS"
        local current_variant=$(sed -n '/^\[boot-stanza-generation.icon.btrfs-logo\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^variant' | head -n1 | awk -F '=' '{print $2}' | sed 's/"//g' | tr -d ' ')
        echo -e "${CYAN}$MSG_CURRENT_VALUE variant = $current_variant${NC}"
        echo -e "${YELLOW}$MSG_VARIANT_OPTIONS${NC}"
        read -p "$MSG_NEW_VARIANT" new_variant
        if [ -n "$new_variant" ]; then
            sed -i "/^\[boot-stanza-generation.icon.btrfs-logo\]/,/\[/ {s|^variant = .*|variant = \"$new_variant\"|}" "$REFIND_BTRFS_CONF"
            success "variant $MSG_UPDATED"
        fi

        local current_size=$(sed -n '/^\[boot-stanza-generation.icon.btrfs-logo\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^size' | head -n1 | awk -F '=' '{print $2}' | sed 's/"//g' | tr -d ' ')
        echo -e "${CYAN}$MSG_CURRENT_VALUE size = $current_size${NC}"
        echo -e "${YELLOW}$MSG_SIZE_OPTIONS${NC}"
        read -p "$MSG_NEW_SIZE" new_size
        if [ -n "$new_size" ]; then
            sed -i "/^\[boot-stanza-generation.icon.btrfs-logo\]/,/\[/ {s|^size = .*|size = \"$new_size\"|}" "$REFIND_BTRFS_CONF"
            success "size $MSG_UPDATED"
        fi

        local current_halign=$(sed -n '/^\[boot-stanza-generation.icon.btrfs-logo\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^horizontal_alignment' | head -n1 | awk -F '=' '{print $2}' | sed 's/"//g' | tr -d ' ')
        echo -e "${CYAN}$MSG_CURRENT_VALUE horizontal_alignment = $current_halign${NC}"
        echo -e "${YELLOW}$MSG_HALIGN_OPTIONS${NC}"
        read -p "$MSG_NEW_HALIGN" new_halign
        if [ -n "$new_halign" ]; then
            sed -i "/^\[boot-stanza-generation.icon.btrfs-logo\]/,/\[/ {s|^horizontal_alignment = .*|horizontal_alignment = \"$new_halign\"|}" "$REFIND_BTRFS_CONF"
            success "horizontal_alignment $MSG_UPDATED"
        fi

        local current_valign=$(sed -n '/^\[boot-stanza-generation.icon.btrfs-logo\]/,/\[/p' "$REFIND_BTRFS_CONF" | grep '^vertical_alignment' | head -n1 | awk -F '=' '{print $2}' | sed 's/"//g' | tr -d ' ')
        echo -e "${CYAN}$MSG_CURRENT_VALUE vertical_alignment = $current_valign${NC}"
        echo -e "${YELLOW}$MSG_VALIGN_OPTIONS${NC}"
        read -p "$MSG_NEW_VALIGN" new_valign
        if [ -n "$new_valign" ]; then
            sed -i "/^\[boot-stanza-generation.icon.btrfs-logo\]/,/\[/ {s|^vertical_alignment = .*|vertical_alignment = \"$new_valign\"|}" "$REFIND_BTRFS_CONF"
            success "vertical_alignment $MSG_UPDATED"
        fi
    fi

    # --- Finalização ---
    header "$MSG_FINISH_CONFIG"
    read -p "$MSG_LOAD_SNAPSHOTS" load_snapshots
    if [[ "$load_snapshots" =~ ^[sSyY]$ ]]; then
        info "$MSG_LOADING_SNAPSHOTS"
        refind-btrfs refresh && success "$MSG_SNAPSHOTS_LOADED" || error "$MSG_SNAPSHOTS_FAILED"
    else
        info "$MSG_SNAPSHOTS_NOT_LOADED"
    fi
    info "$MSG_RETURN_MAIN"
    pausar
    return
}

restaurar_backup_refind_btrfs() {
    reset
    header "$MSG_RESTORE_BTRFS_BACKUP"

    local REFIND_BTRFS_CONF="/etc/refind-btrfs.conf"
    local BACKUP_FILE="${REFIND_BTRFS_CONF}.bak"

    info "$MSG_SEARCH_CONFIG $REFIND_BTRFS_CONF"
    if [ -f "$REFIND_BTRFS_CONF" ]; then
        success "$MSG_CONFIG_FOUND $REFIND_BTRFS_CONF"
    else
        error "$MSG_CONFIG_NOT_FOUND $REFIND_BTRFS_CONF"
        pausar
        return 1
    fi

    info "$MSG_SEARCH_CONFIG $BACKUP_FILE"
    if [ -f "$BACKUP_FILE" ]; then
        cp "$BACKUP_FILE" "$REFIND_BTRFS_CONF"
        if [ $? -eq 0 ]; then
            success "$MSG_BACKUP_RESTORED"
        else
            error "$MSG_BACKUP_FAILED"
        fi
    else
        error "$MSG_BACKUP_NOT_FOUND $BACKUP_FILE"
    fi

    info "$MSG_OPERATION_COMPLETE"
    pausar
    return 0
}

# Função de pausa única
pausar() {
    echo
    read -r -p "$MSG_PRESS_ENTER" </dev/tty
    clear
}

# Função para escolher o editor
escolher_editor() {
    echo
    echo "$MSG_EDITOR_CHOICE"
    echo -e "$MSG_EDITOR_OPTIONS"
    read -rp "$MSG_EDITOR_PROMPT" escolha

    case "$escolha" in
    1) editor_cmd="nano" ;;
    2) editor_cmd="micro" ;;
    3) editor_cmd="vim" ;;
    4) editor_cmd="vi" ;;
    5) editor_cmd="ne" ;;
    6) editor_cmd="joe" ;;
    7) editor_cmd="emacs -nw" ;;
    8) read -rp "$MSG_EDITOR_OTHER" editor_cmd ;;
    *)
        echo "$MSG_EDITOR_INVALID"
        editor_cmd="nano"
        ;;
    esac

    local editor_bin
    editor_bin=$(awk '{print $1}' <<<"$editor_cmd")

    if ! command -v "$editor_bin" >/dev/null 2>&1; then
        echo
        error "$MSG_EDITOR_NOT_FOUND"
        echo
        return 1
    fi
}

# Editar refind.conf com editor escolhido
editar_refind_conf() {
    reset
    busca_refind_conf
    escolher_editor || {
        info "$MSG_RETURN_MAIN"
        pausar
        return
    }
    info "$(printf "$MSG_OPENING_FILE" "$REFIND_CONF" "$editor_cmd")"
    $editor_cmd "$REFIND_CONF"
    info "$MSG_RETURN_MAIN"
    pausar
}

# Editar refind-btrfs.conf com editor escolhido
editar_refind_btrfs_conf() {
    reset
    local CONF="/etc/refind-btrfs.conf"
    if [ ! -f "$CONF" ]; then
        error "$(printf "$MSG_FILE_NOT_FOUND" "$CONF")"
        pausar
        return
    fi
    escolher_editor || {
        info "$MSG_RETURN_MAIN"
        pausar
        return
    }
    info "$(printf "$MSG_OPENING_CONFIG" "$CONF" "$editor_cmd")"
    $editor_cmd "$CONF"
    info "$MSG_RETURN_MAIN"
    pausar
}

# Função para criar snapshot usando snapper e atualizar o rEFInd via refind-btrfs
criar_snapshot_btrfs() {
    reset
    header "$MSG_CREATE_SNAPSHOT_HEADER"

    ask "$MSG_SNAPSHOT_NAME" snapshot_name

    if [ -z "$snapshot_name" ]; then
        error "$MSG_SNAPSHOT_EMPTY"
        pausar
        return
    fi

    info "$(printf "$MSG_CREATING_SNAPSHOT" "${snapshot_name}")"
    snapper create --description "${snapshot_name}"

    if [ $? -eq 0 ]; then
        snapper list
        success "$MSG_SNAPSHOT_CREATED"
        info "$MSG_UPDATING_REFIND"
        refind-btrfs
        if [ $? -eq 0 ]; then
            success "$MSG_REFIND_UPDATED"
        else
            error "$MSG_REFIND_UPDATE_FAILED"
        fi
    else
        error "$MSG_SNAPSHOT_FAILED"
    fi
    pausar
}

# Menu principal
menu_principal() {
    header "$MSG_WELCOME"
    echo -e "${GREEN}1)${NC} $MSG_ADD_BOOT"
    echo -e "${GREEN}2)${NC} $MSG_CONFIG_BTRFS"
    echo -e "${GREEN}3)${NC} $MSG_EDIT_REFIND"
    echo -e "${GREEN}4)${NC} $MSG_EDIT_BTRFS_CONF"
    echo -e "${GREEN}5)${NC} $MSG_RESTORE_REFIND"
    echo -e "${GREEN}6)${NC} $MSG_RESTORE_BTRFS"
    echo -e "${GREEN}7)${NC} $MSG_CREATE_SNAPSHOT"
    echo -e "${RED}8)${NC} $MSG_EXIT"
    echo -e "${LIGHT_CYAN}==========================================================${NC}"
    ask "$MSG_CHOOSE_OPTION" opcao
}

# Execução principal
LANG=$(detect_language)
load_strings
check_root

while true; do
    clear
    menu_principal
    case $opcao in
    1) adiciona_boot_stanza ;;
    2) configure_refind_btrfs ;;
    3) editar_refind_conf ;;
    4) editar_refind_btrfs_conf ;;
    5) restaurar_backup_refind ;;
    6) restaurar_backup_refind_btrfs ;;
    7) criar_snapshot_btrfs ;;
    8)
        info "$MSG_EXITING"
        exit 0
        ;;
    *) error "$MSG_INVALID_OPT" ;;
    esac
done
