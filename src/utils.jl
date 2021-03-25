
_to_vec(x::AbstractArray) = x
_to_vec(x::Tuple) = x
_to_vec(x::Nothing) = x
_to_vec(x) = [x]
