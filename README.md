# Termux Linux-Android Suite

Transforme seu Android em um desktop Linux completo usando Termux + Termux-X11 com um script modular, interativo e biligue (PT-BR / EN).

> **Creditos**: Este projeto e um fork do repositorio de [giovn-aguiar](https://github.com/giovn-aguiar/linux-android), que por sua vez e um fork do projeto original de [Lucas Aguiar](https://github.com/lucasaguiar-la/linux-android). Esta versao estende o conceito original para uma suite modular completa.

---

## Indice

- [Recursos](#recursos)
- [Tutorial de Instalacao](#tutorial-de-instalacao)
- [Uso por Linha de Comando](#uso-por-linha-de-comando)
- [Aplicativos Disponiveis](#aplicativos-disponiveis)
- [Aplicativos Futuros](#aplicativos-futuros)
- [Desktops Suportados](#desktops-suportados)
- [Arquitetura do Projeto](#arquitetura-do-projeto)
- [FAQ e Solucao de Problemas](#faq-e-solucao-de-problemas)
- [Creditos e Licenca](#creditos-e-licenca)

---

## Recursos

- **Menu interativo no terminal** com submenus para cada funcionalidade
- **Biligue** (Portugues / English) com deteccao automatica do idioma do sistema
- **Instalacao modular** - instale, remova ou troque desktops e apps individualmente
- **Catalogo de apps** editavel (`apps.conf`) organizado por categoria
- **Configuracao de GPU** automatica (Adreno/Freedreno) ou manual
- **Temas e personalizacao** - temas escuros, icones, fontes, wallpapers
- **Wine/Hangover** para rodar apps Windows em ARM64
- **Backup e restauracao** de todas as configuracoes
- **Diagnostico** de integridade e visualizacao de logs

---

## Tutorial de Instalacao

### Pre-requisitos

1. **Termux** instalado (versao do [F-Droid](https://f-droid.org/packages/com.termux/) ou [GitHub](https://github.com/termux/termux-app/releases) - NAO use a versao da Play Store, ela esta desatualizada)
2. **Termux-X11** instalado ([GitHub Releases](https://github.com/nicknisi/termux-x11/releases))
3. Conexao com a internet

### Passo 1: Preparar o Termux

Abra o Termux e atualize os pacotes:

```bash
pkg update -y && pkg upgrade -y
```

### Passo 2: Instalar o Git

```bash
pkg install -y git
```

### Passo 3: Clonar o projeto

```bash
git clone https://github.com/eobarretooo/linux-android.git
cd linux-android
```

### Passo 4: Dar permissao de execucao

```bash
chmod +x script-termux.sh
```

### Passo 5: Rodar o script

```bash
./script-termux.sh
```

Na primeira execucao, o script ira:

1. Pedir para selecionar o **idioma** (Portugues ou English)
2. Abrir o **menu principal** com todas as opcoes

### Passo 6: Instalacao Completa (Opcao 1 do menu)

Ao selecionar "Instalacao Completa", o script faz tudo automaticamente:

| Etapa | O que acontece |
|-------|----------------|
| 1 | Prepara o ambiente e corrige pacotes pendentes |
| 2 | Atualiza o sistema (`pkg update && upgrade`) |
| 3 | Adiciona repositorios (`x11-repo`, `tur-repo`) |
| 4 | Instala o servidor grafico (Termux-X11) |
| 5 | Instala o desktop escolhido (XFCE4, LXQt, MATE ou KDE) |
| 6 | Configura drivers de GPU |
| 7 | Instala audio (PulseAudio) |
| 8 | Instala apps e utilitarios basicos |
| 9 | Configura Wine/Hangover (opcional) |
| 10 | Cria scripts de start/stop/info |
| 11 | Cria atalhos no desktop |

### Passo 7: Iniciar o desktop

Depois da instalacao, basta rodar:

```bash
~/start-linux.sh
```

E abrir o app **Termux-X11** no seu celular para ver a interface grafica.

Para parar:

```bash
~/stop-linux.sh
```

Para ver o diagnostico:

```bash
~/linux-info.sh
```

---

## Uso por Linha de Comando

Alem do menu interativo, voce pode usar flags para automatizar:

```bash
# Mostra ajuda
./script-termux.sh --help

# Forca idioma
./script-termux.sh --lang en

# Instalacao completa automatizada
./script-termux.sh --install

# Instala apenas um desktop especifico
./script-termux.sh --desktop xfce4

# Instala um app do catalogo
./script-termux.sh --app firefox
```

---

## Aplicativos Disponiveis

Estes sao os apps que vem no catalogo (`apps.conf`) e podem ser instalados pelo menu:

### Navegadores

| App | Pacote | Descricao |
|-----|--------|-----------|
| Firefox | `firefox` | Navegador completo com suporte a extensoes |
| Chromium | `chromium` | Navegador baseado no motor do Chrome |

### Editores de Codigo

| App | Pacote | Descricao |
|-----|--------|-----------|
| Code OSS | `code-oss` | VS Code open-source para Termux |
| Neovim | `neovim` | Editor de texto avancado no terminal |
| Nano | `nano` | Editor simples para terminal |
| Micro | `micro` | Editor moderno para terminal com mouse |

### Ferramentas de Desenvolvimento

| App | Pacote | Descricao |
|-----|--------|-----------|
| Git | `git` | Controle de versao |
| Python | `python` | Linguagem Python 3 + pip |
| Node.js | `nodejs` | Runtime JavaScript + npm |
| Clang | `clang` | Compilador C/C++ |
| Rust | `rust` | Linguagem Rust + cargo |
| Go | `golang` | Linguagem Go |
| Ruby | `ruby` | Linguagem Ruby + gem |

### Multimidia

| App | Pacote | Descricao |
|-----|--------|-----------|
| VLC | `vlc` | Player de video e audio universal |
| MPV | `mpv` | Player leve de video |
| GIMP | `gimp` | Editor de imagens profissional |
| FFmpeg | `ffmpeg` | Conversor e encoder de midia |

### Utilitarios

| App | Pacote | Descricao |
|-----|--------|-----------|
| Neofetch | `neofetch` | Mostra info do sistema com estilo |
| htop | `htop` | Monitor de processos interativo |
| tmux | `tmux` | Multiplexador de terminal |
| Thunar | `thunar` | Gerenciador de arquivos grafico |
| Ranger | `ranger` | Gerenciador de arquivos no terminal |
| bat | `bat` | Substituto do `cat` com syntax highlight |
| ripgrep | `ripgrep` | Busca rapida em arquivos (substituto do grep) |
| fzf | `fzf` | Buscador fuzzy interativo |
| zip/unzip | `zip unzip` | Compactador/descompactador ZIP |
| tar | `tar` | Compactador/descompactador TAR |

### Rede

| App | Pacote | Descricao |
|-----|--------|-----------|
| curl | `curl` | Transferencia de dados via URL |
| wget | `wget` | Download de arquivos |
| OpenSSH | `openssh` | Cliente e servidor SSH |
| Nmap | `nmap` | Scanner de rede e portas |
| WoL | `wol` | Wake-on-LAN para ligar PCs remotamente |
| iproute2 | `iproute2` | Ferramentas de rede (ip, ss, etc) |

---

## Aplicativos Futuros

Estes apps ja funcionam ou tem potencial para funcionar bem no Termux com X11, e podem ser adicionados ao catalogo no futuro:

### Produtividade e Escritorio

| App | Pacote | Status | Notas |
|-----|--------|--------|-------|
| LibreOffice | `libreoffice` | Funcional | Suite de escritorio completa (pesado, ~500MB) |
| Thunderbird | `thunderbird` | Funcional | Cliente de email |
| Evince | `evince` | Funcional | Leitor de PDF leve |
| Zathura | `zathura` | Funcional | Leitor de PDF minimalista |
| Galculator | `galculator` | Funcional | Calculadora grafica |
| Mousepad | `mousepad` | Funcional | Editor de texto simples (XFCE) |

### Desenvolvimento

| App | Pacote | Status | Notas |
|-----|--------|--------|-------|
| MariaDB | `mariadb` | Funcional | Banco de dados SQL |
| PostgreSQL | `postgresql` | Funcional | Banco de dados avancado |
| Redis | `redis` | Funcional | Cache e banco NoSQL |
| SQLite | `sqlite` | Funcional | Banco de dados em arquivo |
| PHP | `php` | Funcional | Linguagem web + composer |
| Perl | `perl` | Funcional | Linguagem de script |
| Lua | `lua54` | Funcional | Linguagem leve e rapida |
| CMake | `cmake` | Funcional | Sistema de build |
| Meson | `meson` | Funcional | Sistema de build moderno |
| Docker (via proot) | N/A | Experimental | Precisa de proot-distro |

### Multimidia (Futuro)

| App | Pacote | Status | Notas |
|-----|--------|--------|-------|
| Inkscape | `inkscape` | Funcional | Editor de vetores SVG |
| Audacity | N/A | Experimental | Editor de audio (precisa compilar) |
| OBS Studio | N/A | Nao funcional | Precisa de GPU real e pipewire |
| Blender | N/A | Nao funcional | Muito pesado para Android |
| ImageMagick | `imagemagick` | Funcional | Manipulacao de imagens via CLI |

### Rede e Seguranca

| App | Pacote | Status | Notas |
|-----|--------|--------|-------|
| Wireshark (tshark) | `tshark` | Funcional | Analise de pacotes de rede (CLI) |
| Hydra | `hydra` | Funcional | Teste de forca bruta |
| John the Ripper | `john` | Funcional | Cracker de senhas |
| Aircrack-ng | `aircrack-ng` | Funcional | Suite de auditoria WiFi |
| Metasploit | N/A | Via proot | Framework de pentesting |
| SQLMap | `python` + pip | Funcional | Teste de injecao SQL |
| Nikto | `perl` + git | Funcional | Scanner de vulnerabilidades web |

### Terminais e Shells

| App | Pacote | Status | Notas |
|-----|--------|--------|-------|
| Zsh | `zsh` | Funcional | Shell avancado |
| Fish | `fish` | Funcional | Shell amigavel com autocomplete |
| Oh My Zsh | via curl | Funcional | Framework de configuracao do Zsh |
| Starship | `starship` | Funcional | Prompt customizavel multi-shell |
| Alacritty | `alacritty` | Funcional | Terminal acelerado por GPU |

> **Como adicionar novos apps**: Edite o arquivo `apps.conf` seguindo o formato `categoria|Nome|pacote`. O app vai aparecer automaticamente no menu.

---

## Desktops Suportados

| Desktop | Peso | Estabilidade | Recomendacao |
|---------|------|-------------|--------------|
| **XFCE4** | Leve (~150MB) | Muito estavel | Recomendado para todos |
| **LXQt** | Muito leve (~120MB) | Estavel | Bom para dispositivos fracos |
| **MATE** | Medio (~200MB) | Estavel | Para quem prefere estilo GNOME 2 |
| **KDE Plasma** | Pesado (~400MB) | Experimental | Bonito mas pode travar em devices fracos |

---

## Arquitetura do Projeto

```
linux-android/
|-- script-termux.sh          # Ponto de entrada principal
|-- apps.conf                  # Catalogo de apps editavel
|-- lang/
|   |-- pt.sh                 # Strings em Portugues
|   |-- en.sh                 # Strings em English
|-- lib/
    |-- common.sh             # Cores, logs, spinner, helpers
    |-- i18n.sh               # Sistema de traducao
    |-- checks.sh             # Validacoes de ambiente
    |-- device.sh             # Deteccao de hardware/GPU
    |-- desktop.sh            # Gerenciamento de desktops
    |-- apps.sh               # Instalacao de apps do catalogo
    |-- wine.sh               # Gerenciamento de Wine/Hangover
    |-- themes.sh             # Temas, icones, fontes, wallpapers
    |-- scripts.sh            # Geracao de start/stop/info scripts
    |-- backup.sh             # Backup e restauracao
    |-- menu.sh               # Sistema de menus interativos
```

---

## FAQ e Solucao de Problemas

### "Tela preta ao abrir o Termux-X11"

- Rode `~/stop-linux.sh` e depois `~/start-linux.sh` novamente
- Se persistir, va em **Menu > GPU > Desativar aceleracao** e reinicie

### "Termux-X11 nao abre / app nao instalado"

- Instale o APK do Termux-X11 pelo [GitHub](https://github.com/nicknisi/termux-x11/releases)
- O script instala o pacote `termux-x11` interno, mas o app Android precisa ser instalado manualmente

### "Sem audio"

- Va em **Menu > Audio > Reinstalar PulseAudio**
- Depois rode `~/stop-linux.sh` e `~/start-linux.sh`

### "Wine nao funciona"

- Wine/Hangover so funciona em dispositivos **ARM64 (aarch64)**
- Rode `uname -m` para verificar sua arquitetura

### "Erro de dpkg travado"

- O script detecta isso automaticamente e espera ate 90 segundos
- Se persistir, rode manualmente: `dpkg --configure -a`

### "Quero adicionar um app novo"

Edite o arquivo `apps.conf`:

```
# Formato: categoria|Nome|pacote
utilities|Meu App|meu-pacote
```

O app aparece automaticamente no menu na proxima execucao.

### "Quero trocar de desktop"

Va em **Menu > Configurar Desktop > Trocar ambiente** e selecione o novo. O anterior nao e removido automaticamente.

---

## Creditos e Licenca

- **Projeto original**: [Lucas Aguiar - linux-android](https://github.com/lucasaguiar-la/linux-android)
- **Fork intermediario**: [giovn-aguiar - linux-android](https://github.com/giovn-aguiar/linux-android)
- **Versao modular**: Extensao com menus, i18n, catalogo de apps e sistema de backup
- **Licenca**: MIT

---

> Feito para quem quer um Linux de verdade no bolso.
