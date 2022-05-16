"""
    fit!(transform::Transform, data::AbstractArray; dims=:, inds=:)
    fit!(transform::Transform, table, [cols])

Fit the transform to the given data. By default _all the data_ is considered.
This can be restricted to certain slices via the keyword arguments (see below).

# `AbstractArray` keyword arguments
* `dims=:`: the dimension along which to take the `inds` slices. Default uses all dims.
* `inds=:`: the indices to use in computing the statistics. Default uses all indices.

# `Table` keyword arguments
* `cols`: the columns to use in computing the statistics. Default uses all columns.

!!! note
    If you want to transform your data consistently you should use the same `inds`, `dims`,
    or `cols` keywords when calling `apply`. Otherwise, `apply` might rescale the wrong
    data or throw an error.
"""
fit!(t::Transform, args...; kwargs...) = return t
