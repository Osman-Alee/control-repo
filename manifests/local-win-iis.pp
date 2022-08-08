node 'local-win-iis'{
include chocolatey
exec { 'save_dir':
        path => 'C:/Windows/System32',
        command => 'cmd /c "dir > c:\dir1.txt"'
 }
exec { 'Install-Choco':
        command => 'Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString("https://community.chocolatey.org/install.ps1"))',
        unless => 'if (!(choco)){exit 1}',
        provider  => 'powershell',
  }
}
