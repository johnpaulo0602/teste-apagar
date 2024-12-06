## Configuração do Wallet

#### Para Implantar o Wallet você pode utilizar o makefile

#### Explicação dos comandos do makefile

#### Make applyTerraform

Aplica o terraform do Wallet

#### Make applyIngressRoute

Aplica o IngressRoute do wallet e tem como dependência o terraform do Wallet

#### destroyTerraform

Remove as nodePools que aplicadas anteriormente

## Recursos do Terraform do wallet
| Resource | Provider | Name |  
|------|------|------|
| Wallet helm | Helm | wallet |
| cloudflare_record | Cloudflare | stg-wallet |
