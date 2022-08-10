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
file { 'c:/Users/Administrator/OneLink-05042022-ssls.pfx':
     ensure => 'present',
     source => "puppet:///modules/sslcertificate/OneLink-05042022-ssls.pfx",
     owner  => 'administrator',
     group  => ['administrators'],
     mode   => '1777',
}
#     Installing certificate
  sslcertificate { 'Install-PFX-Certificate-for-onelink' :
  name       => 'OneLink-05042022-ssls.pfx',
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
file { 'c:\\inetpub\\wwwroot\\testsite':
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
acl { 'c:\\inetpub\\wwwroot\\testsite':
  permissions => [
    {'identity' => 'System', 'rights' => ['read', 'write', 'execute']},
  ],
}

# Configure IIS

iis_application_pool { 'dot NET v2.0':
  ensure                  => 'present',
  state                   => 'started',
  managed_pipeline_mode   => 'Integrated',
  managed_runtime_version => 'v2.0',
}
iis_application_pool { 'dot NET v2.0 Classic':
  ensure                  => 'present',
  state                   => 'started',
  managed_pipeline_mode   => 'Classic',
  managed_runtime_version => 'v2.0',
}
iis_application_pool { 'dot NET v4.5':
  ensure                  => 'present',
  state                   => 'started',
  managed_pipeline_mode   => 'Integrated',
  managed_runtime_version => 'v4.0',
}
iis_application_pool { 'dot NET v4.5 Classic':
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
iis_application_pool { 'testpool':
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
      'bindinginformation'   => '192.168.59.20:443:',
      'protocol'             => 'https',
      'certificatehash'      => '03DB53F2B1D2ECDD241041EB2B5A898CF9E49D84',
      'certificatestorename' => 'My',
     'sslflags'              => 0,
    },
    {
      'bindinginformation' => '192.168.59.20:80:',
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
      'bindinginformation'   => '192.168.59.21:8443:',
      'protocol'             => 'https',
      'certificatehash'      => '03DB53F2B1D2ECDD241041EB2B5A898CF9E49D84',
      'certificatestorename' => 'My',
      'sslflags'             => 0,
    },
    {
      'bindinginformation' => '192.168.59.21:8080:',
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
      'bindinginformation'   => '192.168.59.20:1443:',
      'protocol'             => 'https',
      'certificatehash'      => '03DB53F2B1D2ECDD241041EB2B5A898CF9E49D84',
      'certificatestorename' => 'My',
     'sslflags'             => 0,
    },
    {
        'bindinginformation' => '192.168.59.20:180:',
        'protocol'           => 'http',
    },
  ],
  require => File['c:\\inetpub\\wwwroot\\OneLinkServicev2'],
}
iis_site { 'testsite':
  ensure           => 'started',
  physicalpath     => 'c:\\inetpub\\wwwroot\\testsite',
  applicationpool  => 'testpool',
  enabledprotocols => 'https',
  bindings         => [
    {
      'bindinginformation'   => '192.168.59.20:4443:',
      'protocol'             => 'https',
      'certificatehash'      => '03DB53F2B1D2ECDD241041EB2B5A898CF9E49D84',
      'certificatestorename' => 'My',
     'sslflags'             => 0,
    },
    {
        'bindinginformation' => '192.168.59.20:1800:',
        'protocol'           => 'http',
    },
  ],
  require => File['c:\\inetpub\\wwwroot\\testsite'],
}
################################################## IIS code ends here ########################################################
}
