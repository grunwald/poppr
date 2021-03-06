\name{bruvo.boot}
\alias{bruvo.boot}
\title{Create a tree using Bruvo's Distance with non-parametric bootstrapping.}
\usage{
  bruvo.boot(pop, replen = c(2), sample = 100, tree = "nj",
    showtree = TRUE, cutoff = NULL, ...)
}
\arguments{
  \item{pop}{a \code{\link{genind}} object}

  \item{replen}{a \code{vector} of \code{integers}
  indicating the length of the nucleotide repeats for each
  microsatellite locus.}

  \item{sample}{an \code{integer} indicated the number of
  bootstrap replicates desired.}

  \item{tree}{choose between "nj" for neighbor-joining and
  "upgma" for a upgma tree to be produced.}

  \item{showtree}{\code{logical} if \code{TRUE}, a tree
  will be plotted with nodelabels.}

  \item{cutoff}{\code{integer} the cutoff value for
  bootstrap node label values (between 0 and 100).}

  \item{...}{any argument to be passed on to
  \code{\link{boot.phylo}}. eg. \code{quiet = TRUE}.}
}
\value{
  a tree with nodelables
}
\description{
  Create a tree using Bruvo's Distance with non-parametric
  bootstrapping.
}
\note{
  This function calculates bruvo's distance for non-special
  cases (ie. the ploidy and all alleles are known).
  Currently there is no way to import polyploid partial
  heterozygote data into adegenet. For Bruvo's Distance
  concerning special cases, see the package \code{polysat}.
  Missing data is ignored, but be sure that missing data is
  NOT set to 0 in the genind object. This is not easy to
  detect and will result in an error. Please use any other
  method in \code{\link{na.replace}} or
  \code{\link{missingno}}.

  If the user does not provide a vector of appropriate
  length for \code{replen} , it will be estimated by taking
  the minimum difference among represented alleles at each
  locus. It is not recommended to rely on this estimation.
}
\examples{
# Please note that the data presented is assuming that the nancycat dataset
# contains all dinucleotide repeats, it most likely is not an accurate
# representation of the data.

# Load the nancycats dataset and construct the repeat vector.
data(nancycats)
ssr <- rep(1,9)

# Analyze the 1st population in nancycats

bruvo.boot(popsub(nancycats, 1), replen=ssr)
}
\seealso{
  \code{\link{nancycats}}, \code{\link{upgma}},
  \code{\link{nj}}, \code{\link{boot.phylo}},
  \code{\link{nodelabels}}, \code{\link{na.replace}},
  \code{\link{missingno}}.
}

