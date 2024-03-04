# Readme

- [Backend Index](#backend-index)
- [Fronted Index](#frontend-index)
- [Localtunnel](#localtunnel)
- [Theory of RAG's](#theory-of-rags)

Note: Installation have been proved on Windows, still working to adapt it to Unix based systems

# Backend Index

- [0. Testing Demo without API](#0-testing-demo-without-api)
 - - [0.1 Python](#01-python)
 - - [0.2 How to run Demo version](#02-how-to-run-demo-version)
- [1. API Installation and Use](#1-api-installation-and-use)
 - - [1.1 Python Installation](#11-python-installation)
 - - [1.2 Installation of Poetry (virtual environment for python libraries)](#12-installation-of-poetry-virtual-environment-for-python-libraries)
 - - [1.3 Install Python dependencies into virtual environment](#13-install-python-dependencies-into-virtual-environment)
- [2. Create - Delete - Update Database with flask-sqlalchemy ORM](#2-create-delete-update-database-with-flask-sqlalchemy-orm)
 - - [2.1 Create Database for first time](#21-create-database-for-first-time)
 - - [2.2 Update db models](#22-update-db-models)
- [3. Run server with Poetry](#3-run-server-with-poetry)
- [4. Install LLM Embeddings (on development yet) this will enable ingestion of documents without make ML models](#4-install-llm-embeddings-on-development-yet-this-will-enable-ingestion-of-documents-without-make-ml-models)
- [5. Troubleshooting](#5-troubleshooting)
 - - [Delete virtual environment to re-install all libraries from scratch](#delete-virtual-environment-to-re-install-all-libraries-from-scratch)
 - - [Delete vector database (QDrant)](#delete-vector-database-qdrant)
 - - [Pydantic.v1 not found](#pydanticv1-not-found)
 - - [WinError 206](#winerror-206)
 - - [NoModuleFoundError](#nomodulefounderror)
- [6. Endpoints documentation](#6-endpoints-documentation)


# 0. Testing Demo without API
## 0.1 Python
Python version recommended: 3.11.6

```bash
pip install pandas
pip install scikit-learn
pip install joblib
```

##  0.2 How to run Demo version
### 0.2.1 Create a Normal model for vectorization of description

```bash
python train.py
```

### 0.2.2 Create/Re-train a Random Forest model

```bash
python random_forest_model.py
```

### 0.2.3 Prediction of a given description with a Random Forest Model

```bash
python run_saved_model.py
```

# 1. API Installation and Use

## 1.1 Python Installation

### 1.1.1 Windows
### 1.1.1.A Python globally:
- [Python 3.11.6](https://www.python.org/downloads/release/python-3116/)

### 1.1.1.B Python local environment (optional but recommended):
If you want to control the Python version to use and change between others:
- Install pyenv (windows):

```sh
Invoke-WebRequest -UseBasicParsing -Uri "https://raw.githubusercontent.com/pyenv-win/pyenv-win/master/pyenv-win/install-pyenv-win.ps1" -OutFile "./install-pyenv-win.ps1"; &"./install-pyenv-win.ps1"
```

You may need to add **pyenv** to environment PATH.

- Install Python Version:

```sh
pyenv install 3.11.6
```

- Use Python Version:

```sh
pyenv local 3.11.6
```

### 1.1.1 UNIX
### 1.1.1.A Python local environment (optional but recommended):

```sh
curl https://pyenv.run | bash
```

You may need to restart the shell. You will need add pyenv command to `~/.bashrc`:

```sh
vim ~/.bashrc
```

Add the following line into the editor:

```sh
eval "$(pyenv virtualenv-init -)"
```

Save the changes, and now reload the file:

```sh
source ~/.bashrc
```

```sh
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bashrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bashrc
echo 'eval "$(pyenv init -)"' >> ~/.bashrc
```

```sh
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.bash_profile
echo '[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(pyenv init -)"' >> ~/.bash_profile
```

Restart the shell:

```sh
exec "$SHELL"
```

Install python:

- Install Python Version:

```sh
pyenv install 3.11.6
```

- Use Python Version:

```sh
pyenv local 3.11.6
```


## 1.2 Installation of Poetry (virtual environment for python libraries)

### 1.2.1 Install Poetry 

### 1.2.1.1 Windows
- Dowload Poetry from: [official](https://python-poetry.org/docs/#installing-with-the-official-installer):

Use Power Shell with administrator permission

```sh
(Invoke-WebRequest -Uri https://install.python-poetry.org -UseBasicParsing).Content | py -
```

Note: If `py` is not recognized, change it with `python`.

- Maybe you'll need to add poetry to the PATH environment variable:

```sh
%AppData%\Roaming\pypoetry\venv\Scripts
```

### 1.2.1.2 Unix

Installation:

```sh
curl -sSL https://install.python-poetry.org | python3 -
```

Add poetry to PATH. Open the editor:

```sh
vim ~/.bashrc
```

Add the following lines:

```sh
export PATH="$HOME/.local/bin:$PATH"
```

Save the changes, and now reload the file:

```sh
source ~/.bashrc

```

You should be able now to run the `poetry` command, test with:

```sh
poetry --version
```

## 1.3 Install Python dependencies into virtual environment
- Create `poetry.lock` to resolve all dependencies and their sub-dependencies in the pyproject.toml file:

```sh
poetry lock --no-update
```

if fails, use: 

```sh
poetry lock
```

- Install dependencies:

```sh
poetry install --with local
```

Note: On UNIX, some libraries will fail like the ones related with nvidia. Don't worry, after some re-tryings it will be stop.

```bash
poetry add pydantic
```

Note: if poetry is already installed but there are new added libraries, you must do:

```sh
poetry update
```

for ingest .doc and .docx files, i recommend install the following library `globally` into the python environment:

```bash
poetry run pip install docx2txt
```

- Copy the .env.example and create .env file (complete the necessary settings for Python server):

```sh
cp .env.example .env
```

# 2. Create - Delete - Update Database with flask-sqlalchemy ORM

## 2.1 Create Database for first time

- Be sure to delete migration folder (Windows)

```sh
rmdir "./migrations" -Force -Recurse
echo rm -R -f ./migrations
```

Then create flask DB instance (inside of virtual environment):
```sh
poetry run flask db init
```

Delete old DB (if exists), and create a new one. (make sure to change the following info with database url, user and name info):
```sh
mysql -h localhost -u root -p -e "DROP DATABASE mldescription;"
mysql -h localhost -u root -p -e "CREATE DATABASE mldescription;"
```

Create tables from models ("modelos") folder:
```sh
poetry run flask db migrate
poetry run flask db upgrade
```

## 2.2 Update db models
Update tables from models folder:
```sh
poetry run flask db migrate
poetry run flask db upgrade
```


# 3. Run server with Poetry
- Run Flask server with Poetry for development (it will restart if detects changes):

```bash
poetry run flask run -p 3341 -h 0.0.0.0
```

- Run Flask server with Poetry for development-stable (it will not restart if detects changes). Use this to test, or upload large documents:

```bash
poetry run flask run -p 3341 -h 0.0.0.0 --no-reload
```

Note: Backend server will be running at port 3341

# 4. Install LLM Embeddings (on development yet) this will enable ingestion of documents without make ML models
For Windows 10/11

To be able to install the python library named: "llama-cpp-python", it's necesary to compile it, and for that you will need a C++ compiler.

To install a C++ compiler on Windows 10/11, follow these steps:
- 0. Be sure to have at least 35 GB free space on disk. (Yes i know, 35 GB to compile just a library ZzZ, but every CPU is diferent so..., for GPU it will need CUDA and that is 12 GB more of disk space, <a href="./docs/gpu/">GPU Installation</a>)
- 1. Install [Visual Studio 2022](https://visualstudio.microsoft.com/downloads/).
- 2. Make sure the following components are selected:
- - 2.1. Universal Windows Platform development
- - 2.2 C++ CMake tools for Windows

Some times, it's possible that you'll need:

- 3. Download the MinGW installer from the [MinGW website](https://sourceforge.net/projects/mingw/).
- 4. Run the installer and select the gcc component.

Ok, if installations are ready, then you'll add llama-cpp-python (you can do it globally with pip)

```bash
poetry run python setup.py
poetry run pip install --force-reinstall --no-cache-dir llama-cpp-python
```

# 5. Troubleshooting

## Delete virtual environment to re-install all libraries from scratch

For this, be sure to be in the root of this project and do this command to know the name of the virtual environment:

```bash
poetry env list
```

after this, run:

```bash
poetry env remove <name.of.the.environment-py3.xx >
```

or more agressive (if is need it):

```bash
poetry env remove python
```



Reinstall following the Steps in [1.2 Installation of Poetry (virtual environment for python libraries)](#12-installation-of-poetry-virtual-environment-for-python-libraries).

## Delete vector database (QDrant)

For this, just remove all content inside of the **local_data** folder (except .gitignore and readme.md). Don't worry, the vector database will be created next time you ingest a file.

## Pydantic.v1 not found

If this happens, that means that the wrong version was installed or not even installed. Please do the following command to update pydantic.

```bash
poetry add pydantic
```

## WinError 206

Error: Could not install packages due to an OSError: [WinError 206] The filename or extension is too long:

To fix this error on your Windows machine on `regedit` and navigate to `Computer\HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\FileSystem` and edit LongPathsEnabled and set value from `0` to `1`

## ModuleNotFoundError

Recently, in few OS, some libraries could have problems to install into virtual environment. One workaround is to do it directly into poetry. Some of the libraries that problems could be found:

```sh
poetry run pip install flask-sqlalchemy==2.5.1
poetry run pip install Flask-Migrate==3.1.0
poetry run pip install Flask==2.2.5
poetry run pip install flask_swagger==0.2.14
poetry run pip install flask_cors==3.0.10
poetry run pip install flask_admin==1.6.0
poetry run pip install flask_jwt_extended==4.4.0
poetry run pip install flask_bcrypt==1.0.1
poetry run pip install flask_apscheduler==1.13.1
poetry run pip install injector==0.21.0
poetry run pip install llama_index==0.9.3
poetry run pip install mysql-connector-python==8.2.0
poetry run pip install SQLAlchemy==1.4.45
```

# 6. Endpoints documentation

For this, please go to the folder <a href="./docs/">docs</a>

# Frontend Index

- [0. Frontend-requirements](#0-frontend-requirements)
- [1. Frontend installation](#1-frontend-installation)
 - - [1.1 Install the packages](#11-install-the-packages-just-need-to-do-this-the-first-time)
 - - [1.2. Edit a .env file](#12-edit-a-env-file-create-env-if-do-not-exist)
- [2. Run frontend server](#2-run-front-end-server)
- [3. Open Browser](#3-open-browser)
- [4. Build Frontend Project:](#4-build-frontend-project)
- [5. Frontend Documentation](#5-frontend-documentation)

## 0. Frontend Requirements:

- Make sure you are using node.js LTS version >= 20.x+ Link: [node v20.9.0 LTS](https://nodejs.org/dist/v20.9.0/node-v20.9.0-x64.msi)

## 1. Frontend installation:

### 1.1 Install the packages (just need to do this the first time):

```bash
npm install --legacy-peer-deps
```
### 1.2. Edit a .env file (create .env if do not exist):

Edit the section of **Front-end variables** as you need

1.2.1 Creation of .env file if it doesn't exist:

```bash
cp .env.example .env
```

## 2. Run front-end server:

```bash
npm run start
```

## 3. Open Browser:

Note that port by default is 3002.
    [http://localhost:3002](http://localhost:3002)

Develop testting app (for testing, design fast, etc, but not 100% usable because you need to login to access to protected endpoints):
    [http://localhost:3002/iq-gpt-develop](http://localhost:3002/iq-gpt-develop)

## 4. Build Frontend Project:

This should create the necessary bundle files to upload this app in any hosting server

```bash
npm run build
```

## 5. Frontend Documentation

For this, please go to the folder <a href="./docs/frontend">docs</a>

## Localtunnel

Localtunnel is a nodeJS library to expose a port to internet in order to share some apps on internet.

Open a new prompt and expose port 3002 to expose web UI:

```bash
lt --port 3002
```

This should retrieve an url, put that URL into .env file to configure correctly the front-end.

Your localtunnel's password will be at:

```url
https://loca.lt/mytunnelpassword
```

## Create image with Docker:

A. Automatic process

```sh
docker-compose up
```

B. Manual process

Create Image:

```sh
docker build --tag ubuntu-qlx-gpt .
```

Enter to Image:

```sh
docker run -it ubuntu-qlx-gpt
```

## Theory of RAG's

For this, please go to the folder <a href="./docs/theory">docs/theory/</a>