



::@ruby -v > NUL 2>&1
::ECHO Ruby Error level %ERRORLEVEL%

::@jruby -v > NUL 2>&1
::ECHO Ruby Error level %ERRORLEVEL%



:: Would like to fix this so that jruby could be used to call muto.rb but can't get it
:: to output the other versions of ruby properly using `"#{ruby_exe}" -v`  :( Will fix soon..
::@jruby %~dp0\muto.rb %* 2> NUL



:: This works    @ruby -v 2>NUL



::ECHO.@ruby -v>NUL
::ECHO Ruby Error level %ERRORLEVEL%
::IF %ERRORLEVEL% EQU 0 GOTO FoundRuby

::@jruby -v
::ECHO Error Jlevel %ERRORLEVEL%
::IF %ERRORLEVEL% EQU 0 GOTO FoundJRuby


:FoundRuby
::ECHO ON
::ECHO found normal ruby
::@ruby %~dp0\muto.rb %*
::GOTO ResetCommandLineVars
::GOTO End
:end

:FoundJRuby
::ECHO ON
::ECHO found jruby
::@jruby %~dp0\muto.rb %*
::GOTO ResetCommandLineVars
::GOTO End
:end

:ResetCommandLineVars
::@ECHO OFF
::reset_command_line.vbs
::call "%TEMP%\reset_command_line.bat"
:end

:End