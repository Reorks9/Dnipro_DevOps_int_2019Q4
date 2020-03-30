# # var 
# $projectSrcFolder   = "$env:TEMP\app";
# $buildFolder        = 'C:\App'

# # to find msbuild path in the system
# function Get-LatestMsBuild {
#   $msbuild = Get-ChildItem -Path "C:\\" |
#   ? { !$PsIsContainer -and $_.Name.StartsWith("20") } |
#   % { @([System.IO.Path]::Combine($_.FullName, "Enterprise", "MsBuild"), [System.IO.Path]::Combine($_.FullName, "Professional", "MsBuild"), [System.IO.Path]::Combine($_.FullName, "Community", "MsBuild"))} |
#   ? { (Test-Path -Path $_) } |
#   % { Get-ChildItem -Path $_ | ? { !$PsIsContainer -and $_.Name.StartsWith("1") } | Select-Object -Expand FullName } |
#   % { Get-ChildItem -Path $_ -Recurse | ? { !$PsIsContainer -and $_.FullName.EndsWith("amd64\msbuild.exe", "OrdinalIgnoreCase") } } |
#   Select-Object -First 1

#   if($msbuild -ne $null){
#     return $msbuild.FullName;
#   }

#   return ( `
#     Get-ChildItem `
#       -Path "C:\Program Files (x86)\MSBuild" `
#       -Recurse `
#       | Where-Object { `
#         !$PsIsContainer -and `
#         $_.FullName.EndsWith("amd64\msbuild.exe", "OrdinalIgnoreCase") `
#       } `
#       | sort FullName -Descending `
#       | Select-Object -First 1`
#   ).FullName
# };

# # install git
# function installGit {
#     [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
# 	$gitDownloadLink = "https://github.com/git-for-windows/git/releases/download/v2.26.0.windows.1/Git-2.26.0-64-bit.exe"
# 	$outpFile = "$env:TEMP\Git.exe"
# 	$installArgs = "/SP- /VERYSILENT /NORESTART /NOCLOSEAPPLICATIONS"
# 	iwr -outf $outpFile $gitDownloadLink
# 	Start-Process -FilePath $outpFile -ArgumentList $installArgs -Wait
# 	$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User");
# }
# # install msbuild
# function addPath {
# 	$msbuildPath = $(Get-LatestMsBuild);
# 	$msbuildDirPath = (ls $msbuildPath | foreach { $_.DirectoryName });
# 	setx /M path "$env:Path;$msbuildDirPath";
# 	$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User");
# }
# function installMSbuild {
#     [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
#     $msBuildDownloadLink = "https://download.visualstudio.microsoft.com/download/pr/69b51b7f-ea5e-4729-9e7e-9ff9e2457545/1a298a04773793df364f3b530691ed8dc96fc9a70237179a6a17f870a867cca7/vs_BuildTools.exe"
#     $outpFile = "$env:TEMP\msbuild.exe";
#     $installArgs = "--add Microsoft.VisualStudio.Workload.MSBuildTools --add Microsoft.VisualStudio.Workload.WebBuildTools --quiet"
# 	iwr -outf $outpFile $msBuildDownloadLink;
# 	Start-Process -FilePath $outpFile -ArgumentList $installArgs -Wait;
# 	addPath;
# }
# # git clone
# function cloneProj {
# 	$appLink       = "https://github.com/studentota2lvl/Dnipro_DevOps_int_2019Q4.git";
# 	$destFolder    = $projectSrcFolder
# 	$appPath       = "$env:TEMP\app\azure\testApp";

# 	New-Item -ItemType Directory -Path $destFolder;
# 	git clone $appLink $destFolder;
# }

# # build app
# function buildApp {
# 	$path = $buildFolder;

#     cd "$projectSrcFolder\azure\testApp\"
#     msbuild -t:restore
#     msbuild "$projectSrcFolder\azure\testApp\WebApplication1.vbproj" /p:OutputPath=$path
# }

# # setup IIS server
# function setupIIS {
# 	$siteName  = 'DemoSite'
# 	$appName   = 'DemoApp'
# 	$port      = 80
# 	$path      = $buildFolder
# 	$appPool   = 'DemoSite'
# 	$pools     = dir IIS:\AppPools

# 	Remove-WebSite -Name "Default web site"
# 	New-WebAppPool $appPool
# 	New-WebSite -Name $siteName -Port $port  -PhysicalPath $path -ApplicationPool $appPool
# 	New-WebApplication -Name $appName -Site $siteName -PhysicalPath $path -ApplicationPool $appPool
#     Set-ItemProperty IIS:\AppPools\$appPool -name processModel -value @{identitytype=3} 
# };

# function setupEnv {
    Write-Host '<!DOCTYPE html><html><head><title>Page Title</title></head><body><h1>My First Heading</h1><p>My first paragraph.</p></body></html>' > C:\inetpub\wwwroot\iisstart.htm
	Get-WindowsFeature NET-* | Add-WindowsFeature;  
	Get-WindowsFeature Web-* | Add-WindowsFeature;
# 	installGit;
# 	installMSbuild;
# 	cloneProj;
# };

# setupEnv;
# buildApp;
# setupIIS;

# Write-Host "##########################################################"
# Write-Host "~~~~~~~~~~~~~~~~~~~~~~~~~~~~DONE~~~~~~~~~~~~~~~~~~~~~~~~~~"
# Write-Host "##########################################################"