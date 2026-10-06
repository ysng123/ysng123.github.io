param(
    [ValidateRange(1024, 65535)]
    [int]$Port = 4000,
    [switch]$BuildOnly,
    [switch]$Install
)

$ErrorActionPreference = 'Stop'
$projectDirectory = $PSScriptRoot
if (-not (Test-Path (Join-Path $projectDirectory '.local\rubyinstaller-3.3.12-1-x64\bin\ruby.exe'))) {
    throw 'Local Ruby is missing. See docs/local-development.md for setup.'
}

$mappedDrive = $null
$locationPushed = $false
$savedEnvironment = @{}
foreach ($name in @('PATH', 'BUNDLE_GEMFILE', 'BUNDLE_PATH', 'JEKYLL_ENV', 'LANG', 'MSYS2_PATH')) {
    $savedEnvironment[$name] = [Environment]::GetEnvironmentVariable($name, 'Process')
}
try {
    # Native Windows tools need an ASCII path, even when the project name is Chinese.
    if ($projectDirectory -match '[^\x00-\x7F]|\s') {
        $letter = @('R', 'S', 'T', 'U', 'V', 'W', 'X', 'Y', 'Z') | Where-Object { -not (Test-Path "${_}:\") } | Select-Object -First 1
        if (-not $letter) { throw 'No free drive letter is available for the local preview.' }
        $mappedDrive = "${letter}:"
        subst $mappedDrive $projectDirectory
        if ($LASTEXITCODE -ne 0) { $mappedDrive = $null; throw 'Could not create the temporary project drive.' }
        $projectDirectory = "$mappedDrive\"
    }
    $rubyDirectory = Join-Path $projectDirectory '.local\rubyinstaller-3.3.12-1-x64\bin'
    $env:PATH = "$rubyDirectory;" + $env:PATH
    $env:BUNDLE_GEMFILE = Join-Path $projectDirectory 'Gemfile.local'
    $env:BUNDLE_PATH = Join-Path $projectDirectory '.local\gems'
    $env:MSYS2_PATH = Join-Path $projectDirectory '.local\msys64'
    $env:JEKYLL_ENV = 'development'
    $env:LANG = 'en_US.UTF-8'
    Push-Location $projectDirectory
    $locationPushed = $true
    if ($Install) {
        foreach ($gem in @('bigdecimal', 'json', 'eventmachine', 'http_parser.rb')) {
            & (Join-Path $rubyDirectory 'bundle.bat') config set --local "build.$gem" '--with-cflags=-no-canonical-prefixes --with-cxxflags=-no-canonical-prefixes --with-ldflags=-no-canonical-prefixes'
            if ($LASTEXITCODE -ne 0) { throw "Failed to configure $gem" }
        }
        & (Join-Path $rubyDirectory 'bundle.bat') install
        if ($LASTEXITCODE -ne 0) { throw 'Dependency installation failed.' }
    }
    & (Join-Path $rubyDirectory 'bundle.bat') check
    if ($LASTEXITCODE -ne 0) { throw 'Missing dependencies. Run this script again with -Install.' }
    if ($BuildOnly) {
        & (Join-Path $rubyDirectory 'bundle.bat') exec jekyll build --trace
    } else {
        Write-Host "Local website: http://127.0.0.1:$Port (Ctrl+C to stop)"
        & (Join-Path $rubyDirectory 'bundle.bat') exec jekyll serve --host 127.0.0.1 --port $Port --force_polling
    }
    if ($LASTEXITCODE -ne 0) { throw "Jekyll exited with code $LASTEXITCODE" }
} finally {
    if ($locationPushed) { Pop-Location }
    if ($mappedDrive) { subst $mappedDrive /D }
    foreach ($name in $savedEnvironment.Keys) {
        [Environment]::SetEnvironmentVariable($name, $savedEnvironment[$name], 'Process')
    }
}
