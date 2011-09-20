
begin; require 'rubygems'; rescue; end
require 'win32/registry'
require 'Win32API'
require 'yaml'

HWND_BROADCAST = 0xffff
WM_SETTINGCHANGE = 0x001A
SMTO_ABORTIFHUNG = 2

class Muto

  def initialize
    @commands = []
    @supported_versions = []
    @all_bin_paths = []

    @versions_yml = YAML.load(IO.read(File.join(File.dirname(__FILE__), 'ruby_versions.yml')))

    @versions_yml['supported_versions'].each do |key, val|
      @supported_versions << @versions_yml['supported_versions'][key]['shortcut']
      @all_bin_paths << @versions_yml['supported_versions'][key]['bin_folder']

      begin
        ruby_exe = File.expand_path(File.join(@versions_yml['supported_versions'][key]['bin_folder'], 'ruby.exe'))
        ruby_version = `"#{ruby_exe}" -v`

        if File.exist?(ruby_exe)
          add_version(:"#{@versions_yml['supported_versions'][key]['shortcut'].to_s}", ruby_version)
        else
          puts "File does not exist: #{ruby_exe.to_s}"
        end

      rescue
        puts "Error: File does not exist: #{ruby_exe.to_s}"
      end

    end

  end

  def add_version(name, description, hidden=false)
    @commands << { :name => name, :desc => description, :hidden => hidden }
  end

  def run
    if ARGV.empty?
      help
    else
      begin
        version = ARGV.shift.to_i
      rescue
        puts "Unknown Version"
        help
      end

      if @supported_versions.include?(version)
        @versions_yml['supported_versions'].each do |key, val|
          update_user_path_variable(key.to_s) if @versions_yml['supported_versions'][key]['shortcut'].to_i == version
        end
      else
        puts "Unknown Version"
        help
      end

    end
  end

  def help
    puts "\nExpected format:  muto [ruby_version]"
    puts "\nAvailable Versions are:"
    @commands.each do |command|
      puts "   #{command[:name]} \t - #{command[:desc]}" unless command[:hidden]
    end

    # The bat file muto.bat will always output the current version of Ruby being
    # used by your system, so just adding this to make it read nice
    puts "\nCurrently using:"
  end


  def broadcast_WM_SETTINGCHANGE_signal
    # After setting a new environment variable, a 'WM_SETTINGCHANGE' signal needs to be broadcast to windows
    # so that you won't need to log off and log back on again for the new settings to be propagated.
    # The following uses the Win32API module to send the signal
    #
    # For more info read up here: http://msdn.microsoft.com/en-us/library/windows/desktop/ms725497%28v=vs.85%29.aspx
    #

    call_timeout_function = Win32API.new('user32', 'SendMessageTimeout', 'LLLPLLP', 'L')
    result = 0
    call_timeout_function.call(HWND_BROADCAST, WM_SETTINGCHANGE, 0, 'Environment', SMTO_ABORTIFHUNG, 5000, result)

    puts "Environment variable updated"
  end

  def update_user_path_variable(versions_yml_key)
    reg_key, path_env_var = Win32::Registry::HKEY_CURRENT_USER.open('Environment').read('PATH')

    #TODO - Fix regex to support all variants of path names
    @all_bin_paths.each do |bin_path|

      path_env_var.gsub!(bin_path, @versions_yml['supported_versions'][versions_yml_key]['bin_folder'].to_s)

    end

    Win32::Registry::HKEY_CURRENT_USER.open('Environment', Win32::Registry::KEY_WRITE) do |reg|
      reg['PATH'] = path_env_var
    end

    @versions_yml['supported_versions'][versions_yml_key]['other_variables'].each do |key, val|
      Win32::Registry::HKEY_CURRENT_USER.open('Environment', Win32::Registry::KEY_WRITE) do |reg|
        reg[key.upcase] = val
      end
    end

    broadcast_WM_SETTINGCHANGE_signal

  end
end


if __FILE__ == $0
  if RUBY_PLATFORM =~ /(:?mswin|mingw)/
    s = Muto.new
    s.run
  end
end
