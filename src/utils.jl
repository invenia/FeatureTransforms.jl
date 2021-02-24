"""
    _try_copy(data)

Try to `copy` the data, fallback to `deepcopy` if not supported.
Not all objects support `copy`, but we should use it to improve performance if possible.
"""
function _try_copy(data)
    try
        copy(data)
    catch
        deepcopy(data)
    end
end

_to_vec(x::AbstractArray) = x
_to_vec(x::Tuple) = x
_to_vec(x::Nothing) = x
_to_vec(x) = [x]
