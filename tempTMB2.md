Fixing gdbsource under Windows with Sys.which(), 'quit', and Rtools 3.5

With a clean install of CRAN R ver 4.2.1 and RTools 4.2, without RTools 3.5 installed, gdbsource() under Windows fails due to a missing gdb.exe. Jeroen Ooms took over maintaining RTools for Windows R from Prof. Brian Ripley and Duncan Murdoch starting with RTools 4.0, and neither RTools 4.0 nor 4.2 have gdb.exe available: https://cran.r-project.org/bin/windows/Rtools/

In 2021 Mark Bravington tried to add gdb to RTools 4.0 under Windows without success: https://stat.ethz.ch/pipermail/r-devel/2021-April/080623.html . In response to the Mark's post, Tomas Kalibera points out that Rtools 3.5 can still be used for gdb.exe (just copying over gdb.exe does not work).

Many of gdbsource() problems under Windows in TMB's issues 'gdbsource Errors #67' and '???????' are from either Rterm.exe not being found or that the Rterm.exe found in the path is not the correct one.  The wrong Rterm.exe could be a version issue or a mismatch between 32 vs. 64-bit.
