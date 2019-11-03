
2, 3, 5, 7, 11, 13, 17, 19, 23, 29, 31, 37, 41, 43, 47, 53, 59, 61, 67, 71, 73, 79, 83, 89, 97, 101, 103, 107, 109, 113, 127, 
131, 137, 139, 149, 151, 157, 163, 167, 173, 179, 181, 191, 193, 197, 199,

lib(Rmpfr)

N <- mpfr(19, precBits = 256)

cbind(0:25, floor(2^(0:25) / N), N * floor(2^(0:25)/N), 2 ^(0:25), 2^(0:25) %% N)

N <-41*199
y <- 10000
# 2^(0:mpfr(y, 2408) %% N)
(0:y)[2^mpfr(0:y, 2^10) %% N == 1]
[1]    0 1980 3960 5940 7920 9900





N <-7
y <- 20
2^mpfr(0:y, 2^10) %% N
(0:y)[2^mpfr(0:y, 2^10) %% N == 1]


N <-7
y <- 20
mpfr(0:y, 2^20) %% log(N +1, 2)
(0:y)[mpfr(0:y, 2^20) %% log(N +1, 2) == 0] # log(1, 2) == 0


N <-197*199
y <- 50000
# 2^(0:mpfr(y, 2408) %% N)
(0:y)[mpfr(0:y, 2^10) %% log(N, 2) == log(1, 2)]


N <-197*199
y <- 10000
# mpfr(0:y, 2^20) %% log(N +1, 2)
(0:y)[mpfr(0:y, 2^20) %% log(N + 1, 2) == 0 ] # log(1, 2) == 0






 18 - log(19*13797 + 1, 2)



N <-19

for (i in 1:60) {

  f <- function(x) {
   
      abs(mpfr(i, precBits = 256) - log(N * mpfr(x, precBits = 256) + 1, 2) - 0)
   }
    
   z <- nlminb(1, f)
   
   cat(i, " ", z$par, "\n")
   
   if(abs(z$par - round(z$par)) < 0.001) cat("\n", i, "looks good:", i - log(N * round(z$par) + 1, 2), "\n\n")
   
   
}









N <- 19
y <- 25
2^mpfr(0:y, 2^10) %% N
(0:y)[2^mpfr(0:y, 2^10) %% N == 1]




f <- function(x) {

   ifelse(abs(x[1] - log(19*x[2] + 1, 2) - 0) == 0 & x[1] > 10, 0, abs(x[1] * x[2] + 100))
}
 
 
f(c(18, 13797))

f(c(0,0))

f(c(10, 10))
 
nlminb(c(18,13796), f)



N <- 19

f <- function(i) {
   
      i - log(N + 1, 2)
   }
f(18)    
  


  

f2 <- function(x) {
   
      abs(mpfr(i, precBits = 256) - log(N * mpfr(x, precBits = 256) + 1, 2) - 0)
   }
    



x <- c(18, 13797)
log(2) * x[1] - log(19) - log(x[2] + 1/19)

# # 0

f <- function(x) {
    log(2) * x[1] - log(19) - log(x[2] + 1/19)
}    
    

    
f.log <- function(x) {
    log(log(2) * x[1] - log(19) - log(x[2] + 1/19))
}    
f.log(c(18, 13797))

    
N <- 19
pB <- 256    
f.log2 <- function(x) {
    log(log(mpfr(2, precBits = pB)) * x[1] - log(mpfr(N, precBits = pB)) - log(x[2] + 1/mpfr(N, precBits = pB)) + 1e-200)
}    
f.log2(c(18, 13797))

(z <- nlminb(c(10,10), f.log2))



N <- 19
pB <- 256    
f.3 <- function(x) {
    print(log(mpfr(2, precBits = pB)) * x[1] - log(mpfr(N, precBits = pB)) - log(x[2] + 1/mpfr(N, precBits = pB)))
}    
f.3(c(18, 13797))
(z <- nlminb(c(18, 13797), f.3))

f.3(c(10, 10))
(z <- nlminb(c(10,10), f.3))



# **** Works with close starting values ****
N <- 19
pB <- 256    
f.norm <- function(x) {
    print(exp(abs(log(2) * x[1] - log(N) - log(x[2] + 1/N) - 0)))
}    
f.norm(c(18, 13797))
f.norm(c(10, 10))

(z <- nlminb(c(15, 13797), f.norm))

f.norm(z$par)



N <- 19
pB <- 256    
f.norm2 <- function(x) {
    print(exp(abs(log(mpfr(2, precBits = pB)) * x[1] - log(mpfr(N, precBits = pB)) - log(x[2] + 1/mpfr(N, precBits = pB)) - 0)))
}    
f.norm2(c(18, 13797))
f.norm2(c(10, 10))

(z <- nlminb(c(20, 13797), f.norm2))




N <- 19
pB <- 256    
f.norm3 <- function(x) {
    print(exp(abs(log(2) * mpfr(x[1], precBits = pB) - log(N) - log(mpfr(x[2], precBits = pB) + 1/N) - 0)))
}    
f.norm3(c(18, 13797))
f.norm3(c(10, 10))

(z <- nlminb(c(20, 13797), f.norm3))



# **** Worksfor 3 * 5!!!!  ****
N <- 3 * 5 
pB <- 256    
f.norm <- function(x) {
    # print(exp(abs(log(2) * x[1] - log(N) - log(x[2] + 1/N) - 0)))
    exp(abs(log(2) * x[1] - log(N) - log(x[2] + 1/N) - 0))
}    
f.norm(c(12, 273))
f.norm(c(10, 10))

# (z <- nlminb(c(5, 2), f.norm, control = list(rel.tol = 1e-20)))
z <- optim_sa(f.norm, start = c(15, 250), lower = c(10, 10), upper = c(20, 400), control = list(nlimit = 50, r = 0.9999, t0 = 500))
# z <- optim_sa(f.norm, start = c(15, 250), lower = c(10, 10), upper = c(200, 1000), control = list(nlimit = 50, r = 0.9999, t0 = 500))  # not so good with wider bounds
z$par
f.norm(z$par)

(2^(z$par[1]/2) - 1) %% 15
(2^(z$par[1]/2) + 1) %% 15







N <-3 * 5
y <- 20
mpfr(0:y, 2^5) %% log(N + 1, 2)
(0:y)[mpfr(0:y, 2^5) %% log(N + 1, 2) == 0] # log(1, 2) == 0



N <-3 * 7
y <- 1e9
# mpfr(0:y, 2^5) %% log(N +1, 2)
(0:y)[0:y %% log(N +1, 2) == 0] # log(1, 2) == 0












