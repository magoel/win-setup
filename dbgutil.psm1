function Override-Feature{
	<#
		.SYNOPSIS
		Override a feature gate
		.DESCRIPTION
		Override a feature gate
		.EXAMPLE
		Override-Feature -FullGateName "Microsoft.Office.Word.MeteorInWord" -Value "true"
#>
		Param(
				[parameter(Mandatory=$true)]
				[string]$FullGateName,
				[parameter(Mandatory=$true)]
				[string]$Value
			 )
		#New-Alias -Name "Feature-Override" -Value \\ocentral\tools\experimentation\FeatureOverride.ps1
		Write-Output "Feature-Override $FullGateName $Value"
		Get-Item -Path HKCU:\Software\Microsoft\Office\16.0\Common\ExperimentEcs\Overrides  | Set-ItemProperty -Name $FullGateName -Value $Value;
}


function Break-File { 
	<#
	.SYNOPSIS
		Generate XML file for importing breakpoints of all functions in a cpp file
	.Example
		Break-File -FilePath "C:\path\to\file.cpp"
	#>
	Param(
			[Parameter(Mandatory=$true)]
			[string]$FilePath
		 )
	$TmpFile="$(split-path -leaf $FilePath).xml"
	cat $FilePath | sls "%%Function: (.*)" | % { $_.Matches.Groups[1].Value } | % -Begin {
		$header=@"
<?xml version="1.0" encoding="utf-8"?>
<BreakpointCollection xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xmlns:xsd="http://www.w3.org/2001/XMLSchema">
	<Breakpoints>
"@
		Write-output $header
	} -End {
		$footer=@"
	</Breakpoints>
</BreakpointCollection>
"@
		Write-output $footer
	} -Process {
		$FunctionName=$_
		$current=@"
<Breakpoint>
	<Version>15</Version>
	<IsEnabled>0</IsEnabled>
	<IsVisible>1</IsVisible>
	<IsEmulated>0</IsEmulated>
	<IsCondition>0</IsCondition>
	<IsProductionBps>0</IsProductionBps>
	<ConditionType>WhenTrue</ConditionType>
	<LocationType>NamedLocation</LocationType>
	<TextPosition>
		<Version>0</Version>
		<startLine>0</startLine>
		<StartColumn>0</StartColumn>
		<EndLine>0</EndLine>
		<EndColumn>0</EndColumn>
		<MarkerId>0</MarkerId>
		<IsLineBased>0</IsLineBased>
		<IsDocumentPathNotFound>0</IsDocumentPathNotFound>
		<ShouldUpdateTextSpan>0</ShouldUpdateTextSpan>
		<Checksum>
			<Version>0</Version>
			<Algorithm>00000000-0000-0000-0000-000000000000</Algorithm>
			<ByteCount>0</ByteCount>
		</Checksum>
	</TextPosition>
	<NamedLocationText>${FunctionName}</NamedLocationText>
	<NamedLocationLine>0</NamedLocationLine>
	<NamedLocationColumn>0</NamedLocationColumn>
	<HitCountType>NoHitCount</HitCountType>
	<HitCountTarget>1</HitCountTarget>
	<Language>00000000-0000-0000-0000-000000000000</Language>
	<IsMapped>0</IsMapped>
	<BreakpointType>PendingBreakpoint</BreakpointType>
	<AddressLocation>
		<Version>0</Version>
		<MarkerId>0</MarkerId>
		<FunctionLine>0</FunctionLine>
		<FunctionColumn>0</FunctionColumn>
		<Language>00000000-0000-0000-0000-000000000000</Language>
	</AddressLocation>
	<DataCount>4</DataCount>
	<IsTracepointActive>0</IsTracepointActive>
	<TracepointTargetType>VsOutputWindow</TracepointTargetType>
	<TimeTravelTraceMarker>NoTracing</TimeTravelTraceMarker>
	<IsBreakWhenHit>1</IsBreakWhenHit>
	<IsRunMacroWhenHit>0</IsRunMacroWhenHit>
	<UseChecksum>1</UseChecksum>
	<Labels />
	<RequestRemapped>0</RequestRemapped>
	<IsSnapshotWhenHit>1</IsSnapshotWhenHit>
	<SnapshotCountTarget>1</SnapshotCountTarget>
	<parentIndex>-1</parentIndex>
</Breakpoint>
"@
			Write-output $current
	} | out-file -FilePath $TmpFile -Encoding ascii;
	Write-Host "Import file ${TmpFile} to import breakpoint of all functions in $FilePath"
}
