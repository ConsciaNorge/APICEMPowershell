
class ParserResult {
    [string[]]$Variables
    [string[]]$SetVariables
    [string[]]$UnsetVariables
}

<#
    .SYNOPSIS
        A super-poor man's version of a velocity script parser

    .NOTES
        I'll do a better job when I get around to it and when I learn
        the grammar better.
#>
class VelocityParser
{
    hidden static [string[]]ExtractVariables([string]$source)
    {
        $matches = [RegEx]::Matches($source, '\$[A-Za-z_][A-Za-z0-9\-_]*')
        if($null -eq $matches -or $matches.Count -eq 0) {
            return @()
        }

        return $matches.Value | Select-Object -unique
    }

    hidden static [string[]]ExtractSetVariables([string]$source)
    {
        $matches = [RegEx]::Matches($source, '(^#|[\r\n]#).*((set\s*\(\s*(?<varname>\$[A-Za-z_][A-Za-z0-9\-_]*)\s*\=)|(foreach\s*\(\s*(?<varname>\$[A-Za-z_][A-Za-z0-9\-_]*)\s*))[^\r\n]*')
        if($null -eq $matches -or $matches.Count -eq 0) {
            return @()
        }

        return $matches.ForEach{ $_.Groups['varname'].Value } | Select-Object -unique
    }

    static [ParserResult]parse([string]$source)
    {
        $result = [ParserResult]@{
            Variables = [VelocityParser]::ExtractVariables($source)
            SetVariables = [VelocityParser]::ExtractSetVariables($source)
        }

        $result.UnsetVariables = $result.Variables | Where-Object { $result.SetVariables.IndexOf($_) -eq -1 }

        return $result
    }
}

Function Get-VelocityDocumentInformation
{
    Param(
        [Parameter(Mandatory)]
        [string]$Source
    )

    return [VelocityParser]::parse($source)
}
