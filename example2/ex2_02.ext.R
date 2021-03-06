################################################################################
# Updated version of the R code for the analysis in:
#
#   "A penalized framework for distributed lag non-linear models"
#   Biometrics, 2017
#   Antonio Gasparrini, Fabian Scheipl, Ben Amstrong, and Michael G. Kenward
#   http://www.ag-myresearch.com/2017_gasparrini_biomet.html
#
# Update: 15 Jan 2017
# * an up-to-date version of this code is available at:
#   https://github.com/gasparrini/2017_gasparrini_biomet_Rcodedata
################################################################################

################################################################################
# SECOND EXAMPLE
# RUN THE MODELS (EXTERNAL METHOD)
################################################################################

################################################################################
# GLM (AS IN GASPARRINI STAT MED 2014)

# DEFINE THE CROSS-BASIS
# NB: EXCLUSION OF INTERCEPT FROM LAG-RESPONSE
cbglm <- crossbasis(Qx,lag=c(2,40),argvar=list(fun="bs",degree=2,knots=59.4),
  arglag=list(fun="bs",degree=2,knots=13.3,int=F))
summary(cbglm)

# RUN THE GLM AND PREDICT
glm <- glm(out~cbglm+cbz+bs(age,df=5)+year,data=main,family=poisson)
predglm <- crosspred(cbglm,glm,at=0:25*10,cen=0)

# PLOTS
plot(predglm,xlab="WLM/year",ylab="Lag (years)",zlab="OR",zlim=c(0.95,1.3),
  theta=230,ltheta=230,lphi=45,cex.axis=0.7,cex.lab=0.8,nticks=9,
  border=grey(0.3),col=grey(0.99),main="Original model")
plot(predglm,var=100,ylab="OR",xlab="Lag (years)",xlim=c(0,40),
  ylim=c(0.9,1.3),lwd=1.5,main="Original model")
plot(predglm,lag=15,xlab="WLM/year",ylab="OR",ylim=c(0.9,1.3),axes=T,lwd=1.5,
  main="Original model")

################################################################################
# GAM

# DEFINE THE CROSS-BASIS
# NB: NON-DEFAULT KNOTS PLACEMENT FOR f(x)
# NB: EXCLUSION OF INTERCEPT FROM LAG-RESPONSE
vk <- c(min(Qx),logknots(Qx,nk=9),max(Qx))
cbgam <- crossbasis(Qx,lag=c(2,40),argvar=list(fun="cr",knots=vk),
  arglag=list(fun="cr",int=F))
summary(cbgam)

# DEFINE THE PENALTY MATRICES
# VARYING RIDGE PENALTY APPLIED TO LAGS (Eq. 7b)
C <- do.call('onebasis',c(list(x=2:40,fun="cr",df=10,intercept=F)))
P <- diag(rep(0:1,c(30-2+1,40-30)))
Slag2 <- t(C) %*% P %*% C
cbgamPen <- cbPen(cbgam,addSlag=Slag2)

# RUN THE GAM MODEL AND PREDICT (TAKES ~220sec IN A 2.4 GHz PC)
system.time({
  gam <- gam(out~cbgam+cbz+bs(age,df=5)+year,data=main,family=poisson,
    paraPen=list(cbgam=cbgamPen))
})
predgam <- crosspred(cbgam,gam,at=0:25*10,cen=0)

# CHECK CONVERGENCE, SMOOTHING PARAMETERS AND EDF
gam$converged
gam$sp
sum(gam$edf[2:101])

# PLOTS
plot(predgam,xlab="WLM/year",ylab="Lag (years)",zlab="RR",zlim=c(0.95,1.3),
  theta=230,ltheta=230,lphi=45,cex.axis=0.7,cex.lab=0.8,nticks=9,
  border=grey(0.3),col=grey(0.99),main="Penalized model")
plot(predgam,var=100,ylab="RR",xlab="Lag (years)",xlim=c(0,40),
  ylim=c(0.9,1.3),lwd=1.5,main="Penalized model")
plot(predgam,lag=15,xlab="WLM/year",ylab="RR",ylim=c(0.9,1.3),axes=T,lwd=1.5,
  main="Penalized model")

#
