@echo off
REM This script should be invoked with CMD

echo.
echo Python location:
where python

REM check python install
echo.
echo Python Version:  (Python for Windows)
python --version
REM check pip install (generally included in python install)
echo.
echo Pip Version:  (Python for Windows)
pip --version
REM check GIT install
echo.
echo GIT Version:  (GIT for Windows)
git --version

REM check ssh-keygen.exe exists:
REM if exist "%ProgramFiles%\Git\usr\bin\ssh-keygen.exe" (
FOR /F "tokens=2,*" %%I IN ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\GitForWindows /v InstallPath') DO SET GITPATH=%%J
if exist "%GITPATH%\usr\bin\ssh-keygen.exe" (
    REM file exists
) else (
    REM file doesn't exist
    echo ERROR: "%GITPATH%\usr\bin\ssh-keygen.exe" is missing
    echo.
    echo  - Did you install GIT for Windows? -
    echo.
    pause
    REM exit 2
)

REM check SSH keys (ssh-keygen included with GIT, but must be run)
REM must generate SSH keys
REM must copy public key to github
echo.
echo check ssh keys exist: (~\.ssh\id_rsa.pub)
if exist %UserProfile%\.ssh\id_rsa.pub (
    REM file exists
    echo    ~\.ssh\id_rsa.pub file found!
) else (
    REM file doesn't exist
    echo ERROR: ~\.ssh\id_rsa.pub missing!
    echo RUN: cmd /C "%GITPATH%\usr\bin\ssh-keygen.exe"
    echo          to generate ~\.ssh\id_rsa.pub
    echo          NOTE: just hit enter at "Enter file in which to save the key (/c/Users/_USER_/.ssh/id_rsa):" prompt
    echo      then copy the contents of ~\.ssh\id_rsa.pub to your GitHub account SSH keys at https://github.com/settings/keys
    pause
    REM exit 3
)

echo.
REM https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh/testing-your-ssh-connection
REM https://stackoverflow.com/a/28469910/861745
echo Test SSH connection to GitHub:
echo ssh -T -o StrictHostKeyChecking=no git@github.com
ssh -T -o StrictHostKeyChecking=no git@github.com
if errorlevel 1 (
    echo   - ssh test succeeded!  exit code: %errorlevel%
) else if errorlevel 0 (
    echo   - ssh test succeeded!  exit code: %errorlevel%
) else (
    echo ERROR: ssh test failed!  exit code: %errorlevel%
    echo   - Have you copied ssh keys to your github account?
    echo.
    type %UserProfile%\.ssh\id_rsa.pub
    echo.
    REM copy public key to clipboard? powershell -c [Windows.Forms.Clipboard]::SetText(???)
    pause
    REM exit %errorlevel%
)


REM TODO: check visual studio build tools
REM VSWhere check:
REM   .\vswhere.exe -all -legacy -products * -format json
REM WMI Relevance check:
REM   selects "* from MSFT_VSInstance" of wmis
REM Install Powershell VSSetup module
REM   powershell -ExecutionPolicy Bypass -command "Import-Module PowerShellGet ; Install-Module VSSetup -Scope CurrentUser -AcceptLicense -Confirm ; Get-VSSetupInstance"
REM   powershell -ExecutionPolicy Bypass -command "Import-Module PowerShellGet ; Install-Module VSSetup -Scope CurrentUser -AcceptLicense -Confirm ; (Get-VSSetupInstance | Select-VSSetupInstance -Product *).packages"
REM Install command:
REM   vs_BuildTools.exe --norestart --passive --downloadThenInstall --includeRecommended --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Workload.MSBuildTools
REM Relevance to generate relevance for folder check:
REM   ("number of unique values of preceding texts of firsts %22,%22 of names of folders whose(name of it starts with %22" & it & "%22) of folders %22Microsoft\VisualStudio\Packages%22 of /* ProgramData */ csidl folders 35") of concatenations "%22 OR name of it starts with %22" of tuple string items of "Microsoft.VisualCpp.Redist.14, Microsoft.PythonTools.BuildCore, Microsoft.VisualStudio.Workload.MSBuildTools, Microsoft.VisualStudio.Workload.VCTools, Win10SDK"
REM Relevance to detect required vsbuildtools are missing:
REM   5 != number of unique values of preceding texts of firsts "," of names of folders whose(name of it starts with "Microsoft.VisualCpp.Redist.14.Latest" OR name of it starts with "Microsoft.PythonTools.BuildCore" OR name of it starts with "Microsoft.VisualStudio.Workload.MSBuildTools" OR name of it starts with "Microsoft.VisualStudio.Workload.VCTools" OR name of it starts with "Win10SDK") of folders "Microsoft\VisualStudio\Packages" of /* ProgramData */ csidl folders 35
REM distutils.errors.DistutilsPlatformError: Microsoft Visual C++ 14.0 or greater is required. Get it with "Microsoft C++ Build Tools": https://visualstudio.microsoft.com/visual-cpp-build-tools/
REM ParentFolder: C:\ProgramData\Microsoft\VisualStudio\Packages\
REM   SubFolders:
REM     Microsoft.VisualCpp.Redist.14*
REM     Microsoft.Build*
REM     Microsoft.PythonTools.BuildCore*
REM     Microsoft.VisualStudio.PackageGroup.VC.Tools*
REM     Microsoft.VisualStudio.Workload.MSBuildTools*
REM     Microsoft.VisualStudio.Workload.VCTools*
REM     Win10SDK*

FOR /F "tokens=2,*" %%I IN ('reg query HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\VisualStudio\Setup /v CachePath') DO SET VSToolsPATH=%%J

REM set default path if query above doesn't work
IF "%VSToolsPATH%"=="" SET VSToolsPATH=%ProgramData%\Microsoft\VisualStudio\Packages

if not exist %VSToolsPATH%\Microsoft.Build* (
    REM folder missing
    echo.
    echo ERROR: missing required Visual Studio Build Tools - Required for Python Pip installs
    echo ERROR: missing folder %VSToolsPATH%\Microsoft.Build*
    echo Install Command:
    echo   vs_BuildTools.exe --norestart --passive --downloadThenInstall --includeRecommended --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Workload.MSBuildTools
    echo.
    pause
    REM exit 9
)
if not exist %VSToolsPATH%\Microsoft.PythonTools.BuildCore* (
    REM folder missing
    echo.
    echo ERROR: missing required Visual Studio Build Tools - Required for Python Pip installs
    echo ERROR: missing folder %VSToolsPATH%\Microsoft.PythonTools.BuildCore*
    echo Install Command:
    echo   vs_BuildTools.exe --norestart --passive --downloadThenInstall --includeRecommended --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Workload.MSBuildTools
    echo.
    pause
    REM exit 9
)
if not exist %VSToolsPATH%\Microsoft.VisualStudio.PackageGroup.VC.Tools* (
    REM folder missing
    echo.
    echo ERROR: missing required Visual Studio Build Tools - Required for Python Pip installs
    echo ERROR: missing folder %VSToolsPATH%\Microsoft.VisualStudio.PackageGroup.VC.Tools*
    echo Install Command:
    echo   vs_BuildTools.exe --norestart --passive --downloadThenInstall --includeRecommended --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Workload.MSBuildTools
    echo.
    pause
    REM exit 9
)
if not exist %VSToolsPATH%\Microsoft.VisualStudio.Workload.MSBuildTools* (
    REM folder missing
    echo.
    echo ERROR: missing required Visual Studio Build Tools - Required for Python Pip installs
    echo ERROR: missing folder %VSToolsPATH%\Microsoft.VisualStudio.Workload.MSBuildTools*
    echo Install Command:
    echo   vs_BuildTools.exe --norestart --passive --downloadThenInstall --includeRecommended --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Workload.MSBuildTools
    echo.
    pause
    REM exit 9
)
if not exist %VSToolsPATH%\Microsoft.VisualStudio.Workload.VCTools* (
    REM folder missing
    echo.
    echo ERROR: missing required Visual Studio Build Tools - Required for Python Pip installs
    echo ERROR: missing folder %VSToolsPATH%\Microsoft.VisualStudio.Workload.VCTools*
    echo Install Command:
    echo   vs_BuildTools.exe --norestart --passive --downloadThenInstall --includeRecommended --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Workload.MSBuildTools
    echo.
    pause
    REM exit 9
)
if not exist %VSToolsPATH%\Win10SDK* (
    REM folder missing
    echo.
    echo ERROR: missing required Visual Studio Build Tools - Required for Python Pip installs
    echo ERROR: missing folder %VSToolsPATH%\Win10SDK*
    echo Install Command:
    echo   vs_BuildTools.exe --norestart --passive --downloadThenInstall --includeRecommended --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Workload.MSBuildTools
    echo.
    pause
    REM exit 9
)

echo.
echo Upgrade pip:
echo python -m pip install --upgrade pip
python -m pip install --upgrade pip

echo.
echo NOTE: The following should be run from within the cloned git "recipes" folder:
if exist .git (
    echo .git folder found
    echo.
) else (
    echo ERROR: .git folder not found!
    echo Are you running this from the cloned git "recipes" folder?
    echo NOTE: this error is expected if you are running this script independantly
    echo         to check intial setup. You should later run this from a cloned repo.
    pause
    REM exit 99
)

echo.
echo include repo .gitconfig:
echo git config --local include.path ../.gitconfig
git config --local include.path ../.gitconfig

echo.
echo Update Current Repo:
echo git pull
git pull

echo.
echo check pip install requirements for this repo:
echo pip install -r .\requirements.txt --quiet --quiet
pip install -r .\requirements.txt --quiet --quiet
if errorlevel 0 (
    echo   - pip install for recipes succeeded!  exit code: %errorlevel%
) else (
    echo ERROR: pip install for recipes failed! exit code: %errorlevel%
    echo   - Have you installed visual studio build tools?
    echo vs_BuildTools.exe --norestart --passive --downloadThenInstall --includeRecommended --add Microsoft.VisualStudio.Workload.NativeDesktop --add Microsoft.VisualStudio.Workload.VCTools --add Microsoft.VisualStudio.Workload.MSBuildTools
    pause
    exit %errorlevel%
)
REM https://stackoverflow.com/a/334890/861745

REM add pre-commit:
echo.
echo Add pre-commit hooks:
echo pre-commit install --install-hooks --allow-missing-config
pre-commit install --install-hooks --allow-missing-config

echo.
echo Finished setup check
echo.
pause
