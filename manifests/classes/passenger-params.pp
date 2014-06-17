# File::      <tt>passenger-params.pp</tt>
# Author::    Hyacinthe Cartiaux (hyacinthe.cartiaux@uni.lu)
# Copyright:: Copyright (c) 2011 Hyacinthe Cartiaux
# License::   GPL v3
#
# ------------------------------------------------------------------------------
# = Class: passenger::params
#
# In this class are defined as variables values that are used in other
# passenger classes.
# This class should be included, where necessary, and eventually be enhanced
# with support for more OS
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# The usage of a dedicated param classe is advised to better deal with
# parametrized classes, see
# http://docs.puppetlabs.com/guides/parameterized_classes.html
#
# [Remember: No empty lines between comments and class definition]
#
class passenger::params {

    ######## DEFAULTS FOR VARIABLES USERS CAN SET ##########################
    # (Here are set the defaults, provide your custom variables externally)
    # (The default used is in the line with '')
    ###########################################

    # ensure the presence (or absence) of passenger
    $ensure = $passenger_ensure ? {
        ''      => 'present',
        default => "${passenger_ensure}"
    }

    #### MODULE INTERNAL VARIABLES  #########
    # (Modify to adapt to unsupported OSes)
    #######################################
    $packagename = $::operatingsystem ? {
        default => 'passenger'
    }
    $version = $::operatingsystem ? {
        default => '3.0.11',
    }

    # RAKE --  Ruby Make
    # See http://rake.rubyforge.org/
    $packagename_rake = $::operatingsystem ? {
        default => 'rake',
    }
    $version_rake = $::operatingsystem ? {
        default => '0.8.7',
    }

    # Rack: a Ruby Webserver Interface
    # See http://rack.github.com/
    $packagename_rack = $::operatingsystem ? {
        default => 'rack',
    }
    $version_rack = $::operatingsystem ? {
        default => '1.1.3',
    }

    $extra_packages = $::operatingsystem ? {
        default => [
                    'apache2-prefork-dev',
                    'build-essential',
                    'rubygems1.8',
                    'libcurl4-openssl-dev'
                    ]
    }

    $configfile_mode = $::operatingsystem ? {
        default => '0644',
    }

    $configfile_owner = $::operatingsystem ? {
        default => 'root',
    }

    $configfile_group = $::operatingsystem ? {
        default => 'root',
    }

    # TODO: consider Ruby Enterprise Edition http://www.rubyenterpriseedition.com/

    # Specify the Ruby interpreter to use.
    $passenger_ruby = $::operatingsystem ? {
        default => '/usr/bin/ruby1.8'
    }

    $default_user = $::operatingsystem ? {
        default => 'nobody'
    }
}

