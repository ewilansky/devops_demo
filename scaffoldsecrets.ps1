$files = "nexus_password.txt", "nexus_usr.txt", "postgres_password.txt", "postgres_usr.txt", "sonarqube_password.txt", "sonarqube_usr.txt"

if (-Not (test-path -Path .\secrets)) {
    New-Item -Path .\secrets -ItemType Directory | Out-Null
    Set-Location secrets 
    foreach ($f in $files) {
        New-Item -Path ./$f -ItemType File | Out-Null
    }
    Write-Output "secrets directory and files created. Please add passwords"
}
else {
    Write-Output "secrets directory exists"
}