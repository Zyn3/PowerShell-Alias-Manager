# PowerShell-Alias-Manager
This script allows you to easily manage PowerShell aliases. You can add, remove, and list aliases, and also specify whether they should be global or local.

## How to Use
To use the script, you can run it from a PowerShell prompt. You can add, remove, or list aliases using the following commands:

| Command | Required Parameters | Optional Parameters | Description |
| --- | --- | --- | --- |
| add | `--name` (alias name), `--path` (target path) | `--global` | Adds a new alias to the system or user profile |
| remove | `--name` (alias name) | | Removes an existing alias from the system or user profile |
| list | | | Lists all configured aliases, along with their ID, name, path, and whether they are global or not |

### Examples

**add** -> ```.\ps-alias.ps1 add --name myalias --path C:\my\path --global``` 

**remove** ->  ```.\ps-alias.ps1 remove --name myalias ```

**list** -> ```.\ps-alias.ps1 list``` 

> Note that when adding a new alias, you can specify the --global flag to make the alias available to all PowerShell sessions! By default, aliases are only available to the current user.
 
###License
This script is released under the MIT License. See LICENSE for more details.
