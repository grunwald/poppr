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
#
# The clone correct function will need a parameter for the lowest population
# level in order to keep at least one individual represented in each population.
# It takes a popper object and will return a poppr object.
#
#' Remove potential bias caused by cloned genotypes in genind object.
#' 
#' This function removes any duplicated multi locus genotypes from any specified
#' population hierarchy.
#'
#' @param pop a \code{\link{genind}} object
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
#' @param combine \code{logical}. When set to TRUE, the heirarchy will be
#' combined to create a new population for the genind object.
#'
#' @return a clone corrected \code{\link{genind}} object. 
#' 
#' @note 
#' This function will clone correct to the population level indicated in
#' the \code{pop} slot of the \code{\link{genind}} object if there is no data
#' frame specified in dfname. If there is no population structure and there is
#' no specified data frame, it will clone correct the entire
#' \code{\link{genind}} object. 
#' 
#'
#' @export
#' @examples
#' # LOAD H3N2 dataset
#' data(H3N2)
#'
#' # Extract only the individuals located in China
#' country <- clonecorrect(H3N2, hier=c("country"), dfname="x")
#'
#' # How many isolates did we have from China before clone correction?
#' length(which(other(H3N2)$x$country=="China")) # 155
#'
#' # How many unique isolates from China after clone correction?
#' length(which(other(country)$x$country=="China")) # 79
#' 
#' \dontrun{
#' # Something a little more complicated. (This could take a few minutes on
#' # slower computers)
#'
#' # setting the hierarchy to be Country > Year > Month  
#' c.y.m <- clonecorrect(H3N2, hier=c("year","month","country"), dfname="x")
#'
#' # How many isolates in the original data set?
#' length(other(H3N2)$x$country) # 1903
#'
#' # How many after we clone corrected for country, year, and month?
#' length(other(c.y.m)$x$country) # 1190
#' }
#==============================================================================#

clonecorrect <- function(pop, hier=c(1), dfname="population_hierarchy", combine=FALSE){
  if(!is.genind(pop)){
    stop("This only works for genind objects")
  }
  if(is.null(other(pop)[[dfname]])){
    if(length(hier) == 1 & hier[1] == 1){
      if(length(levels(pop(pop))) == 1 | is.null(pop(pop))){
        pop <- pop[.clonecorrector(pop), ]
        return(pop)
      }
      else if(length(levels(pop(pop))) > 1){
        other(pop)[[dfname]] <- as.data.frame(list(Pop = as.character(pop(pop))))
        warning(paste("There was no data frame in the 'other' slot called ",
                      dfname,". One is being created from the population factor.", 
                      sep=""))
      }
    }
    else{
      stop(paste("There is no data frame in the 'other' slot called",dfname))
    }
  }
  if(all(pop@ind.names == "")){
    pop@ind.names <- as.character(1:nInd(pop))
  }
  popcall <- pop@call
  pop <- splitcombine(pop, method=2, dfname=dfname, hier=hier)
  cpop <- length(pop$pop.names)
  corWrecked <- function(x, pop){
    subbed <- popsub(pop, x) # population to be...corrected.
    subbed <- subbed[.clonecorrector(subbed), ] # correcting.
    # Return the indices base off of the individual names.
    return(which(pop@ind.names %in% subbed@ind.names))
  }
  #cat(cpop)
  ccpop <- unlist(lapply(1:cpop, corWrecked, pop))
  #cat(ccpop)
  pop <- pop[ccpop, ]
  if(!combine){
    pop(pop) <- pop$other[[dfname]][[hier[1]]]
    names(pop$pop.names) <- levels(pop$pop)
  }
  pop@call <- popcall
  return(pop)
}


#==============================================================================#
# subset a population with a combination of sublists and blacklists. Either one
# is optional, and the default is to do nothing. The structure will allow the
# user to select a range of populations and exclude a small number of them
# without having to use the total. 
# eg pop <- pop.subset(pop, sublist=1:50, blacklist=c(17, 33))
# 
#' Subset a \code{\link{genind}} object by population
#' 
#' Create a new dataset with specified populations or exclude specified
#' populations from the dataset.
#' 
#' @param pop a \code{\link{genind}} object.
#' 
#' @param sublist a \code{vector} of population names or indexes that the user
#' wishes to keep. Default to "ALL".
#'
#' @param blacklist a \code{vector} of population names or indexes that the user
#' wishes to discard. Default to \code{NULL}
#'
#' @param mat a \code{matrix} object produced by \code{\link{mlg.table}} to be
#' subsetted. If this is present, the subsetted matrix will be returned instead
#' of the genind object 
#'
#' @param drop \code{logical}. If \code{TRUE}, unvariate alleles will be dropped
#' from the population.
#' 
#' @return A \code{genind} object or a matrix.
#'
#' @examples
#' # Load the dataset microbov.
#' data(microbov)
#' 
#' # Analyze only the populations with exactly 50 individuals
#' mic.50 <- popsub(microbov, sublist=c(1:6, 11:15), blacklist=c(3,4,13,14))
#'
#' # Analyze the first 10 populations, except for "Bazadais"
#' mic.10 <- popsub(microbov, sublist=1:10, blacklist="Bazadais")
#' 
#' # Take out the two smallest populations
#' micbig <- popsub(microbov, blacklist=c("NDama", "Montbeliard"))
#' 
#' # Analyze the two largest populations
#' miclrg <- popsub(microbov, sublist=c("BlondeAquitaine", "Charolais"))
#'
#' @export
#==============================================================================#

popsub <- function(pop, sublist="ALL", blacklist=NULL, mat=NULL, drop=TRUE){

  if (!is.genind(pop)){
    stop("pop.subset requires a genind object\n")
  }
  if (is.null(pop(pop))){
    if(sublist[1] != "ALL")
      warning("No population structure. Subsetting not taking place.")
    return(pop)
  }
  if(toupper(sublist[1]) == "ALL"){
    if (is.null(blacklist)){
      return(pop)
    }
    else {
      # filling the sublist with all of the population names.
      sublist <- pop@pop.names 
    }
  }

  # Checking if there are names for the population names. 
  # If there are none, it will give them names. 
  if (is.null(names(pop@pop.names))){
    if (length(pop@pop.names) == length(levels(pop@pop))){
      names(pop@pop.names) <- levels(pop@pop)
    }
    else{
      stop("Population names do not match population factors.")
    }
  }

  # Treating anything present in blacklist.
  if (!is.null(blacklist)){

    # If both the sublist and blacklist are numeric or character.
    if(is.numeric(sublist) & is.numeric(blacklist) | class(sublist) == class(blacklist)){
      sublist <- sublist[!sublist %in% blacklist]
    }
    
    # if the sublist is numeric and blacklist is a character. eg s=1:10, b="USA"
    else if(is.numeric(sublist) & class(blacklist) == "character"){
      sublist <- sublist[sublist %in% which(!pop@pop.names %in% blacklist)]
    }
    else{

      # no sublist specified. Ideal situation
      if(all(pop@pop.names %in% sublist)){
        sublist <- sublist[-blacklist]
      }

      # weird situation where the user will specify a certain sublist, yet index
      # the blacklist numerically. Interpreted as an index of populations in the
      # whole data set as opposed to the sublist.
      else{
        warning("Blacklist is numeric. Interpreting blacklist as the index of the population in the total data set.")
        sublist <- sublist[!sublist %in% pop@pop.names[blacklist]]
      }
    }
  }
  if(!is.null(mat)){
    mat <- mat[sublist, , drop=FALSE]
    return(mat[, which(colSums(mat) > 0), drop=FALSE])
  }
  else{
    # subsetting the population. 
    if (is.numeric(sublist))
      sublist <- names(pop@pop.names[sublist])
    else
      sublist <- names(pop@pop.names[pop@pop.names %in% sublist])
      sublist <- (1:length(pop@pop))[pop@pop %in% sublist]
    if(is.na(sublist[1])){
      warning("All items present in Sublist are also present in the Blacklist.\nSubsetting not taking place.")
      return(pop)
    }
    pop <- pop[sublist, ,drop=drop]
    pop@call <- match.call()
    return(pop)
  }
}

#==============================================================================#
# missigno simply applies one of four methods to deal with missing data.
# default is to remove missing loci. 
#' How to deal with missing data in a genind object.
#' 
#' missingno gives the user four options to deal with missing data.
#'
#' @param pop a \code{\link{genind}} object.
#'
#' @param missing a character string: can be "zero", "mean", "loci", or "geno"
#' (see \code{Details} for definitions).]
#' 
#' @param quiet if \code{TRUE}, it will print to the screen the action performed.
#'
#' @section Details: The default way that functions in \code{poppr} deal with
#' missing data is to simply ignore it. These methods provide a way to deal with
#' systematic missing data and to give a wrapper for \code{adegenet}'s \code{
#' \link{na.replace}} function. ALL OF THESE ARE TO BE USED WITH CAUTION.
#'
#' \code{"loci"} - removes all loci containing missing data in the entire data
#' set. 
#'
#' \code{"geno"} - removes any genotypes/isolates/individuals with missing data.
#'
#' \code{"mean"} - replaces all NA's with the mean of the alleles for the entire
#' data set.
#'
#' \code{"zero"} or \code{"0"} - replaces all NA's with "0". 
#' Introduces more diversity.
#'
#' @return a \code{\link{genind}} object.
#'
#' @note
#' \emph{"wild missingno appeared!"}
#'
#' @seealso \code{\link{na.replace}}, \code{\link{poppr}}
#'
#' @export
#' @examples
#'
#' data(nancycats)
#' 
#' # Removing 3 loci with missing data.
#' nancy.locina <- missingno(nancycats, "loci")
#'
#' # Removing 38 individuals/isolates/genotypes with missing data.
#' nancy.genona <- missingno(nancycats, "geno")
#'
#' # Replacing all NA with "0" (see na.replace in the adegenet package).
#' nancy.0 <- missingno(nancycats, "0")
#'
#' # Replacing all NA with the mean of each column (see na.replace in the
#' # adegenet package).
#' nancy.mean <- missingno(nancycats, "mean")
#==============================================================================#

missingno <- function(pop, missing, quiet=FALSE){
  if(sum(is.na(pop@tab)) > 0){
    # removes any loci (columns) with missing values.
    if (toupper(missing)=="LOCI"){
      naloci <- loci.na(pop)
      if(quiet != TRUE){
        remloc <- pop@loc.names[which(cumsum(pop@loc.nall) %in% -naloci)]
        cat("\n Found", sum(is.na(pop@tab)),"missing values.")
        cat("\n Removing",length(remloc),"loci:", remloc,"\n")
      }
      pop <- pop[, naloci]
    }  
    # removes any genotypes (rows) with missing values.
    else if (!is.na(grep("GEN", toupper(missing), value=TRUE)[1])){
      nageno <- geno.na(pop)
      if(quiet != TRUE){
        cat("\n Found", sum(is.na(pop@tab)),"missing values.")
        cat("\n Removing",length(nageno),"genotypes\n")
      }
      pop <- pop[geno.na(pop),]
    }
    # changes all NA's to the mean of the column. NOT RECOMMENDED
    else if (toupper(missing)=="MEAN"){
      pop <- na.replace(pop,"mean", quiet=quiet)
    }
    # changes all NA's to 0. NOT RECOMMENDED. INTRODUCES MORE DIVERSITY.
    else if (toupper(missing)=="ZERO" | missing=="0"){
      pop <- na.replace(pop,"0", quiet=quiet)
    }
  }
  else{
    if(quiet == FALSE){
      cat("\n No missing values detected.\n")
    }
  }
  return (pop)
}


#==============================================================================#
#' Split a or combine items within a data frame in \code{\link{genind}} objects.
#'
#' Often, one way a lot of file formats fail is that they do not allow multiple
#' population hierarchies. This can be circumvented, however, by coding all of
#' the hierarchies in one string in the input file with a common separator (eg.
#' "_"). \code{splitcombine} will be able to recognise those separators and
#' create a data frame of all the population structures for whatever subsetting
#' you might need. 
#'
#' @param pop a \code{\link{genind}} object.
#'
#' @param method an \code{integer}, 1 for splitting, 2 for combining.
#'
#' @param dfname the name of the data frame containing the population structure.
#' for the splitting method, the combined population structure must be in the
#' first column. 
#'
#' @param sep The separator used for separating or combining the data. See note.
#'
#' @param hier a \code{vector} containing the population hierarchy you wish to
#' split or combine. 
#'
#' @param setpopulation \code{logical}. if \code{TRUE}, the population of the
#' resulting genind object will be that of the highest population structure
#' (split method) or the combined populations (combine method).
#'
#' @param fixed \code{logical}. An argument to be passed onto
#' \code{\link{strsplit}}. If \code{TRUE}, \code{sep} must match exactly to the
#' populations for the split method. 
#'
#' @return a \code{\link{genind}} object with a modified data frame in the
#' \code{\link{other}} slot.
#'
#' @note The separator field is sensitive to regular expressions. If you do not
#' know what those are, please use the default underscore to separate your
#' populations. Use \code{fixed = TRUE} to ignore regular expressions.  
#' If you do not set the \code{hier} flag for the split method, your new data
#' frame will have the names "comb", "h1", "h2" and so on; for the combine
#' method, your data frame will return the first column of your data frame.
#'
#' @export
#' @examples
#' data(H3N2)
#' # Create a new data set combining the population factors of year and country
#' H.comb <- splitcombine(H3N2, method=2, dfname="x", hier=c("year", "country"))
#'
#' # Checking to make sure they were actually combined.
#' head(H.comb$other$x$year_country)
#'
#' # Creating new data frame in the object to mess around with. 
#' H.comb$other$year_country <- data.frame(H.comb$other$x$year_country)
#' 
#' # Splitting those factors into their original components and setting the
#' # population to year.
#' H.comb <- splitcombine(H.comb, method=1, dfname="year_country", hier=c("year", "country"))
#'
#' # A situation with real data. 
#' Aeut <- read.genalex(system.file("files/rootrot.csv", package="poppr"))
#' 
#' # We have 19 different "populations", but really, there is a hierarchy.
#' Aeut$pop.names
#' 
#' # Let's split them up. The default data frame from read.genalex is the same
#' # as the default for this function. 
#' Aeut <- splitcombine(Aeut, hier=c("Pop", "Subpop"))
#'
#' # Much better!
#' Aeut$pop.names
#==============================================================================#
splitcombine <- function(pop, method=1, dfname="population_hierarchy", sep="_", hier=c(1), setpopulation=TRUE, fixed=TRUE){
  stopifnot(is.genind(pop))
  stopifnot(is.data.frame(pop$other[[dfname]]))
  METHODS = c("Split", "Combine")
  if (all((1:2)!=method)) {
    cat("1 = Split\n")
    cat("2 = Combine\n")
    cat("Select an integer (1 or 2): ")
    method <- as.integer(readLines(n = 1))
  }
  if (all((1:2)!=method)) (stop ("Non convenient method number"))
  # Splitting !
  if(method == 1){
    df <- pop.splitter(pop$other[[dfname]], sep=sep)
    if(length(df)-1 == length(hier)){
      names(df) <- c(paste(hier, collapse=sep), hier)
    }
    if(length(pop$other[[dfname]] == 1)){
      pop$other[[dfname]] <- df
    }
    else if(any(names(pop$other[[dfname]]) %in% names(df[-1]))){
      df <- df[-1]
      dfcols <- which(names(pop$other[[dfname]]) %in% names(df))
      if(length(names(df)) == length(dfcols))
        pop$other[[dfname]][dfcols] <- df
      else{
        popothernames <- which(names(df) %in% names(pop$other[[dfname]][dfcols]))
        pop$other[[dfname]][dfcols] <- df[popothernames]
        pop$other[[dfname]] <- cbind(pop$other[[dfname]], df[-dfcols])
      }
    }
    else{
      pop$other[[dfname]] <- cbind(pop$other[[dfname]], df[-1])
    }
    if(setpopulation){
      pop(pop) <- pop$other[[dfname]][[hier[1]]]
      names(pop$pop.names) <- levels(pop$pop)
    }
    return(pop)
  }
  
  # Combining !
  else if(method == 2){
    newdf <- pop.combiner(pop$other[[dfname]], hier=hier, sep=sep)
    pop$other[[dfname]][[paste(hier, collapse=sep)]] <- newdf
    if(setpopulation)
      pop(pop) <- newdf
      names(pop$pop.names) <- levels(pop$pop)
    return(pop)
  }
}


