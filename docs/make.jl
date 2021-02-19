using Transforms
using Documenter

makedocs(;
    modules=[Transforms],
    authors="Invenia Technical Computing Corporation",
    repo="https://github.com/invenia/Transforms.jl/blob/{commit}{path}#L{line}",
    sitename="Transforms.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://invenia.github.io/Transforms.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
    strict=true,
    checkdocs=:exports,
)

deploydocs(;
    repo="github.com/invenia/Transforms.jl",
    devbranch = "main",
    push_preview = true,
)
