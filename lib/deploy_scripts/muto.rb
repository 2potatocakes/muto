
require 'rubygems'
require 'win32/registry'
require 'Win32API'
require 'yaml'

HWND_BROADCAST = 0xffff
WM_SETTINGCHANGE = 0x001A
SMTO_ABORTIFHUNG = 2

module Muto

  class Muto

    def initialize
      @commands = []
      @ruby_versions = []
      @all_bin_paths = []
      yml_path = File.expand_path('ruby_versions.yml', File.dirname(__FILE__))

      begin
        @versions_yml = YAML.load_file(yml_path)
      rescue Exception => msg
        puts "An Exception occurred while trying to parse your yml file: #{yml_path}"
        raise msg
      end


      if @versions_yml['ruby_versions'].nil?
        puts "There aren't any version of Ruby defined in your ruby_versions.yml yet"
        puts "Update #{File.expand_path(File.join(File.dirname(__FILE__), "ruby_versions.yml")).to_s.gsub(/\//, '\\')} first and try again"
        puts "\nCurrently using:"
        exit!
      else

        @versions_yml['ruby_versions'].each do |key, val|
          @ruby_versions << @versions_yml['ruby_versions'][key]['shortcut'].to_s
          #Convert the following paths to ruby paths so that they can be escaped more easily later on
          @all_bin_paths << File.expand_path(@versions_yml['ruby_versions'][key]['bin_folder'])

          begin
            exe_name = (@versions_yml['ruby_versions'][key]['exe_name']) ? @versions_yml['ruby_versions'][key]['exe_name'] : 'ruby.exe'
            ruby_exe = File.expand_path(File.join(@versions_yml['ruby_versions'][key]['bin_folder'], exe_name))
            ruby_version = `"#{ruby_exe}" -v`

            if File.exist?(ruby_exe)
              add_version(:"#{@versions_yml['ruby_versions'][key]['shortcut'].to_s}", ruby_version)
            else
              puts "File does not exist: #{ruby_exe.to_s}"
            end

          rescue
            puts "Error: File does not exist: #{ruby_exe.to_s}"
          end

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
          version = ARGV.shift.to_s
        rescue
          puts "Unknown Version"
          help
        end

        if @ruby_versions.include?(version)
          @versions_yml['ruby_versions'].each do |key, val|
            update_user_path_variable(key.to_s) if @versions_yml['ruby_versions'][key]['shortcut'].to_s == version
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
        puts "  #{command[:name]}#{command[:name].to_s.length < 4 ? "\t\t" : "\t"}- #{command[:desc]}" unless command[:hidden]
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


      # The muto.bat script will finish up by outputting the current version or Ruby being used on your system
      # This next line is just sugar
      puts "\nSystem updated. Now using:"
    end

    def update_user_path_variable(versions_yml_key)

      begin
        reg_key, path_env_var = Win32::Registry::HKEY_CURRENT_USER.open('Environment').read('PATH')
      rescue
        user_path_env_not_set_properly_msg
        exit!
      end

      @all_bin_paths.each do |bin_path|
        escapedPath = Regexp.new(bin_path.gsub(/\//, "\\\\\\\\"), Regexp::IGNORECASE)
        path_env_var.gsub!(escapedPath, @versions_yml['ruby_versions'][versions_yml_key]['bin_folder'].to_s)
      end

      Win32::Registry::HKEY_CURRENT_USER.open('Environment', Win32::Registry::KEY_WRITE) do |reg|
        reg['PATH'] = path_env_var
      end

      if @versions_yml['ruby_versions'][versions_yml_key]['user_env_variables']
        @versions_yml['ruby_versions'][versions_yml_key]['user_env_variables'].each do |key, val|
          Win32::Registry::HKEY_CURRENT_USER.open('Environment', Win32::Registry::KEY_WRITE) do |reg|
            reg[key.upcase] = val.nil? ? ";" : val
          end
        end
      end

      broadcast_WM_SETTINGCHANGE_signal
    end

  private

    def user_path_env_not_set_properly_msg
      puts "\nThere are no User environment variables named PATH defined, most likely your
            \nruby version is defined on your System PATH environment variable. Muto can
            \nonly modify User environment variables, not system environment variables.
            \nSwitch your path to ruby over to a User environment variable and you
            \nshould be good to go :)"
      puts "\nSystem did not update! Still using:"
    end
  end
end

#if __FILE__ == $0
  s = Muto::Muto.new
  s.run
#end
