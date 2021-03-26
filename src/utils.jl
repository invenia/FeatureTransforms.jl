_to_vec(x::AbstractArray) = x
_to_vec(x::Tuple) = x
_to_vec(x::Nothing) = x
_to_vec(x) = [x]

_get_cols(table) = propertynames(Tables.columns(table))

_to_table(x, ::Nothing) = Tables.table(x)  # so that we use the defaults in Tables.table
_to_table(x, header) = Tables.table(x, header=header)
