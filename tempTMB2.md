Fixing gdbsource under Windows with Sys.which(), 'quit', and Rtools 3.5

With a clean install of CRAN R ver 4.2.1 and RTools 4.2, without RTools 3.5 installed, gdbsource() under Windows fails due to a missing gdb.exe. Jeroen Ooms took over maintaining RTools for Windows R from Prof. Brian Ripley and Duncan Murdoch starting with RTools 4.0, and neither RTools 4.0 nor 4.2 have gdb.exe available: https://cran.r-project.org/bin/windows/Rtools/

In 2021 Mark Bravington tried to add gdb to RTools 4.0 under Windows without success: https://stat.ethz.ch/pipermail/r-devel/2021-April/080623.html . In response to the Mark's post, Tomas Kalibera points out that Rtools 3.5 can still be used for gdb.exe (just copying over gdb.exe does not work).

Many of gdbsource() problems under Windows in TMB's issues 'gdbsource Errors #67' and '???????' are from either Rterm.exe not being found or that the Rterm.exe found in the system path is not the correct one.  The wrong Rterm.exe could be a version issue or a mismatch between 32 versus 64-bit.

Using base::Sys.which() fixes these problems:



    # -- R ver 4.1.2 --    
    Sys.which('gdb.exe')
                                 gdb.exe 
    "W:\\Rtools\\mingw_64\\bin\\gdb.exe" 
    
    
    Sys.which('g++.exe')
                                 g++.exe 
    "W:\\Rtools\\mingw_64\\bin\\g++.exe" 
    
    
    # -- R ver 4.2.1 --    
    Sys.which('gdb.exe')
                                 gdb.exe 
    "W:\\Rtools\\mingw_64\\bin\\gdb.exe" 
    
    
    Sys.which('g++.exe')
                                                          g++.exe 
    "W:\\rtools42\\x86_64-w64-mingw32.static.posix\\bin\\g++.exe" 
    
    
    # -- Within TMB:::.gdbsource.win --      
    (cmd <- paste("gdb Rterm -x", gdbscript))
    [1] "gdb Rterm -x C:\\Users\\JOHN~1.WAL\\AppData\\Local\\Temp\\RtmpsTF7K8\\file139c76027"
        
    # Rterm.exe always has the full and correct path
    (cmd <- paste0("gdb ", Sys.which('Rterm'), " -x ", gdbscript))
    [1] "gdb W:\\R\\R-4.2.1\\bin\\x64\\Rterm.exe -x C:\\Users\\JOHN~1.WAL\\AppData\\Local\\Temp\\RtmpsTF7K8\\file139c76027"

    
    
    
 sdfgsdfg   
    
    
    
