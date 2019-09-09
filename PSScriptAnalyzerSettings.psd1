@{
    ExcludeRules = @(
        'PSAvoidUsingPlainTextForPassword',
        'PSUseDeclaredVarsMoreThanAssignments',
        'PSAvoidUsingConvertToSecureStringWithPlainText',
        'PSAvoidTrailingWhitespace'
    )

    Severity = @(
        "Warning",
        "Error"
    )

    Rules = @{}
}
