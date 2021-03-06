#' Divide a bullet signature/profile into basis segments of desired length
#'
#' `get_segs` divides a bullet signature/profile (a numeric vector) into consecutive, 
#' non-overlapping, basis segments of the same desired length. If the profile 
#' starts or ends with a sequence of `NA` (missing values), the `NA`s will be trimmed. 
#' If the very last segment does not have the desired length, it will be dropped. 
#' @param x a numeric vector, vector of the bullet signature/profile
#' @param len integer: the desired length of a basis segment
#'
#' @return list with basis segments and their corresponding indices in the profile
#' @export
#' @importFrom zoo na.trim
#' @importFrom assertthat assert_that
#' @examples
#' data("bullets")
#' land2_3 <- bullets$sigs[bullets$bulletland == "2-3"][[1]]
#' x <- land2_3$sig
#' 
#' segments <- get_segs(x, len = 50)
 
get_segs <- function(x, len = 50){
  
  assert_that(is.numeric(x), is.numeric(len))

  idx <- 1:length(x)
  idx[is.na(x)] <- NA

  x.na.count <- .Call(na_trim_c, x)
  xx <- x[(x.na.count[1] + 1) : (length(x) - x.na.count[2])]
  idx <- idx[(x.na.count[1] + 1) : (length(x) - x.na.count[2])]
  # xx <- na.trim(x)
  # idx <- na.trim(idx)
  
  assert_that(!is.na(idx[1]), !is.na(idx[length(idx)]))
  
  idx <- idx[1]:idx[length(idx)]
  
  segs <- split(xx, ceiling(seq_along(xx)/len)) 
  index <- split(idx, ceiling(seq_along(xx)/len))
  
  check_length <- sapply(segs, length) == len
  
  return(list(segs = segs[check_length], index = index[check_length], x = x))
}


#' Change the sacle of a segment
#'
#' In order to identify the congruent registration position of a basis segment,
#' the length of the basis segment will be doubled to compute the correlation curve.
#' `get_seg_scale` computes the increased segment, which has the same center 
#' as the basis segment.
#' @param segments list with basis segments and their corresponding indices in the original profile, obtianed by `get_segs()`
#' @param nseg integer. `nseg` = 3: increase the length of the third basis segment.
#' @param scale integer. The scale of the increased segment. 
#'                      `scale` = 1: the length remains the same;
#'                      `scale` = 2: the length will be doubled. If `len` = 50, the length of the returned segment will be 100;
#'                      `scale` = 3: the length will be doubled twice. If `len` = 50, the length of the returned segment will be 200.
#'                              
#'
#' @return list consisting of 
#' * `aug_seg`: the increased segment 
#' * `aug_idx`: the corresponding indices in the profile
#' @export
#' @importFrom stats median
#' @importFrom assertthat assert_that
#'
#' @examples
#' data("bullets")
#' land2_3 <- bullets$sigs[bullets$bulletland == "2-3"][[1]]
#' x <- land2_3$sig
#' 
#' segments <- get_segs(x, len = 50)
#' seg5_scale3 <- get_seg_scale(segments, nseg = 5, scale = 3)
get_seg_scale <- function(segments, nseg, scale = 2){
  
  assert_that(is.numeric(nseg), is.numeric(scale))
  
  x <- segments$x
  idx <- segments$index[[nseg]]
  
  assert_that( !anyNA(idx) )
  
  ct <- floor(median(idx, na.rm = TRUE))
  unitt <- max(idx, na.rm = TRUE) - ct
  ############# ???
  # cut at the max or min
  min.idx <- max(ct - unitt * 2^(scale-1), 1, na.rm = TRUE)
  max.idx <- min(ct + unitt * 2^(scale-1), length(x), na.rm = TRUE)
  
  
  return(list(aug_seg=x[min.idx:max.idx], aug_idx=min.idx:max.idx))
}