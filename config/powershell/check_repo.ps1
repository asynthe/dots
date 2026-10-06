# Repo status at every prompt; -a all, -r refresh now.
# Port of check_repo in config/zsh/.zsh_functions: same record, same cache
# format, same messages. Keep the two records in sync.
# Plain ASCII on purpose: Windows PowerShell 5.1 reads BOM-less files as ANSI,
# so the status glyphs are built from code points instead.

$script:CheckRepoFile = $PSCommandPath
$script:CheckRepoRecord = @(
    # name   hosts          visibility
    'dots    github,gitlab  public'    # bootstrap.sh curls it raw from gitlab
    'flakes  github,gitlab  public'
    'notes   github,gitlab  private'
    'study   github,gitlab  private'
    'sakuhin github,gitlab  private'
    'auth    github,gitlab  private'
    'sarten  github,gitlab  public'
)
# Windows keeps repos on the Desktop; Linux and macOS in ~/git.
$script:CheckRepoRoots = @(
    (Join-Path (Join-Path $HOME 'Desktop') 'git')
    (Join-Path $HOME 'git')
    $HOME
)

function check_repo {
    param([Alias('a')][switch]$All, [Alias('r')][switch]$Refresh)

    $e = [char]27
    $red = "$e[0;31m"; $yellow = "$e[1;33m"; $green = "$e[0;32m"; $nc = "$e[0m"
    $pencil = [char]0x270E; $warn = [char]0x26A0; $down = [char]0x2193; $cross = [char]0x2717; $tick = [char]0x2713

    $cacheRoot = if ($env:XDG_CACHE_HOME) { $env:XDG_CACHE_HOME } else { Join-Path $HOME '.cache' }
    $cache = Join-Path $cacheRoot 'check_repo'

    # Every repo from the record cloned here, first root wins.
    $repos = @(foreach ($line in $script:CheckRepoRecord) {
        $name, $hosts, $want = -split $line
        foreach ($root in $script:CheckRepoRoots) {
            $p = Join-Path $root $name
            if (Test-Path -LiteralPath (Join-Path $p '.git')) {
                [pscustomobject]@{ Name = $name; Hosts = $hosts -split ','; Want = $want; Path = $p }
                break
            }
        }
    })

    New-Item -ItemType Directory -Force $cache | Out-Null
    $stamp = Join-Path $cache 'stamp'
    $stale = -not (Test-Path $stamp) -or ((Get-Date) - (Get-Item $stamp).LastWriteTime).TotalMinutes -gt 10
    if ($Refresh -or $stale) {
        [IO.File]::WriteAllText($stamp, '')
        # Answers for repos no longer here would never be read again.
        Get-ChildItem $cache -File |
            Where-Object { $_.Extension -in '.github', '.gitlab' -and $_.BaseName -notin $repos.Name } |
            Remove-Item
        # Own process, hidden: the git env vars stay out of this shell, and
        # without -r the prompt doesn't wait on the network.
        $todo = ($repos | ForEach-Object { "'$($_.Name):$($_.Hosts -join ',')'" }) -join ','
        $cmd = ". '$($script:CheckRepoFile -replace "'", "''")'; _check_repo_refresh '$($cache -replace "'", "''")' @($todo)"
        $enc = [Convert]::ToBase64String([Text.Encoding]::Unicode.GetBytes($cmd))
        Start-Process (Get-Process -Id $PID).Path -WindowStyle Hidden -Wait:$Refresh -ArgumentList @(
            '-NoProfile', '-NonInteractive', '-ExecutionPolicy', 'Bypass', '-EncodedCommand', $enc
        )
    }

    foreach ($r in $repos) {
        $repo = $r.Path; $name = $r.Name; $want = $r.Want
        $hostsWith = [ordered]@{}

        # One call for HEAD, branch and dirtiness: this runs at every prompt.
        $head = $null; $branch = $null; $dirty = $false
        foreach ($l in (git -C $repo status --porcelain=v2 --branch 2>$null)) {
            if ($l -like '# branch.oid *') { if ($l.Substring(13) -ne '(initial)') { $head = $l.Substring(13) } }
            elseif ($l -like '# branch.head *') { if ($l.Substring(14) -ne '(detached)') { $branch = $l.Substring(14) } }
            elseif ($l -notlike '# *') { $dirty = $true }
        }
        if (-not $branch) { $branch = 'main' }    # detached HEAD: compare against main
        if ($dirty) { Write-Host "  ${yellow}[$pencil]${nc} Uncommitted changes in '$name'" }

        $remotes = @(git -C $repo remote -v)
        $refs = @{}
        foreach ($l in (git -C $repo for-each-ref --format='%(refname) %(objectname)' refs/remotes)) {
            $k, $v = -split $l
            $refs[$k] = $v
        }

        foreach ($site in $r.Hosts) {
            # Remotes that push to this host, and where git last saw their branch.
            $pushers = 0; $pushedAt = @()
            foreach ($rl in $remotes) {
                $w = -split $rl    # name url (fetch|push)
                if ($w[2] -ne '(push)' -or $w[1] -notmatch "$site\.com[:/]") { continue }
                $pushers++
                $ref = $refs["refs/remotes/$($w[0])/$branch"]
                if ($ref) { $pushedAt += $ref }
            }

            $answer = Join-Path $cache "$name.$site"
            $kind = $null
            if (-not $pushers) {
                $kind = 'nopush'    # a host nothing pushes to falls behind unnoticed
            } elseif (-not $head) {
                # no commits yet
            } elseif (-not (Test-Path $answer)) {
                # Never heard from the host: the tracking ref is all there is.
                if ($pushedAt -and (git -C $repo rev-list -1 HEAD --not @pushedAt)) { $kind = 'unpushed' }
            } else {
                $lines = @(Get-Content $answer)
                if ($lines[0] -eq 'missing') {
                    $kind = 'missing'
                } else {
                    if ($lines[0] -ne $want) {
                        if (-not $hostsWith.Contains('visibility')) { $hostsWith['visibility'] = @() }
                        $hostsWith['visibility'] += $site
                    }
                    $sha = $lines | Where-Object { $_ -match "\srefs/heads/$([regex]::Escape($branch))$" } |
                        Select-Object -First 1 | ForEach-Object { (-split $_)[0] }
                    if (-not $sha) {
                        $kind = 'nobranch'
                    } elseif ($sha -eq $head) {
                    } else {
                        git -C $repo cat-file -e "$sha^{commit}" 2>$null
                        if ($LASTEXITCODE -ne 0) {
                            # The host has commits we don't. Unpushed work on top means diverged.
                            $kind = if (git -C $repo rev-list -1 HEAD --not --remotes) { 'diverged' } else { 'behind' }
                        } else {
                            git -C $repo merge-base --is-ancestor $sha HEAD
                            if ($LASTEXITCODE -eq 0) {
                                if ($pushedAt -notcontains $head) { $kind = 'unpushed' }
                            } else {
                                git -C $repo merge-base --is-ancestor HEAD $sha
                                $kind = if ($LASTEXITCODE -eq 0) { 'behind' } else { 'diverged' }
                            }
                        }
                    }
                }
            }
            if (-not $kind) { continue }
            if (-not $hostsWith.Contains($kind)) { $hostsWith[$kind] = @() }
            $hostsWith[$kind] += $site
        }

        # One line per kind of problem, the hosts that share it grouped.
        foreach ($kind in @($hostsWith.Keys)) {
            $on = $hostsWith[$kind] -join ', '
            switch ($kind) {
                'unpushed' { Write-Host "  ${red}[$warn]${nc} Unpushed changes in '$name' ($on)" }
                'diverged' { Write-Host "  ${red}[$warn]${nc} Diverged in '$name' ($on), fetch first" }
                'behind'   { Write-Host "  ${yellow}[$down]${nc} Behind in '$name' ($on)" }
                'missing'  { Write-Host "  ${red}[$cross]${nc} Missing remote for '$name' ($on)" }
                'nobranch' { Write-Host "  ${yellow}[?]${nc} No '$branch' branch for '$name' ($on)" }
                'nopush'   { Write-Host "  ${yellow}[!]${nc} No remote pushes to $on in '$name'" }
            }
        }
        if ($hostsWith.Contains('visibility')) {
            Write-Host "  ${red}[!]${nc} '$name' is not $want on $($hostsWith['visibility'] -join ', ')"
        }

        if ($All -and -not $dirty -and $hostsWith.Count -eq 0) {
            Write-Host "  ${green}[$tick]${nc} '$name' on $($r.Hosts -join ', ') ($want)"
        }
    }
    Write-Host ''
}

# Asks every host in parallel. Runs in its own hidden process, see check_repo.
function _check_repo_refresh([string]$cache, [string[]]$todo) {
    $env:GIT_TERMINAL_PROMPT = '0'
    $env:GCM_INTERACTIVE = 'never'
    # Extend, don't replace: ~/.gitconfig's sshCommand is what picks the key.
    $ssh = git config core.sshCommand
    if (-not $ssh) { $ssh = 'ssh' }
    $env:GIT_SSH_COMMAND = "$ssh -o BatchMode=yes -o ConnectTimeout=10"

    $asks = foreach ($item in $todo) {
        $name, $hosts = $item -split ':', 2
        foreach ($site in $hosts -split ',') {
            [pscustomobject]@{
                File  = Join-Path $cache "$name.$site"
                Ssh   = _check_repo_start @('ls-remote', '--heads', "git@$site.com:asynthe/$name.git")
                # Anonymous https only works if the world can read it.
                Https = _check_repo_start @('-c', 'credential.helper=', 'ls-remote', "https://$site.com/asynthe/$name.git", 'HEAD')
            }
        }
    }

    # One host's answer, written whole: "missing", or visibility then its heads.
    foreach ($a in $asks) {
        $heads = _check_repo_wait $a.Ssh
        $anon = _check_repo_wait $a.Https
        if (-not $heads.Ok) {
            # Only the host itself makes a repo missing; no answer keeps what we knew.
            if ($heads.Err -match 'Permission denied|Could not resolve|timed out|refused|unreachable|closed by') { continue }
            $out = 'missing'
        } else {
            $vis = if ($anon.Ok) { 'public' } else { 'private' }
            $out = "$vis`n$($heads.Out.TrimEnd())"
        }
        [IO.File]::WriteAllText("$($a.File).tmp", "$out`n")
        Move-Item -Force "$($a.File).tmp" $a.File
    }
}

function _check_repo_start([string[]]$GitArgs) {
    $psi = New-Object System.Diagnostics.ProcessStartInfo 'git'
    $psi.Arguments = ($GitArgs | ForEach-Object { if ($_ -match '\s') { "`"$_`"" } else { $_ } }) -join ' '
    $psi.UseShellExecute = $false
    $psi.CreateNoWindow = $true
    $psi.RedirectStandardOutput = $true
    $psi.RedirectStandardError = $true
    $p = [Diagnostics.Process]::Start($psi)
    [pscustomobject]@{ P = $p; Out = $p.StandardOutput.ReadToEndAsync(); Err = $p.StandardError.ReadToEndAsync() }
}

function _check_repo_wait($job) {
    $job.P.WaitForExit()
    [pscustomobject]@{ Ok = $job.P.ExitCode -eq 0; Out = $job.Out.Result; Err = $job.Err.Result }
}
