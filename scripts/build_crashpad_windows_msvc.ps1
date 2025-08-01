# Create third_party directory if it doesn't exist
if (-not (Test-Path "third_party")) {
    New-Item -ItemType Directory -Path "third_party" | Out-Null
}
Set-Location -Path "third_party"

# Check if crashpad directory already exists
if (-not (Test-Path "crashpad")) {
    Write-Host "Fetching Crashpad using depot_tools..."
    fetch crashpad
    Set-Location -Path "crashpad"
} else {
    Write-Host "Crashpad already exists, updating..."
    Set-Location -Path "crashpad"
    git checkout main
    git pull
    gclient sync
}

# Generate build files with GN for Debug MD configuration
Write-Host "Generating Debug MD build files with GN..."
gn gen out/win-debug-md --args="extra_cflags=\`"/MDd\`" is_debug=true" 

# Generate build files with GN for Debug MT configuration
Write-Host "Generating Debug MT build files with GN..."
gn gen out/win-debug-mt --args="extra_cflags=\`"/MTd\`" is_debug=true" 

# Generate build files with GN for Release MD configuration
Write-Host "Generating Release MD build files with GN..."
gn gen out/win-release-md --args="extra_cflags=\`"/MD\`" is_debug=false" 

# Generate build files with GN for Release MT configuration
Write-Host "Generating Release MT build files with GN..."
gn gen out/win-release-mt --args="extra_cflags=\`"/MT\`" is_debug=false" 

# Build Debug MD
Write-Host "Building Debug MD with Ninja..."
ninja -C out/win-debug-md

# Build Debug MT
Write-Host "Building Debug MT with Ninja..."
ninja -C out/win-debug-mt

# Build Release MD
Write-Host "Building Release MD with Ninja..."
ninja -C out/win-release-md

# Build Release MT
Write-Host "Building Release MT with Ninja..."
ninja -C out/win-release-mt

Write-Host "Crashpad Debug and Release builds complete (MD and MT variants)."

# Return to the original directory
Set-Location -Path "../../" 