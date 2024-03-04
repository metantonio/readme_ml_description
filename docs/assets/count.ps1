$rama_destino = "main"
$ramas = git branch --format='%(refname:short)'

foreach ($rama in $ramas) {
    if ($rama -ne $rama_destino) {
        $count = git log --merges --oneline --no-merges $rama..$rama_destino | Select-String -Pattern "pull request" | Measure-Object | Select-Object -ExpandProperty Count
        Write-Output "Rama: $rama - Pull Requests: $count"
    }
}

