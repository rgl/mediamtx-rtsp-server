$toolsPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"

. "$toolsPath\common.ps1"

Uninstall-Service
