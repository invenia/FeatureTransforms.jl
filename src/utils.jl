
_to_vec(x::AbstractArray) = x
_to_vec(x::Tuple) = x
_to_vec(x::Nothing) = x
_to_vec(x) = [x]

_to_mat(x::Vector) = hcat(x)
_to_mat(x::Vector{<:Vector}) = reduce(hcat, x)
