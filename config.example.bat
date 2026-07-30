@echo off
:: ============================================================
::  CONFIGURACAO DE EXEMPLO (valores ficticios de documentacao)
::  Enderecos das faixas reservadas pela RFC 5737:
::    192.0.2.0/24, 198.51.100.0/24, 203.0.113.0/24
::
::  COMO USAR:
::    1. Copie este arquivo para "config.local.bat"
::    2. Edite "config.local.bat" com os IPs reais da sua rede
::    (config.local.bat esta no .gitignore e nao vai para o repositorio)
:: ============================================================

:: Pasta base dos audios e arquivos de estado
set "ALERT_DIR=C:\Alerta"

:: IPs fixos monitorados (separados por espaco)
set "FIXED_IPS=192.0.2.191 192.0.2.202 192.0.2.80 192.0.2.231 192.0.2.27"

:: IPs excluidos do intervalo sequencial (mesmo prefixo do intervalo abaixo)
set "EXCLUDED_IPS=203.0.113.109 203.0.113.110 203.0.113.126 203.0.113.131 203.0.113.135 203.0.113.163 203.0.113.167"

:: Intervalo sequencial de IPs.
::  IP montado como:  %RANGE_PREFIX%.<i>%RANGE_SUFFIX%
::  para <i> variando de RANGE_FIRST ate RANGE_LAST.
::  Nome da loja = Loja_<i - RANGE_NAME_OFFSET>
set "RANGE_PREFIX=203.0.113"
set "RANGE_SUFFIX="
set "RANGE_FIRST=102"
set "RANGE_LAST=168"
set "RANGE_NAME_OFFSET=100"

:: Mapa de nomes especiais (IP -> nome da unidade)
set "SPECIAL_COUNT=6"
set "SPECIAL_IP[1]=192.0.2.191"  & set "SPECIAL_NAME[1]=Deposito"
set "SPECIAL_IP[2]=192.0.2.202"  & set "SPECIAL_NAME[2]=Administrativo"
set "SPECIAL_IP[3]=192.0.2.80"   & set "SPECIAL_NAME[3]=Loja_09"
set "SPECIAL_IP[4]=192.0.2.27"   & set "SPECIAL_NAME[4]=Loja_26"
set "SPECIAL_IP[5]=192.0.2.31"   & set "SPECIAL_NAME[5]=Loja_28"
set "SPECIAL_IP[6]=192.0.2.231"  & set "SPECIAL_NAME[6]=Loja_31"
