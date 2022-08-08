node 'puppet-agent01'{
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
################################################## New code added for IIS (22-6-2022) ########################################
file { 'c:/Users/Administrator/interpayssl.pfx':
     ensure => 'file',
     source => 'puppet:///modules/sslcertificate/interpayssl.pfx',
#     source_permissions => 'ignore',
     owner  => 'administrator',
     group  => ['administrators'],
     mode   => '1777',
}
sslcertificate { 'Install-PFX-Certificate' :
  name       => 'interpayssl.pfx',
  password   => '12344321',
  location   => 'c:\Users\Administrator',
  thumbprint => '84AAD9F0AFDF02B4032D50F17D32043D9E30E3CC',
  }
# Create Directories

file { 'c:\\inetpub\\complete':
  ensure => 'directory'
}

file { 'c:\\inetpub\\complete_vdir':
  ensure => 'directory'
}

# Set Permissions

acl { 'c:\\inetpub\\complete':
  permissions => [
    {'identity' => 'System', 'rights' => ['read', 'execute']},
  ],
}

acl { 'c:\\inetpub\\complete_vdir':
  permissions => [
    {'identity' => 'System', 'rights' => ['read', 'execute']},
  ],
}

# Configure IIS

iis_application_pool { 'complete_site_app_pool':
  ensure                  => 'present',
  state                   => 'started',
  managed_pipeline_mode   => 'Integrated',
  managed_runtime_version => 'v4.0',
}

# Application Pool No Managed Code .Net CLR Version set up
iis_application_pool {'test_app_pool':
    ensure                    => 'present',
    enable32_bit_app_on_win64 => true,
    managed_runtime_version   => '',
    managed_pipeline_mode     => 'Classic',
    start_mode                => 'AlwaysRunning'
  }

iis_site { 'mysite.interpayafrica.com':
  ensure           => 'started',
  physicalpath     => 'c:\\inetpub\\complete',
  applicationpool  => 'complete_site_app_pool',
  enabledprotocols => 'https',
  bindings         => [
    {
      'bindinginformation'   => '*:443:',
      'protocol'             => 'https',
      'certificatehash'      => '84AAD9F0AFDF02B4032D50F17D32043D9E30E3CC',
      'certificatestorename' => 'My',
     'sslflags'             => 0,
    },
  ],
  require => File['c:\\inetpub\\complete'],
}

iis_virtual_directory { 'vdir':
  ensure       => 'present',
  sitename     => 'mysite.interpayafrica.com',
  physicalpath => 'c:\\inetpub\\complete_vdir',
  require      => File['c:\\inetpub\\complete_vdir'],
}

################################################## IIS code ends here ########################################################
}
