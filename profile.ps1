# place any of these in your $profile, usually 
# $profile.CurrentUserAllHosts or
# $profile.AllUsersAllHosts

# If you use a dark background and find the red errors hard to read
$host.PrivateData.ErrorForegroundColor = "Blue"
$host.PrivateData.ErrorBackgroundColor = "Gray"

# wrap prompt when path gets long
Function prompt { 
    If( $pwd.Path.Length -gt 55 ){
        "$pwd`n>"
    } Else {
        "$pwd>"
    }
}

# use npp to launch notead++
New-Item alias:npp -value "C:\Program Files\Notepad++\notepad++.exe" | Out-Null

# launch SSMS with optional file 
# will not open Obj Explorer, even with
# Tools, Options, Environment, Startup, "Obj Exp and Query"
Function SMS([string]$file){
$server = "YOUR_SERVER_INSTANCE" # like "$Env:USERNAME\INSTANCENAME"
$db = "DEFAULT_DB_NAME"
Write-Host "Launching SSMS $server $db $file"
& "C:\Program Files (x86)\Microsoft SQL Server Management Studio 18\Common7\IDE\Ssms.exe" -S $server -d $db -E -nosplash $file
}

# use dir10 to see the 10 most recently changed files
Function Dir10Recent(){
    Get-ChildItem | Sort LastAccessTime -Desc | Select-Object -First 10
}
New-Item alias:dir10 -value Dir10Recent | Out-Null


# For those that have to navigate many repos with long paths and too much typing
# you will have to edit this for your needs, once setup
#
# to change to a folder:
# goto abr
#
# to open a folder in windows explorer:
# goto abr e
#
# to open a solution in the folder in VS2019 (vs) or VS2022 (v2):
# goto abr v2
#
Function goto([string]$folder, [string]$explorer="0"){
	$root = "C:\WHERE_YOUR_BASE_FOLDER_IS"
    # other vars you may reuse in your abbreviations
	$sample = "$root\companyName"
	# setup abr and path here
	$folders = @{
		"aapi" = "$root\YOUR_API_PROJECT";
		"ajs" = "$root\YOUR_CLIENT";
		"bapi" = "$root\ANOTHER_API_PROJECT";
		"bblz" = "$sample\YOUR_BLAZOR_WASM";
        "vse" = "$root\YOUR_VS_EXTENSION";
		# many more or you likely don't need this
	}
	
	If( $folders.ContainsKey($folder))
	{
		$path = $folders[$folder]
		If( $explorer -eq "0" )
		{
			Set-Location -Path $path
		}
		ElseIf ( $explorer -ieq "VS" -or $explorer -ieq "V2" )
		{
            # Hopefully your sln file is in a predictable place
            # this checks the path and path\src
			$solution = Get-ChildItem -Path $path *.sln
			If( $solution -eq $null )
			{
				If( Test-Path "$path\src" )
				{
					Write-Host "Found $path\src exists"
			        $solution = Get-ChildItem -Path "$path\src" *.sln
				}
			}

			If( $solution.GetType().Name -eq "FileInfo" )
			{
				$devenv = "C:\Program Files (x86)\Microsoft Visual Studio\2019\Professional\Common7\IDE\devenv.exe"
				If( $explorer -ieq "V2" )
				{
					$devenv = "C:\Program Files\Microsoft Visual Studio\2022\Professional\Common7\IDE\devenv.exe"
				}
				$solutionFile = $solution.FullName
				& $devenv $solutionFile
			}
		}
		Else
		{
			Invoke-Item $path
		}
	}
	Else
	{
		Write-Host "Did not find $folder, please try"
		$startsWith = "^$root"  #common prefix
		$list = New-Object Collections.Generic.List[String]
		$maxAbr = ($folders.Keys |
			Select-Object -Property Length |
			Measure-Object -Property Length -Maximum).Maximum + 1

		ForEach( $key in $folders.Keys.GetEnumerator() | Sort)
		{
			$val = $folders[$key]
			If($val -ne $root -and $val -match ('^' + [regex]::Escape($root)))
			{
				$val = $val.Substring($root.length + 1)
			}
			$val = $val -Replace "ANYTHING_LONG_YOU_WANT_TO_SHORTEN", "SHORTENED_TO"

			$info = $key + ( " " * ($maxAbr - $key.Length) ) + $val
			$list.Add( $info )
		}
		$list | 
			Select-Object @{Name='String';Expression={$_}} | 
			Format-Wide String -Column 2
	}
}
