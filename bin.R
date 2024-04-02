# having problems merging so I thought I'd start with a dataset that's just a df of roadnames
just_names <- as.data.frame(roads) |> select(
  name_1
) |>
  head(300000)
attr(just_names, "sf_column") <- NULL
attr(just_names, "na.action") <- NULL
attr(just_names, "agr") <- NULL
just_names <- just_names |> mutate(
  Test = 1
)
