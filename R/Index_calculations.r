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
# The calculation of the Index of Association and standardized Index of 
# Association.
#'
#' Produce a basic summary table for population genetic analyses.
#'
#' This function allows the user to quickly view indecies of distance, 
#' heterozygosity, and inbreeding to aid in the decision of a path to further
#' analyze a specified dataset. It natively takes \code{\link{genind}} formatted
#' files, but can convert any raw data formats that adegenet can take (fstat,
#' structure, gentix, and genpop) as well as genalex files exported into a csv 
#' format (see \code{\link{read.genalex}} for details).
#'
#'
#' @param pop a \code{\link{genind}} object OR any fstat, structure, gentix, 
#' genpop, or genalex formatted file.
#'
#' @param total default \code{TRUE}. Should indecies be calculated for the 
#' combined populations represented in the entire file?
#' 
#' @param sublist a list of character strings or integers to indicate specific 
#' population names (located in \code{$pop.names} within the 
#' \code{\link{genind}} object) Defaults to "ALL".
#'
#' @param blacklist a list of character strings or integers to indicate specific
#' populations to be removed from analysis. Defaults to NULL.
#' 
#' @param sample an integer indicating the number of permutations desired to
#' obtain p-values. Sampling will shuffle genotypes at each locus to simulate
#' a panmictic population using the observed genotypes. Calculating the p-value
#' includes the observed statistics, so set your sample number to one off for a
#' round p-value (eg. \code{sample = 999} will give you p = 0.001 and
#' \code{sample = 1000} will give you p = 0.000999001). 
#'
#' @param method an integer from 1 to 4 indicating the method of sampling desired.
#' see \code{popsample} for details.
#' 
#' @param missing how should missing data be treated? \code{"zero"} and 
#' \code{"mean"} will set the missing values to those documented in 
#' \code{\link{na.replace}}. \code{"loci"} and \code{"geno"} will remove any 
#' loci or genotypes with missing data, respectively (see 
#' \code{\link{missingno}} for more information.
#' 
#' @param quiet Should the function print anything to the screen while it is
#' performing calculations? \code{TRUE} prints nothing, 
#' \code{"minimal"} (defualt) will print the population name and dots indicating 
#' permutation progress, 
#' \code{FALSE} will print the number of individuals in the population.
#' \code{"noisy"} will print out the individual indecies as they are produced.
#' 
#' @param clonecorrect default \code{FALSE}.
#' must be used with the \code{hier} and \code{dfname} parameters, or the user
#' will potentially get undesiered results. see \code{\link{clonecorrect}} for
#' details. 
#' 
#' @param hier a \code{numeric or character list}. This is the list of vectors
#' within a data frame (specified in \code{dfname}) in the 'other' slot of the
#' \code{\link{genind}} object. The list should indicate the population
#' hierarchy to be used for clone correction.
#'
#' @param dfname a \code{character string}. This is the name of the data frame
#' or list containing the vectors of the population hierarchy within the
#' \code{other} slot of the \code{\link{genind}} object.
#' 
#' @param hist \code{logical} if \code{TRUE} a histogram will be produced for
#' each population. 
#' 
#' @param minsamp an \code{integer} indicating the minimum number of individuals
#' to resample for rarefaction analysis. 
#'
#' @return 
#' \item{Pop}{A vector indicating the pouplation factor}
#' \item{N}{An integer vector indicating the number of individuals/isolates in
#' the specified population.}
#' \item{MLG}{An integer vector indicating the number of multilocus genotypes
#' found in the specified poupulation, (see: \code{\link{mlg}})}
#' \item{eMLG}{The expected number of MLG at the lowest common sample size (set
#' by the parameter \code{minsamp}.}
#' \item{SE}{The standard error for the rarefaction analysis}
#' \item{H}{Shannon-Weiner Diversity index}
#' \item{G}{Stoddard and Taylor's Index}
#' \item{Hexp}{Expected heterozygosity or Nei's 1987 genotypic diversity corrected for sample size.}
#' \item{E.5}{Evenness}
#' \item{Ia}{A numeric vector giving the value of the Index of Association for
#' each population factor, (see \code{\link{ia}}).}
#' \item{p.Ia}{A numeric vector indicating the p-value for Ia from the
#' number of reshufflings indicated in \code{sample}. Lowest value is 1/n where
#' n is the number of observed values.}
#' \item{rbarD}{A numeric vector giving the value of the Standardized Index of
#' Association for each population factor, (see \code{\link{ia}}).}
#' \item{p.rD}{A numeric vector indicating the p-value for rbarD from the
#' number of reshufflings indicated in \code{sample}. Lowest value is 1/n where
#' n is the number of observed values.}
#' \item{File}{A vector indicating the name of the original data file.}
#'
#' @note All values are rounded to three significant digits for the final table.
#' 
#' @seealso \code{\link{clonecorrect}}, \code{\link{poppr.all}}, 
#' \code{\link{ia}}, \code{\link{missingno}}, \code{\link{mlg}}
#'
#' @export
#' @examples
#' data(nancycats)
#' poppr(nancycats)
#' 
#' \dontrun{
#' poppr(nancycats, sample=99, total=FALSE, quiet=FALSE)
#' 
#' # Note: this is a larger data set that could take a couple of minutes to run
#' # on slower computers. 
#' data(H3N2)
#' poppr(H3N2, total=FALSE, sublist=c("Austria", "China", "USA"), 
#' 				clonecorrect=TRUE, hier="country", dfname="x")
#' }
#==============================================================================#
#' @import adegenet pegas vegan ggplot2
poppr <- function(pop,total=TRUE,sublist=c("ALL"),blacklist=c(NULL), sample=0,
                  method=1,missing="ignore", quiet="minimal",clonecorrect=FALSE,
                  hier=c(1), dfname="population_hierarchy", hist=TRUE, minsamp=10){
  METHODS = c("multilocus", "permute alleles", "parametric bootstrap",
      "non-parametric bootstrap")
	x <- .file.type(pop, missing=missing, clonecorrect=clonecorrect, hier=hier, 
                  dfname=dfname, quiet=TRUE)	
  # The namelist will contain information such as the filename and population
  # names so that they can easily be ported around.
  namelist <- NULL
  callpop <- match.call()
  if(!is.na(grep("system.file", callpop)[1])){
    popsplt <- unlist(strsplit(pop, "/"))
    namelist$File <- popsplt[length(popsplt)]
  }
  else if(is.genind(pop)){
    namelist$File <- x$X
  }
  else{
    namelist$File <- basename(x$X)
  }
  #poplist <- x$POPLIST
  pop <- popsub(x$GENIND, sublist=sublist, blacklist=blacklist)
  poplist <- .pop.divide(pop)
  # Creating the genotype matrix for vegan's diversity analysis.
  pop.mat <- mlg.matrix(pop)
  if (total==TRUE & !is.null(poplist)){
    poplist$Total <- pop
    pop.mat <- rbind(pop.mat, colSums(pop.mat))
  }
  sublist <- names(poplist)
  Iout <- NULL
  result <- NULL
  origpop <- x$GENIND
  rm(x)
  total <- toupper(total)
  missing <- toupper(missing)
  type <- pop@type
  # For presence/absences markers, a different algorithm is applied. 
  if(type=="PA"){
    .Ia.Rd <- .PA.Ia.Rd
  }
  #''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''#
  # Creating an indicator for multiple subpopulations.
  # MPI = Multiple Population Indicator
  #,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#
  if (is.null(poplist)){
    MPI <- NULL
  }
  else{
    MPI <- 1
  }

  #''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''#
  # ANALYSIS OF MULTIPLE POPULATIONS.
  #,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,# 
 
	if (!is.null(MPI)){
    
    #''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''#
    # Calculations start here.
    #,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#

    MLG.vec <- vapply(sublist, function(x) mlg(poplist[[x]], quiet=TRUE), 1)
    N.vec <- vapply(sublist, function(x) length(poplist[[x]]@ind.names), 1)
    # Shannon-Weiner vegan:::diversity index.
    H <- vegan:::diversity(pop.mat)
    # E_1, Pielou's evenness.
    # J <- H / log(rowSums(pop.mat > 0))
    # inverse Simpson's index aka Stoddard and Taylor: 1/lambda
    G <- vegan:::diversity(pop.mat, "inv")
    Hexp <- (N.vec/(N.vec-1))*vegan:::diversity(pop.mat, "simp")
    # E_5
    E.5 <- (G-1)/(exp(H)-1)
    # rarefaction giving the standard errors. This will use the minimum pop size
    # above a user-defined threshold.
    raremax <- ifelse(is.null(nrow(pop.mat)), sum(pop.mat), 
                      ifelse(min(rowSums(pop.mat)) > minsamp, 
                             min(rowSums(pop.mat)), minsamp))
    
    N.rare <- rarefy(pop.mat, raremax, se=TRUE)
    IaList <- NULL
    invisible(lapply(sublist, function(x) 
                              IaList <<- rbind(IaList, 
                                               .ia(poplist[[x]], 
                                                       sample=sample, 
                                                       method=method, 
                                                       quiet=quiet, 
                                                       missing=missing, 
                                                       namelist=list(File=namelist$File, population = x),
                                                       hist=hist
              ))))

    #''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''#
    # Making the data look pretty.
    #,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#
    Iout <- as.data.frame(list(Pop=sublist, N=N.vec, MLG=MLG.vec, 
                                eMLG=round(N.rare[1, ], 3), 
                                SE=round(N.rare[2, ], 3), 
                                H=round(H, 3), 
                                G=round(G,3),
                                Hexp=round(Hexp, 3),
                                E.5=round(E.5,3),
                                round(IaList, 3),
                                File=namelist$File))
    rownames(Iout) <- NULL
    return(final(Iout, result))
	}
  #''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''#
  # ANALYSIS OF SINGLE POPULATION. This is for if there are no subpopulations to
  # be analyzed. For details of the functions utilized, see the notes above.
  #,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,,#
  else { 
    MLG.vec <- mlg(pop, quiet=TRUE)
    N.vec <- length(pop@ind.names)
    # Shannon-Weiner vegan:::diversity index.
    H <- vegan:::diversity(pop.mat)
    # E_1, Pielou's evenness.
    # J <- H / log(rowSums(pop.mat > 0))
    # inverse Simpson's index aka Stoddard and Taylor: 1/lambda
    G <- vegan:::diversity(pop.mat, "inv")
    Hexp <- (N.vec/(N.vec-1))*vegan:::diversity(pop.mat, "simp")
    # E_5
    E.5 <- (G-1)/(exp(H)-1)
    # rarefaction giving the standard errors. No population structure means that
    # the sample is equal to the number of individuals.
    N.rare <- rarefy(pop.mat, sum(pop.mat), se=TRUE)
    IaList <- .ia(pop, sample=sample, method=method, quiet=quiet, missing=missing,
                      namelist=(list(File=namelist$File, population="Total")),
                      hist=hist)
    Iout <- as.data.frame(list(Pop="Total", N=N.vec, MLG=MLG.vec, 
                          eMLG=round(N.rare[1, ], 3), 
                          SE=round(N.rare[2, ], 3),
                          H=round(H, 3), 
                          G=round(G,3), 
                          Hexp=round(Hexp, 3), 
                          E.5=round(E.5,3), 
                          round(as.data.frame(t(IaList)), 3),
                          File=namelist$File))
    rownames(Iout) <- NULL
    return(final(Iout, result))
  }
}

#==============================================================================#
# This will process a list of files given by filelist
#' Process a list of files with poppr
#'
#' poppr.all is a wrapper function that will loop through a list of files from
#' the workind directory, execute \code{\link{poppr}}, and concatenate the
#' output into one data frame.
#'
#' @param filelist a list of files in the current working directory
#'
#' @param ... arguments passed on to poppr
#'
#' @return see \code{\link{poppr}}
#'
#' @seealso \code{\link{poppr}}, \code{\link{getfile}}
#' @export
#' @examples
#' \dontrun{
#' # Obtain a list of fstat files from a directory.
#' x <- getfile(multFile=TRUE, pattern="^.+?dat$")
#'
#' # set the working directory to that directory.
#' setwd(x$path)
#'
#' # run the analysis on each file.
#' poppr.all(x$files)
#' }
#==============================================================================# 
poppr.all <- function(filelist, ...) {
	result <- NULL
	for(a in filelist){
    cat("| File: ",basename(a),"\n")
		result <- rbind(result, poppr(a, ...))
	}
	return(result)
}
#==============================================================================#
# 
# This will now calculate the index of associaton and also perform the necessary
# permutation analysis, printing out a table of raw information. 
#
#' Index of Association
#' 
#' Calculate the Index of Association and Standardized Index of Association.
#' Obtain p-values from one-sided permutation tests. 
#' 
#' @param pop a \code{\link{genind}} object OR any fstat, structure, gentix, 
#' genpop, or genalex formatted files.
#'
#' @param sample an integer indicating the number of permutations desired (eg
#' 999).
#'
#' @param method an integer from 1 to 4 indicating the sampling method desired.
#' see \code{popsample} for details. 
#'
#' @param quiet Should the function print anything to the screen while it is
#' performing calculations? 
#'
#' \code{TRUE} prints nothing.
#'
#' \code{FALSE} same as "minimal".
#'
#' \code{"minimal"} (defualt) will print the population name and dots indicating 
#' permutation progress.
#'
#' \code{"noisy"} will print out the individual indecies as they are produced.
#'
#' @param missing a character string. see \code{\link{missingno}} for details.
#'
#' @param hist \code{logical} if \code{TRUE}, a histogram will be printed for
#' each population if there is sampling.
#'
#' @return 
#' \emph{If no sampling has occured:}
#' 
#' A named number vector of length 2 giving the Index of Association,
#' "Ia"; and the Standardized Index of Association, "rbarD"
#'
#' \emph{If there is sampling:}
#'
#' A a named number vector of length 4 with the following values:
#' \item{Ia}{numeric. The index of association.}
#' \item{p.Ia}{A number indicating the p-value resulting from a one-sided
#' permutation test based on the number of samples indicated in the original
#' call.}
#' \item{rbarD}{numeric. The standardized index of association.}
#' \item{p.rD}{A factor indicating the p-value resutling from a one-sided
#' permutation test based on the number of samples indicated in the original
#' call.}
#'
#' @seealso \code{\link{poppr}}, \code{\link{missingno}},
#' \code{\link{import2genind}},
#' \code{\link{read.genalex}}, \code{\link{clonecorrect}}
#' 
#' @export
#' @examples
#' data(nancycats)
#' ia(nancycats)
#' 
#' \dontrun{
#' # Get the index for each population.
#' lapply(seppop(nancycats), ia)
#' # With sampling
#' lapply(seppop(nancycats), ia, sample=999)
#' }
#==============================================================================#

ia <- function(pop, sample=0, method=1, quiet="minimal", missing="ignore", 
                hist=TRUE){
  METHODS = c("multilocus", "permute alleles", "parametric bootstrap",
      "non-parametric bootstrap")
  namelist <- NULL
  namelist$population <- ifelse(length(levels(pop@pop)) > 1 | 
                                is.null(pop@pop), "Total", pop@pop.names)
  namelist$File <- as.character(pop@call[2])
  popx <- pop
  missing <- toupper(missing)
  type <- pop@type
  if(type=="PA"){
    .Ia.Rd <- .PA.Ia.Rd
  }
  else {
    popx <- seploc(popx)
  }

  # if there are less than three individuals in the population, the calculation
  # does not proceed. 
  if (nInd(pop) < 3){
    IarD <- as.numeric(c(NA,NA))
    names(IarD) <- c("Ia", "rbarD")
    if(sample==0){
      return(IarD)
    }
    else{
      IarD <- as.numeric(rep(NA,4))
      names(IarD) <- c("Ia","p.Ia","rbarD","p.rD")
      return(IarD)
    }
  }
  IarD <- .Ia.Rd(popx, missing)
  names(IarD) <- c("Ia", "rbarD")
  # no sampling, it will simply return two named numbers.
  if (sample==0){
    Iout <- IarD
    result <- NULL
  }
  # sampling will perform the iterations and then return a data frame indicating
  # the population, index, observed value, and p-value. It will also produce a 
  # histogram.
  else{
    Iout <- NULL 
    idx <- as.data.frame(list(Index=names(IarD)))
    samp <- .sampling(popx, sample, missing, quiet=quiet, type=type, method=method)
    samp2 <- rbind(samp, IarD)
    p.val <- ia.pval(index="Ia", samp2, IarD[1])
    p.val[2] <- ia.pval(index="rbarD", samp2, IarD[2])
    if(hist == TRUE){
      if(require(ggplot2)){
        poppr.plot(samp, observed=IarD, pop=namelist$population,
                          file=namelist$File, pval=p.val, N=nrow(pop@tab))
      }
      else{      
        permut.histogram(samp, IarD, p.val[1], pop=namelist$population, 
                        file=namelist$File)
      }
    }
    result <- 1:4
    result[c(1,3)] <- IarD
    result[c(2,4)] <- p.val
    names(result) <- c("Ia","p.Ia","rbarD","p.rD")
  }  
  return(final(Iout, result))
}

