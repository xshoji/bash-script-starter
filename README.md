# bash-script-starter

ScriptStarter provides a means to generate a nice template of a bash script.

<img src="https://i.imgur.com/5M0Udbv.gif" width="80%" height="80%" style="border:0;box-shadow:0 0 0 0; " alt="Demo">

## Usage

Set ScriptStarter url.

```
bash-4.2# STARTER_URL=https://raw.githubusercontent.com/xshoji/bash-script-starter/master/ScriptStarter.sh
```

Display usage.

```
bash-4.2# ./ScriptStarter.sh -h

 ScriptStarter
------------------ author: xshoji

This script generates a template of bash script tool.

Usage:
  ./ScriptStarter.sh --naming scriptName [ --author author --description Description --description ... --required paramName,sample,description --required ... --optional paramName,sample,description,defaultValue(omittable) --optional ... --flag flagName,description --flag ... --env variableName,sample --env ... --short  --keep-starter-parameters --protect-arguments ]

Required:
  -n, --naming scriptName : Script name.

Optional:
  -a, --author author                                                 : Script author.
  -d, --description Description                                       : Description of this script. [ example: --description "ScriptStarter's description here." ]
  -r, --required paramName,sample,description                         : Required parameter setting. [ example: --required id,1001,"Primary id here." ]
  -o, --optional paramName,sample,description,defaultValue(omittable) : Optional parameter setting. [ example: --option name,xshoji,"User name here.",defaultUser ]
  -f, --flag flagName,description                                     : Optional flag setting. [ example: --flag dryRun,"Dry run mode." ]
  -e, --env variableName,sample                                       : Required environment variable setting. [ example: --env API_HOST,example.com ]
  -s, --short                   : Enable short parameter. [ example: --short ]
  -k, --keep-starter-parameters : Keep parameter details of bash-script-starter in the generated scprit. [ example: --keep-starter-parameters ]
  -p, --protect-arguments       : Declare argument variables as readonly. [ example: --protect-arguments ]

Helper options:
  --help, --debug

bash-4.2#
```

A sample of generated script [here](sample/GeneratedScriptSample.sh).

## Generate script

### Plain

Plain script no needs parameter.

`-h` and `--debug` options are supported as default.

```
bash-4.2# curl -sf ${STARTER_URL} |bash -s - -n MyScript -a xshoji > MyScript
bash-4.2# ./MyScript -h

 MyScript
------------- author: xshoji

This is MyScript.

Usage:
  ./MyScript

Helper options:
  --help, --debug

bash-4.2# ./MyScript
bash-4.2#
```

### Required parameters

Required parameters are validated.

Missing parameters are displayed as `[!]`.

```
bash-4.2# curl -sf ${STARTER_URL} |bash -s - -n MyScript -a xshoji -r id,1001 -r name,xshoji > MyScript
bash-4.2# ./MyScript
[!] --id is required.
[!] --name is required.

 MyScript
------------- author: xshoji

This is MyScript.

Usage:
  ./MyScript --id 1001 --name xshoji

Required:
  --id 1001     : "1001" means id.
  --name xshoji : "xshoji" means name.

Helper options:
  --help, --debug

bash-4.2#
```

### Optional parameters

Optional parameters will be not validated.

These optional parameters are initialised with a default value.

```
bash-4.2# curl -sf ${STARTER_URL} |bash -s - -n MyScript -a xshoji -o id,1001 -o name,xshoji,"A user name.","guest" > MyScript
bash-4.2# ./MyScript -h

 MyScript
------------- author: xshoji

This is MyScript.

Usage:
  ./MyScript [ --id 1001 --name xshoji ]

Optional:
  --id 1001     : "1001" means id.
  --name xshoji : A user name. [ default: guest ]

Helper options:
  --help, --debug

bash-4.2# ./MyScript

[ Optional parameters ]
id: 1001
name: guest

bash-4.2# ./MyScript --name myname

[ Optional parameters ]
id:
name: myname

bash-4.2#
```

### Flags

Flags will be not validated.

These flags are set to "true" string when enabled  (default: empty string).

```
bash-4.2# curl -sf ${STARTER_URL} |bash -s - -n MyScript -a xshoji -f strict -f dryRun > MyScript
bash-4.2# ./MyScript -h

 MyScript
------------- author: xshoji

This is MyScript.

Usage:
  ./MyScript [ --strict --dryRun ]

Optional:
  --strict : Enable strict flag.
  --dryRun : Enable dryRun flag.

Helper options:
  --help, --debug

bash-4.2# ./MyScript --strict

[ Optional parameters ]
strict: true
dryRun: false

bash-4.2# ./MyScript --dryRun

[ Optional parameters ]
strict: false
dryRun: true

bash-4.2#
```

### Environment variables

You can check which environment variables be should be exported.

Missing environment variables are displayed as `[!]`.

```
bash-4.2# curl -sf ${STARTER_URL} |bash -s - -n MyScript -a xshoji -e ENV_VAR_A,1001 -e ENV_VAR_B,xshoji > MyScript
bash-4.2# ./MyScript
[!] export ENV_VAR_A=1001 is required.
[!] export ENV_VAR_B=xshoji is required.

 MyScript
------------- author: xshoji

This is MyScript.

Usage:
  ./MyScript

Environment variables:
  export ENV_VAR_A=1001
  export ENV_VAR_B=xshoji

Helper options:
  --help, --debug

bash-4.2# export ENV_VAR_A=1001; export ENV_VAR_B=xshoji
bash-4.2# ./MyScript

[ Environment variables ]
ENV_VAR_A: 1001
ENV_VAR_B: xshoji
```

### Support short name parameters

You can specify any parameters as a short name parameter.

The `-s, --short` option enables short parameters.

```
bash-4.2# curl -sf ${STARTER_URL} |bash -s - -n MyScript -a xshoji -r id,1001 -o name,xshoji -f dryRun -s > MyScript
bash-4.2# ./MyScript
[!] --id is required.

 MyScript
------------- author: xshoji

This is MyScript.

Usage:
  ./MyScript --id 1001 [ --name xshoji --dryRun ]

Required:
  -i, --id 1001 : "1001" means id.

Optional:
  -n, --name xshoji : "xshoji" means name.
  -d, --dryRun : Enable dryRun flag.

Helper options:
  --help, --debug

bash-4.2# ./MyScript -i 1001 -n myname -d

[ Required parameters ]
id: 1001

[ Optional parameters ]
name: myname
dryRun: true
```

### Protect arguments

`-p, --protect-arguments` option generates readonly declaring.

```
bash-4.2# curl -sf ${STARTER_URL} |bash -s - -n MyScript -r id,1001 -o name,xshoji -s -p > MyScript
bash-4.2# cat MyScript
...
# To readonly variables
readonly ID
readonly NAME
...
```

## How to use the generated script?

Your script should be writen following "Main".

If you would like to alter script parameters, you re-generate a script template by ScriptStarter.
Then, lines from top to "Main" on generated template only have to be copied and pasted to your script.
