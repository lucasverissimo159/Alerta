# Alerta — Monitor de IPs com Alerta Sonoro

Script em *batch* (Windows) para monitoramento contínuo de disponibilidade
de hosts de rede via `ping`. Quando um host fica offline, o script emite um
**alerta sonoro** (um áudio genérico seguido do áudio específico da unidade)
e passa a re-alertar em **intervalos progressivos** enquanto o host continuar
inacessível.

> Ferramenta simples pensada para uma central/portaria acompanhar, de forma
> audível, a queda de links de várias unidades (lojas, depósito, etc.).

## Como funciona

A cada ciclo o script:

1. Faz `ping` em uma lista de **IPs fixos** e em um **intervalo sequencial** de IPs.
2. Para cada host **offline**, toca `Alerta.mp3` e depois o áudio da unidade
   (ex.: `Loja_09.mp3`, `Deposito.mp3`), identificando qual unidade caiu.
3. Registra a falha em um arquivo de estado (`ping_retry.txt`) e passa a
   respeitar um intervalo antes de alertar de novo, que **aumenta a cada falha**:

   | Falha consecutiva | Próximo alerta em |
   |-------------------|-------------------|
   | 1ª                | 5 minutos         |
   | 2ª                | 15 minutos        |
   | 3ª                | 30 minutos        |
   | 4ª ou mais        | 1 hora            |

4. Quando o host volta a responder, ele é removido do estado e volta ao
   monitoramento normal.

## Configuração

Os valores de rede **não** ficam no script — ficam em um arquivo de
configuração externo, para que o repositório não exponha a topologia real.

1. Copie o template de exemplo:

   ```bat
   copy config.example.bat config.local.bat
   ```

2. Edite `config.local.bat` com os **IPs reais** da sua rede.
   O arquivo `config.local.bat` está no `.gitignore` e **não** vai para o
   repositório.

Se `config.local.bat` não existir, o script usa `config.example.bat`, que
contém apenas **endereços fictícios** das faixas reservadas para documentação
pela [RFC 5737](https://datatracker.ietf.org/doc/html/rfc5737)
(`192.0.2.0/24`, `198.51.100.0/24`, `203.0.113.0/24`).

### Parâmetros de configuração

| Variável             | Descrição                                                        |
|----------------------|------------------------------------------------------------------|
| `ALERT_DIR`          | Pasta com os `.mp3` e o arquivo de estado (padrão `C:\Alerta`).  |
| `FIXED_IPS`          | Lista de IPs fixos monitorados (separados por espaço).           |
| `EXCLUDED_IPS`       | IPs a ignorar dentro do intervalo sequencial.                    |
| `RANGE_PREFIX`       | Prefixo do intervalo (ex.: `192.168` ou `203.0.113`).            |
| `RANGE_SUFFIX`       | Sufixo do IP montado (ex.: `.254`, ou vazio).                    |
| `RANGE_FIRST` / `RANGE_LAST` | Faixa numérica varrida no intervalo.                     |
| `RANGE_NAME_OFFSET`  | Deslocamento para nomear a loja (`Loja_<i - offset>`).           |
| `SPECIAL_IP[n]` / `SPECIAL_NAME[n]` | Mapa de IP → nome de unidade específica.          |

O IP do intervalo é montado como `%RANGE_PREFIX%.<i>%RANGE_SUFFIX%`, e o nome
da unidade como `Loja_<i - RANGE_NAME_OFFSET>` (ou o nome do mapa `SPECIAL_*`).

## Áudios

Coloque os arquivos `.mp3` na pasta definida em `ALERT_DIR` (padrão `C:\Alerta`):

- `Alerta.mp3` — alerta genérico tocado antes do áudio da unidade.
- Um `.mp3` por unidade, com o **mesmo nome** usado na configuração
  (`Loja_09.mp3`, `Deposito.mp3`, ...).

Os áudios podem ser gerados por TTS (veja `README.txt` para uma sugestão de
voz em português).

## Uso

1. Ajuste `config.local.bat`.
2. Garanta que os `.mp3` estejam em `ALERT_DIR`.
3. Execute:

   ```bat
   Alerta.bat
   ```

O script roda em laço contínuo. Feche a janela do console para encerrar.

## Requisitos

- Windows (usa `ping`, `find`, `timeout` e o Windows Media Player `wmplayer`).
