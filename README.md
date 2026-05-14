# Projeto Android Linux - Termux

## Descrição

Script de configuração automatizada para instalar e gerenciar um ambiente Linux completo no Termux.

## Recursos

- Detecção automática do dispositivo e GPU
- Suporte a múltiplos ambientes desktop (XFCE4, LXQt, MATE, KDE)
- Aceleração gráfica otimizada por GPU
- Instalação simplificada e automatizada
- Compatibilidade com smartphones e tablets

## Ambientes Desktop Suportados

| Desktop | Peso | Recomendação |
|---------|------|--------------|
| XFCE4   | Médio | Recomendado |
| LXQt    | Leve | Para dispositivos antigos |
| MATE    | Médio | Alternativa estável |
| KDE     | Pesado | Para dispositivos poderosos |

## Instalação

1. Instale o [Termux](https://f-droid.org/pt_BR/packages/com.termux/) do F-Droid
2. Abra o Termux e dê permissões para acesso ao armazenamento do celular:
```
termux-setup-storage
```
3. Desbloqueie o modo Desenvolvedor no seu aparelho
4. Em 'Opções do Desenvolvedor' desabilite a opção 'Desativar restrições de processos filhos' (ou 'Disable child process restrictions')
5. Instale o git:
```
apt install git
```
6. Clone este repositório:
```
git clone https://github.com/lucasaguiar-la/linux-android.git
```
7. Após execute:
```
# Acessa a pasta clonada
cd linux-android

# Da permissões para executar o script
chmod +x script-termux.sh

# Executa o script de instalação
./script-termux.sh
```
8. Selecione o ambiente desktop desejado
9. Aguarde a instalação ser concluída
10. Rode o script:
```
# Navegue para a home
cd

# Execute o script
./start-linux.sh
```
11. Instale o [Termux X11](https://github.com/termux/termux-x11/releases/tag/nightly) para acessar a interface gráfica
12. Abra o Termux X11 e o provedor gráfico já estará funcionando

## Detecção de Hardware

O script detecta automaticamente:
- **Marca do dispositivo**: Samsung, Xiaomi, etc.
- **GPU**: Adreno (Samsung/Qualcomm) ou genérica
- **Driver gráfico**: Freedom ou Zink (compatibilidade)

## Requisitos

- Android 5.0+
- Termux instalado
- Termux: X11
- ~2GB de espaço livre
- Conexão com internet

## Notas

- Use XFCE4 para melhor equilíbrio entre performance e funcionalidade
- Dispositivos antigos: prefira LXQt
- Dispositivos topo de linha: experimente KDE
- Para executar automatizamente o `./start-linux.sh` toda vez que abrir o Termux, faça o seguinte:
```
nano ~/.bashrc

# Cole o conteúdo abaixo:
./start-linux.sh
```

## Licença

MIT
