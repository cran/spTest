% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/htestIso_class.R
\docType{class}
\name{htestIso-class}
\alias{htestIso-class}
\alias{htestIso}
\title{An S4 class to hold output from a hypothesis test of isotropy. Extends the S3 class 'htest'.}
\description{
An S4 class to hold output from a hypothesis test of isotropy. Extends the S3 class 'htest'.
}
\section{Slots}{

\describe{
\item{\code{p.value.finite}}{A length-one numeric vector containing the p-value approximated by using a finite sample adjustment.}

\item{\code{sigma.hat}}{A matrix containing the estimated asymptotic variance-covariance matrix.}

\item{\code{n.subblocks}}{A length-one numeric vector containing the number of subblocks used in estimating the asymptotic variance-covariance.}

\item{\code{n.boot}}{A length-one numeric vector containing the number of bootstrap samples used in estimating the asymptotic variance-covariance.}
}}

