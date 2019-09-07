﻿# PSScriptAnalyzer tests
$ExcludeRules = 'PSAvoidUsingPlainTextForPassword','PSUseDeclaredVarsMoreThanAssignments','PSAvoidUsingConvertToSecureStringWithPlainText','PSAvoidTrailingWhitespace'

$Scripts = Get-ChildItem “$PSScriptRoot\..\” -Filter ‘*.ps1’ -Exclude '*.tests.ps1','build.ps1','install.ps1','psake.ps1' -Recurse
$Modules = Get-ChildItem “$PSScriptRoot\..\” -Filter ‘*.psm1’ -Recurse
$Rules   = Get-ScriptAnalyzerRule | Where-Object { $_.RuleName -notin $ExcludeRules }

If ($Modules.count -gt 0) {
  Describe ‘Testing all Modules against default PSScriptAnalyzer rule-set’ -Tag Default {
    foreach ($module in $modules) {
      Context “Testing Module '$($module.FullName)'” {
        foreach ($rule in $rules) {
          It “passes the PSScriptAnalyzer Rule $rule“ {
            (Invoke-ScriptAnalyzer -Path $module.FullName -IncludeRule $rule.RuleName ).Count | Should Be 0
          }
        }
      }
    }
  }
}

If ($Scripts.count -gt 0) {
  Describe ‘Testing all Script against default PSScriptAnalyzer rule-set’ -Tag Default {
    foreach ($Script in $scripts) {
      Context “Testing Script '$($script.FullName)'” {
        foreach ($rule in $rules) {
          It “passes the PSScriptAnalyzer Rule $rule“ {
            If (-not ($module.BaseName -match 'AppVeyor') -and -not ($rule.Rulename -eq 'PSAvoidUsingWriteHost') ) {
              (Invoke-ScriptAnalyzer -Path $script.FullName -IncludeRule $rule.RuleName ).Count | Should Be 0
            }
          }
        }
      }
    }
  }
}
