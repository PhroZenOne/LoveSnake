@echo off
createLove.vbs Snake\src snake
move /Y Snake.love Executables/snake.love
copy /b LoveLib\love.exe+Executables\snake.love snake.exe
move /Y snake.exe Executables\Combined\snake.exe