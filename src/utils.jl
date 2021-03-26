_to_vec(x::AbstractArray) = x
_to_vec(x::Tuple) = x
_to_vec(x::Nothing) = x
_to_vec(x) = [x]

_get_cols(table) = propertynames(Tables.columns(table))

_to_table(x, ::Nothing) = Tables.table(x)
_to_table(x, header) = Tables.table(x, header=header)
