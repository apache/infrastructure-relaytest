#/environments/windows/modules/jenkins_slave_windows/manifests/download.pp

class jenkins_slave_windows::download (

  $ant = $jenkins_slave_windows::params::ant,
  $chromedriver = $jenkins_slave_windows::params::chromedriver,
  $geckodriver = $jenkins_slave_windows::params::geckodriver,
  $gpg4win  = $jenkins_slave_windows::params::gpg4win,
  $gradle = $jenkins_slave_windows::params::gradle,
  $graphviz = $jenkins_slave_windows::params::graphviz,
  $iedriver = $jenkins_slave_windows::params::iedriver,
  $jdk = $jenkins_slave_windows::params::jdk,
  $maven = $jenkins_slave_windows::params::maven,
  $nant = $jenkins_slave_windows::params::nant,
  $forrest = $jenkins_slave_windows::params::forrest,
) {
  include jenkins_slave_windows::params
  #### Download CMake 3.7.2 from Bintray
  download_file { 'Download Cmake from bintray' :
    url                   => 'http://apache.bintray.com/WindowsPackages/cmake-3.7.2-win64-x64.msi',
    destination_directory => 'C:\temp',
  }
  #### Download cygwin from Bintray
  download_file { 'Download cygwin from bintray' :
    url                   => 'http://apache.bintray.com/WindowsPackages/cygwin64.zip',
    destination_directory => 'C:\temp',
  }
  #### Download Firefox from Bintray ####
  download_file { 'Download Firefox from bintray' :
    url                   => 'http://apache.bintray.com/WindowsPackages/Firefox%20Installer.exe',
    destination_directory => 'C:\temp',
  }
  #### Download flashplayer from Bintray. Needed for FlexJS ####
  download_file { 'Download flashplayer from bintray' :
    url                   => 'http://apache.bintray.com/WindowsPackages/flashplayer_22_sa_debug.exe',
    destination_directory => 'C:\Program Files (x86)\Adobe',
  }
  #### Download Git from Bintray
  download_file { 'Download Git from bintray' :
    url                   => 'http://apache.bintray.com/WindowsPackages/Git-2.14.3-64-bit.exe',
    destination_directory => 'C:\temp',
  }
  #### Download JDK1.8 from Bintray
  download_file { 'Download JDK1.8 from bintray' :
    url                   => 'http://apache.bintray.com/WindowsPackages/asf-build-jdk1.8.0_152.exe',
    destination_directory => 'C:\temp',
  }
  #### Download Visual Studio 2015 from Bintray. Manual install. ####
  download_file { 'Download Visual Studio 2015 from bintray' :
    url                   => 'http://apache.bintray.com/WindowsPackages/vs_community.exe',
    destination_directory => 'C:\temp',
  }
  #### Download winSVN ####
  download_file { 'Download winsvn from bintray' :
    url                   => 'http://apache.bintray.com/WindowsPackages/Setup-Subversion-1.8.17.msi',
    destination_directory => 'C:\temp',
  }

  #### Download ant ####
  define download_ant($ant_version = $title){
    download_file { "Download asf-build-${ant_version} zip from bintray" :
      url                   => "http://apache.bintray.com/WindowsPackages/asf-build-${ant_version}.zip",
      destination_directory => 'F:\tools_zips',
    }
  }
  #### Download chromeDriver ####
  define download_chromedriver($chromedriver_version = $title){
      download_file { "Download asf-build-chromedriver-${chromedriver_version} zip from bintray" :
        url                   => "http://apache.bintray.com/WindowsPackages/asf-build-chromedriver-${chromedriver_version}.zip",
        destination_directory => 'F:\tools_zips',
      }
    }
  #### Download geckoDriver ####
  define download_geckodriver($geckodriver_version = $title){
      download_file { "Download asf-build-geckodriver-${geckodriver_version} zip from bintray" :
        url                   => "http://apache.bintray.com/WindowsPackages/asf-build-geckodriver-${geckodriver_version}.zip",
        destination_directory => 'F:\tools_zips',
      }
    }
    #### Download gpg4win ####
  define download_gpg4win($gpg4win_version = $title){
      download_file { "Download asf-build-gpg4win-${gpg4win_version} zip from bintray" :
        url                   => "http://apache.bintray.com/WindowsPackages/asf-build-gpg4win-${gpg4win_version}.zip",
        destination_directory => 'F:\tools_zips',
      }
    }
  #### Download Gradle ####
  define download_gradle($gradle_version = $title){
        download_file { "Download asf-build-gradle-${gradle_version} zip from bintray" :
          url                   => "http://apache.bintray.com/WindowsPackages/asf-build-gradle-${gradle_version}.zip",
          destination_directory => 'F:\tools_zips',
        }
      }
  #### Download Graphviz ####
  define download_graphviz($graphviz_version = $title){
        download_file { "Download asf-build-graphviz-${graphviz_version} zip from bintray" :
          url                   => "http://apache.bintray.com/WindowsPackages/asf-build-graphviz-${graphviz_version}.zip",
          destination_directory => 'F:\tools_zips',
        }
      }
  #### Download ieDriver ####
  define download_iedriver($iedriver_version = $title){
      download_file { "Download asf-build-iedriver-${iedriver_version} zip from bintray" :
        url                   => "http://apache.bintray.com/WindowsPackages/asf-build-iedriver-${iedriver_version}.zip",
        destination_directory => 'F:\tools_zips',
      }
    }
  #### Download JDK ####
  define download_jdk($jdk_version = $title){
      download_file { "Download asf-build-${jdk_version} zip from bintray" :
        url                   => "http://apache.bintray.com/WindowsPackages/asf-build-${jdk_version}.zip",
        destination_directory => 'F:\tools_zips',
      }
    }
  #### Download maven ####
  define download_maven($maven_version = $title){
      download_file { "Download asf-build-${maven_version} zip from bintray" :
        url                   => "http://apache.bintray.com/WindowsPackages/asf-build-${maven_version}.zip",
        destination_directory => 'F:\tools_zips',
      }
    }
  #### Download nant ####
  define download_nant($nant_version = $title){
      download_file { "Download asf-build-nant-${nant_version} zip from bintray" :
        url                   => "http://apache.bintray.com/WindowsPackages/asf-build-nant-${nant_version}.zip",
        destination_directory => 'F:\tools_zips',
      }
    }
  #### Download forrest ####
  define download_forrest($forrest_version = $title){
      download_file { "Download apache-forrest-${forrest_version} zip from bintray" :
        url                   => "http://apache.bintray.com/WindowsPackages/asf-build-forrest-${forrest_version}.zip",
        destination_directory => 'F:\tools_zips',
      }
    }

  download_ant { $ant:}
  download_chromedriver { $chromedriver:}
  download_geckodriver { $geckodriver:}
  download_gpg4win { $gpg4win:}
  download_gradle { $gradle:}
  download_graphviz { $graphviz:}
  download_iedriver { $iedriver:}
  download_jdk { $jdk:}
  download_maven { $maven:}
  download_nant { $nant:}
  download_forrest { $forrest:}
}
