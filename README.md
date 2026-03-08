Abra o terminal e execute os comandos de acordo com a sua distribuição Linux.

Ubuntu 24.04 (Noble Numbat)

sudo apt update && sudo apt upgrade -y
sudo apt install python3 python3-pip python3-venv python3-dev build-essential -y

Fedora 42

sudo dnf update -y
sudo dnf install python3 python3-pip python3-devel gcc gcc-c++ -y

Configuração do Ambiente Python

Recomenda-se o uso de um ambiente virtual para evitar conflitos de dependências.

Criar o ambiente virtual:

python3 -m venv venv

Ativar o ambiente:

No Ubuntu/Fedora: source venv/bin/activate

Instalar as dependências:

pip install --upgrade pip
pip install pandas numpy scikit-learn matplotlib seaborn statsmodels scipy hdbscan notebook

Com o ambiente ativado e as dependências instaladas, inicie o ambiente Jupyter:

jupyter notebook
