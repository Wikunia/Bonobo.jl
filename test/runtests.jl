using Bonobo
using Test

using JuMP
using Cbc

const BB = Bonobo
    

@testset "End2End tests" begin
    include("end2end/mip.jl")
end

@testset "Unit tests" begin
    include("unit/add_node.jl")
end