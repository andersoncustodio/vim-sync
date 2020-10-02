if exists('g:loaded_sync') | finish | endif
let g:loaded_sync = 1

function Sync(transfer_type)
    if !exists("g:sync_local")
        echomsg "Sync não configurado"
        return
    endif

    if g:sync_local[-1:] != '/' | let g:sync_local .= '/' | endif
    if g:sync_remote[-1:] != '/' | let g:sync_remote.= '/' | endif

    if a:transfer_type == 'up'
        let orig = expand("%:p")
        let dest = substitute(orig, g:sync_local, g:sync_remote, "")

        let msg = "Upload: " . orig . " -> " . dest
    elseif a:transfer_type == 'down'
        let dest = expand("%:p")
        let orig = substitute(dest, g:sync_local, g:sync_remote, "")

        let msg = "Download: " . dest . " <- " . orig
    endif

    let command2exec = ""

    if exists("g:sync_password") && !empty(g:sync_password)
        let command2exec .= "sshpass -p'" . g:sync_password . "' "
    endif

    let command2exec .= "scp"

    if exists("g:sync_port")
        let command2exec .= " -P " . g:sync_port
    endif

    let command2exec .= " '" . orig . "'"
    let command2exec .= " '" . dest . "'"

    let command2exec .= ""

    echomsg msg

    let output = system(command2exec)

    redraw | echo

    if v:shell_error != 0
        echo output
    else
        if a:transfer_type == 'down'
            update | e
        endif
    endif
endfunction

function SyncConfig()
    let local = expand("%:p:h") . '/'

    let question = input(' Deseja configurar o sync no diretório a seguir? ' . local . ' [Yes|No]: ')

    if question != "Yes" | redraw | echomsg 'Configuração do sync não foi relizada' | return | endif

    let remote = input('Remote: ')

    let port = input('Port Number: ')

    let dir_config = local . '/.vim'

    if !isdirectory(dir_config) | call mkdir(dir_config, 'p') | endif

    let sync_file_config = dir_config . '/sync-config.vim'

    let sync_config  = ['let g:sync_local    = "' . local . '"']
    let sync_config += ['let g:sync_remote   = "' . remote . '"']

    if port
        let sync_config += ['let g:sync_port     = '. port]
    endif

    call writefile(sync_config, sync_file_config, 'a')
endfunction

command SyncUp call Sync('up')
command SyncDown call Sync('down')
command SyncConfig call SyncConfig()
