@kaskr, I had not seen your instructions at https://github.com/kaskr/adcomp/wiki/Download#windows-debugger-gdb. 

Firstly, when using Sys.which(‘Rterm’) you no longer need to use step 3 that writes to .Rprofile. (Thankfully for a power user.)

I tried the MSYS2 pacman gdb (ver 11.1) install on two different Window 10 systems, but even after finding a workaround for the current working directory being added to the ‘Rterm’ path, I did not get a proper backtrace with line numbers.  (See https://github.com/John-R-Wallace-NOAA/Improving_TMB_gdbsource_under_Windows/blob/main/R_and%20_Cpp/MSY2_GDB_Test_Code.R for more info on the workaround.)

After some reflection, I realized that the reason it might have worked for you is that your install was of an older version.  Also, even if my version 11.1 did work, the next gdb release that MSYS2 uses when installing with ‘pacman -Sy gdb’ might not work.  Hence, I looked into installing a static version using MSYS2, but that was not fruitful under Windows. I did finally find a gdb ver 10.2 at winlibs.com for which I created a DOS batch file to install gdb from mingw64 ver 8.5.0.  I have added an update to my repo: https://github.com/John-R-Wallace-NOAA/Improving_TMB_gdbsource_under_Windows with all the details. GDB ver 8.5.0 properly gives the backtrace with line number information when using the compile options given in the help for TMB::gdbsource().

After emailing with Andre Punt on how to get TMB::gdbsource() working correctly under Windows for a class he was teaching, I ended up running Ubuntu using WSL (Windows Subsystem for Linux) 
https://github.com/John-R-Wallace-NOAA/TMB_on_Windows_Subsystem_for_Linux