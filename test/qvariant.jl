using CxxWrap
using QML
using Test
using BenchmarkTools

function bench_sum_julia(n)
    result = 0.0
    for i in 1:n
        result += i
    end
    return result
end

function bench_sum_variant(n)
    result = Ref(0.0)
    for i in 1:n
        QML.__test_add_double!(result, QVariant(Float64(i)))
    end
    return result[]
end

function bench_sum_variant_ref(n)
    result = Ref(0.0)
    var = QVariant(0.0)
    varref = CxxRef(var)
    for i in 1:n
        QML.setValue(varref, Float64(i))
        QML.__test_add_double_ref!(result, varref)
    end
    return result[]
end

function bench_return_variant(n)
    result = 0.0
    for i in 1:n
        var = (QML.__test_return_qvariant(Float64(i)))::QML.QVariantAllocated
        result += QML.value(Float64, var)
    end
    return result
end

function bench_return_variant_ref(n)
    result = 0.0
    for i in 1:n
        result += QML.value(Float64, QML.__test_return_qvariant_ref(Float64(i)))
    end
    return result
end

let testvars = [1, 2.0, QString("test")]
    vartype(x) = typeof(x)
    vartype(x::QString) = QString
    for x in testvars
        @test QML.value(vartype(x), QVariant(x)) == x
    end
end


# let
#     const N = 100

#     @test bench_sum_julia(N) == sum(1:N)
#     @test bench_sum_variant(N) == sum(1:N)
#     @test bench_sum_variant_ref(N) == sum(1:N)
#     @test bench_return_variant(N) == sum(1:N)
#     println("Julia sum timing:")
#     @btime bench_sum_julia(N)
#     println("Variant sum timing:")
#     @btime bench_sum_variant(N)
#     println("Variant sum ref timing:")
#     @btime bench_sum_variant_ref(N)
#     println("Variant return timing:")
#     @btime bench_return_variant(N)
#     println("Variant return ref timing:")
#     @btime bench_return_variant_ref(N)
# end

# Reference result (2018 Macbook Air)
# Julia sum timing:
#   78.781 ns (0 allocations: 0 bytes)
# Variant sum timing:
#   13.180 μs (101 allocations: 1.58 KiB)
# Variant sum ref timing:
#   3.103 μs (3 allocations: 48 bytes)
# Variant return timing:
#   10.306 μs (100 allocations: 1.56 KiB)
# Variant return ref timing:
#   1.637 μs (0 allocations: 0 bytes)