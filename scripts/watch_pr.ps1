# Poll PR checks via GitHub API
param(
    [int]$PrNumber = 4,
    [int]$MaxIterations = 20,
    [int]$IntervalSec = 15
)
$owner = 'JollyOscar'
$repo = 'server-config-repo'

for ($i = 0; $i -lt $MaxIterations; $i++) {
    Write-Output "Iteration $($i+1): fetching PR head..."
    try {
        $prJson = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repo/pulls/$PrNumber" -Headers @{ 'User-Agent' = 'watch-pr-script' }
    } catch {
        Write-Output "Failed to fetch PR info: $_"
        exit 2
    }
    $sha = $prJson.head.sha
    Write-Output "Head SHA: $sha"
    try {
        $status = Invoke-RestMethod -Uri "https://api.github.com/repos/$owner/$repo/commits/$sha/status" -Headers @{ 'User-Agent' = 'watch-pr-script' }
    } catch {
        Write-Output "Failed to fetch commit status: $_"
        exit 2
    }
    Write-Output "Combined state: $($status.state)"
    if ($status.state -ne 'pending') {
        Write-Output ("Statuses for {0}:" -f $sha)
        foreach ($s in $status.statuses) {
            Write-Output " - $($s.context): $($s.state) - $($s.description) ($($s.target_url))"
        }
        if ($status.state -eq 'success') {
            Write-Output 'ALL CHECKS PASSED'
            exit 0
        } else {
            Write-Output 'SOME CHECK(S) FAILED/NEUTRAL'
            exit 1
        }
    }
    Start-Sleep -Seconds $IntervalSec
}
Write-Output 'Timed out waiting for checks to complete.'
exit 3
