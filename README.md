# Alert — IP Monitor with Audible Alert

*(Para a versão em português, [clique aqui](#alerta--monitor-de-ip-com-alerta-sonoro))*

Batch script (Windows) for continuous monitoring of the availability
of network hosts via `ping`. When a host goes offline, the script emits an
**audible alert** (a generic sound followed by the unit-specific sound)
and begins to re-alert at **progressive intervals** as long as the host remains
unreachable.

> Simple tool designed for a central office or reception desk to monitor, in an
> audible manner, the loss of connections from various units (stores, warehouse, etc.).

> ⚠️ **Repository available for portfolio purposes only.** The code can
> be viewed, but **cannot** be copied, downloaded, used, or
> reused in other projects. See the [License](#license) section and the
> [`LICENSE`](./LICENSE) file.

## How it works

In each cycle, the script:

1. `Pings` a list of **fixed IPs** and a **sequential range** of IPs.
2. For each **offline** host, it plays `Alerta.mp3` and then the audio file for that unit
   (e.g., `Loja_09.mp3`, `Deposito.mp3`), identifying which unit went down.
3. It logs the failure in a status file (`ping_retry.txt`) and then
   wait a certain interval before alerting again, which **increases with each failure**:

   | Consecutive failures | Next alert in |
   |-------------------|-------------------|
   | 1st                | 5 minutes         |
   | 2nd                | 15 minutes        |
   | 3rd                | 30 minutes        |
   | 4th or more     | 1 hour            |

4. When the host starts responding again, it is removed from the status list and returns to
   normal monitoring.

## Configuration

Network values are **not** included in the script—they are stored in an
external configuration file, so that the repository does not expose the actual topology.

1. Copy the example template:

   ```bat
   copy config.example.bat config.local.bat
   ```

2. Edit `config.local.bat` with the **actual IP addresses** of your network.
   The `config.local.bat` file is listed in `.gitignore` and **will not** be added to the
   repository.

If `config.local.bat` does not exist, the script uses `config.example.bat`, which
contains only **fictitious addresses** from the ranges reserved for documentation
by [RFC 5737](https://datatracker.ietf.org/doc/html/rfc5737)
(`192.0.2.0/24`, `198.51.100.0/24`, `203.0.113.0/24`).

### Configuration Parameters

| Variable             | Description                                                        |
|----------------------|------------------------------------------------------------------|
| `ALERT_DIR`          | Folder containing the `.mp3` files and the status file (default `C:\Alerta`).  |
| `FIXED_IPS`          | List of monitored fixed IPs (separated by spaces).           |
| `EXCLUDED_IPS`       | IPs to ignore within the sequential range.                    |
| `RANGE_PREFIX`       | Range prefix (e.g., `192.168` or `203.0.113`).            |
| `RANGE_SUFFIX`       | Suffix of the assembled IP (e.g., `.254`, or empty).                    |
| `RANGE_FIRST` / `RANGE_LAST` | Numeric range scanned within the interval.                     |
| `RANGE_NAME_OFFSET`  | Offset for naming the store (`Store_<i - offset>`).           |
| `SPECIAL_IP[n]` / `SPECIAL_NAME[n]` | Map from IP to specific unit name.          |

The IP address in the range is formatted as `%RANGE_PREFIX%.<i>%RANGE_SUFFIX%`, and the unit name
as `Store_<i - RANGE_NAME_OFFSET>` (or the name from the `SPECIAL_*` mapping).

## Audio Files

Place the `.mp3` files in the folder specified in `ALERT_DIR` (default `C:\Alerta`):

- `Alerta.mp3` — generic alert played before the unit’s audio.
- One `.mp3` file per unit, with the **same name** used in the configuration
  (`Loja_09.mp3`, `Deposito.mp3`, ...).

Audio files can be generated using TTS (see `README.txt` for a suggestion for a
Portuguese voice).

## Usage

1. Configure `config.local.bat`.
2. Ensure that the `.mp3` files are in `ALERT_DIR`.
3. Run:

   ```bat
   Alerta.bat
   ```

The script runs in a continuous loop. Close the console window to stop it.

## Requirements

- Windows (uses `ping`, `find`, `timeout`, and the Windows Media Player `wmplayer`).

## License

This repository **is not open source**. It is made publicly available
solely for portfolio/technical demonstration purposes.

- ✅ Allowed: view the code via the GitHub interface.
- ❌ Prohibited: copying, downloading, cloning for reuse, using, modifying, executing,
  or redistributing this code, in whole or in part, without prior
  written permission from the author.

All rights reserved. See the full terms at
[`LICENSE`](./LICENSE).

---

# Alerta — Monitor de IP com Alerta Sonoro

Script em lote (Windows) para monitoramento contínuo da disponibilidade
de hosts na rede via `ping`. Quando um host fica offline, o script emite um
**alerta sonoro** (um som genérico seguido pelo som específico da unidade)
e começa a alertar novamente em **intervalos progressivos** enquanto o host permanecer
inacessível.

> Ferramenta simples projetada para um escritório central ou recepção para monitorar, de forma
> sonora, a perda de conexões de várias unidades (lojas, depósito, etc.).

> ⚠️ **Repositório disponível apenas para fins de portfólio.** O código pode
> ser visualizado, mas **não pode** ser copiado, baixado, usado ou
> reutilizado em outros projetos. Veja a seção [Licença](#licença) e o
> arquivo [`LICENSE`](./LICENSE).

## Como funciona

Em cada ciclo, o script:

1. Executa `ping` em uma lista de **IPs fixos** e um **intervalo sequencial** de IPs.
2. Para cada host **offline**, reproduz `Alerta.mp3` e em seguida o arquivo de áudio daquela unidade
   (ex., `Loja_09.mp3`, `Deposito.mp3`), identificando qual unidade caiu.
3. Registra a falha em um arquivo de status (`ping_retry.txt`) e depois
   aguarda um certo intervalo antes de alertar novamente, que **aumenta a cada falha**:

   | Falhas consecutivas | Próximo alerta em |
   |---------------------|-------------------|
   | 1ª                  | 5 minutos         |
   | 2ª                  | 15 minutos        |
   | 3ª                  | 30 minutos        |
   | 4ª ou mais          | 1 hora            |

4. Quando o host volta a responder, ele é removido da lista de status e retorna ao
   monitoramento normal.

## Configuração

Os valores de rede **não** estão incluídos no script—eles são armazenados em um
arquivo de configuração externo, para que o repositório não exponha a topologia real.

1. Copie o modelo de exemplo:

   ```bat
   copy config.example.bat config.local.bat
   ```

2. Edite `config.local.bat` com os **endereços IP reais** da sua rede.
   O arquivo `config.local.bat` está listado no `.gitignore` e **não será** adicionado ao
   repositório.

Se `config.local.bat` não existir, o script usa `config.example.bat`, que
contém apenas **endereços fictícios** dos intervalos reservados para documentação
pela [RFC 5737](https://datatracker.ietf.org/doc/html/rfc5737)
(`192.0.2.0/24`, `198.51.100.0/24`, `203.0.113.0/24`).

### Parâmetros de Configuração

| Variável             | Descrição                                                          |
|----------------------|--------------------------------------------------------------------|
| `ALERT_DIR`          | Pasta contendo os arquivos `.mp3` e o arquivo de status (padrão `C:\Alerta`).  |
| `FIXED_IPS`          | Lista de IPs fixos monitorados (separados por espaços).            |
| `EXCLUDED_IPS`       | IPs a ignorar dentro do intervalo sequencial.                      |
| `RANGE_PREFIX`       | Prefixo do intervalo (ex., `192.168` ou `203.0.113`).              |
| `RANGE_SUFFIX`       | Sufixo do IP montado (ex., `.254`, ou vazio).                      |
| `RANGE_FIRST` / `RANGE_LAST` | Faixa numérica verificada no intervalo.                    |
| `RANGE_NAME_OFFSET`  | Deslocamento para nomear a loja (`Loja_<i - offset>`).             |
| `SPECIAL_IP[n]` / `SPECIAL_NAME[n]` | Mapeamento de IP para nome de unidade específica.          |

O endereço IP no intervalo é formatado como `%RANGE_PREFIX%.<i>%RANGE_SUFFIX%`, e o nome da unidade
como `Store_<i - RANGE_NAME_OFFSET>` (ou o nome do mapeamento `SPECIAL_*`).

## Arquivos de Áudio

Coloque os arquivos `.mp3` na pasta especificada em `ALERT_DIR` (padrão `C:\Alerta`):

- `Alerta.mp3` — alerta genérico reproduzido antes do áudio da unidade.
- Um arquivo `.mp3` por unidade, com o **mesmo nome** usado na configuração
  (`Loja_09.mp3`, `Deposito.mp3`, ...).

Os arquivos de áudio podem ser gerados usando TTS (veja `README.txt` para uma sugestão de
voz em português).

## Uso

1. Configure `config.local.bat`.
2. Certifique-se de que os arquivos `.mp3` estão em `ALERT_DIR`.
3. Execute:

   ```bat
   Alerta.bat
   ```

O script é executado em um loop contínuo. Feche a janela do console para pará-lo.

## Requisitos

- Windows (usa `ping`, `find`, `timeout` e o Windows Media Player `wmplayer`).

## Licença

Este repositório **não é open source**. Ele é disponibilizado publicamente
exclusivamente para fins de portfólio/demonstração técnica.

- ✅ Permitido: visualizar o código através da interface do GitHub.
- ❌ Proibido: copiar, baixar, clonar para reutilização, usar, modificar, executar,
  ou redistribuir este código, no todo ou em parte, sem permissão
  prévia por escrito do autor.

Todos os direitos reservados. Veja os termos completos em
[`LICENSE`](./LICENSE).
