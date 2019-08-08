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

 ScriptStarter
------------------ author: xshoji

Usage:
  ./ScriptStarter.sh --naming scriptName [ --author author --description Description --required paramName,sample,description --required ... --optional paramName,sample,description,defaultValue(omittable) --optional ... --flag flagName,description --flag ... --env variableName,sample --env ... --short ]

Description:
  This script generates a template of bash script tool.

Required:
  -n, --naming scriptName : Script name.

Optional:
  -a, --author author                                                 : Script author. [ default: anonymous ]
  -d, --description Description                                       : Description of this script. [ example: --description "ScriptStarter's description here." ]
  -r, --required paramName,sample,description                         : Required parameter setting. [ example: --required id,1001,"Primary id here." ]
  -o, --optional paramName,sample,description,defaultValue(omittable) : Optional parameter setting. [ example: --option name,xshoji,"User name here.",defaultUser ]
  -f, --flag flagName,description                                     : Optional flag parameter setting. [ example: --flag dryRun,"Dry run mode." ]
  -e, --env variableName,sample                                       : Required environment variable. [ example: --env API_HOST,example.com ]
  -s, --short : Enable short parameter. [ example: --short ]
  --debug : Enable debug mode

bash-4.2#
```

## Generate script

### Plain

Plain script no needs parameter.

`-h` and `--debug` options are supported as default.

```
bash-4.2# curl -sf ${STARTER_URL} |bash -s - -n MyScript -a xshoji > MyScript
bash-4.2# ./MyScript -h

   MyScript
  ------------- author: xshoji

  Usage:
    ./MyScript

  Description:
    This is MyScript

  Optional:
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
    ./test.sh --id 1001 --name xshoji

  Description:
    This is MyScript

  Required:
    --id 1001     : "1001" means id
    --name xshoji : "xshoji" means name

  Optional:
    --debug : Enable debug mode

bash-4.2#
```

### Optional parameters

Optional parameters are not validated.

These optional parameters are initialized by default value.

```
bash-4.2# curl -sf ${STARTER_URL} |bash -s - -n MyScript -a xshoji -o id,1001 -o name,xshoji,"A user name.","guest" > /tmp/MyScript > MyScript
bash-4.2# chmod 777 MyScript
bash-4.2# ./MyScript -h

   MyScript
  ------------- author: xshoji

  Usage:
    ./MyScript [ --id 1001 --name xshoji ]

  Description:
    This is MyScript

  Optional:
    --id 1001     : "1001" means id [ default: 1001 ]
    --name xshoji : A user name. [ default: guest ]
    --debug : Enable debug mode

bash-4.2# ./MyScript

[ Optional parameters ]
id: 1001
name: guest

bash-4.2# ./MyScript --name myname

[ Optional parameters ]
id: 1001
name: myname

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

  Optional:
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

  Optional:
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

Required:
  -i, --id 1001 : "1001" means id

Optional:
  -n, --name xshoji : "xshoji" means name
  -d, --dryRun : Enable dryRun flag
  --debug : Enable debug mode

bash-4.2# ./MyScript -i 1001 -n myname -d

[ Required parameters ]
id: 1001

[ Optional parameters ]
name: myname
dryRun: true

bash-4.2#
```

## How to use the generated script?

Your script should be writen following "Main".

If you would like to alter script parameters, you re-generate a script template by ScriptStarter.
Then, lines from top to "Main" on generated template only have to be copied and pasted to your script.
