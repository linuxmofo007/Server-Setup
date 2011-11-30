#!/usr/bin/perl -w

# Written by: linuxmofo007@gmail.com
# Version: 0.1

#
# Any needed modules and 'USE' statements go here
#
use strict;

#
# User supplied variables
#

# Change groups, supportgroups, admins, users, services to match your setup.
my @groups = qw { group1 group2 ... group10 };
my @supportgroups = qw { extragroup1 extragroup2 ... extragroup10 };
my @admins = qw { admin1 admin2 ... admin10 };
my @users = qw { user1 user2 ... user10 };
my @shutdown_services = qw { restorecond portmap mdmonitor rpcidmapd setroubleshoot gpm sendmail cups hidd acpid pcscd bluetooth xfs yum-updated avahi-daemon firstboot ip6tables mcstrans microcode_ctl smartd nfs autofs nfslock };

#
# Setup groups
#
foreach $group (@groups) {
  system(groupadd $group)
};

#
# Setup admin user accounts
#
foreach my $user (@admins) {
  system(useradd -g noc -G sshaccess $user)
};

#
# Setup  other users
#
for each my $user (@users) {
  system(useradd -G sshaccess,tier1 $user)
};

#
# Grant sudo access
#
my $sudo_file = '/etc/sudoers';

# add support groups to have sudo 
foreach my $group (@supportgroups) {
  my $sudo_append = "$group    ALL=(ALL)    ALL";
  open(DATA, ">>$sudo_file") || die("Could not open file");
  print DATA "$sudo_append";
  close(DATA);
}

# add noc to have sudo w/ no passwords
open(DATA, ">>$sudo_file") || die("Could not open file");
print DATA '%noc    ALL=(ALL)    NOPASSWD: ALL';
close(DATA);

#
# Fix the SSH config
#
my $ssh_config = '/etc/ssh/sshd_config';
# No idea how to do tis the next 2 with perl
system(sed -i 's/#UseDNS yes/UseDNS no' $ssh_config);
system(sed -i 's/#PermitRootLogin yes/PermitRootLogin no/' $ssh_config);
open(DATA, ">>$ssh_config") || die("Could not open file");
  print DATA "AllowGroups sshaccess";
  close(DATA);

#
# Disable SELINUX
#
system('sed -i s/SELINUX=enforcing/SELINUX=disabled');

#
# Shutdown unwanted services
# 
foreach my $service (@shutdown_services) {
  system("chkconfig $service off");
};

#
# Update Server & Reboot
#
system("yum update -y");
system("reboot");
