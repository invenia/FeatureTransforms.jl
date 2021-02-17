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

function invert_dims(A::AbstractArray, dims)
    ndims(A) == 1 && return dims
    # TODO: support named dims
    inverted_dims = setdiff(1:ndims(A), dims)
    if length(inverted_dims) == 1
        inverted_dims = inverted_dims[1]
    end

    return inverted_dims
end
