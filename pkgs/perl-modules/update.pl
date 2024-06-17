#!/usr/bin/env nix-shell
#!nix-shell -i perl -p common-updater-scripts

use strict;
use warnings;
use CPAN;

# Suppress CPAN output by redirecting STDOUT and STDERR to /dev/null
open my $old_stdout, '>&', \*STDOUT;
open my $old_stderr, '>&', \*STDERR;
open STDOUT, '>', '/dev/null';
open STDERR, '>', '/dev/null';

# Check if the package name is provided as an argument
if (@ARGV != 1) {
    open STDOUT, '>&', $old_stdout;
    open STDERR, '>&', $old_stderr;
    die "Usage: $0 <CPAN-package-name>\n";
}

my $package_name = $ARGV[0];

# Initialize CPAN and reload index silently
CPAN::HandleConfig->load;
CPAN::Shell::setup_output;
CPAN::Index->reload;

# Find the latest version of the package
my $module = CPAN::Shell->expand('Module', $package_name);

unless ($module) {
    open STDOUT, '>&', $old_stdout;
    open STDERR, '>&', $old_stderr;
    die "Package $package_name not found on CPAN.\n";
}

# Get the latest version of the package
my $latest_version = $module->cpan_version;

# Restore STDOUT and STDERR
open STDOUT, '>&', $old_stdout;
open STDERR, '>&', $old_stderr;

# Print the latest version
print "Latest version: $latest_version";

# Run the update-source-version command with the package name and version
(my $modified_package_name = $package_name) =~ s/::/_/g;
$modified_package_name = lc($modified_package_name);

my $command = "update-source-version $modified_package_name $latest_version";
system($command) == 0
    or die "Failed to run command: $command\n";
