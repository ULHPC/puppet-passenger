# File::      <tt>params.pp</tt>
# Author::    S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team (hpc-sysadmins@uni.lu)
# Copyright:: Copyright (c) 2016 S. Varrette, H. Cartiaux, V. Plugaru, S. Diehl aka. UL HPC Management Team
# License::   Gpl-3.0
#
# ------------------------------------------------------------------------------
# You need the 'future' parser to be able to execute this manifest (that's
# required for the each loop below).
#
# Thus execute this manifest in your vagrant box as follows:
#
#      sudo puppet apply -t --parser future /vagrant/tests/params.pp
#
#

include 'passenger::params'

$names = ["ensure", "packagename", "version", "packagename_rake", "version_rake", "packagename_rack", "version_rack", "extra_packages", "configfile_mode", "configfile_owner", "configfile_group", "passenger_ruby", "default_user"]

notice("passenger::params::ensure = ${passenger::params::ensure}")
notice("passenger::params::packagename = ${passenger::params::packagename}")
notice("passenger::params::version = ${passenger::params::version}")
notice("passenger::params::packagename_rake = ${passenger::params::packagename_rake}")
notice("passenger::params::version_rake = ${passenger::params::version_rake}")
notice("passenger::params::packagename_rack = ${passenger::params::packagename_rack}")
notice("passenger::params::version_rack = ${passenger::params::version_rack}")
notice("passenger::params::extra_packages = ${passenger::params::extra_packages}")
notice("passenger::params::configfile_mode = ${passenger::params::configfile_mode}")
notice("passenger::params::configfile_owner = ${passenger::params::configfile_owner}")
notice("passenger::params::configfile_group = ${passenger::params::configfile_group}")
notice("passenger::params::passenger_ruby = ${passenger::params::passenger_ruby}")
notice("passenger::params::default_user = ${passenger::params::default_user}")

#each($names) |$v| {
#    $var = "passenger::params::${v}"
#    notice("${var} = ", inline_template('<%= scope.lookupvar(@var) %>'))
#}
