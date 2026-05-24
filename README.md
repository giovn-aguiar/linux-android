# Cyberdeck: Linux no Android

<div align="center">

![GitHub repo size](https://img.shields.io/github/repo-size/giovn-aguiar/linux-android?style=for-the-badge&color=8A2BE2)
![GitHub language count](https://img.shields.io/github/languages/count/giovn-aguiar/linux-android?style=for-the-badge&color=8A2BE2)
![GitHub forks](https://img.shields.io/github/forks/giovn-aguiar/linux-android?style=for-the-badge&color=8A2BE2)
![GitHub issues](https://img.shields.io/github/issues/giovn-aguiar/linux-android?style=for-the-badge&color=8A2BE2)

<img src="image.png" alt="Cyberdeck Banner" width="100%">

> *Cyberdecks são computadores portáteis personalizados inspirados em ficção científica, cultura hacker e estética cyberpunk. Este projeto transforma seu Android em uma central Linux portátil.*

</div>

---

##  Índice
- [Sobre o Projeto](#sobre-o-projeto)
- [Pré-requisitos](#️pré-requisitos)
- [Instalação automática](instalação-automatica)
- [Instalação e Configuração](#instalação-e-configuração)
- [Ambientes Gráficos Suportados](#ambientes-gráficos-suportados)
- [Script](#otimização-automática)
- [Inicialização](#inicialização-automática)
- [Licença](#licença)

---

## Sobre o Projeto
Este script foi desenvolvido para automatizar a instalação de uma distribuição Linux completa com interface gráfica dentro do ambiente Termux no Android. A proposta é dar vida a um **Cyberdeck**, aproveitando ao máximo o hardware do seu dispositivo.

---

## Pré-requisitos

> **Nota:** Na criação de um cyberdeck não existem regras — você pode criar utilizando desde um celular antigo até uma TV Box. Os requisitos abaixo servem como base para a nossa stack:

*   **Dispositivo:** Android 5.0+ com conexão à internet.
*   **Espaço em Disco:** Mínimo de **2 GB livres** de armazenamento interno.
*   **Periféricos:** Teclado, mouse e um Hub USB/OTG.
*   **Software:** Versão mais recente do [Termux via F-Droid](https://f-droid.org/packages/com.termux/).
*   **Principal:** Muita criatividade.

---

## Instalação automática

Para uma configuração rápida, você pode rodar o instalador passando o ambiente gráfico desejado diretamente como parâmetro. Caso queira seguir com a instalação manual siga para [instalação e configuração](instalacao-e-configuracao).
> Verifique se o arquivo script-installation.sh está baixado e no diretório certo.

Verificar a integridade do script:

```bash
ls
```
Deverá mostrar as pastas do sistema, ao baixar veja se o arquivo está na pasta Download ou em outra.

```bash
cd Downloads/
```

Execute o comando abaixo no seu Termux:

```bash
bash ~/script-instalation.sh <parametro>

```

### Parâmetros disponíveis:

* `xfce4`
* `lxqt`
* `mate`
* `kde`

>  **Comportamento do Script:**
> * Se nenhum parâmetro for passado, o script abrirá um menu interativo para você escolher a interface.
> * Se um parâmetro inválido ou inexistente for digitado, o script adotará o `xfce4` como padrão automaticamente e seguirá com a instalação.
> 
> 

Exemplo de uso:

```bash
bash ~/script-instalation.sh xfce4

```

---

## Instalação e Configuração

Siga os passos abaixo na ordem indicada para configurar o seu ambiente de forma correta:

### Passo 1: Preparação do Android
Antes de abrir o script, precisamos ajustar as permissões e o sistema operacional:
1. Abra o **Termux** e libere o acesso ao armazenamento interno executando:
```bash
   termux-setup-storage
```

2. Ative o **Modo Desenvolvedor** no seu aparelho Android.
3. Nas *Opções do Desenvolvedor*, procure por **"Desativar restrições de processos filhos"** (*Disable child process restrictions*) e **desative-a**. Isso evita que o Android feche o Linux em segundo plano.

### Passo 2: Instalação do Script

Agora vamos clonar o repositório e rodar o instalador:

```bash
# Instala o git no Termux
pkg update && pkg install git -y

# Clona o repositório do projeto
git clone [https://github.com/lucasaguiar-la/linux-android.git](https://github.com/lucasaguiar-la/linux-android.git)

# Acessa a pasta clonada
cd linux-android

# Concede permissão de execução ao script
chmod +x script-termux.sh

# Executa o instalador
./script-termux.sh

```

4. Durante a execução, selecione o ambiente desktop de sua preferência (veja a tabela abaixo) e aguarde a conclusão.

### Passo 3: Inicialização e Interface Gráfica

Para renderizar a interface visual do Linux, usaremos o servidor gráfico do Termux:

1. Baixe e instale o [Termux X11 (Versão Nightly)](https://www.google.com/search?q=https://github.com/termux/termux-x11/releases/tag/nightly) no seu Android.
2. No Termux, inicie o ambiente Linux rodando:

```bash
   cd && ./start-linux.sh

```

3. Abra o aplicativo **Termux X11** que você instalou. A interface gráfica do Linux já estará rodando!

---

## Ambientes Gráficos Suportados

| Ambiente | Performance | Recomendação de Uso |
| --- | --- | --- |
| **XFCE4** | 🟢 Média | **Recomendado**. |
| **LXQt** | 🟢 Muito Leve | Ideal para dispositivos fracos. |
| **MATE** | 🟡 Média | Alternativa estável. |
| **KDE** | 🔴 Pesado | Visual moderno e completo. Indicado apenas para dispositivos topo de linha. |

---

## Script

O script possui um sistema inteligente de detecção de hardware que configura o ecossistema de forma otimizada para o seu chip:

* **Hardware:** Identificação automática da marca (Samsung, Xiaomi, etc.).
* **Gráficos:** Detecção de GPUs Adreno (Qualcomm) ou genéricas.
* **Drivers:** Seleção automática entre os drivers gráficos *Freedom* ou *Zink* para máxima compatibilidade e aceleração de hardware.

---

## Inicialização

Se você quer transformar seu dispositivo de forma definitiva em um Cyberdeck e deseja que o Linux inicie **automaticamente** assim que você abrir o Termux, siga estes passos:

```bash
# Abre o arquivo de configuração do terminal
nano ~/.bashrc

```

Adicione a seguinte linha ao final do arquivo:

```bash
./start-linux.sh

```

Salve o arquivo (`CTRL + O`, depois `Enter`) e saia (`CTRL + X`).

---

## FAQ

Aqui estão as respostas para as dúvidas mais comuns sobre o projeto. Clique na pergunta para expandir.

<details>
<summary><b>1. Consigo rodar o VS Code, Chrome ou programas pesados nesse ambiente?</b></summary>
<br>
O VS Code (versão OSS para ARM64) e navegadores como o Chromium rodam, mas o desempenho depende diretamente do processador e da RAM do seu Android. Dispositivos com menos de 4GB de RAM podem sofrer travamentos ao abrir muitos apps ao mesmo tempo.
</details>

<details>
<summary><b>2. O projeto precisa de ROOT no celular?</b></summary>
<br>
<b>Não!</b> O script foi projetado para rodar completamente em modo <i>rootless</i> (sem root) usando o PRoot para emular o sistema de arquivos Linux. Isso garante que qualquer aparelho saia de fábrica pronto para virar um Cyberdeck sem riscos de segurança.
</details>

<details>
<summary><b>3. Por que meu Linux fecha sozinho depois de alguns minutos?</b></summary>
<br>
Isso geralmente acontece porque o sistema de gerenciamento de bateria do Android (especialmente em interfaces como MIUI, OneUI ou em aparelhos Android 12+) "mata" processos em segundo plano. Certifique-se de seguir o <b>Passo 1 (Desativar restrições de processos filhos)</b> na seção de Instalação para corrigir isso. Vale ressaltar que o Termux e Termux X11 você deve verificar a <b>restrição de uso de bateria</b>. Geralmente fica em <b>Economia de bateria</b> (Battery saver), mude para <b>Sem restrições</b> (No restrictions).
</details>

<details>
<summary><b>4. Posso instalar jogos da Steam ou apps de PC normal (.exe ou x86)?</b></summary>
<br>

Nativamente não, porque o seu Android usa um processador de arquitetura <b>ARM</b>, e a maioria dos softwares de PC comuns são feitos para arquitetura <b>x86/x64</b>. Para rodar programas x86, você precisaria configurar ferramentas de tradução como o <i>Box64</i> ou <i>Fex-Emu</i> dentro do ambiente. Entretanto, isso não lhe impedi de testar jogos de plataformas como <b>Steam, Heroic, Epic Games, etc</b> e análisar o seu desempenho (recomendo compartilhar sua experiência com a comunidade), os principais problemas que você deve encontrar é seu processador, memória RAM, armazenamento interno, etc.
</details>

<details>
<summary><b>5. O som e o microfone funcionam dentro do Linux?</b></summary>
<br>
Para o áudio funcionar, é necessário configurar o servidor PulseAudio no Termux. O script atual foca na estabilidade do ambiente gráfico.
</details>

<details>
<summary><b>6. Qual a diferença entre usar o modo DeX, uma Custom ROM ou este Cyberdeck?</b></summary>
<br>

Se você quer usar o Android como um computador, existem três caminhos principais. Cada um oferece um nível diferente de controle, liberdade e conhecimento técnico:

*   <b>Samsung DeX (e similares):</b> É apenas uma "roupagem" visual (Launcher) oficial sobre o próprio Android. Os aplicativos ainda são os apps normais do celular (<code>.apk</code>). É estável, mas totalmente limitado às regras da fabricante. Você não tem um terminal Linux real nem pode instalar pacotes via <code>apt</code> ou outro Gerenciador de Pacotes.
*   <b>Custom ROM (Ex: LineageOS):</b> Uma Custom ROM é uma versão do Android modificada por desenvolvedores e entusiastas que oferece uma experiência adaptada e otimizada. Essas ROMs trazem recursos ausentes nas builds oficiais dos fabricantes, como melhorias de desempenho, novas funções, interfaces personalizadas e a possibilidade de remover apps pré‑instalados indesejados.
*   <b>Cyberdeck:</b> Roda um Linux completo e independente <b>lado a lado</b> com o seu Android atual através de emulação no espaço de usuário (usando <code>PRoot</code> e <code>Termux X11</code>). O risco é **zero** (não precisa de root), você mantém as funções do celular intactas e ganha total liberdade de um ecossistema Linux real.

<br>

<table width="100%">
    <thead>
        <tr align="left">
            <th>Característica</th>
            <th>Samsung DeX</th>
            <th>Custom ROM</th>
            <th>Cyberdeck</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><b>Risco de quebrar o aparelho</b></td>
            <td>⚪ Nenhum</td>
            <td>🔴 Risco de <i>Brick</i></td>
            <td>⚪ Nenhum</td>
        </tr>
        <tr>
            <td><b>Exige modificação avançada</b></td>
            <td>Não (Nativo apenas para Samsung)</td>
            <td>Sim (Desbloquear Bootloader)</td>
            <td>Não (Apenas instalar apps)</td>
        </tr>
        <tr>
            <td><b>O que roda por baixo</b></td>
            <td>Apps Android</td>
            <td>ROM modificada</td>
            <td>Distribuição Linux</td>
        </tr>
        <tr>
            <td><b>Ferramentas de Dev</b></td>
            <td>Muito limitado</td>
            <td>Depende da ROM instalada, liberdade total</td>
            <td><b>Liberdade Total</b></td>
        </tr>
    </tbody>
</table>
<br>
</details>

---

## Licença

Este projeto está sob a licença correspondente do repositório. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.
