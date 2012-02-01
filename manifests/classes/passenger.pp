# File::      <tt>passenger.pp</tt>
# Author::    Hyacinthe Cartiaux (hyacinthe.cartiaux@uni.lu)
# Copyright:: Copyright (c) 2011 Hyacinthe Cartiaux
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Class: passenger
#
# Configure and manage passenger
#
# == Parameters:
#
# $ensure:: *Default*: 'present'. Ensure the presence (or absence) of passenger
# $version:: *Default*: '3.0.11'. Version of passenger 
# $version_rake:: *Default*: '0.8.7'. Version of rake (dependency) 
# $version_rack:: *Default*: '1.1.3'. Version of rack (dependency) 
#
# == Actions:
#
# Install and configure passenger module for Apache
#
# == Requires:
#
# You must include apache module in order to use the passenger module
#
# == Sample Usage:
#
#     import passenger
#
# You can then specialize the various aspects of the configuration,
# for instance
#
#         class { 'passenger':
#             ensure       => 'present',
#             version      => '3.0.11',
#             version_rake => '0.8.7',
#             version_rack => '1.1.3',
#         }
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
#
# [Remember: No empty lines between comments and class definition]
#
class passenger( $ensure       = $passenger::params::ensure,
                 $version      = $passenger::params::version_passenger,
                 $version_rake = $passenger::params::version_rake,
                 $version_rack = $passenger::params::version_rack
               ) inherits passenger::params
{
    info ("Configuring passenger (with ensure = ${ensure})")

    if ! ($ensure in [ 'present', 'absent' ]) {
        fail("passenger 'ensure' parameter must be set to either 'absent' or 'present'")
    }

    # Ensure the class apache has been instanciated
    if (! defined( Class['apache'] ) ) { 
        fail("The class 'apache' is not instancied")
    }

    case $::operatingsystem {
        debian, ubuntu:         { include passenger::debian }
        default: {
            fail("Module $module_name is not supported on $operatingsystem")
        }
    }
}

# ------------------------------------------------------------------------------
# = Class: passenger::common
#
# Base class to be inherited by the other passenger classes
#
# Note: respect the Naming standard provided here[http://projects.puppetlabs.com/projects/puppet/wiki/Module_Standards]
class passenger::common {

    # Load the variables used in this module. Check the passenger-params.pp file
    require passenger::params

    package { "${passenger::params::name_rake}":
        ensure => $passenger::ensure ? { 
                      'present' => "${passenger::version_rake}",
                       default  => "${passenger_ensure}"
                  },
        provider => gem,
    }
    
    package { "${passenger::params::name_rack}":
        ensure => $passenger::ensure ? { 
                      'present' => "${passenger::version_rack}",
                       default  => "${passenger_ensure}"
                  },
        provider => gem,
    }

    package { "${passenger::params::name_passenger}":
        ensure => $passenger::ensure ? { 
                      'present' => "${passenger::version_passenger}",
                       default  => "${passenger_ensure}"
                  },
        provider => gem,
    }
   
    package { 'makedep':
        name   => $passenger::params::makedep,
        ensure => $passenger::ensure
    }

    Package['makedep'] -> Package["${passenger::params::name_rake}"] -> Package["${passenger::params::name_rack}"] -> Package["${passenger::params::name_passenger}"]

    exec { 'passenger-install':
        command => "/usr/bin/yes \"\" | /var/lib/gems/1.8/bin/passenger-install-apache2-module > /tmp/debug_passenger 2>&1",
        creates => "/var/lib/gems/1.8/gems/passenger-$version/ext/apache2/mod_passenger.so",
        require => [ Package['passenger'], Package['makedep'] ];
    }

    file { 'passenger.load':
        ensure  => $passenger::ensure,
        path    => "${apache::params::mods_availabledir}/passenger.load",
        content => "LoadModule passenger_module /var/lib/gems/1.8/gems/passenger-$version/ext/apache2/mod_passenger.so\n",
        mode    => $passenger::params::configfile_mode,
        owner   => $passenger::params::configfile_owner,
        group   => $passenger::params::configfile_group,
    }

    file { 'passenger.conf':
        ensure  => $passenger::ensure,
        path    => "${apache::params::mods_availabledir}/passenger.conf",
        content => template("passenger/passenger.conf.erb"),
        mode    => $passenger::params::configfile_mode,
        owner   => $passenger::params::configfile_owner,
        group   => $passenger::params::configfile_group,
    }

    apache::module{"passenger":
        ensure  => $passenger::ensure,
        require => [ Exec['passenger-install'], File['passenger.load'], File['passenger.conf'] ]
    }
}


# ------------------------------------------------------------------------------
# = Class: passenger::debian
#
# Specialization class for Debian systems
class passenger::debian inherits passenger::common { }

# ------------------------------------------------------------------------------
# = Class: passenger::redhat
#
# Specialization class for Redhat systems
class passenger::redhat inherits passenger::common { }



