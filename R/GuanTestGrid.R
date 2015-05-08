#' Nonparametric Test of Isotropy Using the Sample Semivariogram
#'
#' This function performs the nonparametric test of isotropy from Guan et. al. (2004) for spatial data with sampling locations on a grid. See Guan et. al. (2004) for more details.
#'
#'@export
#'@keywords external
#'
#' @param spdata	An \eqn{n} by \eqn{3} matrix. The first two columns provide \eqn{(x,y)} spatial coordinates. The third column provides data values at the coordinates.
#' @param delta	A scalar indicating the distance between grid locations. Defaults to 1 (integer grid) and assumes equal spacing between locations in the x and y directions.
#' @param lagmat A \eqn{k} by \eqn{2} matrix of spatial lags. Each row corresponds to a lag of the form \eqn{(x.lag, y.lag)} for which the semivariogram value will be estimated. The scale of the lags provided in 'lagmat' are in units of 'delta'.
#' @param A	A \eqn{d} by \eqn{k} contrast matrix. The contrasts correspond to contrasts of the estimated semivariogram at the lags given in 'lagmat'.
#' @param df A scalar indicating the row rank of A. This value gives the degrees of freedom for the asymptotic Chi-sq distribution used to compute the p-value.
#' @param subblock.dims	A vector of length two corresponding to the width and height (in number of columns and rows, respectively) of the moving windows used to estimate the asymptotic variance-covariance matrix. If window width does not evenly divide the number of columns of spatial data, some data will be ommited during subsampling, i.e., function does not handle partial windows. Same applies to window height and number of rows of spatial data.
#' @param pt.est.edge Logical. True corrects for edge effects in the point estimate (see Guan et. al. (2004), Section 4.2.1 for details).
#' @param sig.est.edge Logical. True corrects for edge effects when estimating the semivariogram in the moving windows (see Guan et. al. (2004), Section 4.2.1 for details).
#' @param sig.est.finite Logical. True provides a finite sample correction in estimating Sigma (see Guan et. al. (2004) Section 3.2.1, Equation 5). False provides the empirical variance-covariance matrix of sample semivariogram values computed via the moving windows.
#'
#' @details This function currently only supports square and rectangular sampling regions and does not currently support partial blocks. For example, suppose the sampling grid contains 20 columns and 30 rows of data. Then an ideal value of subblock.dims would be (2,3) since its entries evenly divide the number of columns (20) and rows (30), respectively, of data. To preserve the spatial dependence structure, the spatial blocks should have the same shape (i.e. square or rectangle) and orientation as the entire sampling domain.
#'
#' The parameter 'delta' serves to scale the samplng locations to the integer grid. Thus the lags provided in 'lagmat' are scaled by 'delta'. For example, suppose spatial locations are observed on grid boxes of 0.5 degrees by 0.5 degrees and referenced by longitude and latitude coordinates in degrees. Then, 'delta' should be 0.5 and a spatial lag of (0,1) corresponds to a change in coordinates of (0, 0.5), i.e, moving one sampling location north in the y-direction.
#'
#' @return \item{gamma.hat}{A matrix of the spatial lags provided and the semivariogram point estimates at those lags used to construct the test statistic.}
#' \item{sigma.hat}{The estimate of asymptotic variance-covariance matrix, Sigma, used to construct test statistic.} 
#' \item{n.subblocks}{The number of moving windows (blocks) used to estimate Sigma.}
#' \item{test.stat}{The calculated test statistic.}
#' \item{pvalue.finite}{The approximate, finite-sample adjusted p-value computed by using the moving windows (see Guan et. al. (2004), Section 3.3 for details).}
#' \item{pvalue.chisq}{The p-value computed using the asymptotic Chi-sq distribution.}
#'
#' @references Guan, Y., Sherman, M., & Calvin, J. A. (2004). A nonparametric test for spatial isotropy using subsampling. \emph{Journal of the American Statistical Association}, 99(467), 810-821.
#'
#' @seealso \code{\link{GuanTestUnif}} \code{\link{MaityTest}}
#'
#' @examples
#' library(mvtnorm)
#' set.seed(1)
#' #number of rows and columns
#' nr <- 18
#' nc <- 12
#' n <- nr*nc
#' #Set up the coordinates
#' coords <- expand.grid(0:(nr-1), 0:(nc-1))
#' coords <- cbind(coords[,2], coords[,1])
#' #compute the distance between sampling locations
#' D <- as.matrix(dist(coords))
#' #Set parameter values for exponential covariance function
#' sigma.sq <- 1
#' tau.sq <- 0.0
#' phi <- 1/4
#' R <- sigma.sq * exp(-phi*D)
#' R <- R + diag(tau.sq, nrow = n, ncol = n)
#' #Simulate Gaussian spatial data
#' z <- rmvnorm(1,rep(0,n), R, method = c("chol"))
#' z <-  z-mean(z)
#' z <- t(z)
#' mydata <- cbind(coords, z)
#' mylags <-  rbind(c(1,0), c(0, 1), c(1, 1), c(-1,1))
#' myA <-  rbind(c(1, -1, 0 , 0), c(0, 0, 1, -1))
#' tr <- GuanTestGrid(mydata, delta = 1, mylags, myA, subblock.dims = c(3,2), 
#' pt.est.edge = TRUE, sig.est.edge = TRUE, sig.est.finite = TRUE, df = 2 )
#' tr
#'
#' #Simulate data from anisotropic covariance function
#' aniso.angle <- pi/4
#' aniso.ratio <- 2
#' coordsA <- coords.aniso(coords, c(aniso.angle, aniso.ratio))
#' Da <- as.matrix(dist(coordsA))
#' R <- sigma.sq * exp(-phi*Da)
#' R <- R + diag(tau.sq, nrow = n, ncol = n)
#' z <- rmvnorm(1,rep(0,n), R, method = c("chol"))
#' z <-  z-mean(z)
#' z <- t(z)
#' mydata <- cbind(coords, z)
#' #Run the test on the data generated from an anisotropic covariance function
#' tr <- GuanTestGrid(mydata, delta = 1, mylags, myA, subblock.dims = c(3,2), 
#' pt.est.edge = TRUE,sig.est.edge = TRUE, sig.est.finite = TRUE, df = 2 )
#' tr

GuanTestGrid = function(spdata, delta = 1, lagmat, A, df, subblock.dims, pt.est.edge = TRUE, sig.est.edge = TRUE, sig.est.finite = TRUE)
{
	if(dim(spdata)[2] != 3)
	{stop("matrix of spatial data must have 3 columns")}
	if(dim(spdata)[1] <= 3)
	{stop("matrix of spatial data must have at least 4 rows")}
	if(delta <= 0)
	{stop("spacing between points (delta) must be positive")}
	if(dim(lagmat)[2] != 2)
	{stop("matrix of spatial lags must have 2 columns")}
	if(dim(lagmat)[1] != dim(A)[2])
	{stop("non-conformable A matrix")}
	if(length(subblock.dims) != 2)
	{stop("subblock.dims must be length 2")}
	if(subblock.dims[1] <= 0 | subblock.dims[2] <= 0)
	{stop("subblock dimensions must be positive")}
	
	nrows <- length(unique(spdata[,2]))
	ncols <- length(unique(spdata[,1]))
	
	if(subblock.dims[1] >= ncols)
	{stop("subblock width must be less than the number of columns of data")}
	if(subblock.dims[2] >= nrows)
	{stop("subblock height must be less than the number of rows of data")}
	if( (ncols%%subblock.dims[1])!= 0 )
	{print("Warning: width of subblock does not divide number of columns of data evenly, some data will be ommited during subsampling")}
	if( (nrows%%subblock.dims[2])!= 0 )
	{print("Warning: height of subblock does not divide number of rows of data evenly, some data will be ommited during subsampling")}
	
	spdata <- scale_coords_guan(spdata, delta)
	
	rawdata <- lag_dist_diff_reg(spdata)
	rawdata <- raw_data_sub(rawdata, lagmat)
	if(pt.est.edge == T)
	{
		pedata <- est_gamma2(rawdata, lagmat, edge.eff = T)
	}
	if(pt.est.edge == F)
	{
		pedata <- est_gamma2(rawdata, lagmat, edge.eff = F)
	}
	n.lags <- dim(lagmat)[1]
	gamma.hat <- pedata$gamma.hat
	gh <- matrix(gamma.hat[,3], nrow = n.lags, ncol = 1)
	
	if(sig.est.edge == T & sig.est.finite == T)
	{
		sig.data <- est_sigma_reg(spdata, lagmat, subblock.dims[1], subblock.dims[2], edge.eff = T, finite.sample = T)
	}
	if(sig.est.edge == T & sig.est.finite == F)
	{
		sig.data <- est_sigma_reg(spdata, lagmat, subblock.dims[1], subblock.dims[2], edge.eff = T, finite.sample = F)
	}
	if(sig.est.edge == F & sig.est.finite == T)
	{
		sig.data <- est_sigma_reg(spdata, lagmat, subblock.dims[1], subblock.dims[2], edge.eff = F, finite.sample = T)
	}
	if(sig.est.edge == F & sig.est.finite == F)
	{
		sig.data <- est_sigma_reg(spdata, lagmat, subblock.dims[1], subblock.dims[2], edge.eff = F, finite.sample = F)
	}
	
	sigma.hat <- sig.data$sigma.hat
	block.ghats <- sig.data$block.ghats
	n.blks <- dim(block.ghats)[1]
	
	n.pts <- dim(spdata)[1]
	test.stat <- n.pts*t(A%*%gh) %*% solve(A%*%sigma.hat%*%t(A)) %*% (A%*%gh)
	test.stat <- test.stat[1,1]

	blk.size <- subblock.dims[1]*subblock.dims[2]
	block.test.stats <-  c()
	for(i in 1:n.blks)
	{
		gh <- matrix( block.ghats[i,], nrow = n.lags, ncol = 1)
		ts <- blk.size*t(A%*%gh) %*% solve(A%*%sigma.hat%*%t(A)) %*% (A%*%gh)
		block.test.stats <-  c(block.test.stats, ts)
	}
	pvalue.finite <- sum(block.test.stats >= test.stat)/n.blks
	
	pvalue.chisq <-  pchisq(test.stat, df, lower.tail = F)

	rv <- list("gamma.hat" = gamma.hat, "sigma.hat" = sigma.hat, "n.subblocks" = n.blks, "test.stat" = test.stat,"pvalue.finite" = pvalue.finite, "pvalue.chisq" =
	pvalue.chisq)
}