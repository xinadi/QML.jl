using QML
using Test
using BenchmarkTools

function bench_sum_variant(n)
    result = Ref(0.0)
    for i in 1:n
        QML.__test_add_int!(result, QML.QVariant(Float64(i)))
    end
    return result[]
end

function bench_return_variant(n)
    result = 0.0
    for i in 1:n
        result += QML.__test_make_qvariant(Float64(i)).value
    end
    return result
end

@test bench_sum_variant(100) == sum(1:100)
@test bench_return_variant(100) == sum(1:100)
println("Variant sum timing: ")
@btime bench_sum_variant(100)
println("Variant return timing: ")
@btime bench_return_variant(100)
