Plugin super simples em fase de desenvolvimento que utiliza o comando `scp` para
fazer download ou upload no arquivo que está sendo editado

### Configuração
    let g:sync_port   = 22
    let g:sync_local  = '/local/path'
    let g:sync_remote = 'user@server:/server/path'

    " Utilize apenas se o mundo estiver acabando, sempre utilize chaves SSH
    let g:sync_password = 'senha'
