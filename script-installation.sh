#!/bin/bash

# ==========================================================================
#  ⚡ Cyberdeck: Linux no Android - Script de Instalação e Configuração
# ==========================================================================

cat << 'EOF'
  /$$$$$$            /$$                                                 /$$                     /$$      
 /$$__  $$          | $$                                                 | $$                    | $$      
| $$  \__/ /$$   /$$| $$$$$$$   /$$$$$$   /$$$$$$   /$$$$$$$  /$$$$$$   /$$$$$$$| $$   /$$
| $$      | $$  | $$| $$__  $$ /$$__  $$ /$$__  $$ /$$__  $$ /$$__  $$ /$$_____/| $$  /$$/
| $$      | $$  | $$| $$  \ $$| $$$$$$$$| $$  \__/| $$  | $$| $$$$$$$$| $$      | $$$$$$/ 
| $$    $$| $$  | $$| $$  | $$| $$_____/| $$      | $$  | $$| $$_____/| $$      | $$_  $$ 
|  $$$$$$/|  $$$$$$$| $$$$$$$/|  $$$$$$$| $$      |  $$$$$$$|  $$$$$$$|  $$$$$$$| $$ \  $$
 \______/  \____  $$|_______/  \_______/|__/       \_______/ \_______/ \_______/|__/  \__/
           /$$  | $$                                                                      
          |  $$$$$$/                                                                      
           \______/                                                                       
EOF

# Permissão de armazenamento
echo -e "\n[1/5] Solicitando acesso ao armazenamento interno..."
termux-setup-storage
sleep 2

# Atualiza os pacotes e instala o Git
echo -e "\n[2/5] Atualizando o Termux e instalando o Git..."
pkg update -y && pkg upgrade -y
pkg install git -y

if [ $? -ne 0 ]; then
    echo -e "Nota: Se a atualização falhar, certifique-se de estar usando a versão do F-Droid."
fi

# Clone do Repositório
echo -e "\n[3/5] Clonando o repositório linux-android..."

# Verifica se a pasta já existe, caso ele com o git clone
if [ -d "linux-android" ]; then
    echo "A pasta 'linux-android' já existe. Atualizando repositório existente..."
    cd linux-android && git pull
else
    git clone https://github.com/lucasaguiar-la/linux-android.git
    cd linux-android
fi

# Verificação do parâmetro de ambiente gráfico
if [ -z "$1" ]; then
    echo -e "\nAlerta: Voce nao escolheu um ambiente grafico via parametro. O padrao sera xfce4."
    AMBIENTE_PARAM="xfce4"
else
    AMBIENTE_PARAM=$(echo "$1" | tr '[:upper:]' '[:lower:]')
fi

# Ambiente gráfico
echo -e "\n[4/5] Configurando o Ambiente Gráfico..."

if [ "$AMBIENTE_PARAM" = "xfce4" ] || [ "$AMBIENTE_PARAM" = "lxqt" ] || [ "$AMBIENTE_PARAM" = "mate" ] || [ "$AMBIENTE_PARAM" = "kde" ]; then
    case $AMBIENTE_PARAM in
        xfce4) AMBIENTE="XFCE4";;
        lxqt)  AMBIENTE="LXQt";;
        mate)  AMBIENTE="MATE";;
        kde)   AMBIENTE="KDE";;
     lockesinc) AMBIENTE="XFCE4";;
    esac
else
    echo "------------------------------------------------------"
    echo "Escolha a interface gráfica desejada para o seu Cyberdeck:"
    echo -e "1) XFCE4  (Recomendado - Melhor equilíbrio de performance)"
    echo -e "2) LXQt   (Muito Leve - Ideal para dispositivos antigos)"
    echo -e "3) MATE   (Média - Alternativa clássica e estável)"
    echo -e "4) KDE    (Pesado - Apenas para dispositivos modernos/topo de linha)"
    echo "------------------------------------------------------"
    read -p "Digite o número da sua opção (1-4): " opcao

    case $opcao in
        1) AMBIENTE="XFCE4";;
        2) AMBIENTE="LXQt";;
        3) AMBIENTE="MATE";;
        4) AMBIENTE="KDE";;
        *) echo -e "Opção inválida. Definindo o padrão recomendado (XFCE4)."; AMBIENTE="XFCE4";;
    esac
fi

echo -e "\nSelecionado: $AMBIENTE. Iniciando o instalador principal..."

# Concede permissão de execução e roda o script interno do repositório clonado
chmod +x script-termux.sh
./script-termux.sh

# Instalação conluido
echo -e "\n======================================================"
echo -e "Instalação do script concluido!"
echo -e "======================================================"
