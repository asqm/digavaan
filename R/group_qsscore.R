#' Calculate quality of latent variable sum scores by groups
#'
#' @param model A lavaan model
#' @param groups A character vector specifying which groups to filter in the final model
#'
#' @return A data frame
#' @export
group_qsscore <- function(model, groups) {
  # Grab original data and name columns
  # I don't calculate the variance yet because
  # I need to know why variables were composing the
  # composite score.
  df_names <- lavaan::lavNames(model)
  cnt_dt <- lapply(lavaan::inspect(model, "data"), todf, some_names = df_names)
  
  # Get all the estimates, separate by country
  # and name the list w/ country names
  pooled_est <- summary_lavaan(model, standardized = TRUE)$estimates
  sep_est <- split(pooled_est, pooled_est$group)
  names(sep_est) <- names(cnt_dt)
  
  latent_sep <- lapply(sep_est, country_latent)
  
  cnt_quality <- Map(vec_subsetting_lat, latent_sep, cnt_dt)
  final_df <- cbind(groups = names(cnt_quality), Reduce(rbind, cnt_quality))
  
  if (!missing(groups)) {
    final_df <- final_df[final_df$groups %in% groups, ]
  }
  
  final_df
}

#' Calculate quality of a composite score
#' @param lambda Standardized estimates from a model
#'
#' @param var_data Variance of the actual data
#' @param variance_cs Variance of the composite score
#'
#' @return A numeric vector of length 1
#' @export
q_sscore <- function(lambda, var_data, variance_cs) {
  1 - (sum((1 - (lambda^2)) * var_data) * (1 / variance_cs))
}


