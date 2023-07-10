$toolsPath = "$(Split-Path -Parent $MyInvocation.MyCommand.Definition)"

. "$toolsPath\common.ps1"

Install-Service
