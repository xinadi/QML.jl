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
        qvar = QVariant(x)
        @test QML.value(qvar) == x
        @test QML.type(qvar) == vartype(x)
        @test string(qvar) == "QVariant of type $(vartype(x)) with value $x"
    end
end

let x = 1.5
    qvar = QVariant(x)
    @test QML.value(qvar) == 1.5
    @test QML.value(Float64,qvar) == 1.5
    @test QML.value(Int,qvar) == 2
    @test QML.value(QString,qvar) == "1.5"
end

let x = true
    qvar = QVariant(x)
    @test QML.value(qvar) == true
    @test QML.value(Bool,qvar) == true
    @test QML.value(Int,qvar) == 1
    @test QML.value(QString,qvar) == "true"
end

let qvl = QML.QVariantList()
    push!(qvl, 3)
    @test QML.value(qvl[1]) == 3
    @test length(qvl) == 1
    result = 0
    for x in qvl
        result += QML.value(x)
    end
    @test result == 3
end

nb_created = 0
nb_finalized = 0

mutable struct FooVariant
    x::Int
    function FooVariant(x)
        global nb_created += 1
        return new(x)
    end
end

foovar = FooVariant(42)
finalizer(foovar) do y
    y.x = 0
    global nb_finalized += 1
end
qfoovar = QVariant(foovar)
foovar = nothing
GC.gc(); GC.gc(); GC.gc()
@test nb_created == 1
@test nb_finalized == 0
@test QML.value(qfoovar).x == 42
qfoovar = nothing
GC.gc(); GC.gc(); GC.gc()
@test nb_created == 1
@test nb_finalized == 1

let N = 100
    @test bench_sum_julia(N) == sum(1:N)
    @test bench_sum_variant(N) == sum(1:N)
    @test bench_sum_variant_ref(N) == sum(1:N)
    @test bench_return_variant(N) == sum(1:N)
    println("Julia sum timing:")
    @btime bench_sum_julia($N)
    println("Variant sum timing:")
    @btime bench_sum_variant($N)
    println("Variant sum ref timing:")
    @btime bench_sum_variant_ref($N)
    println("Variant return timing:")
    @btime bench_return_variant($N)
    println("Variant return ref timing:")
    @btime bench_return_variant_ref($N)
end

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