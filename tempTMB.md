gdbsource() under Windows fails due to the missing gdb.exe under RTools 4.0 and 4.2

With a clean install of CRAN R ver 4.2.1 and RTools 4.2, without RTools 3.5 installed, gdbsource() under Windows fails due to a missing gdb.exe.
Jeroen Ooms took over maintaining RTools for Windows R from Prof. Brian Ripley and Duncan Murdoch starting with RTools 4.0, and neither RTools 4.0 nor 4.2 have gdb.exe available: https://cran.r-project.org/bin/windows/Rtools/  

In 2021 Mark Bravington tried to add gdb to RTools 4.0 under Windows without success: https://stat.ethz.ch/pipermail/r-devel/2021-April/080623.html 
	
Regardless, even with Rtools 3.5’s location for gdb.exe in the system path (C:/Rtools/mingw_64/bin) no line numbers are given in the gdb Windows error output. This is true for the compile options given in the R help for gdbsource() and for the many other options I have tried.

A post I recently found on StackOverFlow: https://stackoverflow.com/questions/18407563/gcc-doesnt-produce-line-number-information-even-with-g-option points out a dwarf4 versus dwarf2 debugging options issue under Linux (which might be the cause of @iperedaagirre's TMB Issue #367), but changing that option under Windows didn't help with line numbers in the gdb.exe error reporting.

When I initially came across this issue under Windows 10 I moved to using gdbsource() only on Linux as an easy fix, since I have a Linux server available to me. However, Andre Punt emailed me about this issue since he was teaching a class that covered TMB and he and his students were using Window machines. After searching for a solution on Windows, I ended using Ubuntu on WSL (Windows Subsystem for Linux): 
https://github.com/John-R-Wallace-NOAA/TMB_on_Windows_Subsystem_for_Linux 
(Click on the 'README.md' file to expand the instructions for easier reading.)

The WSL Ubuntu installation allows gdbsource() to properly debug CPP files while using a PC running Windows 10 as the main OS. It also provides R on an Ubuntu installation with GDB debugging software for any other purpose. Also, WSL saves all the software in a single folder, which can be used for computational reproducibility, exporting to another machine, or sharing with a colleague.

Andre followed the instructions and found them to work for him.  He did want a more complete working environment and asked for graphics beyond the default pdf(), so there are also instructions to add the  X11cairo graphics device, which works well.
Notes.md on the repo has additional information and Linux_vs_Windows_gdb_errors.md gives a comparison of the Linux GDB output compared to that under Windows. It also shows the use of Sys.which() to always find the correct path for Rterm.exe in .gdbsource.win(). 
