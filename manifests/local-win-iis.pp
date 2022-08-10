node 'local-win-iis.localdomain'{
include chocolatey
################################################# Tesing Batch commands ############################################
exec { 'save_dir':
        path => 'C:/Windows/System32',
        command => 'cmd /c "dir > c:\dir1.txt"'
 }
 ################################################# Install chocolatey ############################################
 exec { 'Install-Choco':
        command => 'Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString("https://community.chocolatey.org/install.ps1"))',
        unless => 'if (!(choco)){exit 1}',
        provider  => 'powershell',
  }
################################################## Below code manages IIS ########################################
$iis_features = ['Web-WebServer','Web-Scripting-Tools']
iis_feature { $iis_features:
  ensure => 'present',
}
#     Removing default site
iis_site {'Default Web Site':
   ensure   => 'absent',
   applicationpool => 'DefaultAppPool',
   require   => Iis_feature['Web-WebServer'],
}
#     Upload SSL certificate from server to agent
file { 'c:/Users/Administrator/cert_for_onelink.pfx':
     ensure => 'file',
     source => 'puppet:///modules/sslcertificate/cert_for_onelink.pfx',
#     source_permissions => 'ignore',
     owner  => 'administrator',
     group  => ['administrators'],
     mode   => '1777',
}
#     Installing certificate
sslcertificate { 'Install-PFX-Certificate' :
  name       => 'cert_for_onelink.pfx',
  password   => '0504202222024050',
  location   => 'c:\Users\Administrator',
  thumbprint => '03DB53F2B1D2ECDD241041EB2B5A898CF9E49D84',
  }

# Create Directories
file { 'c:\\inetpub\\wwwroot\\OneLinkService':
  ensure => 'directory'
}
file { 'c:\\inetpub\\wwwroot\\OneLinkServiceSite2':
  ensure => 'directory'
}
file { 'c:\\inetpub\\wwwroot\\OneLinkServicev2':
  ensure => 'directory'
}

# Set Permissions

acl { 'c:\\inetpub\\wwwroot\\OneLinkService':
  permissions => [
    {'identity' => 'System', 'rights' => ['read', 'write', 'execute']},
  ],
}
acl { 'c:\\inetpub\\wwwroot\\OneLinkServiceSite2':
  permissions => [
    {'identity' => 'System', 'rights' => ['read', 'write', 'execute']},
  ],
}
acl { 'c:\\inetpub\\wwwroot\\OneLinkServicev2':
  permissions => [
    {'identity' => 'System', 'rights' => ['read', 'write', 'execute']},
  ],
}

# Configure IIS

iis_application_pool { '.NET v2.0':
  ensure                  => 'present',
  state                   => 'started',
  managed_pipeline_mode   => 'Integrated',
  managed_runtime_version => 'v2.0',
}
iis_application_pool { '.NET v2.0 Classic':
  ensure                  => 'present',
  state                   => 'started',
  managed_pipeline_mode   => 'Classic',
  managed_runtime_version => 'v2.0',
}
iis_application_pool { '.NET v4.5':
  ensure                  => 'present',
  state                   => 'started',
  managed_pipeline_mode   => 'Integrated',
  managed_runtime_version => 'v4.0',
}
iis_application_pool { '.NET v4.5 Classic':
  ensure                  => 'present',
  state                   => 'started',
  managed_pipeline_mode   => 'Classic',
  managed_runtime_version => 'v4.0',
}
iis_application_pool { 'Classic .NET AppPool':
  ensure                  => 'present',
  state                   => 'started',
  managed_pipeline_mode   => 'Classic',
  managed_runtime_version => 'v2.0',
}
iis_application_pool { 'OneLinkSite2':
  ensure                  => 'present',
  state                   => 'started',
  managed_pipeline_mode   => 'Integrated',
  managed_runtime_version => 'v4.0',
}
iis_application_pool { 'OneLinkv2':
  ensure                  => 'present',
  state                   => 'started',
  managed_pipeline_mode   => 'Integrated',
  managed_runtime_version => 'v4.0',
}
iis_application_pool { 'webtest':
  ensure                  => 'present',
  state                   => 'started',
  managed_pipeline_mode   => 'Integrated',
  managed_runtime_version => 'v4.0',
}

iis_site { 'OneLink':
  ensure           => 'started',
  physicalpath     => 'c:\\inetpub\\wwwroot\\OneLinkService',
  applicationpool  => 'webtest',
  enabledprotocols => 'https',
  bindings         => [
    {
      'bindinginformation'   => '*:443:',
      'protocol'             => 'https',
      'certificatehash'      => '03DB53F2B1D2ECDD241041EB2B5A898CF9E49D84',
      'certificatestorename' => 'My',
     'sslflags'              => 0,
    },
    {
      'bindinginformation' => '*:80:',
      'protocol'           => 'http',
    },
  ],
  require => File['c:\\inetpub\\wwwroot\\OneLinkService'],
}
iis_site { 'OneLinkSite2':
  ensure           => 'started',
  physicalpath     => 'c:\\inetpub\\wwwroot\\OneLinkServiceSite2',
  applicationpool  => 'OneLinkSite2',
  enabledprotocols => 'https',
  bindings         => [
    {
      'bindinginformation'   => '*:8443:',
      'protocol'             => 'https',
      'certificatehash'      => '03DB53F2B1D2ECDD241041EB2B5A898CF9E49D84',
      'certificatestorename' => 'My',
      'sslflags'             => 0,
    },
    {
      'bindinginformation' => '*:8080:',
      'protocol'           => 'http',
    },
  ],
  require => File['c:\\inetpub\\wwwroot\\OneLinkServiceSite2'],
}
iis_site { 'OneLinkv2':
  ensure           => 'stopped',
  physicalpath     => 'c:\\inetpub\\wwwroot\\OneLinkServicev2',
  applicationpool  => 'OneLinkv2',
  enabledprotocols => 'https',
  bindings         => [
    {
      'bindinginformation'   => '*:1443:',
      'protocol'             => 'https',
      'certificatehash'      => '03DB53F2B1D2ECDD241041EB2B5A898CF9E49D84',
      'certificatestorename' => 'My',
     'sslflags'             => 0,
    },
    {
        'bindinginformation' => '*:180:',
        'protocol'           => 'http',
    },
  ],
  require => File['c:\\inetpub\\wwwroot\\OneLinkServicev2'],
}
################################################## IIS code ends here ########################################################
}
