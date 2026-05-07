## Data Validation
```{r}
library(openxlsx)

# check for any other positions than the standard ones
final_table |> 
  select(unique(Position))

# check for any duplicated names within the final table
final_table$Player[duplicated(final_table$Player)]

# convert salary into an integer for better chart/graph making in tableau
parse_number(final_table$Salary)

final_table$Salary <- as.numeric(parse_number(final_table$Salary))

# create final table excel sheet
write.xlsx(final_table, "ISA401_final_table.csv", rowNames = FALSE)
```
