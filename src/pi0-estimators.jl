## pi_0 estimators ##

## https://github.com/StoreyLab/qvalue/blob/master/R/pi0est.R
function storey_pi0{T<:FloatingPoint}(pValues::Vector{T}, lambda::T)
    validPValues(pValues)
    pi0 = (sum(pValues .>= lambda)) / (1-lambda) / length(pValues)
    pi0 = min(pi0, 1.)
    return pi0
end


function bootstrap_pi0{T<:FloatingPoint}(pValues::Vector{T}, lambda::Vector{T} = [0.05:0.05:0.95], q::T = 0.1)
    validPValues(pValues)
    #validPValues(lambda) ## TODO check bounds
    n = length(pValues)
    if !issorted(lambda)
        sort!(lambda)
    end
    pi0 = [mean(pValues .>= l) / (1-l) for l in lambda]
    min_pi0 = quantile(pi0, q)
    ## in a loop? relevant only for very large vectors 'lambda'
    w = [sum(pValues .>= l) for l in lambda]
    mse = (w ./ (n .^ 2 .* (1-lambda) .^ 2 )) .* (1-w/n) + (pi0-min_pi0) .^2
    pi0 = min(pi0[indmin(mse)], 1.)
    pi0
end

#pval = [0.01:0.05:0.91] ## consistent with 'qvalue::pi0est'
#bootstrap_pi0(pval)


function lsl_pi0_vec{T<:FloatingPoint}(pValues::Vector{T})
    n = length(pValues)
    ## sorting requires most time
    if !issorted(pValues)
        sort!(pValues)
    end
    s = (1 - pValues) ./ (n - [1:n] + 1)
    d = diff(s) .< 0
    idx = findfirst(d) + 1
    pi0 = min( 1/s[idx] + 1, n ) / n
    return(pi0)
end


function lsl_pi0{T<:FloatingPoint}(pValues::Vector{T})
    n = length(pValues)
    ## sorting requires most time
    if !issorted(pValues)
        sort!(pValues)
    end
    s0 = lsl_slope(1, n, pValues)
    sx = 0.
    for i in 2:n
        s1 = lsl_slope(i, n, pValues)
        if (s1 - s0) < 0.
            sx = s1
            break
        end
        s0 = s1
    end
    pi0 = min( 1/sx + 1, n ) / n
    return(pi0)
end

function lsl_slope{T<:FloatingPoint}(i::Int, n::Int, pval::Vector{T})
    s = (1 - pval[i]) / (n - i + 1)
    return s
end


# function smooth_pi0{T<:FloatingPoint}(pValues::Vector{T}, lambda = 0.05:0.05:0.95)
#     validPvalues(pValues)
#     #validPvalues(lambda) ## TODO check bounds
#     n = length(pValues)
#     ## CHCK: Only for smoothing (due to cubic spline)?
#     if length(lambda) < 4
#         throw(ArgumentError())
#     end
#     if !issorted(lambda)
#         throw(DomainError())
#     end
#     pi0 = Float64[mean(pValues .>= l) / (1-l) for l in lambda]
#     ##CoordInterpGrid(lambda, pi0, BCnil, InterpCubic) ## broken
# end