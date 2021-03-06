\name{popsub}
\alias{popsub}
\title{Subset a \code{\link{genind}} object by population}
\usage{
  popsub(pop, sublist = "ALL", blacklist = NULL,
    mat = NULL, drop = TRUE)
}
\arguments{
  \item{pop}{a \code{\link{genind}} object.}

  \item{sublist}{a \code{vector} of population names or
  indexes that the user wishes to keep. Default to "ALL".}

  \item{blacklist}{a \code{vector} of population names or
  indexes that the user wishes to discard. Default to
  \code{NULL}}

  \item{mat}{a \code{matrix} object produced by
  \code{\link{mlg.table}} to be subsetted. If this is
  present, the subsetted matrix will be returned instead of
  the genind object}

  \item{drop}{\code{logical}. If \code{TRUE}, unvariate
  alleles will be dropped from the population.}
}
\value{
  A \code{genind} object or a matrix.
}
\description{
  Create a new dataset with specified populations or
  exclude specified populations from the dataset.
}
\examples{
# Load the dataset microbov.
data(microbov)

# Analyze only the populations with exactly 50 individuals
mic.50 <- popsub(microbov, sublist=c(1:6, 11:15), blacklist=c(3,4,13,14))

# Analyze the first 10 populations, except for "Bazadais"
mic.10 <- popsub(microbov, sublist=1:10, blacklist="Bazadais")

# Take out the two smallest populations
micbig <- popsub(microbov, blacklist=c("NDama", "Montbeliard"))

# Analyze the two largest populations
miclrg <- popsub(microbov, sublist=c("BlondeAquitaine", "Charolais"))
}

