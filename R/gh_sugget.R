#' Suggest Github Repository from a Incomplete Name
#' 
#' @param repo_name a character. A part of a repository name.
#' @param keep_title logical. Indicates to keep the package titles as an attrbite. Default \code{FALSE}.
#' 
#' @return candidates for the repository name.
#' 
#' @examples 
#' gh_guess("AnomalyDetection")
#' # [1] "twitter/AnomalyDetection"
#' gh_guess("BnomalyDetection")
#' # [1] "twitter/AnomalyDetection"
#' gh_guess("uwitter/BnomalyDetection")
#' # [1] "twitter/AnomalyDetection"
#' 
#' @importFrom utils adist
#' 
#' @export
gh_suggest <- function (repo_name, keep_title = FALSE) {
  repo_name <- repo_name[1]
  package_list <- get_package_list()
  
  if (is_full_repo_name(repo_name)) {
    target <- paste0(package_list$author, "/", package_list$package_name)
    if(keep_title) titles <- package_list$title
  } else {
    target <- unique(package_list$package_name)
  }
  
  dist <- adist(repo_name, target)[1, ]
  mindist <- min(dist)
  result <- target[dist == mindist]
  
  if (is_full_repo_name(repo_name)) {
    if(keep_title) attr(result, "title") <- titles[dist == mindist]
    result
  } else {
    candidates_list <- lapply(result, function(package_name) {
      ind <- package_list$package_name == package_name
      if (all(!ind)) {
        NULL
      } else {
        authors <- package_list$author[ind]
        candidates <- paste0(authors, "/", package_name)
        if (keep_title) {
          titles <- package_list$title[ind]
          attr(candidates, "title") <- titles
        }
        candidates
      }
    })
    result <- unlist(candidates_list)
    if(keep_title) {
      titles <- Reduce(function(x, y) c(attr(x, "title"), attr(y, "title")), init = c(), candidates_list)
      attr(result, "title") <- titles
    }
    result
  }
}

#' @inheritParams gh_suggest
#' @rdname gh_suggest
#' @export
gh_guess <- function(repo_name, keep_title = FALSE) {
  .Deprecated("gh_suggest")
  gh_suggest(repo_name = repo_name, keep_title = keep_title)
}