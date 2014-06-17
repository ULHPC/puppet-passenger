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
class passenger(
    $ensure       = $passenger::params::ensure,
    $version      = $passenger::params::version,
    $version_rake = $passenger::params::version_rake,
    $version_rack = $passenger::params::version_rack,
    $passenger_ruby = $passenger::params::passenger_ruby,
    $default_user = $passenger::params::default_user
)
inherits passenger::params
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

    # Install Rake (Ruby Make) from gems
    $rake_ensure = $passenger::ensure ? {
        'present' => "${passenger::version_rake}",
        default   => "${passenger::ensure}"
    }
    package { 'ruby-rake':
        name     => "${passenger::params::packagename_rake}",
        ensure   => "${rake_ensure}",
        provider => gem,
    }

    # Install Rack: a Ruby Webserver Interface via gems
    $rack_ensure = $passenger::ensure ? {
        'present' => "${passenger::version_rack}",
        default   => "${passenger::ensure}"
    }
    package { 'ruby-rack':
        name     => "${passenger::params::packagename_rack}",
        ensure   => "${rack_ensure}",
        provider => gem,
    }

    # Now install passenger
    $real_passenger_ensure = $passenger::ensure ? {
        'present' => "${passenger::version}",
        default   => "${passenger::ensure}"
    }
    package { 'passenger':
        name     => "${passenger::params::packagename}",
        ensure   => "${real_passenger_ensure}",
        provider => gem,
    }

    
    package { 'passenger_extra_packages':
        name   => $passenger::params::extra_packages,
        ensure => "${passenger::ensure}"
    }

    # Ensure installation in the good order
    Package['passenger_extra_packages'] -> Package['ruby-rake'] -> Package['ruby-rack'] -> Package['passenger']


    if $passenger::passenger_ruby == '/usr/bin/ruby1.9.1' or $passenger::passenger_ruby == '/usr/bin/ruby1.9.3' {
      #Fix for debian7.4 and ruby version 1.9.x
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
      require => [
                  Package['passenger'],
                  Package['passenger_extra_packages']
                  ]
    }

    # Now prepare the apache module files
    include apache::params
    file { "${apache::params::mods_availabledir}/passenger.load":
      ensure  => "${passenger::ensure}",
      content => $passenger_load_module,
      mode    => "${passenger::params::configfile_mode}",
      owner   => "${passenger::params::configfile_owner}",
      group   => "${passenger::params::configfile_group}",
    }

    file { "${apache::params::mods_availabledir}/passenger.conf": 
        ensure  => "${passenger::ensure}",
        content => template("passenger/passenger.conf.erb"),
        mode    => "${passenger::params::configfile_mode}",
        owner   => "${passenger::params::configfile_owner}",
        group   => "${passenger::params::configfile_group}",
    }

    apache::module{"passenger":
        ensure  => "${passenger::ensure}",
        require => [
                    Exec['passenger-install'],
                    File["${apache::params::mods_availabledir}/passenger.load"],
                    File["${apache::params::mods_availabledir}/passenger.conf"]
                    ]
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



