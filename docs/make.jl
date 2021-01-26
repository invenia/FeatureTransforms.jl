using Transform
using Documenter

makedocs(;
    modules=[Transform],
    authors="Invenia Technical Computing Corporation",
    repo="https://github.com/invenia/Transform.jl/blob/{commit}{path}#L{line}",
    sitename="Transform.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://invenia.github.io/Transform.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
    strict=true,
    checkdocs=:exports,
)

deploydocs(;
    repo="github.com/invenia/Transform.jl",
)
