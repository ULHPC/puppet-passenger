# File::      <tt>init.pp</tt>
# Author::    S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2016 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team
# License::   Gpl-3.0
#
# = Class: passenger
#
# Configure and manage passenger
#
# == Parameters:
#
# $ensure:: *Default*: 'present'. Ensure the presence (or absence) of passenger
# $version:: *Default*: '3.0.11'. Version of passenger <deprecated, required for Debian < 8)
# $version_rake:: *Default*: '0.8.7'. Version of rake (dependency) <deprecated, required for Debian < 8)
# $version_rack:: *Default*: '1.1.3'. Version of rack (dependency) <deprecated, required for Debian < 8)
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
        debian, ubuntu:         { include passenger::common::debian }
        default: {
            fail("Module passenger is not supported on ${::operatingsystem}")
        }
    }
}
