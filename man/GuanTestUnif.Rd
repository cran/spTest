% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/GuanTestUnif.R
\name{GuanTestUnif}
\alias{GuanTestUnif}
\title{Nonparametric Test of Isotropy Using the Sample Semivariogram}
\usage{
GuanTestUnif(spdata, lagmat, A, df, h = 0.7, kernel = "norm",
  truncation = 1.5, xlims, ylims, grid.spacing = c(1, 1),
  window.dims = c(2, 2), subblock.h = h, sig.est.finite = TRUE)
}
\arguments{
\item{spdata}{An \eqn{n \times 3}{n x 3} matrix. The first two columns provide \eqn{(x,y)}{(x,y)} spatial coordinates. The third column provides data values at the coordinates. This argument can also be an object of class \code{\link[geoR]{geodata}} from the package \pkg{geoR} or of class \code{SpatialPointsDataFame} from the package \pkg{sp}.}

\item{lagmat}{A \eqn{k \times 2}{k x 2} matrix of spatial lags. Each row corresponds to a lag of the form \eqn{(x.lag, y.lag)}{(x.lag, y.lag)} for which the semivariogram value will be estimated.}

\item{A}{A \eqn{d \times k}{d x k} contrast matrix. The contrasts correspond to contrasts of the estimated semivariogram at the lags given in \code{lagmat}.}

\item{df}{A scalar indicating the row rank of the matrix \code{A}. This value gives the degrees of freedom for the asymptotic \eqn{\chi^2}{Chi-squared} distribution used to compute the p-value.}

\item{h}{A scalar giving the bandwidth for the kernel smoother. The same bandwidth is used for lags in both the x and y directions.}

\item{kernel}{A string taking one of the following values: \code{norm}, \code{ep}, \code{cos}, or \code{unif}, for the normal, Epanechnikov, cosine, or uniform kernel functions. Defaults to \code{norm}.}

\item{truncation}{A scalar providing the truncation value for the normal density if \code{kernel = "norm"}.}

\item{xlims}{A vector of length two providing the lower and upper x-limits of the sampling region. To ensure all sampling locations are included in the subsampling procedure, the x-limits should be \strong{slightly} wider than than the minimum and maximum observed x-coordinates of sampling locations.}

\item{ylims}{A vector of length two providing the lower and upper y-limits of the sampling region. To ensure all sampling locations are included in the subsampling procedure, the y-limits should be \strong{slightly} wider than than the minimum and maximum observed y-coordinates of sampling locations.}

\item{grid.spacing}{A vector of length two providing the x (width) and y (height) spacing, respectively, of the underlying grid laid on the sampling region to create moving windows. If the grid spacing width does not evenly divide the width of the sampling region, some data will be ommited during subsampling, i.e., the function does not handle partial windows. Same applies to grid spacing height and height of sampling region. See details for an example.}

\item{window.dims}{A vector of length two corresponding to the width and height of the moving windows used to estimate the asymptotic variance-covariance matrix. The width and height are given in terms of the spacing of the grid laid on the sampling region. See details for an example.}

\item{subblock.h}{A scalar giving the bandwidth used for the kernel smoother when estimating the semivariogram on the moving windows (sub-blocks of data). Defaults to the same bandwidth used for the entire domain.}

\item{sig.est.finite}{Logical. Defaults to \code{TRUE}, which provides a finite sample correction in estimating \eqn{\Sigma}{Sigma} (see Guan et. al. (2004) Section 4.2.2). False provides the empirical variance-covariance matrix of sample semivariogram values computed via the moving windows.}
}
\value{
\item{gamma.hat}{A matrix of the spatial lags provided and the semivariogram point estimates, \eqn{\hat{\gamma}()}{gamma-hat}, at those lags used to construct the test statistic.}
\item{sigma.hat}{The estimate of asymptotic variance-covariance matrix, \eqn{\widehat{\Sigma}}{Sigma-hat}, used to construct the test statistic.} 
\item{n.subblocks}{The number of subblocks created by the moving window used to estimate \eqn{\Sigma}{Sigma}.}
\item{test.stat}{The calculated test statistic.}
\item{pvalue.finite}{The approximate, finite-sample adjusted p-value computed by using the subblocks created by the moving windows (see Guan et. al. (2004), Section 3.3 for details).}
\item{pvalue.chisq}{The p-value computed using the asymptotic \eqn{\chi^2}{Chi-squared} distribution.}
}
\description{
This function performs the nonparametric test of isotropy using the sample semivariogram from Guan et. al. (2004) for spatial data with uniformly distributed sampling locations. See Guan et. al. (2004) for more details.
}
\details{
This function currently only supports square and rectangular sampling regions and does not support partial blocks. For example, suppose the sampling region runs from 0 to 20 in the x-direction and from 0 to 30 in the y-direction and an underlying grid of 1 by 1 is laid over the sampling region. Then an ideal value of \code{window.dims} would be (2,3) since its entries evenly divide the width (20) and height (30), respectively, of the sampling region. Using \code{window.dims} (3, 4.5) would imply that some data will not be used in the moving windows since these values would create partial blocks in the sampling region.

The value \code{window.dims} provides the width and height of the moving window in terms of the underlying grid laid on the sampling region. For example, if a grid with dimensions of grid.spacing = c(0.1, 0.2) is laid on the sampling region and window.dims = c(2,3) then the dimensions of the subblocks created by the moving windows are (0.2, 0.6). Thus, the user must take care to ensure that the values of \code{grid.spacing} and \code{window.dims} are compatible with the dimensions of the sampling region. The easiest way to meet this constrain is to make the \code{grid.spacing} values a function of the \code{xlims} and \code{ylims} values. For example, to put down a \eqn{10 \times 10}{10 x 10} grid on the domain, use \code{grid.spacing = (xlims[2]-xlims[1], ylim[2]-ylims[1])/10}. Then, setting \code{window.dims = c(2,2)} ensures that no data will be omitted during the subsampling.

To preserve the spatial dependence structure, the moving window should have the same shape (i.e. square or rectangle) and orientation as the entire sampling domain.
}
\examples{
library(mvtnorm)
set.seed(1)
#Sample Size
N <- 300
#Set parameter values for exponential covariance function
sigma.sq <- 1
tau.sq <- 0.0
phi <- 1/4
#Generate sampling locations
coords <-  cbind(runif(N,0,16), runif(N,0,16))
D <-  as.matrix(dist(coords))
R <- sigma.sq * exp(-phi*D)
R <- R + diag(tau.sq, nrow = N, ncol = N)
#Simulate Gaussian spatial data
z <- rmvnorm(1,rep(0,N), R, method = "chol")
z <- z - mean(z)
z <- t(z)
mydata <- cbind(coords, z)
mylags = rbind(c(1,0), c(0, 1), c(1, 1), c(-1,1))
myA = rbind(c(1, -1, 0 , 0), c(0, 0, 1, -1))
my.grid = c(1,1)
my.windims = c(4,4)
myh = 0.7
myh.sb = 0.8
my.xlims = c(0, 16)
my.ylims = c(0, 16)
tr <- GuanTestUnif(mydata, mylags, myA, df = 2, myh, "norm", 1.5,
 my.xlims, my.ylims, my.grid,my.windims, myh.sb)
tr


\dontrun{
library(geoR)
Simulate data from anisotropic covariance function
aniso.angle <- pi/4
aniso.ratio <- 2
coordsA <- coords.aniso(coords, c(aniso.angle, aniso.ratio))
Da <- as.matrix(dist(coordsA))
R <- sigma.sq * exp(-phi*Da)
R <- R + diag(tau.sq, nrow = N, ncol = N)
z <- rmvnorm(1,rep(0,N), R, method = c("chol"))
z <-  z-mean(z)
z <- t(z)
mydata <- cbind(coords, z)
Run the test on the data generated from an anisotropic covariance function
tr <- GuanTestUnif(mydata, mylags, myA, df = 2, myh, "norm", 1.5,
 my.xlims, my.ylims, my.grid,my.windims, myh.sb)
tr
}
}
\references{
Guan, Y., Sherman, M., & Calvin, J. A. (2004). A nonparametric test for spatial isotropy using subsampling. \emph{Journal of the American Statistical Association}, 99(467), 810-821.
}
\seealso{
\code{\link{MaityTest}} \code{\link{GuanTestGrid}}
}
\keyword{external}
