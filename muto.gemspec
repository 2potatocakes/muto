# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "muto/version"

Gem::Specification.new do |s|
  s.name        = "muto"
  s.version     = Muto::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Lucas Hills"]
  s.email       = ["lucas@lucashills.com"]
  s.homepage    = 'https://github.com/2potatocakes/muto'
  s.summary     = 'I got sick of manually having to change windows environment variables and versions of ruby in the control panel'
  s.description = 'Set up different Windows Ruby environments and switch between them on the command line'

  s.files       = %w(Rakefile Gemfile README.textile muto.gemspec) + Dir.glob("{bin,lib}/**/*")
  s.bindir      = 'bin'
  s.executables = %w(extract_muto)
  s.post_install_message = %q{
========================================================================
Muto installed!
------------------------------------------------------------------------
This gem is basically just a wrapper to make deployment easier. Delete
the gem after you've deployed the scripts if you want. To extract the
scripts, cd into a directory where you'd like to keep them and from the
command line run:

extract_muto

========================================================================
}

  s.require_paths = ['lib']
  s.extra_rdoc_files = ['README.textile']
end
