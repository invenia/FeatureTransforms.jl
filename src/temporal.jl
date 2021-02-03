"""
    CustomTransform <: Transform

Apply the function passed in to CustomTransform as the transform.
"""
struct HoD <: Transform end

function _apply!(x, ::HoD; kwargs...)
    x[:] = hour.(x)
    return x
end

# struct HoW() <: Transform end

# function _apply!(x, ::HoD; kwargs...)

#     function hour_of_week(x)
#         # TODO: this doesn't handle DST
#         return dayofweek(x) * 24 + hour(x)
#     end
#     x[:] = hour_of_week.(x)
#      return x
# end
