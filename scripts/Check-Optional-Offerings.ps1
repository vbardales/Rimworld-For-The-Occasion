<#
.SYNOPSIS
    Check optional offering references against installed 1.6 Defs and LoadFolders.
.DESCRIPTION
    Reads metadata and XML only. Does not activate mods or modify game configuration.
    Missing source packages fail verification; they are not silently skipped.
    Override SourcePaths when the installed packages live elsewhere.
#>
[CmdletBinding()]
param(
    [string] $WorkshopDir = 'C:\Program Files (x86)\Steam\steamapps\workshop\content\294100',
    [hashtable] $SourcePaths,
    [string] $OfferingsFile = (Join-Path $PSScriptRoot '..\Mod\Defs\OfferingCategoryDefs\OfferingCategories.xml')
)
$ErrorActionPreference = 'Stop'
if (-not $SourcePaths) {
    $SourcePaths = @{
        'romyashi.perfumes' = Join-Path $WorkshopDir '3013711969'
        'romyashi.animaexpansion' = Join-Path $WorkshopDir '3532147582'
        'vanillaexpanded.vbrewe' = Join-Path $WorkshopDir '2186560858'
        'nelim.rimscent.extended.incenseplus' = Join-Path $PSScriptRoot '..\..\RimScentExtendedIncensePlusExpansion\Mod'
        'nelim.rumandshanties' = Join-Path $PSScriptRoot '..\..\RumAndShanties\Mod'
    }
}
function Read-Xml($path) {
    $doc = New-Object Xml.XmlDocument
    $doc.Load((Resolve-Path -LiteralPath $path).Path)
    return $doc
}
function Satisfies($node, $active) {
    $all = $node.GetAttribute('MayRequire')
    if ($all) { foreach ($id in $all.Split(',')) { if (-not $active.Contains($id.Trim())) { return $false } } }
    $any = $node.GetAttribute('MayRequireAnyOf')
    if ($any -and -not @($any.Split(',') | Where-Object { $active.Contains($_.Trim()) }).Count) { return $false }
    return $true
}
foreach ($id in $SourcePaths.Keys) {
    $about = Read-Xml (Join-Path $SourcePaths[$id] 'About\About.xml')
    if ($about.ModMetaData.packageId -ine $id) { throw "Wrong package at $($SourcePaths[$id]): expected $id" }
    if ('1.6' -notin @($about.ModMetaData.supportedVersions.li)) { throw "$id does not declare 1.6" }
}
$offerings = Read-Xml $OfferingsFile
$references = @($offerings.SelectNodes('/Defs/ForTheOccasion.OfferingCategoryDef/filter/thingDefs/li[@MayRequire]'))
if ($references.Count -ne 23) { throw "Expected the current 23 optional items, found $($references.Count); review this coverage inventory" }
$profiles = @{
    'none' = @()
    'brewing only' = @('vanillaexpanded.vbrewe')
    'brewing and plants' = @('vanillaexpanded.vbrewe','vanillaexpanded.vplantse')
    'brewing and plants copy' = @('vanillaexpanded.vbrewe','vanillaexpanded.vplantse_copy')
    'perfumes only' = @('romyashi.perfumes')
    'anima only' = @('romyashi.animaexpansion')
    'perfumes and anima' = @('romyashi.perfumes','romyashi.animaexpansion')
    'all' = @($SourcePaths.Keys) + @('vanillaexpanded.vplantse')
}
foreach ($profile in $profiles.Keys | Sort-Object) {
    $active = [Collections.Generic.HashSet[string]]::new([StringComparer]::OrdinalIgnoreCase)
    foreach ($id in @('ludeon.rimworld','ludeon.rimworld.ideology','ludeon.rimworld.royalty','brrainz.harmony') + $profiles[$profile]) { [void]$active.Add($id) }
    $defs = [Collections.Generic.HashSet[string]]::new([StringComparer]::Ordinal)
    foreach ($id in $SourcePaths.Keys) {
        if (-not $active.Contains($id)) { continue }
        $root = $SourcePaths[$id]
        $folders = @($root, (Join-Path $root '1.6'))
        $loadPath = Join-Path $root 'LoadFolders.xml'
        if (Test-Path -LiteralPath $loadPath) {
            $folders = @()
            $load = Read-Xml $loadPath
            $entries = @($load.SelectNodes('/loadFolders/v1.6/li'))
            if (-not $entries.Count) { throw "No 1.6 LoadFolders entry for $id; review actual load rules" }
            foreach ($entry in $entries) {
                $include = $entry.GetAttribute('IfModActive')
                $exclude = $entry.GetAttribute('IfModNotActive')
                if ($include -and -not $active.Contains($include)) { continue }
                if ($exclude -and $active.Contains($exclude)) { continue }
                $relative = $entry.InnerText.Trim().Trim('/')
                $folders += $(if ($relative) { Join-Path $root $relative } else { $root })
            }
        }
        foreach ($folder in $folders | Sort-Object -Unique) {
            $defsDir = Join-Path $folder 'Defs'
            if (-not (Test-Path -LiteralPath $defsDir)) { continue }
            foreach ($file in Get-ChildItem -LiteralPath $defsDir -Recurse -Filter '*.xml' -File) {
                $doc = Read-Xml $file.FullName
                foreach ($def in $doc.SelectNodes('/Defs/ThingDef[defName]')) {
                    if (Satisfies $def $active) { [void]$defs.Add($def.defName) }
                }
            }
        }
    }
    $checked = 0
    foreach ($reference in $references) {
        if (-not (Satisfies $reference $active)) { continue }
        $name = $reference.InnerText.Trim()
        if (-not $defs.Contains($name)) { throw "$profile exposes $name, but no active source ThingDef defines it" }
        $checked++
    }
    if ($profile -eq 'all' -and $checked -ne 23) { throw 'The all profile must exercise every optional reference' }
    Write-Output "$profile : $checked optional references resolved"
}
Write-Output '8 profiles passed; 23 distinct optional targets checked. XML checks, not in-game integration tests.'
