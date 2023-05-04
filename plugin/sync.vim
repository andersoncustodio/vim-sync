if exists('g:loaded_sync') | finish | endif
let g:loaded_sync = 1

if !exists("g:sync_permission")
    let g:sync_permission = "755"
endif

function Sync(transfer_type)
    if !exists("g:sync_local")
        echomsg "Sync não configurado"
        return
    endif

    let g:sync_transfer_type = a:transfer_type

    if g:sync_local[-1:] != '/' | let g:sync_local .= '/' | endif
    if g:sync_remote[-1:] != '/' | let g:sync_remote.= '/' | endif

    if a:transfer_type == 'up'
        let orig = expand("%:p")
        let dest = substitute(orig, g:sync_local, g:sync_remote, "")

        let msg = "Upload: -> " . dest
    elseif a:transfer_type == 'down'
        let dest = expand("%:p")
        let orig = substitute(dest, g:sync_local, g:sync_remote, "")

        let msg = "Download: <- " . orig
    endif

    let command2exec = ""

    if exists("g:sync_password") && !empty(g:sync_password)
        let command2exec .= "sshpass -p'" . g:sync_password . "' "
    endif

    let command2exec .= "rsync -a"

    if exists("g:sync_permission") && !empty(g:sync_permission)
        let command2exec .= " --chmod=" . g:sync_permission
    endif

    " SSH config
    let command2exec .= " -e 'ssh"
    let command2exec .= " -o controlmaster=auto"
    let command2exec .= " -o controlpersist=yes"
    let command2exec .= " -o controlpath=/tmp/ssh-%r@%h:%p"

    if exists("g:sync_port")
        let command2exec .= " -p " . g:sync_port
    endif

    let command2exec .= "'"

    let command2exec .= " '" . orig . "'"
    let command2exec .= " '" . dest . "'"

    let command2exec .= ""

    function! s:handler(job_id, data, event_type)
        if a:event_type == 'exit'
            if a:data > 0
                redraw | echo a:data
            else
                if g:sync_transfer_type == 'down'
                    update | e
                endif

                redraw | echo
            endif
        endif
    endfunction

    let jobid = async#job#start(command2exec, {
        \ 'on_exit': function('s:handler')
        \ })

    if jobid == 0
       redraw | echomsg 'Fail sync'
    endif

    redraw | echomsg msg
endfunction

function SyncConfig()
    let local = getcwd() . '/'

    let question = input(' Deseja configurar o sync no diretório a seguir? ' . local . ' [Yes|No]: ')

    if question != "Yes" | redraw | echomsg 'Configuração do sync não foi relizada' | return | endif

    let remote = input('Remote: ')

    let port = input('Port Number: ')

    let dir_config = local . '/.vim'

    if !isdirectory(dir_config) | call mkdir(dir_config, 'p') | endif

    let sync_file_config = dir_config . '/sync-config.vim'

    let sync_config  = ['let g:sync_local    = "' . local . '"']
    let sync_config += ['let g:sync_remote   = "' . remote . '"']

    let g:sync_local = local
    let g:sync_remote = remote

    if port
        let sync_config += ['let g:sync_port     = '. port]
        let g:sync_port = port
    endif

    call writefile(sync_config, sync_file_config, 'a')
endfunction

command SyncUp call Sync('up')
command SyncDown call Sync('down')
command SyncConfig call SyncConfig()
