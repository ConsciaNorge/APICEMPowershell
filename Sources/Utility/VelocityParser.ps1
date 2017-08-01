
<#
This code is written and maintained by Darren R. Starr from Conscia Norway AS.

License :

Copyright (c) 2017 Conscia Norway AS

Permission is hereby granted, free of charge, to any person obtaining a 
copy of this software and associated documentation files (the "Software"), 
to deal in the Software without restriction, including without limitation 
the rights to use, copy, modify, merge, publish, distribute, sublicense, 
and/or sell copies of the Software, and to permit persons to whom the Software 
is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in 
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, 
INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A 
PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT 
HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION 
OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#>

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
