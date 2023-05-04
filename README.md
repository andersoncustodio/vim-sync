Super simple plugin in development phase that uses the `rsync` command for
Download or upload the file being edited.

### Configuration
    let g:sync_port   = 22
    let g:sync_local  = '/local/path'
    let g:sync_remote = 'user@server:/server/path'
    let g:sync_permission = 755

    " Only use if the world is ending, always use SSH keys
    let g:sync_password = 'Password'
