#!/usr/bin/python3
import subprocess

def start():
    windows_command = "flask run -p 3340 -h 0.0.0.0" 
    result = subprocess.run(windows_command, shell=True, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    # Imprimir la salida del comando
    print("Salida del comando:")
    print(result.stdout)
    # Imprimir la salida de error si hay algún problema
    if result.stderr:
        print("Error del comando:")
        print(result.stderr)

def reset_db_win_local():
    windows_command = "@powershell -noninteractive -nologo -noprofile -executionpolicy bypass './docs/assets/reset_sql_copy.ps1'" 
    result = subprocess.run(windows_command, shell=True, check=True, stdout=subprocess.PIPE, stderr=subprocess.PIPE, text=True)
    # Imprimir la salida del comando
    print("Salida del comando:")
    print(result.stdout)
    # Imprimir la salida de error si hay algún problema
    if result.stderr:
        print("Error del comando:")
        print(result.stderr)