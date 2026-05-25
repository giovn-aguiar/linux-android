# Política de Segurança

Valorizamos a segurança do projeto **Cyberdeck: Linux no Android**. Se você descobrir uma vulnerabilidade de segurança neste ecossistema, encorajamos fortemente que nos avise de forma privada para que possamos corrigir o problema o mais rápido possível.

---

## Versões Suportadas

Apenas a versão mais recente do repositório recebe atualizações de segurança de forma ativa.

| Versão | Suportada |
| :--- | :--- |
| **Atual (Main)** | Sim |
| **< Antigas** | Não |

---

## Como Reportar uma Vulnerabilidade

>  **Por favor, NÃO abra uma Issue pública para relatar falhas de segurança.**

## Como Reportar uma Vulnerabilidade

Se você encontrar um problema que possa comprometer a integridade do dispositivo do usuário, siga os passos abaixo:

1. **Vulnerabilidades Críticas:** 
   * Pedimos que **não** publique um passo a passo detalhado (exploit) diretamente no fórum público para evitar que a falha seja explorada maliciosamente antes de ser corrigida.
   * Abra uma **Issue aqui no GitHub** descrevendo o problema de forma clara e organizada (ex: *"Falha encontrada na validação do parâmetro X do script de instalação"*) e informe que possui os detalhes da correção.

2. **Bugs de Segurança Simples ou Configurações Inseguras:**
   * Podem ser discutidos diretamente na aba de **Issues** deste repositório ou no canal de fórum do Discord da comunidade, idealmente já propondo uma solução ou *Pull Request* para corrigir o problema.

---

## Considerações Importantes 

Este projeto roda em modo *rootless* (sem root) dentro do espaço de usuário do Android através do Termux e PRoot. Isso significa que:
* O ambiente Linux está isolado dentro do armazenamento do Termux, mitigando riscos de danificar o sistema operacional nativo do celular.
* No entanto, qualquer script ou programa executado dentro do ambiente Linux tem acesso à internet e às permissões que o usuário concedeu ao Termux (como acesso ao armazenamento interno). Tenha cuidado ao rodar códigos de terceiros dentro do seu Cyberdeck.
