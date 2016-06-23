class packer::vagrant(
  $manage_user = 'true',
  $manage_ssh = 'false',
  $public_rsa_key = 'AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ==',
  $manage_sudo = 'false',
) inherits packer::vagrant::params {

  if str2bool($manage_user) {
    group { 'vagrant':
      ensure => present,
    }

    user { 'vagrant':
      ensure     => present,
      home       => "${home_base}/vagrant",
      managehome => true,
      gid        => 'vagrant',
      groups     => [ 'vagrant', ],
      shell      => '/bin/bash',
      require    => Group[ 'vagrant' ],
    }
  }

  if str2bool($manage_ssh) {
    file { "${home_base}/vagrant/.ssh":
      ensure  => directory,
      owner   => 'vagrant',
      group   => 'vagrant',
      mode    => '0600',
      require => User[ 'vagrant' ],
    }

    ssh_authorized_key { 'vagrant':
      ensure  => present,
      user    => 'vagrant',
      key     => $public_rsa_key,
      type    => 'ssh-rsa',
    }
  }

  if str2bool($manage_sudo) {
    sudo::sudoers { 'vagrant':
      ensure   => 'present',
      users    => ['vagrant'],
      tags     => ['NOPASSWD'],
    }

    file_line { "allow ${sudoers_file} notty":
      path   => $sudoers_file,
      line   => '#Defaults requiretty',
      match  => 'Defaults\s+requiretty',
    }
  }
}
