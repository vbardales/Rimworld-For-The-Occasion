<#
.SYNOPSIS
    Functional tests for For the Occasion, run without starting RimWorld.

.DESCRIPTION
    TESTING.md is the other half of the testing for this mod: scenarios to observe in a
    real colony. This file asks the question those scenarios cannot.

    The mod hands its conduct to vanilla classes. It relies on a removal clearing a flag, on a
    duel's outcome ending in a call to its base, on a quality calculation filtering comps by
    type, on a save key nobody else writes. None of that is enforced by the compiler, and none of
    it fails loudly: the mod is written to fail open, so when a delegation stops holding, the
    result is silence rather than an error.

    So the tests here read the answer out of the game's own code rather than asserting it, and
    execute the mod's own code rather than describing it.

.PARAMETER GameDir
    RimWorld's install directory. Found in the usual Steam place when not given.

.PARAMETER Only
    Run only these test numbers, as an array: -Only 8,12. Note that `powershell -File` cannot
    pass an array; call with -Command from outside PowerShell.

.PARAMETER ListTests
    Print the numbered test list and stop.

.PARAMETER AssemblyPath
    Optional earlier or mutated DLL for regression checks. Defaults to the shipped assembly.
    The selected DLL is copied to scratch before loading; it never replaces the shipped DLL.

.NOTES
    Windows PowerShell 5.1. Written for it, not for pwsh, and it has traps: -Raw without
    -Encoding UTF8 mangles prose, -replace ignores case, and a param's type constraint survives
    every later reassignment of that name.
#>
[CmdletBinding()]
param(
    [string] $GameDir = "C:\Program Files (x86)\Steam\steamapps\common\RimWorld",
    [int[]]  $Only,
    [string] $AssemblyPath,
    [switch] $ListTests
)

$ErrorActionPreference = 'Stop'

# RimWorld's Root calls CultureInfoUtility.EnsureEnglish before Scribe runs.
# PowerShell otherwise uses the desktop culture and writes e.g. 1,5 as a float.
[Threading.Thread]::CurrentThread.CurrentCulture = [Globalization.CultureInfo]::GetCultureInfo('en-US')

$script:Root      = Split-Path $PSScriptRoot -Parent
$script:ModDir    = Join-Path $script:Root 'Mod'
$script:Managed   = Join-Path $GameDir 'RimWorldWin64_Data\Managed'
$script:DataDir   = Join-Path $GameDir 'Data'
$script:Flags     = [Reflection.BindingFlags]'Public,NonPublic,Instance,Static,DeclaredOnly'
$script:FlatFlags = [Reflection.BindingFlags]'Public,NonPublic,Instance,Static,FlattenHierarchy'

# =============================================================================================
# Loading the two assemblies
#
# The mod's DLL is loaded FROM A COPY. Loading it where it lies locks the file for the life of
# the process, and the next `dotnet build` then fails on a destination it cannot overwrite. That
# cost a build the first time it happened.
# =============================================================================================

$script:Resolving  = @{}
$script:HarmonyDir = $null
$nugetHarmony = Join-Path $env:USERPROFILE '.nuget\packages\lib.harmony'
if (Test-Path $nugetHarmony) {
    $found = Get-ChildItem $nugetHarmony -Recurse -Filter '0Harmony.dll' -ErrorAction SilentlyContinue |
             Where-Object { $_.DirectoryName -match 'net4' } | Select-Object -First 1
    if ($found) { $script:HarmonyDir = $found.DirectoryName }
}

$resolver = [ResolveEventHandler] {
    param($theSender, $e)
    $name = $e.Name.Split(',')[0]
    foreach ($a in [AppDomain]::CurrentDomain.GetAssemblies()) {
        if ($a.GetName().Name -eq $name) { return $a }
    }
    # Without this guard, LoadFrom inside the handler re-enters it for the same name and the
    # process dies of a stack overflow rather than of a missing file.
    if ($script:Resolving.ContainsKey($name)) { return $null }
    $script:Resolving[$name] = $true
    try {
        foreach ($dir in @($script:Managed, $script:HarmonyDir)) {
            if (-not $dir) { continue }
            $p = Join-Path $dir "$name.dll"
            if (Test-Path $p) { return [Reflection.Assembly]::LoadFrom($p) }
        }
    } finally { $script:Resolving.Remove($name) }
    return $null
}
[AppDomain]::CurrentDomain.add_AssemblyResolve($resolver)

function Get-LoadedTypes($asm) {
    try { return @($asm.GetTypes()) }
    catch {
        $ex = $_.Exception
        if ($ex.Types) { return @($ex.Types | Where-Object { $_ }) }
        if ($ex.InnerException -and $ex.InnerException.Types) {
            return @($ex.InnerException.Types | Where-Object { $_ })
        }
        throw
    }
}

$script:Scratch = Join-Path ([IO.Path]::GetTempPath()) ('fto-tests-' + [Guid]::NewGuid().ToString('N').Substring(0, 8))
[void](New-Item -ItemType Directory -Path $script:Scratch -Force)
$modCopy = Join-Path $script:Scratch 'ForTheOccasion.dll'
if (-not $AssemblyPath) { $AssemblyPath = Join-Path $script:ModDir 'Assemblies\ForTheOccasion.dll' }
Copy-Item $AssemblyPath $modCopy -Force

$script:Cs       = [Reflection.Assembly]::LoadFrom((Join-Path $script:Managed 'Assembly-CSharp.dll'))
$script:Mod      = [Reflection.Assembly]::LoadFrom($modCopy)
$script:CsTypes  = Get-LoadedTypes $script:Cs
$script:ModTypes = Get-LoadedTypes $script:Mod

$script:ByName = @{}
foreach ($t in $script:CsTypes) {
    if ($t.FullName -and -not $script:ByName.ContainsKey($t.FullName)) { $script:ByName[$t.FullName] = $t }
}
foreach ($t in $script:CsTypes) {
    if ($t.Name -and -not $script:ByName.ContainsKey($t.Name)) { $script:ByName[$t.Name] = $t }
}
$script:ModByName = @{}
foreach ($t in $script:ModTypes) { $script:ModByName[$t.FullName] = $t }

function GameType($name) {
    if (-not $script:ByName.ContainsKey($name)) { throw "no such type in Assembly-CSharp: $name" }
    $script:ByName[$name]
}
function ModTypeOf($name) {
    if (-not $script:ModByName.ContainsKey($name)) { throw "no such type in the mod: $name" }
    $script:ModByName[$name]
}

# [Activator]::CreateInstance($t) is ambiguous under PowerShell 5.1 and fails on the overload
# rather than on the type. Go through the constructor.
function New-Obj($t) { $t.GetConstructor([Type]::EmptyTypes).Invoke([object[]]@()) }

# RitualOutcomeEffectDef declares both `description` and `Description`, and PowerShell's type
# system then refuses to read ANY property off such an object. Every field goes through
# reflection for that reason, not out of habit.
function Get-ObjField($obj, $name) {
    $f = $obj.GetType().GetField($name, $script:FlatFlags)
    if (-not $f) { throw "no field $name on $($obj.GetType().Name)" }
    $f.GetValue($obj)
}
function Set-ObjField($obj, $name, $value) {
    $f = $obj.GetType().GetField($name, $script:FlatFlags)
    if (-not $f) { throw "no field $name on $($obj.GetType().Name)" }
    $f.SetValue($obj, $value)
}

# =============================================================================================
# Reading IL
#
# Method bodies come back by plain reflection; Harmony is not needed and is not in the game's
# Managed folder anyway. Inside one module a metadata token is just an integer, so the operand
# of a call or a field access resolves without any lookup by name.
# =============================================================================================

function Get-AllMethods($type) {
    $out = @($type.GetMethods($script:Flags)) + @($type.GetConstructors($script:Flags))
    foreach ($n in $type.GetNestedTypes($script:Flags)) {
        $out += @($n.GetMethods($script:Flags)) + @($n.GetConstructors($script:Flags))
    }
    $out
}

function Get-IL($method) {
    $b = $null
    try { $b = $method.GetMethodBody() } catch { return $null }
    if (-not $b) { return $null }
    $b.GetILAsByteArray()
}

function Get-CallSites($method) {
    $il = Get-IL $method
    if (-not $il) { return @() }
    $mdl = $method.Module
    $ga = $null
    if ($method.DeclaringType -and $method.DeclaringType.IsGenericType) {
        $ga = $method.DeclaringType.GetGenericArguments()
    }
    $out = @()
    for ($i = 0; $i -le $il.Length - 5; $i++) {
        $op = $il[$i]
        $kind = $null
        if ($op -eq 0x28) { $kind = 'call' }
        elseif ($op -eq 0x6F) { $kind = 'callvirt' }
        elseif ($op -eq 0x73) { $kind = 'newobj' }
        if (-not $kind) { continue }
        $mm = $null
        try { $mm = $mdl.ResolveMethod([BitConverter]::ToInt32($il, $i + 1), $ga, $null) } catch { continue }
        if (-not $mm) { continue }
        $out += [pscustomobject]@{
            Kind     = $kind
            Name     = $mm.Name
            Declares = $(if ($mm.DeclaringType) { $mm.DeclaringType.FullName } else { '' })
            Target   = $mm
            Offset   = $i
            PrevByte = $(if ($i -gt 0) { $il[$i - 1] } else { 0 })
        }
    }
    $out
}

function Get-FieldSites($method) {
    $il = Get-IL $method
    if (-not $il) { return @() }
    $mdl = $method.Module
    $out = @()
    for ($i = 0; $i -le $il.Length - 5; $i++) {
        $op = $il[$i]
        if ($op -ne 0x7B -and $op -ne 0x7D -and $op -ne 0x7E -and $op -ne 0x80) { continue }
        $f = $null
        try { $f = $mdl.ResolveField([BitConverter]::ToInt32($il, $i + 1)) } catch { continue }
        if (-not $f) { continue }
        $out += [pscustomobject]@{
            Name     = $f.Name
            Offset   = $i
            Declares = $(if ($f.DeclaringType) { $f.DeclaringType.FullName } else { '' })
            Target   = $f
            Writes   = ($op -eq 0x7D -or $op -eq 0x80)
        }
    }
    $out
}

function Get-TypeSites($method) {
    $il = Get-IL $method
    if (-not $il) { return @() }
    $mdl = $method.Module
    $out = @()
    for ($i = 0; $i -le $il.Length - 5; $i++) {
        $op = $il[$i]
        if ($op -ne 0x74 -and $op -ne 0x75) { continue }
        $t = $null
        try { $t = $mdl.ResolveType([BitConverter]::ToInt32($il, $i + 1)) } catch { continue }
        if ($t) { $out += [pscustomobject]@{ Kind = $(if ($op -eq 0x75) { 'isinst' } else { 'castclass' }); Type = $t } }
    }
    $out
}

function Get-StringLits($method) {
    $il = Get-IL $method
    if (-not $il) { return @() }
    $mdl = $method.Module
    $out = @()
    for ($i = 0; $i -le $il.Length - 5; $i++) {
        if ($il[$i] -ne 0x72) { continue }
        try { $out += [pscustomobject]@{ Value = $mdl.ResolveString([BitConverter]::ToInt32($il, $i + 1)); Offset = $i } } catch { }
    }
    $out
}

# Which literals are TRANSLATION keys, as opposed to save keys or toil names, which share the
# same prefix. Asking the prefix cannot tell them apart; asking the call can. For every call to
# Translate, the key is the nearest FTO_ literal loaded before it - nearest rather than
# immediately preceding, because an argument can push a literal of its own in between, as
# ToStringPercent("0.#") does in the settings window.
function Get-TranslationKeys($method) {
    $lits = @(Get-StringLits $method)
    if ($lits.Count -eq 0) { return @() }
    $out = @()
    $last = 0
    foreach ($c in (Get-CallSites $method)) {
        if ($c.Name -cne 'Translate') { continue }
        # Every FTO_ literal since the previous Translate call, not only the nearest one: a ternary
        # that picks between a .One and a .Many key loads both before the single call.
        $from = $last
        $before = @($lits | Where-Object { $_.Offset -lt $c.Offset -and $_.Offset -ge $from -and $_.Value -cmatch '^FTO_' })
        $last = $c.Offset
        foreach ($b in $before) { $out += $b.Value }
    }
    $out
}

# Whether the CLR would let this access through without IgnoresAccessChecksTo. Protected reaches
# a subclass, which is how the mod writes the base comp's `label` and its assignedPawns lists
# while remaining an ordinary, non-publicised assembly.
function Test-AccessAllowed($accessingType, $declaringType, $isPublic, $isFamily) {
    if ($isPublic) { return $true }
    if (-not $isFamily) { return $false }
    if (-not $declaringType -or -not $accessingType) { return $false }
    $t = $accessingType
    while ($t) {
        if ($t -eq $declaringType) { return $true }
        $t = $t.BaseType
    }
    # A lambda or an iterator lives in a type nested inside the one that owns the code.
    $outer = $accessingType.DeclaringType
    while ($outer) {
        $t = $outer
        while ($t) {
            if ($t -eq $declaringType) { return $true }
            $t = $t.BaseType
        }
        $outer = $outer.DeclaringType
    }
    return $false
}

# The compiler lifts an iterator or a lambda into a type named after its method. Those bodies
# belong to the method as much as the stub does, so anything that asks "does this method call X"
# has to look there as well.
function Get-MethodAndLifted($type, $name) {
    $out = @()
    $m = $type.GetMethod($name, $script:Flags)
    if ($m) { $out += $m }
    foreach ($n in $type.GetNestedTypes($script:Flags)) {
        if ($n.Name -like "<$name>*") { $out += @($n.GetMethods($script:Flags)) }
    }
    $out
}

# =============================================================================================
# The game's own Defs, read once
# =============================================================================================

$script:GameDefsCache = $null
function Get-GameDefs {
    if ($script:GameDefsCache) { return $script:GameDefsCache }
    $defNames    = New-Object 'System.Collections.Generic.HashSet[string]'
    $apparelTags = @{}
    $parents     = @{}
    $roles       = @()
    $fileCount   = 0
    foreach ($f in Get-ChildItem $script:DataDir -Recurse -Filter '*.xml' -File) {
        $x = New-Object Xml.XmlDocument
        try { $x.Load($f.FullName) } catch { continue }
        $fileCount++
        foreach ($d in $x.SelectNodes('/Defs/*')) {
            $dn = $d.SelectSingleNode('defName')
            $label = $(if ($dn) { $dn.InnerText.Trim() } else { '(abstract) ' + $d.GetAttribute('Name') })
            if ($dn) { [void]$defNames.Add($dn.InnerText.Trim()) }

            if ($d.Name -eq 'ThingDef') {
                $p = $d.GetAttribute('ParentName')
                if ($p) {
                    if (-not $parents.ContainsKey($p)) { $parents[$p] = @() }
                    $parents[$p] += $label
                }
                foreach ($li in $d.SelectNodes('apparel/tags/li')) {
                    $tag = $li.InnerText.Trim()
                    if (-not $apparelTags.ContainsKey($tag)) { $apparelTags[$tag] = @() }
                    $apparelTags[$tag] += $label
                }
            }
            foreach ($r in $d.SelectNodes('.//roles/li')) {
                $roles += [pscustomobject]@{
                    Def = $label
                    Id  = $(if ($r.SelectSingleNode('id')) { $r.SelectSingleNode('id').InnerText.Trim() } else { '' })
                    # Vanilla writes `true` and `True` in the same file: never compare with case.
                    Required = $(if ($r.SelectSingleNode('required')) { $r.SelectSingleNode('required').InnerText.Trim() } else { '' })
                    Counts   = $(if ($r.SelectSingleNode('countsAsParticipant')) { $r.SelectSingleNode('countsAsParticipant').InnerText.Trim() } else { '' })
                }
            }
        }
    }
    $script:GameDefsCache = [pscustomobject]@{
        Files = $fileCount; DefNames = $defNames; ApparelTags = $apparelTags
        Parents = $parents; Roles = $roles
    }
    $script:GameDefsCache
}

function Get-Heirs($parentName) {
    $defs = Get-GameDefs
    $out = @()
    if (-not $defs.Parents.ContainsKey($parentName)) { return $out }
    foreach ($c in $defs.Parents[$parentName]) {
        $out += $c
        if ($c -like '(abstract)*') { $out += Get-Heirs ($c -creplace '^\(abstract\) ', '') }
    }
    $out
}

function Get-ModXml($relative) {
    $x = New-Object Xml.XmlDocument
    $x.Load((Join-Path $script:ModDir $relative))
    $x
}

# Prose is read with -Encoding UTF8 on purpose: without it, 5.1 decodes a BOM-less UTF-8 file
# with the system code page and a test of documentary drift reports mojibake as a difference.
function Get-Prose($absolute) { Get-Content $absolute -Raw -Encoding UTF8 }

# =============================================================================================
# Running the game's real patch engine, outside the game
#
# PatchOperationConditional and PatchOperationAdd are ordinary classes. The operations here are
# rebuilt FROM THE SHIPPED XML, never written out by hand, or the test would only be testing the
# copy. Apply opens on `if (DeepProfiler.enabled)`, whose buffers are null outside the game, so
# that flag goes down first and the real Apply then runs, success handling included.
# =============================================================================================

(GameType 'Verse.DeepProfiler').GetField('enabled', $script:Flags).SetValue($null, $false)

function Build-PatchOp($node) {
    $cls = $node.GetAttribute('Class')
    if (-not $cls) { $cls = 'PatchOperationAdd' }
    $t = $null
    foreach ($candidate in @($cls, "Verse.$cls")) {
        if ($script:ByName.ContainsKey($candidate)) { $t = $script:ByName[$candidate]; break }
    }
    if (-not $t) { throw "unknown patch operation class: $cls" }
    $op = New-Obj $t
    $patchOpType = GameType 'Verse.PatchOperation'
    foreach ($child in $node.ChildNodes) {
        if ($child.NodeType -ne 'Element') { continue }
        $f = $t.GetField($child.Name, $script:FlatFlags)
        if (-not $f) { continue }
        if ($f.FieldType.FullName -eq 'System.String') {
            $f.SetValue($op, $child.InnerText)
        }
        elseif ($f.FieldType.Name -eq 'XmlContainer') {
            # XmlContainer holds one field, `node`. The <value> element goes in as it stands;
            # PatchOperationAdd does the ImportNode itself.
            $xc = New-Obj $f.FieldType
            $xc.GetType().GetField('node', $script:FlatFlags).SetValue($xc, $child)
            $f.SetValue($op, $xc)
        }
        elseif ($f.FieldType -eq $patchOpType -or $f.FieldType.IsSubclassOf($patchOpType)) {
            $f.SetValue($op, (Build-PatchOp $child))
        }
    }
    $op
}

function Invoke-PatchFile($relative, $doc) {
    $patch = Get-ModXml $relative
    $n = 0
    foreach ($opNode in $patch.SelectNodes('/Patch/Operation')) {
        $n++
        [void](Build-PatchOp $opNode).Apply($doc)
    }
    $n
}

function New-DefsDoc($nodes) {
    $doc = New-Object Xml.XmlDocument
    [void]$doc.AppendChild($doc.CreateElement('Defs'))
    foreach ($n in $nodes) { [void]$doc.DocumentElement.AppendChild($doc.ImportNode($n, $true)) }
    $doc
}

$script:CeremonialComp = "ForTheOccasion.CompProperties_AssignableToPawn_CeremonialStand"

function New-OutfitStandDoc {
    $src = New-Object Xml.XmlDocument
    $src.Load((Join-Path $script:DataDir 'Odyssey\Defs\ThingDefs_Buildings\Buildings_Furniture.xml'))
    New-DefsDoc $src.SelectNodes("/Defs/ThingDef[defName='Building_OutfitStand' or defName='Building_KidOutfitStand']")
}

function Count-CeremonialComps($doc) {
    $out = @()
    foreach ($n in $doc.SelectNodes('/Defs/ThingDef')) {
        $out += [pscustomobject]@{
            Def   = $n.SelectSingleNode('defName').InnerText
            Comps = $n.SelectNodes("comps/li[@Class='$script:CeremonialComp']").Count
        }
    }
    $out
}

# =============================================================================================
# The tests
#
# Each returns nothing on success, the string 'skip' with a reason on a test that cannot run
# here, or throws with what it actually found. Never a bare boolean: `$r -eq 'skip'` on a
# boolean converts the STRING to a boolean, and every non-empty string is true, which once turned
# a whole passing suite into a suite that announced SKIP throughout.
# =============================================================================================

function Fail($msg) { throw $msg }

$script:Tests = @()
function Test-Case($group, $name, $body) {
    $script:Tests += [pscustomobject]@{ Number = $script:Tests.Count + 1; Group = $group; Name = $name; Body = $body }
}

# --- group 0 -----------------------------------------------------------------------------------

Test-Case 'harness' 'everything the other tests read is actually loaded' {
    # A test written in the negative passes whenever its input is empty. This one exists so that
    # no other test below can report "the game does not do that" while holding nothing at all.
    if ($script:CsTypes.Count -lt 10000) { Fail "Assembly-CSharp yielded $($script:CsTypes.Count) types" }
    if ($script:ModTypes.Count -lt 25)   { Fail "the mod yielded $($script:ModTypes.Count) types" }
    foreach ($n in 'ForTheOccasion.CeremonialWardrobe', 'ForTheOccasion.OfferingScan',
                   'ForTheOccasion.RitualOutcomeComp_Offerings',
                   'ForTheOccasion.RitualOutcomeComp_PreparedParticipants',
                   'ForTheOccasion.Patch_JobInterception') {
        if (-not $script:ModByName.ContainsKey($n)) { Fail "the mod no longer declares $n" }
    }
    $defs = Get-GameDefs
    if ($defs.Files -lt 1000)          { Fail "only $($defs.Files) Def files under Data" }
    if ($defs.DefNames.Count -lt 8000) { Fail "only $($defs.DefNames.Count) defNames under Data" }
    if ($defs.Roles.Count -lt 20)      { Fail "only $($defs.Roles.Count) ritual roles found" }
    $cats = (Get-ModXml 'Defs\OfferingCategoryDefs\OfferingCategories.xml').SelectNodes('/Defs/ForTheOccasion.OfferingCategoryDef')
    if ($cats.Count -lt 4) { Fail "the mod ships $($cats.Count) offering categories" }
}

# --- group 1: the mod's own C# runs ------------------------------------------------------------

Test-Case 'mod code' 'a category reports its own bad configuration' {
    # Not "the method exists": the real ConfigErrors is enumerated, on a real instance.
    $t = ModTypeOf 'ForTheOccasion.OfferingCategoryDef'
    $good = New-Obj $t
    Set-ObjField $good 'filter' (New-Obj (GameType 'Verse.ThingFilter'))
    Set-ObjField $good 'countRequired' 2
    Set-ObjField $good 'defName' 'FTO_Probe'
    $errs = @($t.GetMethod('ConfigErrors', $script:Flags).Invoke($good, @()))
    if ($errs.Count -ne 0) { Fail "a well-formed category reported: $($errs -join '; ')" }

    $noFilter = New-Obj $t
    Set-ObjField $noFilter 'defName' 'FTO_Probe'
    Set-ObjField $noFilter 'countRequired' 1
    $errs = @($t.GetMethod('ConfigErrors', $script:Flags).Invoke($noFilter, @()))
    if (-not ($errs -match 'filter')) { Fail "a category with no filter reported: $($errs -join '; ')" }

    $zero = New-Obj $t
    Set-ObjField $zero 'defName' 'FTO_Probe'
    Set-ObjField $zero 'filter' (New-Obj (GameType 'Verse.ThingFilter'))
    Set-ObjField $zero 'countRequired' 0
    $errs = @($t.GetMethod('ConfigErrors', $script:Flags).Invoke($zero, @()))
    if (-not ($errs -match 'countRequired')) { Fail "a category needing nothing reported: $($errs -join '; ')" }
}

Test-Case 'mod code' 'both quality comps derive from the base the game filters on' {
    $quality = GameType 'RimWorld.RitualOutcomeComp_Quality'
    foreach ($n in 'ForTheOccasion.RitualOutcomeComp_Offerings',
                   'ForTheOccasion.RitualOutcomeComp_PreparedParticipants') {
        if (-not (ModTypeOf $n).IsSubclassOf($quality)) { Fail "$n no longer derives from RitualOutcomeComp_Quality" }
    }
}

Test-Case 'mod code' 'each comp follows its own switch in the settings' {
    # ForTheOccasionMod.Settings is initialised to a live object rather than to null, exactly so
    # that a comp asked for its opinion before the mod constructor has run does not throw in the
    # middle of vanilla ritual code. That is what makes this callable out of the game at all.
    $settingsField = (ModTypeOf 'ForTheOccasion.ForTheOccasionMod').GetField('Settings', $script:Flags)
    $settings = $settingsField.GetValue($null)
    if (-not $settings) { Fail 'ForTheOccasionMod.Settings is null before the game starts' }

    $pairs = @(
        ,@('ForTheOccasion.RitualOutcomeComp_Offerings', 'offeringsEnabled')
        ,@('ForTheOccasion.RitualOutcomeComp_PreparedParticipants', 'preparationEnabled')
    )
    foreach ($pair in $pairs) {
        $comp = New-Obj (ModTypeOf $pair[0])
        $applies = (ModTypeOf $pair[0]).GetMethod('Applies', $script:FlatFlags)
        Set-ObjField $settings $pair[1] $true
        if (-not $applies.Invoke($comp, @($null))) { Fail "$($pair[0]) does not apply with $($pair[1]) on" }
        Set-ObjField $settings $pair[1] $false
        if ($applies.Invoke($comp, @($null))) { Fail "$($pair[0]) still applies with $($pair[1]) off" }
        Set-ObjField $settings $pair[1] $true
    }
}

Test-Case 'mod code' 'nothing of ours is left in a save when the mod is removed' {
    # RitualOutcomeEffectWorker.compDatas is scribed, in LookMode.Deep. A Data class of our own in
    # there would leave an unreadable node behind on the day the mod is uninstalled. So the
    # offerings comp returns null and the preparation comp returns a VANILLA type.
    $off = New-Obj (ModTypeOf 'ForTheOccasion.RitualOutcomeComp_Offerings')
    $d = (ModTypeOf 'ForTheOccasion.RitualOutcomeComp_Offerings').GetMethod('MakeData', $script:FlatFlags).Invoke($off, @())
    if ($null -ne $d) { Fail "the offerings comp now makes a $($d.GetType().FullName)" }

    $prep = New-Obj (ModTypeOf 'ForTheOccasion.RitualOutcomeComp_PreparedParticipants')
    $d = (ModTypeOf 'ForTheOccasion.RitualOutcomeComp_PreparedParticipants').GetMethod('MakeData', $script:FlatFlags).Invoke($prep, @())
    if ($null -eq $d) { Fail 'the preparation comp makes no data at all, so presence cannot accumulate' }
    if ($d.GetType().Assembly -ne $script:Cs) {
        Fail "the preparation comp makes a $($d.GetType().FullName), which is ours and would be scribed into the save"
    }
    if ($d.GetType().FullName -ne 'RimWorld.RitualOutcomeComp_DataThingPresence') {
        Fail "the preparation comp now makes a $($d.GetType().FullName)"
    }
    # And the field it accumulates into is still there.
    if (-not $d.GetType().GetField('presentForTicks', $script:FlatFlags)) {
        Fail 'RitualOutcomeComp_DataThingPresence no longer has presentForTicks'
    }
}

Test-Case 'mod code' 'the label can still be written from outside the comp' {
    # `label` is protected on the vanilla base, and the mod sets it at startup from the
    # translation keys. SetLabel exists for that and nothing else.
    $comp = New-Obj (ModTypeOf 'ForTheOccasion.RitualOutcomeComp_Offerings')
    (ModTypeOf 'ForTheOccasion.RitualOutcomeComp_Offerings').GetMethod('SetLabel', $script:FlatFlags).Invoke($comp, @('probe'))
    if ((Get-ObjField $comp 'label') -ne 'probe') { Fail 'SetLabel did not reach the base class field' }
    $f = (GameType 'RimWorld.RitualOutcomeComp').GetField('label', $script:Flags)
    if (-not $f) { Fail 'RitualOutcomeComp no longer declares label' }
    if ($f.IsPublic) { Fail 'label is public now, so SetLabel is dead weight and should go' }
}

Test-Case 'mod code' 'the quality budget is the number the mod tells the player it is' {
    # The two maxima are consts, read without touching the class, so its static constructor -
    # which walks the def database - is never triggered here.
    $t = ModTypeOf 'ForTheOccasion.OutcomeCompInstaller'
    $offerings = $t.GetField('OfferingsMax', $script:Flags).GetRawConstantValue()
    $prepared  = $t.GetField('PreparedMax', $script:Flags).GetRawConstantValue()
    $total = [math]::Round($offerings + $prepared, 4)
    if ($total -ne 0.25) { Fail "the budget is now $total, not 0.25" }

    $about = Get-Prose (Join-Path $script:ModDir 'About\About.xml')
    foreach ($claim in '+0.25', '+0.12', '+0.13') {
        if ($about -cnotmatch [regex]::Escape($claim)) { Fail "the About no longer states $claim" }
    }
    if ([math]::Round($offerings, 4) -ne 0.12) { Fail "offerings are worth $offerings, but the About says 0.12" }
    if ([math]::Round($prepared, 4)  -ne 0.13) { Fail "preparation is worth $prepared, but the About says 0.13" }
}

# --- group 2: what the game must still do ------------------------------------------------------

Test-Case 'the game' 'removing a garment still destroys its force-worn flag' {
    # THE reason PreparationRecord captures forced-ness at check-in. If this ever became
    # conditional, the record would be pointless rather than wrong, and nobody would notice.
    $m = (GameType 'RimWorld.Pawn_ApparelTracker').GetMethod('Notify_ApparelRemoved', $script:Flags)
    if (-not $m) { Fail 'Pawn_ApparelTracker no longer has Notify_ApparelRemoved' }
    $sites = @(Get-CallSites $m | Where-Object { $_.Name -eq 'SetForced' })
    if ($sites.Count -ne 1) { Fail "Notify_ApparelRemoved calls SetForced $($sites.Count) times" }
    # 0x16 is ldc.i4.0: the argument is a literal false, so the flag goes down for every removal.
    if ($sites[0].PrevByte -ne 0x16) {
        Fail ("SetForced is no longer preceded by ldc.i4.0 but by 0x{0:X2}: the flag may now survive a removal" -f $sites[0].PrevByte)
    }
}

Test-Case 'the game' "vanilla's own stand driver still force-flags what it hands back" {
    # This is why the mod does not reuse JobDriver_UseOutfitStand: it would hand a colonist back
    # their own street clothes force-worn, which no apparel policy can then undo.
    $t = GameType 'RimWorld.JobDriver_UseOutfitStand'
    $found = @()
    foreach ($m in (Get-AllMethods $t)) {
        $found += @(Get-CallSites $m | Where-Object { $_.Name -eq 'SetForced' } |
                    ForEach-Object { [pscustomobject]@{ Method = $m.Name; Prev = $_.PrevByte } })
    }
    if ($found.Count -eq 0) { Fail 'the vanilla stand driver no longer forces anything: the mod could use it now' }
    # 0x17 is ldc.i4.1.
    $forced = @($found | Where-Object { $_.Prev -eq 0x17 })
    if ($forced.Count -eq 0) {
        Fail "the vanilla stand driver calls SetForced but never with a literal true: $($found | ForEach-Object { $_.Method })"
    }
}

Test-Case 'the game' 'a duel still ends by calling the outcome the mod patches' {
    # LordJob_Ritual_Duel overrides ApplyOutcome. The mod patches only the base. That is sound
    # exactly as long as the override finishes with an unconditional, non-virtual call to it.
    $m = (GameType 'RimWorld.LordJob_Ritual_Duel').GetMethod('ApplyOutcome', $script:Flags)
    if (-not $m) { return 'skip: LordJob_Ritual_Duel no longer overrides ApplyOutcome, so the base patch covers duels outright' }
    $il = Get-IL $m
    $sites = @(Get-CallSites $m | Where-Object { $_.Name -eq 'ApplyOutcome' -and $_.Declares -eq 'RimWorld.LordJob_Ritual' })
    if ($sites.Count -ne 1) { Fail "the duel override calls the base ApplyOutcome $($sites.Count) times" }
    if ($sites[0].Kind -ne 'call') { Fail "the base call is a $($sites[0].Kind), not a non-virtual call" }
    # Last instruction of the body bar the return: nothing can branch around it.
    if ($sites[0].Offset -lt $il.Length - 12) {
        Fail "the base call sits at offset $($sites[0].Offset) of $($il.Length), so it may now be conditional"
    }
}

Test-Case 'the game' 'the quality calculation still picks comps out by type' {
    # RitualOutcomeComp_Quality is the base the mod's two comps use, and this is the only reason.
    $t = GameType 'RimWorld.RitualOutcomeEffectWorker_FromQuality'
    $m = $t.GetMethod('GetQuality', $script:Flags)
    if (-not $m) { Fail 'RitualOutcomeEffectWorker_FromQuality no longer has GetQuality' }
    $hits = @(Get-TypeSites $m | Where-Object { $_.Type.FullName -eq 'RimWorld.RitualOutcomeComp_Quality' })
    if ($hits.Count -eq 0) { Fail 'GetQuality no longer tests comps against RitualOutcomeComp_Quality' }
}

Test-Case 'the game' 'the outcome worker still rebuilds its comp data when the count changes' {
    # The mod APPENDS its comps to def.comps, and an existing save then holds fewer data entries
    # than there are comps. FillCompData starting over on that mismatch is what repairs the save
    # silently, in both directions - installing the mod and removing it.
    $t = GameType 'RimWorld.RitualOutcomeEffectWorker'
    $f = $t.GetField('compDatas', $script:Flags)
    if (-not $f) { Fail 'RitualOutcomeEffectWorker no longer has compDatas' }
    $m = $t.GetMethod('FillCompData', $script:Flags)
    if (-not $m) { Fail 'RitualOutcomeEffectWorker no longer has FillCompData' }
    $counts = @(Get-CallSites $m | Where-Object { $_.Name -eq 'get_Count' })
    if ($counts.Count -lt 2) {
        Fail "FillCompData reads a count $($counts.Count) times, so it may no longer compare the two lists"
    }
}

Test-Case 'the game' 'the ritual end flag is still where the prefix reads it' {
    # ApplyOutcome can be called twice and returns at once the second time. Reading `ended` in a
    # prefix, before the method sets it, is what stops the offerings being consumed twice.
    $f = (GameType 'RimWorld.LordJob_Ritual').GetField('ended', $script:Flags)
    if (-not $f) { Fail 'LordJob_Ritual no longer has an `ended` field' }
    if ($f.FieldType.FullName -ne 'System.Boolean') { Fail "`ended` is now a $($f.FieldType.Name)" }
    if ($f.IsStatic) { Fail '`ended` is static now' }
    $names = @((GameType 'RimWorld.LordJob_Ritual').GetMethod('ApplyOutcome', $script:Flags).GetParameters() | ForEach-Object { $_.Name })
    # Harmony binds a postfix parameter BY NAME. A rename here silently unbinds `cancelled`.
    if ($names -notcontains 'cancelled') { Fail "ApplyOutcome's parameters are now: $($names -join ', ')" }
}

Test-Case 'the game' 'the job tracker still exposes what the detour writes to' {
    # The mod assigns curJob and curDriver directly while it pre-reserves the deferred job's
    # targets, and enqueues through jobQueue. No publicised assembly is involved: these are
    # public in the real Assembly-CSharp, and the test is that they have stayed so.
    $t = GameType 'Verse.AI.Pawn_JobTracker'
    foreach ($n in 'curJob', 'curDriver', 'jobQueue') {
        $f = $t.GetField($n, $script:Flags)
        if (-not $f) { Fail "Pawn_JobTracker no longer has $n" }
        if (-not $f.IsPublic) { Fail "Pawn_JobTracker.$n is no longer public, so the mod cannot write it" }
    }
    if (-not $t.GetField('pawn', $script:Flags)) { Fail 'Pawn_JobTracker has no `pawn` field for the prefix to take as ___pawn' }
    $names = @($t.GetMethod('StartJob', $script:Flags).GetParameters() | ForEach-Object { $_.Name })
    foreach ($n in 'newJob', 'lastJobEndCondition', 'resumeCurJobAfterwards', 'cancelBusyStances') {
        if ($names -notcontains $n) { Fail "StartJob no longer has a parameter named $n; the prefix binds by name" }
    }
    if (-not (GameType 'Verse.AI.JobQueue').GetMethod('EnqueueFirst', $script:FlatFlags)) {
        Fail 'JobQueue no longer has EnqueueFirst'
    }
}

Test-Case 'the game' 'the two owner lists are written under keys that cannot collide' {
    # Both this mod and Shift Change put a CompAssignableToPawn subclass on the same stand def,
    # and the base scribes assignedPawns FLAT into the thing's node. Proven by reading the string
    # literals out of both PostExposeData bodies rather than by trusting either comment.
    $vanilla = @(Get-StringLits ((GameType 'RimWorld.CompAssignableToPawn').GetMethod('PostExposeData', $script:Flags)) | ForEach-Object { $_.Value })
    $ours    = @(Get-StringLits ((ModTypeOf 'ForTheOccasion.CompAssignableToPawn_CeremonialStand').GetMethod('PostExposeData', $script:Flags)) | ForEach-Object { $_.Value })
    if ($vanilla.Count -eq 0) { Fail 'CompAssignableToPawn.PostExposeData writes no key at all now' }
    if ($ours.Count -eq 0)    { Fail 'the mod comp writes no key at all' }
    foreach ($k in $ours) {
        if ($vanilla -ccontains $k) { Fail "the mod writes '$k', which the vanilla base also writes" }
        if ($k -cnotmatch '^FTO_')  { Fail "the mod writes '$k', which is not prefixed" }
    }
    # And it must not call the base, which would write the unprefixed keys as well.
    $baseCalls = @(Get-CallSites ((ModTypeOf 'ForTheOccasion.CompAssignableToPawn_CeremonialStand').GetMethod('PostExposeData', $script:Flags)) |
                   Where-Object { $_.Name -eq 'PostExposeData' })
    if ($baseCalls.Count -ne 0) { Fail 'the mod comp calls base.PostExposeData, which writes the shared keys' }
}

Test-Case 'the game' 'the gizmo hotkey the mod gives up is still taken twice over' {
    # CompAssignableToPawn's own gizmo is hardcoded to Misc4, which is N; on a storage building N
    # is already the storage settings clipboard. The mod rebuilds the gizmo with no hotkey.
    $vanillaKeys = @()
    foreach ($m in (Get-MethodAndLifted (GameType 'RimWorld.CompAssignableToPawn') 'CompGetGizmosExtra')) {
        $vanillaKeys += @(Get-FieldSites $m | Where-Object { $_.Declares -eq 'RimWorld.KeyBindingDefOf' } | ForEach-Object { $_.Name })
    }
    $clipboardKeys = @()
    foreach ($m in (Get-MethodAndLifted (GameType 'RimWorld.StorageSettingsClipboard') 'CopyPasteGizmosFor')) {
        $clipboardKeys += @(Get-FieldSites $m | Where-Object { $_.Declares -eq 'RimWorld.KeyBindingDefOf' } | ForEach-Object { $_.Name })
    }
    if ($vanillaKeys.Count -eq 0)   { return 'skip: the vanilla assignment gizmo no longer binds a hotkey, so there is nothing left to collide' }
    if ($clipboardKeys.Count -eq 0) { return 'skip: the storage clipboard no longer binds a hotkey' }
    $shared = @($vanillaKeys | Where-Object { $clipboardKeys -ccontains $_ } | Select-Object -Unique)
    if ($shared.Count -eq 0) {
        Fail "no collision any more: the gizmo takes $($vanillaKeys -join ','), the clipboard $($clipboardKeys -join ',')"
    }
    # Ours writes none at all, whatever they collide on.
    $ourKeys = @()
    foreach ($m in (Get-AllMethods (ModTypeOf 'ForTheOccasion.CompAssignableToPawn_CeremonialStand'))) {
        $ourKeys += @(Get-FieldSites $m | Where-Object { $_.Name -eq 'hotKey' -and $_.Writes })
    }
    if ($ourKeys.Count -ne 0) { Fail "the mod's gizmo writes a hotKey again, and $($shared -join ',') is taken" }
}

Test-Case 'the game' 'banishment still runs through the overload the mod patches' {
    # UnclaimAll does not reach a banished colonist: Banish clears guest status and then calls
    # SetFaction(null), and the map-exit route is gated on a flag that clearing guest status has
    # already made false. So the mod patches Banish itself, by its argument types.
    $t = GameType 'RimWorld.PawnBanishUtility'
    $all = @($t.GetMethods($script:Flags) | Where-Object { $_.Name -eq 'Banish' })
    $long = @($all | Where-Object { $_.GetParameters().Count -eq 3 })
    if ($long.Count -ne 1) { Fail "PawnBanishUtility has $($long.Count) three-argument Banish overloads" }
    $types = @($long[0].GetParameters() | ForEach-Object { $_.ParameterType.Name })
    if ($types -join '+' -cne 'Pawn+PlanetTile+Boolean') { Fail "the patched overload now takes $($types -join ', ')" }
    $short = @($all | Where-Object { $_.GetParameters().Count -eq 2 })
    if ($short.Count -eq 1) {
        $delegates = @(Get-CallSites $short[0] | Where-Object { $_.Name -eq 'Banish' })
        if ($delegates.Count -eq 0) { Fail 'the short Banish no longer delegates to the long one, so half the banishments escape the patch' }
    }
    if (-not (GameType 'RimWorld.Pawn_Ownership').GetMethod('UnclaimAll', $script:FlatFlags)) {
        Fail 'Pawn_Ownership no longer has UnclaimAll'
    }
    if (-not (GameType 'RimWorld.Pawn_Ownership').GetField('pawn', $script:Flags)) {
        Fail 'Pawn_Ownership has no `pawn` field for the postfix to take as ___pawn'
    }
}

Test-Case 'the game' 'the ritual start hook still carries the assignments' {
    $m = (GameType 'RimWorld.RitualBehaviorWorker').GetMethod('TryExecuteOn', $script:Flags)
    if (-not $m) { Fail 'RitualBehaviorWorker no longer has TryExecuteOn' }
    $names = @($m.GetParameters() | ForEach-Object { $_.Name })
    foreach ($n in 'target', 'ritual', 'assignments') {
        if ($names -notcontains $n) { Fail "TryExecuteOn's parameters are now: $($names -join ', ')" }
    }
    foreach ($n in 'required', 'countsAsParticipant') {
        if (-not (GameType 'RimWorld.RitualRole').GetField($n, $script:FlatFlags)) {
            Fail "RitualRole no longer has $n, and the rule that spares a birth reads both"
        }
    }
}

Test-Case 'the game' 'the outfit stand still holds, hands over and takes back' {
    $t = GameType 'RimWorld.Building_OutfitStand'
    $p = $t.GetProperty('HeldItems', $script:FlatFlags)
    if (-not $p) { Fail 'Building_OutfitStand no longer exposes HeldItems' }
    # It is an IReadOnlyList, which has no Contains: the mod walks it by index for that reason.
    if ($p.PropertyType.Name -cne 'IReadOnlyList`1') { Fail "HeldItems is now a $($p.PropertyType.Name)" }
    if ($p.PropertyType.GetMethod('Contains')) { Fail 'HeldItems now has Contains, so the hand-written loop can go' }

    $add = $t.GetMethod('AddApparel', $script:FlatFlags)
    if (-not $add) { Fail 'Building_OutfitStand no longer has AddApparel' }
    # The mod branches on the result to drop a garment on the floor when the stand is full.
    if ($add.ReturnType.FullName -ne 'System.Boolean') { Fail "AddApparel now returns $($add.ReturnType.Name)" }
    if (-not $t.GetMethod('RemoveApparel', $script:FlatFlags)) { Fail 'Building_OutfitStand no longer has RemoveApparel' }
    # One AllBuildingsColonistOfClass<Building_OutfitStand> has to catch the children's stand too.
    if (-not (GameType 'RimWorld.Building_KidOutfitStand').IsSubclassOf($t)) {
        Fail 'Building_KidOutfitStand no longer derives from Building_OutfitStand, so it is missed'
    }
}

Test-Case 'the game' 'face paint is still free, and still reachable' {
    # ChooseStyleItem is private; RandomTattooFor is the public way in, and the only one.
    $t = GameType 'RimWorld.PawnStyleItemChooser'
    $m = $t.GetMethod('RandomTattooFor', $script:FlatFlags)
    if (-not $m -or -not $m.IsPublic) { Fail 'PawnStyleItemChooser.RandomTattooFor is gone or no longer public' }
    foreach ($n in 'NoTattoo_Face', 'NoTattoo_Body') {
        if (-not (GameType 'RimWorld.TattooDefOf').GetField($n, $script:FlatFlags)) { Fail "TattooDefOf no longer has $n" }
    }
    $style = GameType 'RimWorld.Pawn_StyleTracker'
    foreach ($n in 'FaceTattoo', 'BodyTattoo') {
        $p = $style.GetProperty($n, $script:FlatFlags)
        if (-not $p -or -not $p.CanWrite) { Fail "Pawn_StyleTracker.$n is gone or read-only, so the paint cannot be applied" }
    }
    if (-not $style.GetMethod('Notify_StyleItemChanged', $script:FlatFlags)) {
        Fail 'Pawn_StyleTracker no longer has Notify_StyleItemChanged, so a change would not be drawn'
    }
}

Test-Case 'the game' 'the mod reaches nothing the game keeps to itself' {
    # The csproj sets GenerateAssemblyInfo false. If a publicised reference ever crept in, the
    # IgnoresAccessChecksTo attribute would NOT be emitted and every such access would throw
    # FieldAccessException at runtime, behind a perfectly clean startup. The verdict here is the
    # CLR's own accessibility flags, not a promise in a csproj.
    $declared = @($script:Mod.GetCustomAttributesData() | Where-Object { $_.AttributeType.Name -cmatch 'IgnoresAccessChecksTo' })
    $bad = @()
    foreach ($t in $script:ModTypes) {
        foreach ($m in (Get-AllMethods $t)) {
            foreach ($s in (Get-FieldSites $m)) {
                if (-not $s.Target.Module -or $s.Target.Module.Assembly -ne $script:Cs) { continue }
                $ok = Test-AccessAllowed $t $s.Target.DeclaringType $s.Target.IsPublic ($s.Target.IsFamily -or $s.Target.IsFamilyOrAssembly)
                if (-not $ok) { $bad += "$($t.Name).$($m.Name) reads $($s.Declares).$($s.Name)" }
            }
            foreach ($s in (Get-CallSites $m)) {
                if (-not $s.Target.Module -or $s.Target.Module.Assembly -ne $script:Cs) { continue }
                $ok = Test-AccessAllowed $t $s.Target.DeclaringType $s.Target.IsPublic ($s.Target.IsFamily -or $s.Target.IsFamilyOrAssembly)
                if (-not $ok) { $bad += "$($t.Name).$($m.Name) calls $($s.Declares).$($s.Name)()" }
            }
        }
    }
    if ($bad.Count -gt 0 -and $declared.Count -eq 0) {
        Fail ("the mod reaches game members it has no right to, and declares no IgnoresAccessChecksTo: " +
              (($bad | Select-Object -Unique | Select-Object -First 4) -join '; '))
    }
    if ($declared.Count -gt 0) {
        return "skip: the mod declares IgnoresAccessChecksTo, so a publiciser is in play and this test no longer decides anything"
    }
}

# --- group 3: the XML does what it says --------------------------------------------------------

Test-Case 'the xml' 'each outfit stand ends up with exactly one ceremonial owner' {
    # Run against Odyssey's real defs, not a copy written here. Two of these comps on one stand
    # would mean two owner lists under one save key, and nothing would look wrong in play.
    if (-not (Test-Path (Join-Path $script:DataDir 'Odyssey'))) { return 'skip: Odyssey is not installed' }
    $doc = New-OutfitStandDoc
    if ($doc.SelectNodes('/Defs/ThingDef').Count -ne 2) { Fail 'Odyssey no longer ships the two outfit stand defs under that file' }
    [void](Invoke-PatchFile 'Patches\OutfitStand_CeremonialOwner.xml' $doc)
    foreach ($r in (Count-CeremonialComps $doc)) {
        if ($r.Comps -ne 1) { Fail "$($r.Def) carries $($r.Comps) ceremonial owner comps" }
    }
}

Test-Case 'the xml' 'running the stand patch twice changes nothing' {
    # The two operations are complementary but NOT disjoint over time: the first creates the node
    # that makes the second one's predicate true. Idempotence is what the exclusion in the second
    # predicate buys, and it is the guard against that whole class of mistake.
    if (-not (Test-Path (Join-Path $script:DataDir 'Odyssey'))) { return 'skip: Odyssey is not installed' }
    $doc = New-OutfitStandDoc
    [void](Invoke-PatchFile 'Patches\OutfitStand_CeremonialOwner.xml' $doc)
    [void](Invoke-PatchFile 'Patches\OutfitStand_CeremonialOwner.xml' $doc)
    foreach ($r in (Count-CeremonialComps $doc)) {
        if ($r.Comps -ne 1) { Fail "after two passes $($r.Def) carries $($r.Comps) ceremonial owner comps" }
    }
}

Test-Case 'the xml' 'a stand another mod got to first is still served once' {
    # This is the case the second operation exists for. Today both Odyssey defs arrive with no
    # comps node, so the second operation never fires on a clean install and the case has to be
    # built on purpose or it would never be covered.
    if (-not (Test-Path (Join-Path $script:DataDir 'Odyssey'))) { return 'skip: Odyssey is not installed' }
    $doc = New-OutfitStandDoc
    foreach ($n in $doc.SelectNodes('/Defs/ThingDef')) {
        $comps = $doc.CreateElement('comps')
        $li = $doc.CreateElement('li')
        $li.SetAttribute('Class', 'SomeOtherMod.CompProperties_Whatever')
        [void]$comps.AppendChild($li)
        [void]$n.AppendChild($comps)
    }
    [void](Invoke-PatchFile 'Patches\OutfitStand_CeremonialOwner.xml' $doc)
    foreach ($r in (Count-CeremonialComps $doc)) {
        if ($r.Comps -ne 1) { Fail "$($r.Def), already given comps by another mod, carries $($r.Comps) of ours" }
    }
    foreach ($n in $doc.SelectNodes('/Defs/ThingDef')) {
        if ($n.SelectNodes('comps').Count -ne 1) { Fail "$($n.SelectSingleNode('defName').InnerText) ends with two comps nodes, which resolves last-wins with a red error" }
        if ($n.SelectNodes("comps/li[@Class='SomeOtherMod.CompProperties_Whatever']").Count -ne 1) { Fail 'the other mod comp was displaced' }
    }
}

Test-Case 'the xml' 'the ceremonial tag lands on the garments the comment names' {
    # Patched by criterion, never by defName. Three of the marked defs are ABSTRACT BASES, and
    # that is the mechanism rather than an accident: the royal wardrobe inherits the mark from
    # them. A DLC renaming one of these tags would silently empty the no-building path.
    $doc = New-DefsDoc (Get-GameApparelNodes)
    if ($doc.SelectNodes('/Defs/ThingDef').Count -lt 50) { Fail 'too few apparel defs collected to conclude anything' }
    [void](Invoke-PatchFile 'Patches\Apparel_CeremonialTag.xml' $doc)
    $tagged = @($doc.SelectNodes("/Defs/ThingDef[apparel/tags/li='FTO_Ceremonial']"))
    if ($tagged.Count -eq 0) { Fail 'the patch marked nothing at all' }
    foreach ($n in $tagged) {
        if ($n.SelectNodes("apparel/tags/li[text()='FTO_Ceremonial']").Count -ne 1) {
            Fail "$($n.SelectSingleNode('defName').InnerText) carries the tag more than once"
        }
    }
    $abstract = @($tagged | Where-Object { $_.GetAttribute('Abstract') -eq 'True' })
    if ($abstract.Count -eq 0) {
        Fail 'no abstract base carries the tag any more, so the royal wardrobe no longer inherits it'
    }
    $comment = Get-Prose (Join-Path $script:ModDir 'Patches\Apparel_CeremonialTag.xml')
    if ($comment -cnotmatch [regex]::Escape("Twelve defs in all")) {
        Fail 'the comment no longer states how many defs it marks'
    }
    if ($tagged.Count -ne 12) { Fail "the patch marks $($tagged.Count) defs; the comment says twelve" }
}

Test-Case 'the xml' 'the roles the rite cannot spare are counted as the comment says' {
    # The census in HoldsTheRiteTogether is a claim about the game, so it is tested against the
    # game. A DLC adding a required role is exactly the drift this catches.
    $defs = Get-GameDefs
    $required = @($defs.Roles | Where-Object { $_.Required -match '^(?i)true$' })
    $nonPart  = @($defs.Roles | Where-Object { $_.Counts -match '^(?i)false$' })
    $spared   = @($defs.Roles | Where-Object { $_.Required -notmatch '^(?i)true$' -and $_.Counts -notmatch '^(?i)false$' })

    $src = Get-Prose (Join-Path $script:Root 'Source\Preparation\Patch_RitualLifecycle.cs')
    $flat = $src -replace '\s+', ' '
    foreach ($claim in 'declare 33 roles', '29 are required and 29 do not count as participants') {
        if ($flat -cnotmatch [regex]::Escape($claim)) { Fail "the comment no longer states: $claim" }
    }
    if ($defs.Roles.Count -ne 33) { Fail "the game declares $($defs.Roles.Count) roles; the comment says 33" }
    if ($required.Count -ne 29)   { Fail "$($required.Count) roles are required; the comment says 29" }
    if ($nonPart.Count -ne 29)    { Fail "$($nonPart.Count) roles do not count as participants; the comment says 29" }
    if ($spared.Count -ne 1)      { Fail "$($spared.Count) roles escape both tests: $(($spared | ForEach-Object { $_.Def + '/' + $_.Id }) -join ', ')" }

    # And the case that made the rule necessary at all.
    $birth = @($defs.Roles | Where-Object { $_.Def -eq 'ChildBirth' })
    if ($birth.Count -lt 2) { Fail 'the childbirth ritual no longer declares two roles' }
    foreach ($r in $birth) {
        if ($r.Required -notmatch '^(?i)true$') { Fail "childbirth's $($r.Id) is no longer required" }
        if ($r.Counts -notmatch '^(?i)false$')  { Fail "childbirth's $($r.Id) now counts as a participant" }
    }
}

# --- group 4: the content hangs together -------------------------------------------------------

Test-Case 'content' 'every offering the mod can count without a gate really exists' {
    # An item listed with no MayRequire has to be a vanilla def. One that is not fails the
    # cross-reference at load and takes the whole category down with it, which is how the six
    # Romy_* perfumes were once gated on a mod that defines none of them.
    $defs = Get-GameDefs
    $cats = Get-ModXml 'Defs\OfferingCategoryDefs\OfferingCategories.xml'
    $missing = @()
    $gated = 0
    foreach ($li in $cats.SelectNodes('/Defs/ForTheOccasion.OfferingCategoryDef/filter/thingDefs/li')) {
        if ($li.GetAttribute('MayRequire')) { $gated++; continue }
        $name = $li.InnerText.Trim()
        if (-not $defs.DefNames.Contains($name)) { $missing += $name }
    }
    if ($missing.Count -gt 0) { Fail "ungated offerings that no longer exist: $($missing -join ', ')" }
    if ($gated -eq 0) { Fail 'no offering is gated any more, so no modded item can be counted' }
}

Test-Case 'content' 'every key the code asks for is translated in both languages' {
    # The keys are taken out of the compiled IL, not off a list kept by hand, and they are found
    # by the call rather than by the prefix. FTO_assignedPawns is a save key, FTO_PrepareDelay a
    # toil name and FTO_Ceremonial an apparel tag: all three share the prefix and none of them is
    # translated, so a prefix test would demand three translations that must not exist.
    $keys = New-Object 'System.Collections.Generic.HashSet[string]'
    foreach ($t in $script:ModTypes) {
        foreach ($m in (Get-AllMethods $t)) {
            foreach ($k in (Get-TranslationKeys $m)) { [void]$keys.Add($k) }
        }
    }
    if ($keys.Count -lt 10) { Fail "only $($keys.Count) translation keys found in the IL" }
    foreach ($notAKey in 'FTO_assignedPawns', 'FTO_uninstalledAssignedPawns', 'FTO_PrepareDelay', 'FTO_Ceremonial') {
        if ($keys.Contains($notAKey)) { Fail "$notAKey was taken for a translation key; it is not one" }
    }

    foreach ($lang in 'English', 'French') {
        $x = Get-ModXml "Languages\$lang\Keyed\ForTheOccasion.xml"
        $have = New-Object 'System.Collections.Generic.HashSet[string]'
        foreach ($n in $x.SelectNodes('/LanguageData/*')) { [void]$have.Add($n.Name) }
        $absent = @($keys | Where-Object { -not $have.Contains($_) })
        if ($absent.Count -gt 0) { Fail "$lang is missing: $($absent -join ', ')" }
        $orphan = @($have | Where-Object { $_ -cmatch '^FTO_' -and -not $keys.Contains($_) })
        if ($orphan.Count -gt 0) { Fail "$lang translates keys nothing asks for: $($orphan -join ', ')" }
    }
}

Test-Case 'content' 'the counts the player is told are the counts the mod uses' {
    # TESTING.md tells the player to expect exactly these to be taken. A value changed in
    # the XML and not in the file would make a true scenario read as a failure.
    $cats = Get-ModXml 'Defs\OfferingCategoryDefs\OfferingCategories.xml'
    $actual = @{}
    foreach ($c in $cats.SelectNodes('/Defs/ForTheOccasion.OfferingCategoryDef')) {
        $actual[$c.SelectSingleNode('defName').InnerText] = [int]$c.SelectSingleNode('countRequired').InnerText
    }
    $expected = @{ 'FTO_Offering_Scent' = 2; 'FTO_Offering_Food' = 4; 'FTO_Offering_Drink' = 4; 'FTO_Offering_Treasure' = 50 }
    foreach ($k in $expected.Keys) {
        if (-not $actual.ContainsKey($k)) { Fail "the mod no longer ships $k" }
        if ($actual[$k] -ne $expected[$k]) { Fail "$k now needs $($actual[$k]), not $($expected[$k])" }
    }
    $testing = Get-Prose (Join-Path $script:Root 'TESTING.md')
    if ($testing -cnotmatch [regex]::Escape('2 scent, 4 food, 4 drink, 50 treasure')) {
        Fail 'TESTING.md no longer names the amounts a scenario tells the player to count'
    }
}

Test-Case 'content' 'the table can physically carry every category at once' {
    # A 1x2 table at one stack per cell would hold two categories, and the other two could never
    # count. maxItemsInCell is 3 for that reason and no other.
    $x = Get-ModXml 'Defs\ThingDefs_Buildings\Buildings_Offerings.xml'
    $def = $x.SelectSingleNode("/Defs/ThingDef[defName='FTO_OfferingTable']")
    if (-not $def) { Fail 'the offering table def is gone' }
    $size = $def.SelectSingleNode('size').InnerText.Trim() -creplace '[()\s]', ''
    $parts = $size.Split(',')
    $cells = [int]$parts[0] * [int]$parts[1]
    $perCell = [int]$def.SelectSingleNode('building/maxItemsInCell').InnerText
    $categories = $x.OwnerDocument
    $catCount = (Get-ModXml 'Defs\OfferingCategoryDefs\OfferingCategories.xml').SelectNodes('/Defs/ForTheOccasion.OfferingCategoryDef').Count
    if ($cells * $perCell -lt $catCount) {
        Fail "the table holds $($cells * $perCell) stacks but there are $catCount categories to satisfy"
    }
    if ($def.SelectSingleNode('thingClass').InnerText.Trim() -cne 'Building_Storage') {
        Fail 'the table is no longer a Building_Storage, so nothing can be laid on it'
    }
    if (-not (GameType 'RimWorld.Building_Storage')) { Fail 'Building_Storage is gone from the game' }
    # The fixed filter is built at startup from the categories, so it must start out empty here.
    $written = $def.SelectNodes('building/fixedStorageSettings/filter/thingDefs/li')
    if ($written.Count -ne 0) { Fail "the table's def writes out $($written.Count) allowed defs, duplicating the categories" }
}

# =============================================================================================
# Settings regressions. Keep the original test numbers and historical mutation record stable.
# =============================================================================================

function Assert-Settings($settings, $expected) {
    foreach ($name in $expected.Keys) {
        $actual = Get-ObjField $settings $name
        if ($actual -ne $expected[$name]) { Fail "$name expected $($expected[$name]), got $actual" }
    }
}

function Read-TestSettings($path) {
    $settings = New-Obj (ModTypeOf 'ForTheOccasion.FtoSettings')
    $scribe = GameType 'Verse.Scribe'
    $loader = $scribe.GetField('loader', $script:Flags).GetValue($null)
    try {
        $loader.InitLoading($path)
        $settings.ExposeData()
        $loader.FinalizeLoading()
    }
    finally { [void]$scribe.GetMethod('ForceStop', $script:Flags).Invoke($null, @()) }
    $settings
}

Test-Case 'settings' 'fresh settings expose the documented eight defaults' {
    Assert-Settings (New-Obj (ModTypeOf 'ForTheOccasion.FtoSettings')) @{
        qualityBudget = [single]1; offeringsEnabled = $true; preparationEnabled = $true
        prepareOnObligation = $true; prepareOnLaunch = $true; obligationWindowHours = [single]12
        maxDetourDistance = [single]40; tattooEnabled = $true
    }
}

Test-Case 'settings' 'numeric settings reject nonfinite values and enforce UI bounds' {
    $settings = New-Obj (ModTypeOf 'ForTheOccasion.FtoSettings')
    foreach ($case in @(
        ,@(-1, -2, -3, 0, 1, 5)
        ,@(3, 49, 121, 2, 48, 120)
        ,@([single]::NaN, [single]::PositiveInfinity, [single]::NegativeInfinity, 1, 12, 40)
        ,@(0.5, 12.2, 39.8, 0.5, 12, 40)
        ,@(0, 1, 5, 0, 1, 5)
        ,@(2, 48, 120, 2, 48, 120)
    )) {
        Set-ObjField $settings 'qualityBudget' ([single]$case[0])
        Set-ObjField $settings 'obligationWindowHours' ([single]$case[1])
        Set-ObjField $settings 'maxDetourDistance' ([single]$case[2])
        $settings.Normalize()
        Assert-Settings $settings @{qualityBudget=[single]$case[3]; obligationWindowHours=[single]$case[4]; maxDetourDistance=[single]$case[5]}
    }
}

Test-Case 'settings' 'all eight values survive a real Scribe save and fresh-instance reload' {
    $settings = New-Obj (ModTypeOf 'ForTheOccasion.FtoSettings')
    $expected = @{qualityBudget=[single]1.5; offeringsEnabled=$false; preparationEnabled=$false
        prepareOnObligation=$false; prepareOnLaunch=$false; obligationWindowHours=[single]23
        maxDetourDistance=[single]87; tattooEnabled=$false}
    foreach ($name in $expected.Keys) { Set-ObjField $settings $name $expected[$name] }
    $path = Join-Path $script:Scratch 'settings-roundtrip.xml'
    $scribe = GameType 'Verse.Scribe'
    $saver = $scribe.GetField('saver', $script:Flags).GetValue($null)
    try {
        $saver.InitSaving($path, 'Settings')
        $settings.ExposeData()
        $saver.FinalizeSaving()
    }
    finally { $scribe.GetMethod('ForceStop', $script:Flags).Invoke($null, @()) }
    Assert-Settings (Read-TestSettings $path) $expected
}

Test-Case 'settings' 'missing and older serialized values recover defaults and valid bounds' {
    $path = Join-Path $script:Scratch 'settings-old.xml'
    [IO.File]::WriteAllText($path, '<Settings><qualityBudget>99</qualityBudget><obligationWindowHours>-1</obligationWindowHours><maxDetourDistance>NaN</maxDetourDistance></Settings>')
    Assert-Settings (Read-TestSettings $path) @{qualityBudget=[single]2; obligationWindowHours=[single]1
        maxDetourDistance=[single]40; offeringsEnabled=$true; preparationEnabled=$true
        prepareOnObligation=$true; prepareOnLaunch=$true; tattooEnabled=$true}
    [IO.File]::WriteAllText($path, '<Settings/>')
    Assert-Settings (Read-TestSettings $path) @{qualityBudget=[single]1; obligationWindowHours=[single]12
        maxDetourDistance=[single]40; offeringsEnabled=$true; preparationEnabled=$true
        prepareOnObligation=$true; prepareOnLaunch=$true; tattooEnabled=$true}
}

Test-Case 'settings' 'the shortcut declares native hidden visibility and the shared Options dialog' {
    $node = (Get-ModXml 'Defs\MainButtonDefs\MainButtons.xml').SelectSingleNode('/Defs/MainButtonDef[defName="FTO_Settings"]')
    if (-not $node) { Fail 'the discoverable settings MainButtonDef is absent' }
    $def = New-Obj (GameType 'RimWorld.MainButtonDef')
    Set-ObjField $def 'buttonVisible' ([bool]::Parse($node.buttonVisible))
    $workerType = ModTypeOf $node.workerClass
    Set-ObjField $def 'workerClass' $workerType
    $worker = $def.Worker
    if (Get-ObjField $def 'buttonVisible') { Fail 'settings button is visible on a clean configuration' }
    Set-ObjField $def 'buttonVisible' $true
    if (-not (Get-ObjField (Get-ObjField $worker 'def') 'buttonVisible')) { Fail 'worker does not share the editable definition' }
    Set-ObjField $def 'buttonVisible' $false
    if (Get-ObjField (Get-ObjField $worker 'def') 'buttonVisible') { Fail 'worker does not see a restored hidden definition' }
    if ($workerType.GetMethod('get_Visible', $script:Flags)) { Fail 'shortcut overrides the native visibility contract' }
    # Calling native Visible would initialize ModsConfig and scan the user's installed mods.
    # Read the installed game's actual getter instead; no interactive visibility test is claimed.
    $nativeVisible = (GameType 'RimWorld.MainButtonWorker').GetMethod('get_Visible', $script:Flags)
    if (-not (@(Get-FieldSites $nativeVisible).Name -contains 'buttonVisible')) { Fail 'native Visible no longer reads the configurable field' }
    if ($node.validWithoutMap -ne 'true') { Fail 'settings cannot be opened without a map' }
    $factory = $workerType.GetMethod('CreateDialog', $script:Flags)
    $calls = @(Get-CallSites $factory)
    $lookup = @($calls | Where-Object { $_.Declares -eq 'Verse.LoadedModManager' -and $_.Name -eq 'GetMod' })
    if ($lookup.Count -ne 1 -or $lookup[0].Target.GetGenericArguments()[0] -ne (ModTypeOf 'ForTheOccasion.ForTheOccasionMod')) {
        Fail 'shortcut does not retrieve the existing ForTheOccasionMod instance'
    }
    if (@($calls | Where-Object { $_.Kind -eq 'newobj' -and $_.Declares -eq 'RimWorld.Dialog_ModSettings' }).Count -ne 1) {
        Fail 'shortcut no longer creates the native Mod settings dialog'
    }
    $activate = @(Get-CallSites ($workerType.GetMethod('Activate', $script:Flags)))
    if (-not ($activate.Name -contains 'CreateDialog') -or -not ($activate.Name -contains 'Add')) { Fail 'Activate does not open the shared dialog' }
    $close = @(Get-CallSites ((GameType 'RimWorld.Dialog_ModSettings').GetMethod('PreClose', $script:Flags)))
    if (-not ($close.Name -contains 'WriteSettings')) { Fail 'native dialog no longer saves on close' }
}

Test-Case 'settings' 'disabling preparation cannot bypass a borrowers return path' {
    # Test the delivered control flow, including calls on both sides of the guard.
    # The original bug reads the switch and returns before RecordFor/Undress.
    $decide = (ModTypeOf 'ForTheOccasion.Patch_JobInterception').GetMethod('Decide', $script:Flags)
    $switch = @(Get-FieldSites $decide | Where-Object Name -eq 'preparationEnabled')
    $returns = @(Get-CallSites $decide | Where-Object Name -eq 'Undress')
    if ($switch.Count -ne 1 -or $returns.Count -ne 2) { Fail 'return-path shape changed; review the guard regression' }
    if (@($returns | Where-Object { $_.Offset -gt $switch[0].Offset }).Count) { Fail 'preparation switch bypasses an existing return path' }
    $stay = (ModTypeOf 'ForTheOccasion.PreparationReason').GetMethod('ShouldStayDressed', $script:Flags)
    $staySwitch = @(Get-FieldSites $stay | Where-Object Name -eq 'preparationEnabled')
    $ritual = @(Get-CallSites $stay | Where-Object Name -eq 'InRitual')
    if ($staySwitch.Count -ne 1 -or $ritual.Count -ne 1 -or $staySwitch[0].Offset -gt $ritual[0].Offset) {
        Fail 'a running ritual retains dress despite disabling preparation'
    }
    $change = (ModTypeOf 'ForTheOccasion.JobDriver_PrepareForOccasion').GetMethod('DoChange', $script:Flags)
    $guard = @(Get-FieldSites $change | Where-Object Name -eq 'preparationEnabled')
    $calls = @(Get-CallSites $change)
    $undress = @($calls | Where-Object Name -eq 'Undress')
    $dress = @($calls | Where-Object Name -eq 'Dress')
    if ($guard.Count -ne 1 -or $undress.Count -ne 1 -or $dress.Count -ne 1 -or
        $guard[0].Offset -lt $undress[0].Offset -or $guard[0].Offset -gt $dress[0].Offset) {
        Fail 'an in-flight job does not guard dressing while preserving undressing'
    }
}

Test-Case 'settings' 'saving settings invalidates anticipation and rescales installed quality curves' {
    $mod = ModTypeOf 'ForTheOccasion.ForTheOccasionMod'
    $calls = @(Get-CallSites ($mod.GetMethod('WriteSettings', $script:Flags)))
    foreach ($name in 'Normalize', 'WriteSettings', 'Invalidate', 'RescaleCurves') {
        if (-not ($calls.Name -contains $name)) { Fail "settings close no longer calls $name" }
    }
    $watch = ModTypeOf 'ForTheOccasion.ObligationWatch'
    $watch.GetField('lastCheckTick', $script:Flags).SetValue($null, 123456)
    $watch.GetField('cachedOpen', $script:Flags).SetValue($null, $true)
    $watch.GetMethod('Invalidate', $script:Flags).Invoke($null, @())
    if ($watch.GetField('lastCheckTick', $script:Flags).GetValue($null) -ge 0 -or
        $watch.GetField('cachedOpen', $script:Flags).GetValue($null)) { Fail 'anticipation cache survived settings close' }
    $rescale = (ModTypeOf 'ForTheOccasion.OutcomeCompInstaller').GetMethod('RescaleCurves', $script:Flags)
    $fields = @(Get-FieldSites $rescale)
    if (-not ($fields.Name -contains 'qualityBudget') -or @($fields | Where-Object { $_.Name -eq 'curve' -and $_.Writes }).Count -ne 2) {
        Fail 'rescaling does not read current budget and replace both comp curves'
    }
}

# =============================================================================================
Test-Case 'settings' 'closing settings applies the selected budget to actual installed comps' {
    # No world or user configuration is loaded. Native logging is disabled because its
    # sink requires Unity; labels fall back to keys, tested separately by content checks.
    $logLock = (GameType 'Verse.Log').GetMethod('LockMessages', $script:Flags).Invoke($null, @())
    $mod = ModTypeOf 'ForTheOccasion.ForTheOccasionMod'
    $settingsField = $mod.GetField('Settings', $script:Flags)
    $oldSettings = $settingsField.GetValue($null)
    $settings = New-Obj (ModTypeOf 'ForTheOccasion.FtoSettings')
    $settingsField.SetValue($null, $settings)
    $installer = ModTypeOf 'ForTheOccasion.OutcomeCompInstaller'
    $offList = $null; $prepList = $null
    try {
        $offList = $installer.GetField('offeringComps', $script:Flags).GetValue($null)
        $prepList = $installer.GetField('preparedComps', $script:Flags).GetValue($null)
        $off = New-Obj (ModTypeOf 'ForTheOccasion.RitualOutcomeComp_Offerings')
        $prep = New-Obj (ModTypeOf 'ForTheOccasion.RitualOutcomeComp_PreparedParticipants')
        $offList.Add($off); $prepList.Add($prep)
        # Skip only the mod constructor's user-config read, not its WriteSettings implementation.
        # Its base modSettings is null; serialization is exercised separately in tests 33-34.
        $instance = [Runtime.Serialization.FormatterServices]::GetUninitializedObject($mod)
        foreach ($budget in @([single]0, [single]0.5, [single]1, [single]2, [single]1)) {
            Set-ObjField $settings 'qualityBudget' $budget
            $mod.GetMethod('WriteSettings', $script:Flags).Invoke($instance, @())
            # SimpleCurve is enumerable; returning it through Get-ObjField would unwrap points.
            $offCurve = $off.GetType().GetField('curve', $script:FlatFlags).GetValue($off)
            $prepCurve = $prep.GetType().GetField('curve', $script:FlatFlags).GetValue($prep)
            if ([math]::Abs($offCurve.Evaluate([single]100) - 0.12 * $budget) -gt 0.00001) { Fail 'offering budget not applied on close' }
            if ([math]::Abs($prepCurve.Evaluate([single]100) - 0.13 * $budget) -gt 0.00001) { Fail 'preparation budget not applied on close' }
            if ($offCurve.Evaluate([single]0) -ne 0 -or $prepCurve.Evaluate([single]0) -ne 0) { Fail 'empty ritual receives a bonus' }
        }
        if ((ModTypeOf 'ForTheOccasion.FtoLog').GetProperty('Disabled').GetValue($null)) { Fail 'mod silently disabled during settings application' }
    }
    finally {
        if ($null -ne $offList) { [void]$offList.Remove($off) }
        if ($null -ne $prepList) { [void]$prepList.Remove($prep) }
        $settingsField.SetValue($null, $oldSettings)
        $logLock.Dispose()
    }
}

Test-Case 'content' 'a counted message has a singular and a plural sentence in both languages' {
    # TRANSLATIONS.md, counts and plurals: never a count in front of a pluralised noun. French
    # pluralises every word whatever the count, so "1 offrandes" would be printed. Each form is a
    # whole sentence with the count as {0}, and the code has to be able to ask for both.
    $asked = New-Object 'System.Collections.Generic.HashSet[string]'
    foreach ($m in (Get-AllMethods (ModTypeOf 'ForTheOccasion.Patch_ConsumeOfferings'))) {
        foreach ($k in (Get-TranslationKeys $m)) { [void]$asked.Add($k) }
    }
    foreach ($form in 'FTO_OfferingsConsumed.One', 'FTO_OfferingsConsumed.Many') {
        if (-not $asked.Contains($form)) { Fail "the ritual-end hook no longer asks for $form" }
    }
    if ($asked.Contains('FTO_OfferingsConsumed')) { Fail 'the bare FTO_OfferingsConsumed is asked for again, with a count in front of a noun' }
    foreach ($lang in 'English', 'French') {
        $x = Get-ModXml "Languages\$lang\Keyed\ForTheOccasion.xml"
        $one = $x.SelectSingleNode('/LanguageData/*[local-name()="FTO_OfferingsConsumed.One"]')
        $many = $x.SelectSingleNode('/LanguageData/*[local-name()="FTO_OfferingsConsumed.Many"]')
        if (-not $one -or -not $many) { Fail "$lang lacks a .One or a .Many form of FTO_OfferingsConsumed" }
        foreach ($n in $one, $many) {
            if ($n.InnerText -cnotmatch '^\S.*\{0\}') { Fail "$lang $($n.Name) has no {0} for the count" }
        }
        if ($one.InnerText -ceq $many.InnerText) { Fail "$lang uses the same sentence for one and for many" }
        if ($x.SelectSingleNode('/LanguageData/*[local-name()="FTO_OfferingsConsumed"]')) { Fail "$lang still defines the bare FTO_OfferingsConsumed" }
    }
}

# =============================================================================================
# Collecting the game's apparel defs, used by one test above
# =============================================================================================

function Get-GameApparelNodes {
    $out = @()
    foreach ($f in Get-ChildItem $script:DataDir -Recurse -Filter '*.xml' -File) {
        $x = New-Object Xml.XmlDocument
        try { $x.Load($f.FullName) } catch { continue }
        foreach ($n in $x.SelectNodes('/Defs/ThingDef[apparel]')) { $out += $n }
    }
    $out
}

# =============================================================================================
# Running them
# =============================================================================================

if ($ListTests) {
    foreach ($t in $script:Tests) { '{0,3}. [{1,-9}] {2}' -f $t.Number, $t.Group, $t.Name }
    return
}

$pass = 0; $fail = 0; $skip = 0
$failures = @()
$started = Get-Date

Write-Host ''
Write-Host 'For the Occasion, functional tests' -ForegroundColor White
Write-Host ("game: " + $GameDir)
Write-Host ''

$lastGroup = ''
foreach ($t in $script:Tests) {
    if ($Only -and ($Only -notcontains $t.Number)) { continue }
    if ($t.Group -ne $lastGroup) {
        Write-Host ''
        Write-Host ("  " + $t.Group) -ForegroundColor DarkGray
        $lastGroup = $t.Group
    }
    $result = $null
    $error1 = $null
    try { $result = & $t.Body } catch { $error1 = $_ }

    if ($error1) {
        $fail++
        Write-Host ('{0,3}  FAIL  {1}' -f $t.Number, $t.Name) -ForegroundColor Red
        $msg = $error1.Exception.Message
        Write-Host ('          ' + $msg) -ForegroundColor Red
        $failures += [pscustomobject]@{ Number = $t.Number; Name = $t.Name; Message = $msg }
    }
    # A bare -eq against a boolean converts the STRING and every non-empty string is true, so the
    # type is tested first. Getting this wrong once made a whole passing suite announce SKIP.
    elseif (($result -is [string]) -and ($result -cmatch '^skip')) {
        $skip++
        Write-Host ('{0,3}  SKIP  {1}' -f $t.Number, $t.Name) -ForegroundColor DarkYellow
        Write-Host ('          ' + ($result -creplace '^skip:?\s*', '')) -ForegroundColor DarkYellow
    }
    else {
        $pass++
        Write-Host ('{0,3}  ok    {1}' -f $t.Number, $t.Name) -ForegroundColor DarkGreen
    }
}

$elapsed = [int]((Get-Date) - $started).TotalSeconds
Write-Host ''
Write-Host ("{0} passed, {1} failed, {2} skipped, in {3}s" -f $pass, $fail, $skip, $elapsed) -ForegroundColor White
if ($failures.Count -gt 0) {
    Write-Host ''
    foreach ($f in $failures) { Write-Host ("  {0}. {1}" -f $f.Number, $f.Name) -ForegroundColor Red }
}
Write-Host ''

try { Remove-Item $script:Scratch -Recurse -Force -ErrorAction SilentlyContinue } catch { }
exit $(if ($fail -gt 0) { 1 } else { 0 })

# =============================================================================================
# What these tests are worth
#
# A test that has never been seen to fail is a guess. All thirty were put through a mutation
# campaign on 2026-09-12, on copies of the mod and of this file, never on the repository itself.
# Thirty-four mutations, each of which had to wake its own test and no other. All thirty-four
# did.
#
# Eighteen of them changed the mod: the idempotence guard taken out of the stand patch, an
# offering amount moved, a French key deleted, an English key added that nothing asks for, the
# table reduced to one stack per cell, an ungated offering pointed at a def that does not exist,
# the table's filter written out a second time, the budget raised in the About and then in the
# code, the offerings comp made to produce data of its own, a settings switch stopped being read,
# a config error stopped being reported, SetLabel made a no-op, the shared base called from
# PostExposeData, the key prefix dropped, a hotkey taken back, the second stand operation made
# never to match, and the three censuses in the comments and the docs made stale one at a time.
# Every mutation that touched C# had to compile first, or it would have proved nothing.
#
# Thirteen of them changed the QUESTION instead. Tests 8 to 21 interrogate Assembly-CSharp, and
# no edit to this mod can reach them: a member renamed inside a copy of this file is the only way
# to see them go red. Each of them named what it could not find, which is what they are for.
#
# ONE test has never been seen red: number 1, the harness guard. It exists so that a suite run
# against an empty game folder cannot report "the game no longer does that" thirty times over,
# and the only mutation that reaches it would take every other test down with it. Read it as a
# precondition rather than as a test.
#
# This does not run in CI. It needs RimWorld's Managed folder and its Data folder, and a build
# runner has neither. The workflow compiles the mod; this file is run by hand before a release.
#
# The other half of the testing is TESTING.md, and it is not optional. Nothing here observes
# a colonist walking to a wardrobe, an offering being taken off a table, or a raid arriving while
# somebody is in evening dress. These tests say that the game still does what the mod expects of
# it. Only a colony says that the mod does what it says it does.
# =============================================================================================
