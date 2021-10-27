using Bonobo
using Documenter

DocMeta.setdocmeta!(Bonobo, :DocTestSetup, :(using Bonobo); recursive=true)

makedocs(;
    modules=[Bonobo],
    authors="Ole Kroeger <o.kroeger@opensourc.es> and contributors",
    repo="https://github.com/Wikunia/Bonobo.jl/blob/{commit}{path}#{line}",
    sitename="Bonobo.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://Wikunia.github.io/Bonobo.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/Wikunia/Bonobo.jl",
    devbranch="main",
)
