Fixing gdbsource under Windows with Sys.which(), 'quit' in gdb, Rtools 3.5, and DLLFLAGS="" in the compile call.

With a clean install of CRAN R ver 4.2.1 and RTools 4.2, without RTools 3.5 installed, gdbsource() under Windows fails due to a missing gdb.exe. Jeroen Ooms took over maintaining RTools for Windows R from Prof. Brian Ripley and Duncan Murdoch starting with RTools 4.0, and neither RTools 4.0 nor 4.2 have gdb.exe available: https://cran.r-project.org/bin/windows/Rtools/

In 2021 Mark Bravington tried to add gdb to RTools 4.0 under Windows without success: https://stat.ethz.ch/pipermail/r-devel/2021-April/080623.html . In response to the Mark's post (and as I independently discovered), Tomas Kalibera points out that Rtools 3.5 can still be used for gdb.exe (just copying over gdb.exe does not work).

However for TMB, many of gdbsource() problems under Windows in TMB's issues 'gdbsource Errors #67' and 'gdbsource error #248' are either from Rterm.exe not being found or that the Rterm.exe found in the system path is not the correct one.  The wrong Rterm.exe could be a different version or a mismatch between 32 versus 64-bit.

### Sys.which()

Using base::Sys.which() fixes these problems:

    # -- R ver 4.1.2 --    
    Sys.which('gdb.exe')
                                 gdb.exe 
    "C:\\Rtools\\mingw_64\\bin\\gdb.exe" 
    
    
    Sys.which('g++.exe')
                                 g++.exe 
    "C:\\Rtools\\mingw_64\\bin\\g++.exe" 
    
    
    # -- R ver 4.2.1 --    
    Sys.which('gdb.exe')
                                 gdb.exe 
    "C:\\Rtools\\mingw_64\\bin\\gdb.exe" 
    
    
    Sys.which('g++.exe')
                                                          g++.exe 
    "C:\\rtools42\\x86_64-w64-mingw32.static.posix\\bin\\g++.exe" 
    
    
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
        
    # But using Sys.which() always gives the full and correct path for Rterm.exe using the current version of R being used:
    (cmd <- paste0("gdb ", Sys.which('Rterm'), " -x ", gdbscript))
    [1] "gdb C:\\R\\R-4.2.1\\bin\\x64\\Rterm.exe -x C:\\Users\\JOHN~1.WAL\\AppData\\Local\\Temp\\RtmpsTF7K8\\file139c76027"
    

    # Sys.which() will find the path without being in the system path
    shell("where g++")
    C:\Rtools\mingw_64\bin\g++.exe
    
    Sys.which('g++')
                                     g++ 
    "C:\\Rtools\\mingw_64\\bin\\g++.exe" 
    
    
    shell("where Rterm")
    INFO: Could not find files for the given pattern(s).
    Warning message:
    In shell("where Rterm") : 'where Rterm' execution failed with error code 1
    
    Sys.which('Rterm')
                                  Rterm 
    "C:\\MRO\\MRO\\bin\\x64\\Rterm.exe" 

    

    
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
    

    
With the latest versions of Windows R, the non-interactive section of TMB:::.gdbsource.win() also needs a 'quit' for gdb (see below). I say latest versions here because @skuag says back in 2018 in Issue 'gdbsource error #248' that "[gdbsource()] ... has worked for me in previous versions of R/Rtools"  

 ### Putting everthing together
 
Putting these three items together gives a function with a verbose error message for now:


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
   
### Testing gdbsource.win()
   
On a Windows machine, put the 'simpleError.cpp' and 'simpleError.R' given below into C:\TMB_Debug and run:
   
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
      
simpleError.cpp

    // Normal linear mixed model specified through sparse design matrices.
    #include <TMB.hpp>
    
    template<class Type>
    Type objective_function<Type>::operator() ()
    {
      DATA_VECTOR(x);         // Observations
      DATA_SPARSE_MATRIX(B);  // Random effect design matrix
      DATA_SPARSE_MATRIX(A);  // Fixed effect design matrix
      PARAMETER_VECTOR(u);    // Random effects vector
      PARAMETER_VECTOR(beta); // Fixed effects vector
      PARAMETER(logsdu);      // Random effect standard deviations
      PARAMETER(logsd0);      // Measurement standard deviation
    
      // Distribution of random effect (u):
      Type ans = 0;
      ans -= dnorm(u, Type(0), exp(logsdu), true).sum();
    
      // Optionally: How to simulate the random effects
      SIMULATE {
        u = rnorm(u.size(), Type(0), exp(logsdu));
        REPORT(u);
      }
    
      // Distribution of obs given random effects (x|u):
      vector<Type> y = A * beta + B * u;
      ans -= dnorm(x, y, exp(logsd0), true).sum();
      
      vector<Type> f(4);
      f(5) = 3;                // 5 is not a valid index value here
    
      // Optionally: How to simulate the data
      SIMULATE {
        x = rnorm(y, exp(logsd0));
        REPORT(x);
      }
    
      // Apply delta method on sd0:
      Type sd0=exp(logsd0);	
      ADREPORT( sd0 );
      REPORT(sd0);
    
      // Report posterior mode and mean of sum(exp(u))
      ADREPORT( sum(exp(u)) );
     
    
      return ans;
    }
    
simpleError.R

    require(TMB)
    dyn.load(dynlib("simpleError"))
    
    ## Test data
    set.seed(123)
    y <- rep(1900:2010,each=2)
    year <- factor(y)
    quarter <- factor(rep(1:4,length.out=length(year)))
    period <- factor((y > mean(y))+1)
    ## Random year+quarter effect, fixed period effect:
    B <- model.matrix(~year+quarter-1)
    A <- model.matrix(~period-1)
    B <- as(B,"dgTMatrix")
    A <- as(A,"dgTMatrix")
    u <- rnorm(ncol(B)) ## logsdu=0
    beta <- rnorm(ncol(A))*100
    eps <- rnorm(nrow(B),sd=1) ## logsd0=0
    x <- as.numeric( A %*% beta + B %*% u + eps )
    
    ## Fit model
    obj <- MakeADFun(data=list(x=x, B=B, A=A),
                     parameters=list(u=u*0, beta=beta*0, logsdu=1, logsd0=1),
                     random="u",
                     DLL="simpleError",
                     silent=TRUE
                     )
    print(opt <- nlminb(obj$par, obj$fn, obj$gr))
        
    
    

    
 
