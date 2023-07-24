if (Test-Path "./PowerToys") {
    Remove-Item "./PowerToys" -Recurse
}

Copy-Item -Path "$env:localAppData/Microsoft/PowerToys" -Destination "./PowerToys" -Recurse -Filter "*.json"
Get-ChildItem "./PowerToys" -Directory -Recurse | Where-Object { (Get-ChildItem $_ -File -Recurse) -eq $null } | Remove-Item -Recurse

git reset
$PowerToysChangeCount = (git status --porcelain | Where-Object { ($_.Trim().Split()[1]) -Like "PowerToys/*" }).Count
if ($PowerToysChangeCount -gt 0) {
    git add PowerToys
    git commit -m "**Commit PowerToys Settings**"
    git push
}
