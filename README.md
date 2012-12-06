URU-MOSS-Shard-Helpers
======================

Helper scripts for maintaining a MOSS Uru shard.

Setting up and reconfiguring a Uru shard is a lot of grunt work, and I am lazy.
Why not let the computer do most of the work?

Here is what we have:

--This generates files for the 'file' server--

makembm.pl      - generate manifest files and gzip the target files for the MOSS file server.

--These generate files for the 'auth' server--

pack-python.pl  - generate a stock python.pak and appropriate manifest.

secure-SDL.pl   - Secure the SDL files and generate a appropriate manifest.

moss1.ps1 - Powershell script that generates 'auth' and 'game' server files and deposits them on the server.
  