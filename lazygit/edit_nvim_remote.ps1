param(
    [Parameter(Mandatory=$true, Position=0)]
    [string]$FileName,

    [Parameter(Mandatory=$false, Position=1)]
    [int]$LineNumber
)

if (Test-Path Env:NVIM) {
    nvim --server "$($env:NVIM)" --remote-send "<C-\><C-n>q"

    nvim --server "$($env:NVIM)" --remote-send ":e $FileName<CR>"

    if ($LineNumber -gt 0) {
        nvim --server "$($env:NVIM)" --remote-send ":${LineNumber}<CR>"
    }
}
else {
    $nvimFileArgs = @()
    if ($LineNumber -gt 0) {
        $nvimFileArgs += "+$LineNumber"
    }
    $nvimFileArgs += $FileName

    nvim $nvimFileArgs
}
