# This file is part of the ValidatedNumerics.jl package; MIT licensed

# The order in which files are included is important,
# since certain things need to be defined before others use them

## Interval type

immutable Interval{T<:Real} <: Real
    lo :: T
    hi :: T

    function Interval(a::Real, b::Real)

        if a > b
            (isinf(a) && isinf(b)) && return new(a, b)  # empty interval = [∞,-∞]

            throw(ArgumentError("Must have a ≤ b to construct Interval(a, b)."))
        end

        new(a, b)
    end
end


## Outer constructors

Interval{T<:Real}(a::T, b::T) = Interval{T}(a, b)
Interval{T<:Real}(a::T) = Interval(a, a)
Interval(a::Tuple) = Interval(a...)
Interval{T<:Real, S<:Real}(a::T, b::S) = Interval(promote(a,b)...)

## Concrete constructors for Interval, to effectively deal only with Float64,
# BigFloat or Rational{Integer} intervals.
Interval{T<:Integer}(a::T, b::T) = Interval(float(a), float(b))
Interval{T<:Irrational}(a::T, b::T) = Interval(float(a), float(b))

eltype{T<:Real}(x::Interval{T}) = T


## Include files
include("special.jl")
include("macros.jl")
include("conversion.jl")
include("precision.jl")
include("arithmetic.jl")
include("functions.jl")
include("trigonometric.jl")
include("hyperbolic.jl")


# Syntax for intervals

a..b = @interval(a, b)

macro I_str(ex)  # I"[3,4]"
    @interval(ex)
end

a ± b = (a-b)..(a+b)  


## Output

function basic_show(io::IO, a::Interval)
    if isempty(a)
        output = "∅"
    else
        output = "[$(a.lo), $(a.hi)]"
        output = replace(output, "inf", "∞")
        output = replace(output, "Inf", "∞")

        output
    end

    print(io, output)
end

show(io::IO, a::Interval) = basic_show(io, a)
show(io::IO, a::Interval{BigFloat}) = ( basic_show(io, a); print(io, subscriptify(precision(a.lo))) )

function subscriptify(n::Int)
    subscript_digits = [c for c in "₀₁₂₃₄₅₆₇₈₉"]
    dig = reverse(digits(n))
    join([subscript_digits[i+1] for i in dig])
end
