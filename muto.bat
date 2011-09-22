@ECHO OFF



C:\ruby\bin\ruby.exe %~dp0\muto.rb %* 2> NUL


:: The following 2 lines allow you to not have to reset your command line in order to pick up
:: the new Environment Variables

reset_command_line.vbs
call "%TEMP%\reset_command_line.bat"



:: The end of this script just outputs the now current version of Ruby being used by your system
:: Using 2> NUL just means that if the ruby/jruby command doesn't exist, the error message won't be output

@ruby -v 2> NUL
@jruby -v 2> NUL
