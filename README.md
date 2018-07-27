# bash-script-starter

ScriptStarter provides a means to generate a pretty template of bash script.

## Usage

Set ScriptStarter url.

```
bash-4.2# STARTER_URL=https://raw.githubusercontent.com/xshoji/bash-script-starter/master/ScriptStarter.sh
```

Display usage.

```
bash-4.2# curl -sf ${STARTER_URL} |bash -s
[!] --naming is required.
[!] --author is required.

   ScriptStarter
  ------------------- author: xshoji

  Usage:
    ./bash --naming scriptName --author name [ --description "ScriptStarter's description here." --required paramName,sample --required ... --option paramName,sample --option ... --flag flagName --flag ... --env varName,sample --env ... --short ]

  Description:
    This script generates a template of bash script tool.

  Required parameters:
    --naming,-n scriptName : Script name.
    --author,-a authorName : Script author.

  Optional parameters:
    --description,-d "Description"             : Description of this script. [ example: --description "ScriptStarter's description here." ]
    --required,-r paramName,sample,description : Required parameter setting. [ example: --required id,1001,"Primary id here." ]
    --option,-o paramName,sample,description   : Optional parameter setting. [ example: --option name,xshoji,"User name here." ]
    --flag,-f flagName,description             : Optional flag parameter setting. [ example: --flag dryRun,"Dry run mode." ]
    --env,-e varName,sample                    : Required environment variable. [ example: --env API_HOST,example.com ]
    --short,-s                                 : Enable short parameter. [ example: --short ]

bash-4.2#
```

## Generate script

### Plain

Plain script no needs parameter.

A `-h` option is supported as default.

```
bash-4.2# curl -sf ${STARTER_URL} |bash -s - -n MyScript -a xshoji > MyScript
bash-4.2# ./MyScript -h

   MyScript
  ------------- author: xshoji

  Usage:
    ./MyScript

  Description:
    This is MyScript

  Optional parameters:
    --debug : Enable debug mode

bash-4.2# ./MyScript
bash-4.2#
```

### Required parameters

Required parameters are validated.

Missing parameters are displayed as `[!]`.

```
bash-4.2#
bash-4.2# curl -sf ${STARTER_URL} |bash -s - -n MyScript -a xshoji -r id,1001 -r name,xshoji > MyScript
bash-4.2# chmod 777 MyScript
bash-4.2# ./MyScript
[!] --id is required.
[!] --name is required.

   MyScript
  ------------- author: xshoji

  Usage:
    ./MyScript --id 1001 --name xshoji

  Description:
    This is MyScript

  Required parameters:
    --id 1001 : 1001 is specified as id
    --name xshoji : xshoji is specified as name

  Optional parameters:
    --debug : Enable debug mode

bash-4.2#
```

### Optional parameters

Optional parameters are not validated.

These optional parameters are initialized by empty string.

```
bash-4.2# curl -sf ${STARTER_URL} |bash -s - -n MyScript -a xshoji -o id,1001 -o name,xshoji > MyScript
bash-4.2# chmod 777 MyScript
bash-4.2# ./MyScript -h

   MyScript
  ------------- author: xshoji

  Usage:
    ./MyScript [ --id 1001 --name xshoji ]

  Description:
    This is MyScript

  Optional parameters:
    --id 1001 : 1001 is specified as id
    --name xshoji : xshoji is specified as name
    --debug : Enable debug mode

bash-4.2# ./MyScript

[ Optional parameters ]
id:
name:

bash-4.2# ./MyScript --id 1001

[ Optional parameters ]
id: 1001
name:

bash-4.2#
```

### Flags

Flags are not validated.

These flags are set "true" string on enabling (default: empty string).

```
bash-4.2# curl -sf ${STARTER_URL} |bash -s - -n MyScript -a xshoji -f strict -f dryRun > MyScript
bash-4.2# ./MyScript -h

   MyScript
  ------------- author: xshoji

  Usage:
    ./MyScript [ --strict --dryRun ]

  Description:
    This is MyScript

  Optional parameters:
    --strict : Enable strict flag
    --dryRun : Enable dryRun flag
    --debug : Enable debug mode

bash-4.2# ./MyScript --strict

[ Optional parameters ]
strict: true
dryRun:

bash-4.2# ./MyScript --dryRun

[ Optional parameters ]
strict:
dryRun: true

bash-4.2#
```

### Environment variables

You can check environment variables be should exported.

Missing environment variables are displayed as `[!]`.

```
bash-4.2# curl -sf ${STARTER_URL} |bash -s - -n MyScript -a xshoji -e ENV_VAR_A,1001 -e ENV_VAR_B,xshoji > MyScript
bash-4.2# ./MyScript
[!] export ENV_VAR_A=1001 is required.
[!] export ENV_VAR_B=xshoji is required.

   MyScript
  ------------- author: xshoji

  Usage:
    ./MyScript

  Description:
    This is MyScript

  Environment settings are required such as follows,
    export ENV_VAR_A=1001
    export ENV_VAR_B=xshoji

  Optional parameters:
    --debug : Enable debug mode

bash-4.2# export export ENV_VAR_A=1001; export ENV_VAR_B=xshoji
bash-4.2# ./MyScript

[ Environment variables ]
ENV_VAR_A: 1001
ENV_VAR_B: xshoji

bash-4.2#
```

### Support short name parameters

You can specify each parameters as short name parameter.

`-s` option enables short parameter.

```
bash-4.2# curl -sf ${STARTER_URL} |bash -s - -n MyScript -a xshoji -r id,1001 -o name,xshoji -f dryRun -s > MyScript
bash-4.2# ./MyScript
[!] --id is required.

   MyScript
  ------------- author: xshoji

  Usage:
    ./MyScript --id 1001 [ --name xshoji --dryRun ]

  Description:
    This is MyScript

  Required parameters:
    --id,-i 1001 : 1001 is specified as id

  Optional parameters:
    --name,-n xshoji : xshoji is specified as name
    --dryRun,-d : Enable dryRun flag
    --debug : Enable debug mode

bash-4.2# ./MyScript -i 1001 -n xshoji -d

[ Required parameters ]
id: 1001

[ Optional parameters ]
name: xshoji
dryRun: true

bash-4.2#
```

## How to use the generated script?

Your script should be writen following "Main".

If you would like to alter script parameters, you re-generate the script template by ScriptStarter.
Then, lines from top to "Main" on generated template only have to be copied and pasted to your script.
