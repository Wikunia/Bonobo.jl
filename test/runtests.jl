using Bonobo
using Test

using JuMP
using Cbc

const BB = Bonobo
    

@testset "Bonobo.jl" begin
    include("end2end/mip.jl")
end
