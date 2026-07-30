@echo off
setlocal EnableDelayedExpansion
:: ============================================================
::  Monitor de IPs com alertas sonoros para falhas
::  Criado por Lucas Verissimo
::
::  Intervalos progressivos de re-alerta:
::    5 min (1a falha), 15 min (2a), 30 min (3a), 1 hora (4a+)
::
::  Toda a configuracao de rede (IPs, intervalo e nomes de
::  unidades) fica em um arquivo externo:
::    - config.local.bat    -> valores reais (ignorado pelo git)
::    - config.example.bat  -> valores de exemplo (RFC 5737)
::
::  Se config.local.bat nao existir, os valores ficticios de
::  config.example.bat sao usados.
:: ============================================================

:: Configura a janela do console (60 colunas, 30 linhas)
mode con: cols=60 lines=30

:: ---- Carrega a configuracao ----
if exist "%~dp0config.local.bat" (
    call "%~dp0config.local.bat"
) else (
    if exist "%~dp0config.example.bat" (
        call "%~dp0config.example.bat"
        echo [AVISO] config.local.bat nao encontrado.
        echo [AVISO] Usando config.example.bat com valores ficticios de documentacao.
        echo.
    ) else (
        echo [ERRO] Nenhum arquivo de configuracao encontrado.
        echo Copie config.example.bat para config.local.bat e ajuste os IPs.
        pause
        exit /b 1
    )
)

:: Validacao minima da configuracao
if not defined FIXED_IPS (
    echo [ERRO] Configuracao invalida: FIXED_IPS nao definido.
    pause
    exit /b 1
)
if not defined ALERT_DIR set "ALERT_DIR=C:\Alerta"

:: Cria a pasta base se nao existir
if not exist "%ALERT_DIR%" mkdir "%ALERT_DIR%"

:: Reprodutor de audio (Windows Media Player)
set "PLAYER=wmplayer"

:: Arquivo de audio generico para falhas
set "ALERT_FILE=%ALERT_DIR%\Alerta.mp3"

:: Arquivo temporario para rastrear IPs com falha
set "TEMP_FILE=%ALERT_DIR%\ping_retry.txt"
if exist "%TEMP_FILE%" del "%TEMP_FILE%"

:: Titulo da janela do console
title Monitor de IPs - Status de Rede (por Lucas Verissimo)

:MAIN_LOOP
echo.
echo ==========================================================
echo  MONITOR DE IPs - STATUS DE REDE (%date% %time:~0,8%)
echo ==========================================================
echo.

set /a SUCCESS_COUNT=0
set /a FAILURE_COUNT=0
set /a SKIP_COUNT=0

echo [INFO] Iniciando ciclo de pings...
echo.

:: ---- IPs fixos ----
echo IPs Fixos:
echo ----------------------------------------------------------
for %%i in (%FIXED_IPS%) do (
    call :CHECK_RETRY %%i
    if !SKIP!==0 (
        ping -n 4 -w 1000 %%i | find "TTL=" >nul
        if errorlevel 1 (
            call :GET_SPECIAL_NAME %%i
            call :HANDLE_FAILURE %%i "!STORE_NAME!"
            set /a FAILURE_COUNT+=1
        ) else (
            echo [OK] %%i - Online
            call :CLEAR_RETRY %%i
            set /a SUCCESS_COUNT+=1
        )
    ) else (
        echo [AGUARDANDO] %%i - Em espera
        set /a SKIP_COUNT+=1
    )
    timeout /t 1 /nobreak >nul
)
echo.

:: ---- Intervalo sequencial ----
echo IPs no Intervalo (%RANGE_FIRST%-%RANGE_LAST%):
echo ----------------------------------------------------------
for /L %%i in (%RANGE_FIRST%,1,%RANGE_LAST%) do (
    set "IP=%RANGE_PREFIX%.%%i%RANGE_SUFFIX%"
    echo !EXCLUDED_IPS! | find "!IP!" >nul
    if errorlevel 1 (
        call :CHECK_RETRY !IP!
        if !SKIP!==0 (
            ping -n 4 -w 1000 !IP! | find "TTL=" >nul
            if errorlevel 1 (
                call :GET_SPECIAL_NAME !IP!
                if "!STORE_NAME!"=="!IP!" (
                    set /a STORE_NUM=%%i - %RANGE_NAME_OFFSET%
                    if !STORE_NUM! LSS 10 (
                        set "STORE_NAME=Loja_0!STORE_NUM!"
                    ) else (
                        set "STORE_NAME=Loja_!STORE_NUM!"
                    )
                )
                call :HANDLE_FAILURE !IP! "!STORE_NAME!"
                set /a FAILURE_COUNT+=1
            ) else (
                echo [OK] !IP! - Online
                call :CLEAR_RETRY !IP!
                set /a SUCCESS_COUNT+=1
            )
        ) else (
            echo [AGUARDANDO] !IP! - Em espera
            set /a SKIP_COUNT+=1
        )
        timeout /t 1 /nobreak >nul
    )
)

echo.
echo ==========================================================
echo Resumo do Ciclo:
echo - IPs Online: !SUCCESS_COUNT!
echo - IPs Offline: !FAILURE_COUNT!
echo - IPs em Espera: !SKIP_COUNT!
echo ==========================================================
echo Ciclo concluido. Aguardando 10s...
timeout /t 10 /nobreak >nul
goto MAIN_LOOP


:GET_SPECIAL_NAME
:: Resolve o nome da unidade para um IP via mapa SPECIAL_* da config.
:: Fallback (nao encontrado): o proprio IP.
set "STORE_NAME=%~1"
if not defined SPECIAL_COUNT exit /b
for /L %%n in (1,1,%SPECIAL_COUNT%) do (
    if "!SPECIAL_IP[%%n]!"=="%~1" set "STORE_NAME=!SPECIAL_NAME[%%n]!"
)
exit /b

:CHECK_RETRY
:: Verifica se o IP esta em timeout (intervalo depende do numero de falhas)
set IP=%1
set SKIP=0
if exist "%TEMP_FILE%" (
    for /f "tokens=1,2,3 delims= " %%a in (%TEMP_FILE%) do (
        if "%%a"=="%IP%" (
            set /a CURRENT_TIME=%time:~0,2%*3600 + %time:~3,2%*60 + %time:~6,2%
            set /a STORED_TIME=%%b
            set /a NUM_FAILS=%%c
            if "!STORED_TIME!"=="" set STORED_TIME=0
            if "!NUM_FAILS!"=="" set NUM_FAILS=1
            set /a ELAPSED=!CURRENT_TIME! - !STORED_TIME!
            if !ELAPSED! LSS 0 set /a ELAPSED=86400 + !ELAPSED!
            if !NUM_FAILS! EQU 1 (
                set INTERVAL=300
            ) else if !NUM_FAILS! EQU 2 (
                set INTERVAL=900
            ) else if !NUM_FAILS! EQU 3 (
                set INTERVAL=1800
            ) else (
                set INTERVAL=3600
            )
            if !ELAPSED! LSS !INTERVAL! (
                set SKIP=1
            ) else (
                call :REMOVE_IP_FROM_FILE "%IP%"
            )
        )
    )
)
exit /b

:HANDLE_FAILURE
:: Trata falhas de ping: toca audios e registra no ping_retry.txt
::   %1 = IP
::   %2 = nome da unidade (entre aspas)
set "IP=%~1"
set "STORE_NAME=%~2"
if "%STORE_NAME%"=="" set "STORE_NAME=%IP%"
:: Arquivo de audio especifico da unidade
set "AUDIO_FILE=%ALERT_DIR%\%STORE_NAME%.mp3"
:: Conta as falhas acumuladas para este IP
set /a NUM_FAILS=1
if exist "%TEMP_FILE%" (
    for /f "tokens=1,2,3 delims= " %%a in (%TEMP_FILE%) do (
        if "%%a"=="%IP%" (
            set /a NUM_FAILS=%%c+1
        )
    )
)
echo [FALHA] %IP% - Offline (!STORE_NAME!) - Tentativa !NUM_FAILS!
:: Registra IP, horario atual e numero de falhas
set /a CURRENT_TIME=%time:~0,2%*3600 + %time:~3,2%*60 + %time:~6,2%
echo %IP% !CURRENT_TIME! !NUM_FAILS! > "%TEMP_FILE%.tmp"
if exist "%TEMP_FILE%" type "%TEMP_FILE%" | findstr /v "%IP%" >> "%TEMP_FILE%.tmp"
move /y "%TEMP_FILE%.tmp" "%TEMP_FILE%" >nul
:: Toca o audio generico (Alerta.mp3) por 7 segundos
if exist "%ALERT_FILE%" (
    start /min "" "%ALERT_FILE%"
    timeout /t 7 /nobreak >nul
    taskkill /IM %PLAYER%.exe /F >nul 2>&1
    timeout /t 1 /nobreak >nul
) else (
    echo [ERRO] Arquivo Alerta.mp3 nao encontrado em %ALERT_DIR%
)
:: Toca o audio especifico da unidade duas vezes
if exist "%AUDIO_FILE%" (
    for /L %%i in (1,1,2) do (
        start /min "" "%AUDIO_FILE%"
        timeout /t 7 /nobreak >nul
        taskkill /IM %PLAYER%.exe /F >nul 2>&1
        timeout /t 1 /nobreak >nul
    )
) else (
    echo [ERRO] Arquivo !STORE_NAME!.mp3 nao encontrado em %ALERT_DIR%
)
:: Limpeza final
taskkill /IM %PLAYER%.exe /F >nul 2>&1
exit /b

:CLEAR_RETRY
:: Remove o IP do ping_retry.txt quando ele volta a ficar online
set IP=%1
if exist "%TEMP_FILE%" (
    findstr /v "%IP%" "%TEMP_FILE%" > "%TEMP_FILE%.tmp"
    if errorlevel 0 (
        move /y "%TEMP_FILE%.tmp" "%TEMP_FILE%" >nul
    ) else (
        del "%TEMP_FILE%.tmp" >nul 2>&1
    )
)
exit /b

:REMOVE_IP_FROM_FILE
:: Remove a linha de um IP do arquivo temporario (reset apos o intervalo)
set "IP=%~1"
if exist "%TEMP_FILE%" (
    findstr /v /c:"%IP% " "%TEMP_FILE%" > "%TEMP_FILE%.tmp" 2>nul
    move /y "%TEMP_FILE%.tmp" "%TEMP_FILE%" >nul 2>&1
)
exit /b
