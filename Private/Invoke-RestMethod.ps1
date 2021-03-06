﻿function Invoke-RestMethod
{
    [CmdletBinding(HelpUri='http://go.microsoft.com/fwlink/?LinkID=217034')]
    param(
        [Microsoft.PowerShell.Commands.WebRequestMethod]
        ${Method},

        [Parameter(Mandatory=$true, Position=0)]
        [ValidateNotNullOrEmpty()]
        [uri]
        ${Uri},

        [Microsoft.PowerShell.Commands.WebRequestSession]
        ${WebSession},

        [Alias('SV')]
        [string]
        ${SessionVariable},

        [pscredential]
        ${Credential},

        [switch]
        ${UseDefaultCredentials},

        [ValidateNotNullOrEmpty()]
        [string]
        ${CertificateThumbprint},

        [ValidateNotNull()]
        [System.Security.Cryptography.X509Certificates.X509Certificate]
        ${Certificate},

        [string]
        ${UserAgent},

        [switch]
        ${DisableKeepAlive},

        [int]
        ${TimeoutSec},

        [System.Collections.IDictionary]
        ${Headers},

        [ValidateRange(0, 2147483647)]
        [int]
        ${MaximumRedirection},

        [uri]
        ${Proxy},

        [pscredential]
        ${ProxyCredential},

        [switch]
        ${ProxyUseDefaultCredentials},

        [Parameter(ValueFromPipeline=$true)]
        [System.Object]
        ${Body},

        [string]
        ${ContentType},

        [ValidateSet('chunked','compress','deflate','gzip','identity')]
        [string]
        ${TransferEncoding},

        [string]
        ${InFile},

        [string]
        ${OutFile},

        [switch]
        ${PassThru},

        [switch]
        ${AllowEscapedDotsAndSlashes})

    begin
    {
        try {
            $outBuffer = $null
            if ($PSBoundParameters.TryGetValue('OutBuffer', [ref]$outBuffer))
            {
                $PSBoundParameters['OutBuffer'] = 1
            }
            
            $wrappedCmd = $ExecutionContext.InvokeCommand.GetCommand('Microsoft.PowerShell.Utility\Invoke-RestMethod', [System.Management.Automation.CommandTypes]::Cmdlet)

            # check whether need to disable UnEscapingDotsAndSlases on UriParser
            $requiresDisableUnEscapingDotsAndSlashes = ($AllowEscapedDotsAndSlashes -and $Uri.OriginalString -match '%2f')
            # remove additional proxy parameter to prevent original function from failing
            if($PSBoundParameters['AllowEscapedDotsAndSlashes']) { $null = $PSBoundParameters.Remove('AllowEscapedDotsAndSlashes') }

            
            #By default the content-length is -1, which prevents ['Body'] from setting the content length.
            if($PSBoundParameters['Body']) {
                if ($PSBoundParameters['Headers']) {
                    $PSBoundParameters['Headers']['content-length'] = 0
                } else {
                    $PSBoundParameters['Headers'] = @{ 'content-length' = 0 }
                }
            }
            
            #It seems that sometimes errors occur if you don't yield a short time.
            Start-Sleep -Milliseconds 100

            $scriptCmd = {& $wrappedCmd @PSBoundParameters }
            $steppablePipeline = $scriptCmd.GetSteppablePipeline($myInvocation.CommandOrigin)
            $steppablePipeline.Begin($PSCmdlet)
        } catch {
            throw
        }
    }

    process
    {
        try {
            # Disable UnEscapingDotsAndSlashes on UriParser when necessary
            if ($requiresDisableUnEscapingDotsAndSlashes) {
                PreventUnEscapeDotsAndSlashesOnUri
            }

            $steppablePipeline.Process($_)
        } 
        finally {
            # Restore UnEscapingDotsAndSlashes on UriParser when necessary
            if ($requiresDisableUnEscapingDotsAndSlashes) {
                RestoreUriParserFlags
            }
        }
    }

    end
    {
        try {
            $steppablePipeline.End()
        } catch {
            throw
        }
    }
}
<#

.ForwardHelpTargetName Invoke-RestMethod
.ForwardHelpCategory Cmdlet

#>
