if exists('g:loaded_sync') | finish | endif
let g:loaded_sync = 1

function Sync(transfer_type)
    if !exists("g:sync_local")
        echomsg "Sync não configurado"
        return
    endif

    if a:transfer_type == 'up'
        let orig = expand("%:p")
        let dest = substitute(orig, g:sync_local, g:sync_remote, "")

        if exists("g:sync_user")
            let dest = g:sync_user . '@' . g:sync_server . ':' . desc
        endif

        let msg = "Upload: " . orig . " -> " . dest
    elseif a:transfer_type == 'down'
        let dest = expand("%:p")
        let orig = substitute(dest, g:sync_local, g:sync_remote, "")

        if exists("g:sync_user")
            let orig = g:sync_user . '@' . g:sync_server . ':' . orig
        endif

        let msg = "Download: " . dest . " <- " . orig
    endif

    let command2exec  = ":!scp"

    if exists("g:sync_port")
        let command2exec .= " -P " . g:sync_port
    endif

    let command2exec .= " '" . orig . "'"
    let command2exec .= " '" . dest . "'"

    let command2exec .= ""

    echomsg msg
    execute command2exec
endfunction

command SyncUp call Sync('up')
command SyncDown call Sync('down')
