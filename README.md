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

## Licença

Este projeto está sob a licença correspondente do repositório. Veja o arquivo [LICENSE](LICENSE.md) para mais detalhes.
