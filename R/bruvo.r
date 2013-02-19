#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#
# This software was authored by Zhian N. Kamvar and Javier F. Tabima, graduate 
# students at Oregon State University; and Dr. Nik Grünwald, an employee of 
# USDA-ARS.
#
# Permission to use, copy, modify, and distribute this software and its
# documentation for educational, research and non-profit purposes, without fee, 
# and without a written agreement is hereby granted, provided that the statement
# above is incorporated into the material, giving appropriate attribution to the
# authors.
#
# Permission to incorporate this software into commercial products may be
# obtained by contacting USDA ARS and OREGON STATE UNIVERSITY Office for 
# Commercialization and Corporate Development.
#
# The software program and documentation are supplied "as is", without any
# accompanying services from the USDA or the University. USDA ARS or the 
# University do not warrant that the operation of the program will be 
# uninterrupted or error-free. The end-user understands that the program was 
# developed for research purposes and is advised not to rely exclusively on the 
# program for any reason.
#
# IN NO EVENT SHALL USDA ARS OR OREGON STATE UNIVERSITY BE LIABLE TO ANY PARTY 
# FOR DIRECT, INDIRECT, SPECIAL, INCIDENTAL, OR CONSEQUENTIAL DAMAGES, INCLUDING
# LOST PROFITS, ARISING OUT OF THE USE OF THIS SOFTWARE AND ITS DOCUMENTATION, 
# EVEN IF THE OREGON STATE UNIVERSITY HAS BEEN ADVISED OF THE POSSIBILITY OF 
# SUCH DAMAGE. USDA ARS OR OREGON STATE UNIVERSITY SPECIFICALLY DISCLAIMS ANY 
# WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF 
# MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE AND ANY STATUTORY 
# WARRANTY OF NON-INFRINGEMENT. THE SOFTWARE PROVIDED HEREUNDER IS ON AN "AS IS"
# BASIS, AND USDA ARS AND OREGON STATE UNIVERSITY HAVE NO OBLIGATIONS TO PROVIDE
# MAINTENANCE, SUPPORT, UPDATES, ENHANCEMENTS, OR MODIFICATIONS. 
#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!#
#==============================================================================#
# BRUVO'S DISTANCE
#
# This distance is already applied in polysat, but that is more appropriate for
# polyploids. This is being implemented here so that the user does not have to 
# convert their data in order to perform the analysis.
#==============================================================================#
#==============================================================================#
#
#' Calculate the average Bruvo's Distance over all loci in a population.
#'
#' @param pop a \code{\link{genind}} object
#'
#' @param replen a \code{vector} of \code{integers} indicating the length of the
#' nucleotide repeats for each microsatellite locus.
#'
#' @return a \code{distance matrix}
#'
#' @seealso \code{\link{nancycats}}
#'
#' @note This function calculates bruvo's distance for non-special cases (ie.
#' the ploidy and all alleles are known). Currently there is no way to import
#' polyploid partial heterozygote data into adegenet. For Bruvo's Distance 
#' concerning special cases, see the package \code{polysat}.
#'
#' If the user does not provide a vector of appropriate length for \code{replen}
#' , it will be estimated by taking the minimum difference among represented
#' alleles at each locus. It is not recommended to rely on this estimation. 
#'
#' @export
#' @examples
#' # Please note that the data presented is assuming that the nancycat dataset 
#' # contains all dinucleotide repeats, it most likely is not an accurate
#' # representation of the data.
#'
#' # Load the nancycats dataset and construct the repeat vector.
#' data(nancycats)
#' ssr <- rep(1,9)
#' 
#' # Analyze the 1st population in nancycats
#'
#' bruvo.dist(popsub(nancycats, 1), replen=ssr)
#'
#' # View each population as a heatmap.
#' 
#' sapply(nancycats$pop.names, function(x) 
#' heatmap(as.matrix(bruvo.dist(popsub(nancycats, x))), symm=TRUE))
#==============================================================================#
#' @useDynLib poppr
bruvo.dist <- function(pop, replen=c(2)){
  # This attempts to make sure the data is true microsatellite data. It will
  # reject snp and aflp data. 
  if(pop@type != "codom" | all(is.na(unlist(lapply(pop@all.names, as.numeric))))){
    stop("\nThis dataset does not appear to be microsatellite data. Bruvo's Distance can only be applied for true microsatellites.")
  }
  ploid <- ploidy(pop)
  # Bruvo's distance depends on the knowledge of the repeat length. If the user
  # does not provide the repeat length, it can be estimated by the smallest
  # repeat difference greater than 1. This is not a preferred method. 
  if (length(replen) != length(pop@loc.names)){
    guesslengths <- function(vec){
      if(length(vec) > 1){
        lens <- vapply(2:length(vec), function(x) abs(vec[x]-vec[x-1]), 1)
        return(min(lens[lens > 1]))
      }
      else
        return(1)
    }
    replen <- vapply(pop@all.names, function(x) guesslengths(as.numeric(x)), 1)
    #		replen <- rep(replen[1], numLoci)
    warning("\n\nRepeat length vector for loci is not equal to the number of loci represented.\nEstimating repeat lengths from data:\n", immediate.=TRUE)
    cat(replen,"\n\n")
  }
  popcols <- length(pop@loc.names)*ploid
  indnames <- pop@ind.names
  if(any(!round(pop@tab,10) %in% c(0,(1/ploid),1, NA))){
    pop@tab[!round(pop@tab,10) %in% c(0,(1/ploid),1, NA)] <- NA
  }
  if(any(rowSums(pop@tab, na.rm=TRUE) < nLoc(pop))){
    pop <- as.matrix(genind2df(pop, sep="/", usepop=FALSE))
    pop[pop %in% c("", NA)] <- paste(rep(0, ploid), collapse="/")
    return(phylo.bruvo.dist(pop, replen=replen, ploid=ploid))
  }
  else{
    pop <- matrix(as.numeric(as.matrix(genind2df(
  	  pop, oneColPerAll=TRUE, usepop=F))), ncol=popcols)
  }
  # Setting all missing data to 0.
  pop[is.na(pop)] <- 0
  # Dividing the data by the repeat length of each locus.
  pop <- pop / rep(replen, each=ploid*nrow(pop))
  pop <- matrix(as.integer(pop), ncol=popcols)
  # Getting the permutation vector.
  perms <- .Call("permuto", ploid)
  # Calculating bruvo's distance over each locus. 
  distmat <- .Call("bruvo_distance", pop, perms, ploid)
  # If there are missing values, the distance returns 100, which means that the
  # comparison is not made. These are changed to NA.
  distmat[distmat == 100] <- NA
  # Obtaining the average distance over all loci.
  avg.dist.vec <- apply(distmat, 1, mean, na.rm=TRUE)
  # presenting the information in a lower triangle distance matrix.
  dist.mat <- matrix(ncol=nrow(pop), nrow=nrow(pop))
  dist.mat[which(lower.tri(dist.mat)==TRUE)] <- avg.dist.vec
  dist.mat <- as.dist(dist.mat)
  attr(dist.mat, "Labels") <- indnames
  attr(dist.mat, "method") <- "Bruvo"
  attr(dist.mat, "call") <- match.call()
  return(dist.mat)
}


#==============================================================================#
#
#' Create a tree using Bruvo's Distance with non-parametric bootstrapping.
#'
#' @param pop a \code{\link{genind}} object
#'
#' @param replen a \code{vector} of \code{integers} indicating the length of the
#' nucleotide repeats for each microsatellite locus.
#'
#' @param sample an \code{integer} indicated the number of bootstrap replicates
#' desired.
#'
#' @param tree choose between "nj" for neighbor-joining and "upgma" for a upgma
#' tree to be produced.
#'
#' @param showtree \code{logical} if \code{TRUE}, a tree will be plotted with
#' nodelabels.
#' 
#' @param cutoff \code{integer} the cutoff value for bootstrap node label values (between 0 and 100).
#' 
#' @param ... any argument to be passed on to \code{\link{boot.phylo}}. eg.
#' \code{quiet = TRUE}.
#'
#' @return a tree with nodelables
#'
#' @seealso \code{\link{nancycats}}, \code{\link{upgma}}, \code{\link{nj}},
#' \code{\link{boot.phylo}}, \code{\link{nodelabels}}, \code{\link{na.replace}},
#' \code{\link{missingno}}.
#'
#' @note This function calculates bruvo's distance for non-special cases (ie.
#' the ploidy and all alleles are known). Currently there is no way to import
#' polyploid partial heterozygote data into adegenet. For Bruvo's Distance 
#' concerning special cases, see the package \code{polysat}. 
#' Missing data is ignored, but be sure that missing data is NOT set to 0 in the
#' genind object. This is not easy to detect and will result in an error. Please
#' use any other method in \code{\link{na.replace}} or \code{\link{missingno}}. 
#'
#' If the user does not provide a vector of appropriate length for \code{replen}
#' , it will be estimated by taking the minimum difference among represented
#' alleles at each locus. It is not recommended to rely on this estimation. 
#'
#' @export
#' @examples
#' # Please note that the data presented is assuming that the nancycat dataset 
#' # contains all dinucleotide repeats, it most likely is not an accurate
#' # representation of the data.
#'
#' # Load the nancycats dataset and construct the repeat vector.
#' data(nancycats)
#' ssr <- rep(1,9)
#' 
#' # Analyze the 1st population in nancycats
#'
#' bruvo.boot(popsub(nancycats, 1), replen=ssr)
#'
#==============================================================================#
#' @importFrom phangorn upgma
#' @importFrom ape nodelabels nj boot.phylo
bruvo.boot <- function(pop, replen=c(2), sample = 100, tree = "nj", showtree=TRUE, cutoff=NULL, ...) {
  # This attempts to make sure the data is true microsatellite data. It will
  # reject snp and aflp data. 
  if(pop@type != "codom" | all(is.na(unlist(lapply(pop@all.names, as.numeric))))){
    stop("\nThis dataset does not appear to be microsatellite data. Bruvo's Distance can only be applied for true microsatellites.")
  }
  ploid <- ploidy(pop)
  # Bruvo's distance depends on the knowledge of the repeat length. If the user
  # does not provide the repeat length, it can be estimated by the smallest
  # repeat difference greater than 1. This is not a preferred method. 
  if (length(replen) != length(pop@loc.names)){
    guesslengths <- function(vec){
      if(length(vec) > 1){
        lens <- vapply(2:length(vec), function(x) abs(vec[x]-vec[x-1]), 1)
        return(min(lens[lens > 1]))
      }
      else
        return(1)
    }
    replen <- vapply(pop@all.names, function(x) guesslengths(as.numeric(x)), 1)
    #    replen <- rep(replen[1], numLoci)
    warning("\n\nRepeat length vector for loci is not equal to the number of loci represented.\nEstimating repeat lengths from data:\n", immediate.=TRUE)
    cat(replen,"\n\n")
  }
  if(any(!round(pop@tab,10) %in% c(0,(1/ploid),1, NA))){
    pop@tab[!round(pop@tab,10) %in% c(0,(1/ploid),1, NA)] <- NA
  }
  # Converting the genind object into a matrix with each allele separated by "/"
  bar <- as.matrix(genind2df(pop, sep="/", usepop=FALSE))
  # The bruvo algorithm will ignore missing data, coded as 0.
  bar[bar %in% c("", NA)] <- paste(rep(0, ploid), collapse="/")
  stopifnot(require(phangorn))
  # Steps: Create initial tree and then use boot.phylo to perform bootstrap
  # analysis, and then place the support labels on the tree.
  if(tree == "upgma")
    newfunk <- upgma
  else if(tree == "nj")
    newfunk <- nj
  tre<-newfunk(phylo.bruvo.dist(bar, replen=replen, ploid=ploid))
  if (any (tre$edge.length < 0)){
    warning("The branch lengths of the tree are negative.", immediate.=TRUE)
    us.promp<- as.numeric(readline(prompt="What do you want to do?, You can:\n1. Stop the analysis\n2. Convert negative branch values to Zero (Not biologically relevant)\nEnter your Selection:"))
    if (us.promp == 1){
      cat("Analysis stopped due to negative branches in the resulting tree\n")
      return(tre)
      stop()
    }
    else if (us.promp == 2){
      tre$edge.length[tre$edge.length < 0] <- 0
    }
    else{
      cat("Non-valid option. Returning tree.\n")
      return(tre)
    }
  }
  bp <- boot.phylo(tre, bar, FUN = function (x) newfunk(phylo.bruvo.dist(x, replen=replen, ploid=ploid)), B = sample, ...)
  tre$node.labels <- round(((bp/sample)*100))
  if (!is.null(cutoff)){
    if (cutoff<1|cutoff>100){
      cat("Cutoff value must be between 0 and 100.\n")
      cutoff<- as.numeric(readline(prompt="Choose a new cutoff value between 0 and 100:\n"))
    }
    tre$node.labels[tre$node.labels<cutoff]<-NA
  }
  tre$tip.label <- pop@ind.names
  if(showtree)
    plot(tre, show.node.label=TRUE)
  if(tree=="upgma")
    axisPhylo(3)
  return(tre)
}

