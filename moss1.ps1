# Process SDL and Python scripts for a MOSS shard server
# July 10 2011  F. Holmer
# ver 0.1
#
$env:path += ";c:\Program Files (x86)\PuTTY"
$env:path += ";c:\sperl\perl\bin\perl"
#
$password = "SuperSecret"
# where things can be found and where things go.
$moulScripts = "c:\Users\Owner\Work\H-uru\moul-scripts"
$utilPath = "c:\Users\Owner\Work\H-uru\Plasma\build\bin\Release"
$server = "moss@windring.ussc.com:auth/default"
$serverSDL = "$server/SDL"
$serverPython = "$server/Python"
#
New-Alias secure $utilPath\plFileSecure
New-alias pack $utilPath\plPythonPack
#
set-location $moulScripts
# 
# clean up from the last time
remove-item *.mbam
remove-item Python.txt
remove-item SDL.txt
remove-item -recurse secureSDL
remove-item -recurse game
#
# Let us begin by packing and securing Python.
# The result is $moulScripts\Python\python.pak
pack Python
secure Python pak
set-content Python.txt "Python\python.pak"
perl make-mbam.pl Python.txt
pscp -pw $password Python/python.pak $serverPython
#
# do the SDLs
# First, copy them to a new folder then secure them
copy-item $moulScripts\SDL -destination $moulScripts\secureSDL -recurse
secure secureSDL sdl
foreach ($i in (get-childitem -name secureSDL)) { 
    add-content SDL.txt "SDL\$i" 
}
perl make-mbam.pl SDL.txt
pscp -pw $password secureSDL/*.sdl $serverSDL
pscp -pw $password *.mbam $server
#
# update the game server files
$game = "moss@windring.ussc.com:game"
$gameSDL = "$game/SDL"
$gameAge = "$game/age"
#
new-item -type directory game\SDL\common
new-item -type directory game\SDL\Garrison
new-item -type directory game\SDL\Teledahn
#
copy-item $moulScripts\SDL\*.sdl -destination $moulScripts\game
set-location $moulScripts\game
rename-item PhilRelto.sdl philRelto.sdl
rename-item ahnonay.sdl Ahnonay.sdl
rename-item ahnonaycathedral.sdl AhnonayCathedral.sdl
move-item .\grsnTrnCtrDoors.sdl -destination $moulScripts\game\SDL\Garrison
move-item .\tldnPwrTwrPeriscope.sdl -destination $moulScripts\game\SDL\Teledahn
move-item .\tldnVaporScope.sdl -destination $moulScripts\game\SDL\Teledahn
move-item .\tldnWRCCBrain.sdl -destination $moulScripts\game\SDL\Teledahn
move-item .\*.sdl -destination $moulScripts\game\SDL\common
#
pscp -pw $password SDL\common\*.sdl $gameSDL/common
pscp -pw $password SDL\Garrison\*.sdl $gameSDL/Garrison
pscp -pw $password SDL\Teledahn\*.sdl $gameSDL/Teledahn
#
set-location $moulScripts\dat
pscp -pw $password *.age $gameAge
