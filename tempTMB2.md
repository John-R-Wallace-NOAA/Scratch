Fixing gdbsource under Windows with Sys.which(), 'quit' in gdb, Rtools 3.5, and DLLFLAGS="" in the compile call.

With a clean install of CRAN R ver 4.2.1 and RTools 4.2, without RTools 3.5 installed, gdbsource() under Windows fails due to a missing gdb.exe. Jeroen Ooms took over maintaining RTools for Windows R from Prof. Brian Ripley and Duncan Murdoch starting with RTools 4.0, and neither RTools 4.0 nor 4.2 have gdb.exe available: https://cran.r-project.org/bin/windows/Rtools/

In 2021 Mark Bravington tried to add gdb to RTools 4.0 under Windows without success: https://stat.ethz.ch/pipermail/r-devel/2021-April/080623.html . In response to the Mark's post, Tomas Kalibera points out that Rtools 3.5 can still be used for gdb.exe (just copying over gdb.exe does not work).

However for TMB, many of gdbsource() problems under Windows in TMB's issues 'gdbsource Errors #67' and '???????' are either from Rterm.exe not being found or that the Rterm.exe found in the system path is not the correct one.  The wrong Rterm.exe could be a different version or a mismatch between 32 versus 64-bit.

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
    function (file, interactive = FALSE) 
    {
        gdbscript <- tempfile()
        txt <- paste("set breakpoint pending on\nb abort\nrun --vanilla -f", 
            file, "\nbt\n")
        cat(txt, file = gdbscript)
        cmd <- paste("gdb Rterm -x", gdbscript)
        if (interactive) {
            cmd <- paste("start", cmd)
            shell(cmd)
            return(NULL)
        }
        else {
            txt <- system(cmd, intern = TRUE, ignore.stdout = FALSE, 
                ignore.stderr = TRUE)
            attr(txt, "file") <- file
            class(txt) <- "backtrace"
            return(txt)
        }
    }

    # Where:
    (cmd <- paste("gdb Rterm -x", gdbscript))
    [1] "gdb Rterm -x C:\\Users\\JOHN~1.WAL\\AppData\\Local\\Temp\\RtmpsTF7K8\\file139c76027"
        
    # But using Sys.which() will always give the full and correct path for Rterm.exe:
    (cmd <- paste0("gdb ", Sys.which('Rterm'), " -x ", gdbscript))
    [1] "gdb W:\\R\\R-4.2.1\\bin\\x64\\Rterm.exe -x C:\\Users\\JOHN~1.WAL\\AppData\\Local\\Temp\\RtmpsTF7K8\\file139c76027"
    

    # Sys.which() will find the path without being in the system path
    shell("where g++")
    W:\Rtools\mingw_64\bin\g++.exe
    
    Sys.which('g++')
                                     g++ 
    "W:\\Rtools\\mingw_64\\bin\\g++.exe" 
    
    
    shell("where Rterm")
    INFO: Could not find files for the given pattern(s).
    Warning message:
    In shell("where Rterm") : 'where Rterm' execution failed with error code 1
    
    Sys.which('Rterm')
                                  Rterm 
    "W:\\MRO\\MRO\\bin\\x64\\Rterm.exe" 

    

    
 ### 'quit' in .gdbsource.win    
    
Like the non-interactive Linux section of gdbsource(), which has a 'quit' for gdb: 
    
    gdbsource <-   function (file, interactive = FALSE) 
    {
        if (!file.exists(file)) 
            stop("File '", file, "' not found")
        if (.Platform$OS.type == "windows") {
            return(.gdbsource.win(file, interactive))
        }
        gdbscript <- tempfile()
        if (interactive) {
            gdbcmd <- c(paste("run --vanilla <", file), "bt")
            gdbcmd <- paste(gdbcmd, "\n", collapse = "")
            cat(gdbcmd, file = gdbscript)
            cmd <- paste("R -d gdb --debugger-args=\"-x", gdbscript, 
                "\"")
            system(cmd, intern = FALSE, ignore.stdout = FALSE, ignore.stderr = TRUE)
            return(NULL)
        }
        else {
            cat("run\nbt\nquit\n", file = gdbscript)  #  <== quit
            cmd <- paste("R --vanilla < ", file, " -d gdb --debugger-args=\"-x", 
                gdbscript, "\"")
            txt <- system(cmd, intern = TRUE, ignore.stdout = FALSE, 
                ignore.stderr = TRUE)
            attr(txt, "file") <- file
            class(txt) <- "backtrace"
            return(txt)
        }
    }

    cat("run\nbt\nquit\n")
    run
    bt
    quit
    
With the latest versions of Windows R, the non-interactive section of TMB:::.gdbsource.win() also needs a 'quit' for gdb. Putting these 3 items together gives:


    gdbsource.win <- function (file, interactive = FALSE) 
         {
             if(Sys.which('gdb.exe') == "") {
                 print(Sys.which('gdb.exe')); cat('\n')
                 print(Sys.which('g++.exe')); cat('\n')             
                 stop("gdb.exe not found. 
                      Until a new version of Rtools includes gdb.exe, please install both Rtools 4.2
                      and Rtools 3.5 (Rtools35.exe) for gdb.exe. Make sure 'C:\\Rtools\\mingw_64\\bin' is in the system path.
                      A properly installed Rtools 4.2 will prepend its path to the system path within R and hence
                      will always be in front of the Rtools 3.5 path. View the path using: shell('path')")
             }         
             gdbscript <- tempfile()
             txt <- paste("set breakpoint pending on\nb abort\nrun --vanilla -f", file, "\nbt\n")
             cat(txt, file = gdbscript)
             cmd <- paste0("gdb ", Sys.which('Rterm'), " -x ", gdbscript)
             if (interactive) {
                 cmd <- paste("start", cmd)
                 shell(cmd)
                 return(NULL)
             }
             else {
                 cat("quit\n", file = gdbscript, append = TRUE)   
                 txt <- system(cmd, intern = TRUE, ignore.stdout = FALSE, ignore.stderr = TRUE)
                 attr(txt, "file") <- file
                 class(txt) <- "backtrace"
                 return(txt)
              }
         }
  
   
   
As the TMB issues on gdbsource() do point out, but is still not in the gdbsource's help, < DLLFLAGS="" > is also needed for when using compile() under Windows for debugging.
   
On a Windows machine, put the 'simpleError.cpp' and simpleError.R given below into C:\TMB_Debug and run:
   
    setwd('C:/TMB_Debug')
    library(TMB)
 
    if(file.exists('simpleError.o')) file.remove(c('simpleError.o'))
    if(file.exists('simpleError.dll')) file.remove(c('simpleError.dll')) # Windows dll 
    compile('simpleError.cpp', "-O0 -g", DLLFLAGS="")     
      
    gdbsource.win('simpleError.R') 
   
    gdbsource.win('simpleError.R', interactive = TRUE) 
    
    
    # -- See how not using 'quit' in gdb hangs up R by using the following code --
    file <- 'simpleError.R'
    gdbscript <- tempfile()
    txt <- paste("set breakpoint pending on\nb abort\nrun --vanilla -f", file, "\nbt\n")
    cat(txt, file = gdbscript)
    # cat("quit\n", file = gdbscript, append = TRUE)   # Consistently hangs without the 'quit'. Use <Esc> to exit the hang.
    (cmd <- paste0("gdb ", Sys.which('Rterm'), " -x ", gdbscript))
    # file.show(gdbscript)  # Look at the commands in gdbscript temp file, if desired.
    system(cmd)
      
      
    
