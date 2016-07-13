# File::      <tt>common.pp</tt>
# Author::    S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2016 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team
# License::   Gpl-3.0
#
# ------------------------------------------------------------------------------
# = Class: passenger::common
#
# Base class to be inherited by the other passenger classes, containing the common code.
#
# Note: respect the Naming standard provided here[http://projects.puppetlabs.com/projects/puppet/wiki/Module_Standards]
# ------------------------------------------------------------------------------
# = Class: passenger::common
#
# Base class to be inherited by the other passenger classes
#
# Note: respect the Naming standard provided here[http://projects.puppetlabs.com/projects/puppet/wiki/Module_Standards]
class passenger::common {

    # Load the variables used in this module. Check the passenger-params.pp file
    require passenger::params

    if ( $::lsbdistcodename in ['squeeze', 'wheezy'] ) {
        # Deprecated installation method...


        # Install Rake (Ruby Make) from gems
        $rake_ensure = $passenger::ensure ? {
            'present' => $passenger::version_rake,
            default   => $passenger::ensure
        }
        package { 'ruby-rake':
            ensure   => $rake_ensure,
            name     => $passenger::params::packagename_rake,
            provider => gem,
        }

        # Install Rack: a Ruby Webserver Interface via gems
        $rack_ensure = $passenger::ensure ? {
            'present' => $passenger::version_rack,
            default   => $passenger::ensure
        }
        package { 'ruby-rack':
            ensure   => $rack_ensure,
            name     => $passenger::params::packagename_rack,
            provider => gem,
        }

        # Now install passenger
        $real_passenger_ensure = $passenger::ensure ? {
            'present' => $passenger::version,
            default   => $passenger::ensure
        }

        package { $passenger::params::extra_packages:
            ensure => $passenger::ensure
        }->
        package { 'passenger':
            ensure   => $real_passenger_ensure,
            name     => $passenger::params::packagename,
            provider => gem,
        }


        # Ensure installation in the good order
        Package['ruby-rake'] -> Package['ruby-rack'] -> Package['passenger']


        if $passenger::passenger_ruby == '/usr/bin/ruby2.1' {
          $passenger_rootdir = "/var/lib/gems/2.1/gems/passenger-${passenger::version}"
          $passenger_command = "/usr/bin/yes \"\" | /usr/local/bin/passenger-install-apache2-module > /tmp/debug_passenger 2>&1"
          $passenger_creates= "${passenger_rootdir}/buildout/apache2/mod_passenger.so"
          $passenger_load_module = "LoadModule passenger_module ${passenger_rootdir}/buildout/apache2/mod_passenger.so\n"
        } elsif $passenger::passenger_ruby == '/usr/bin/ruby1.9.1' or $passenger::passenger_ruby == '/usr/bin/ruby1.9.3' {
          $passenger_rootdir = "/var/lib/gems/1.9.1/gems/passenger-${passenger::version}"
          $passenger_command = "/usr/bin/yes \"\" | passenger-install-apache2-module > /tmp/debug_passenger 2>&1"
          $passenger_creates= "${passenger_rootdir}/buildout/apache2/mod_passenger.so"
          $passenger_load_module = "LoadModule passenger_module ${passenger_rootdir}/buildout/apache2/mod_passenger.so\n"
        } else {
          # Where Passenger is actually installed
          $passenger_rootdir = $::operatingsystem ? {
              default => "/var/lib/gems/1.8/gems/passenger-${passenger::version}"
          }
          $passenger_command = "/usr/bin/yes \"\" | /var/lib/gems/1.8/bin/passenger-install-apache2-module > /tmp/debug_passenger 2>&1"
          $passenger_creates= "${passenger_rootdir}/ext/apache2/mod_passenger.so"
          $passenger_load_module = "LoadModule passenger_module ${passenger_rootdir}/ext/apache2/mod_passenger.so\n"
        }

        exec { 'passenger-install':
          command => $passenger_command,
          timeout => 0,
          creates => $passenger_creates,
          require => Package['passenger']
        }

        Exec['passenger-install'] -> Apache::Module['passenger']

    } else {

        $passenger_rootdir = '/usr/lib/ruby/vendor_ruby/phusion_passenger/locations.ini'
        $passenger_load_module = 'LoadModule passenger_module /usr/lib/apache2/modules/mod_passenger.so'
        package { 'passenger':
            ensure => $real_passenger_ensure,
            name   => $passenger::params::packagename,
        }
        Package['passenger'] -> Apache::Module['passenger']

    }

    # Now prepare the apache module files
    include apache::params
    file { "${apache::params::mods_availabledir}/passenger.load":
      ensure  => $passenger::ensure,
      content => $passenger_load_module,
      mode    => $passenger::params::configfile_mode,
      owner   => $passenger::params::configfile_owner,
      group   => $passenger::params::configfile_group,
    }

    file { "${apache::params::mods_availabledir}/passenger.conf":
        ensure  => $passenger::ensure,
        content => template('passenger/passenger.conf.erb'),
        mode    => $passenger::params::configfile_mode,
        owner   => $passenger::params::configfile_owner,
        group   => $passenger::params::configfile_group,
    }

    apache::module{'passenger':
        ensure  => $passenger::ensure,
        require => [
                    File["${apache::params::mods_availabledir}/passenger.load"],
                    File["${apache::params::mods_availabledir}/passenger.conf"]
                    ]
    }
}
