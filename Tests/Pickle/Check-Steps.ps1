<#
.SYNOPSIS
    Checks the steps of the suite against Pickle's own expression engine, without a game. A few seconds.

.DESCRIPTION
    A suite that has never been played can still be wrong in the ways that cost a whole run:

      1. An INVALID pattern makes Pickle play zero scenarios (infrastructure-error). In a Cucumber
         Expression parentheses mean optional text and a slash means alternation, so "at (x, y)" is not what
         it looks like. Every pattern declared under Source\ is compiled with the parameter registry the
         game uses.
      2. A pattern declared TWICE, or a step line matched by two expressions, is an "Ambiguous step" that
         fails a healthy scenario. Pickle loads the steps of every mod staged in a run into one namespace
         and matches on the text alone, so a line is matched against this suite's expressions, Pickle's own
         vocabulary and the PickleTools companions this suite's pass maps stage.
      3. A step line no expression matches is an undefined step: the scenario cannot run at all.

    Only what a pass can stage is compared, so no walk of the repository is needed. It does NOT prove a step
    does what its sentence says: only a run does.

.EXAMPLE
    powershell.exe -ExecutionPolicy Bypass -File Tests/Pickle/Check-Steps.ps1
#>
param(
    [string]$PickleAssemblies = 'C:\Program Files (x86)\Steam\steamapps\workshop\content\294100\3791648678\Assemblies',
    [string]$Cecil = "$env:USERPROFILE\.nuget\packages\mono.cecil\0.11.5\lib\net40\Mono.Cecil.dll"
)
$ErrorActionPreference = 'Stop'
$here = $PSScriptRoot
$repo = Split-Path (Split-Path $here -Parent) -Parent           # the mod's repository
$collection = Split-Path $repo -Parent                          # ...\rimworld, where PickleTools lives

foreach ($dll in 'CucumberExpressions.dll', 'RimWorks.Pickle.Core.dll') {
    $path = Join-Path $PickleAssemblies $dll
    if (-not (Test-Path $path)) { throw "$dll not found under $PickleAssemblies" }
    [Reflection.Assembly]::LoadFrom($path) | Out-Null
}
Add-Type -Path $Cecil
$core = [AppDomain]::CurrentDomain.GetAssemblies() | Where-Object { $_.GetName().Name -eq 'RimWorks.Pickle.Core' }
$registryType = $core.GetType('RimWorks.Pickle.Core.Steps.PickleParameterTypeRegistry')
if (-not $registryType) { throw 'PickleParameterTypeRegistry no longer exists: Pickle renamed it, update this script.' }
$registry = [Activator]::CreateInstance($registryType)
function New-Expr($pattern) { New-Object CucumberExpressions.CucumberExpression($pattern, $registry) }

# The attribute argument is a C# literal: undo its escaping to get the pattern Pickle sees.
$attr = '\[(?:Given|When|Then)\("((?:[^"\\]|\\.)*)"'
function Read-Patterns($dir, $source) {
    foreach ($f in Get-ChildItem -LiteralPath $dir -Filter *.cs -ErrorAction SilentlyContinue) {
        $text = [IO.File]::ReadAllText($f.FullName)
        foreach ($m in [regex]::Matches($text, $attr)) {
            [pscustomobject]@{ Source = $source; File = $f.Name; Pattern = ($m.Groups[1].Value -replace '\\\\', '\' -replace '\\"', '"') }
        }
    }
}

$bad = 0

# --- this suite -------------------------------------------------------------------------------------
$mine = @(Read-Patterns (Join-Path $here 'Source') 'this suite')
if ($mine.Count -eq 0) { throw "no step patterns under $here\Source: the attribute shape this script looks for has changed" }
foreach ($g in ($mine | Group-Object Pattern | Where-Object { $_.Count -gt 1 })) {
    Write-Host "DUPLICATE  $($g.Name)  (declared $($g.Count) times)" -ForegroundColor Red; $bad++
}
$exprs = @()
foreach ($d in $mine) {
    try { $exprs += [pscustomobject]@{ Source = $d.Source; Pattern = $d.Pattern; Regex = (New-Expr $d.Pattern).Regex; Used = $false } }
    catch {
        $e = $_.Exception; while ($e.InnerException) { $e = $e.InnerException }
        Write-Host "INVALID  $($d.File): $($d.Pattern)`n         $($e.Message.Split("`n")[0])" -ForegroundColor Red; $bad++
    }
}

# --- what a pass can stage besides it -----------------------------------------------------------------
$others = @()
foreach ($name in 'RimWorks.Pickle.Vanilla.dll', 'RimWorks.Pickle.dll') {
    $asm = [Mono.Cecil.AssemblyDefinition]::ReadAssembly((Join-Path $PickleAssemblies $name))
    foreach ($t in $asm.MainModule.GetTypes()) {
        foreach ($m in $t.Methods) {
            foreach ($a in $m.CustomAttributes | Where-Object { $_.AttributeType.Name -in 'GivenAttribute', 'WhenAttribute', 'ThenAttribute' }) {
                $others += [pscustomobject]@{ Source = 'pickle'; Pattern = [string]$a.ConstructorArguments[0].Value }
            }
        }
    }
}
# Registered by the runner as string literals (RunSession.RegisterBuiltInEngineSteps), so an extraction of Pickle's attributes
# cannot see them. Used verbatim by Pickle's own features and by suites that have played them (Adaptive Storage Neolithic Renew).
foreach ($p in 'the save {string} is loaded', 'I save and reload', 'I save and reload as {string}', 'the save round trips') { $others += [pscustomobject]@{ Source = 'pickle-engine'; Pattern = $p } }
$pickleCount = $others.Count

$tools = @{}
foreach ($map in Get-ChildItem -LiteralPath $here -Filter 'wsl-deps.*.map') {
    foreach ($line in Get-Content -LiteralPath $map.FullName) {
        if ($line -match '^\s*(nelim\.pickletools\.[a-z]+)\s+path:PickleTools/([A-Za-z]+)/Mod') { $tools[$Matches[1]] = $Matches[2] }
    }
}
foreach ($pkg in $tools.Keys) {
    $src = Join-Path $collection "PickleTools\$($tools[$pkg])\Source"
    if (-not (Test-Path -LiteralPath $src)) { Write-Host "MISSING  $src (staged by a pass map as $pkg)" -ForegroundColor Red; $bad++; continue }
    foreach ($p in Read-Patterns $src ('tool:' + $tools[$pkg])) { $others += $p }
}
$otherExprs = @()
foreach ($o in $others) {
    try { $otherExprs += [pscustomobject]@{ Source = $o.Source; Pattern = $o.Pattern; Regex = (New-Expr $o.Pattern).Regex } } catch { }
}

# --- every step line of every feature ----------------------------------------------------------------
$lines = 0; $ambiguous = @{}; $unresolved = @(); $byFeature = @{}
foreach ($file in Get-ChildItem -LiteralPath (Join-Path $here 'Mod\Pickle\Features') -Filter *.feature) {
    foreach ($raw in [IO.File]::ReadAllLines($file.FullName)) {
        if ($raw.Trim() -notmatch '^(Given|When|Then|And|But)\s+(.+)$') { continue }
        $step = $Matches[2].Trim(); $lines++
        $mineHit = @($exprs | Where-Object { $_.Regex.IsMatch($step) })
        $otherHit = @($otherExprs | Where-Object { $_.Regex.IsMatch($step) })
        foreach ($h in $mineHit) { $h.Used = $true }
        $total = $mineHit.Count + $otherHit.Count
        if ($total -eq 0) { $unresolved += "$($file.Name): $step" }
        elseif ($total -gt 1) {
            $names = @($mineHit | ForEach-Object { 'this suite "' + $_.Pattern + '"' }) + @($otherHit | ForEach-Object { "$($_.Source) `"$($_.Pattern)`"" })
            $ambiguous["$($file.Name): $step"] = $names -join ' AND '
        }
    }
}

Write-Host ''
Write-Host "$($mine.Count) patterns of this suite, $($exprs.Count) compile. $lines step lines in the features."
Write-Host "Compared against $($otherExprs.Count) others: $pickleCount from Pickle, $($otherExprs.Count - $pickleCount) from the companions the pass maps stage ($($tools.Values -join ', '))."

foreach ($k in $ambiguous.Keys) { Write-Host "AMBIGUOUS  $k`n           $($ambiguous[$k])" -ForegroundColor Red; $bad++ }
if ($unresolved.Count -gt 0) {
    Write-Host ''
    Write-Host "$($unresolved.Count) step line(s) match no expression at all, so the scenario cannot run:" -ForegroundColor Red
    $unresolved | Sort-Object -Unique | ForEach-Object { Write-Host "  $_" -ForegroundColor Red }
    $bad++
}
$unused = @($exprs | Where-Object { -not $_.Used })
if ($unused.Count -gt 0) {
    Write-Host ''
    Write-Host "$($unused.Count) pattern(s) of this suite that no feature uses - weight, not an error:" -ForegroundColor Yellow
    foreach ($u in $unused) { Write-Host "  $($u.Pattern)" -ForegroundColor Yellow }
}

Write-Host ''
if ($bad -gt 0) {
    Write-Host "$bad PROBLEM(S). An invalid pattern makes a run play zero scenarios; an ambiguous line fails a healthy scenario; an undefined step cannot run." -ForegroundColor Red
    exit 1
}
Write-Host 'ALL PATTERNS COMPILE, NONE DECLARED TWICE, NONE AMBIGUOUS, EVERY STEP LINE RESOLVES' -ForegroundColor Green
exit 0
