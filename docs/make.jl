using GEM
using Documenter
import Glob


# ================================================================
# Documentation-generation helpers
# ================================================================

"""
    clear_generated_markdown_pages(directory)

Remove generated Markdown pages from `directory`.

The `docs/src/api` and `docs/src/examples` directories are generated from the
currently loaded GEM modules and the current contents of `examples/`.
Removing old generated pages before rebuilding prevents Documenter from
evaluating stale pages that refer to deleted modules or removed examples.
"""
function clear_generated_markdown_pages(
    directory::AbstractString,
)
    mkpath(directory)

    removed_pages =
        String[]

    for path in readdir(
        directory;
        join=true,
    )
        isfile(path) ||
            continue

        endswith(
            lowercase(path),
            ".md",
        ) || continue

        rm(
            path;
            force=true,
        )

        push!(
            removed_pages,
            path,
        )
    end

    return removed_pages
end


# ================================================================
# Recursively discover GEM submodules
# ================================================================

"""
    get_all_submodules(mod, found=Dict{String,Module}())

Return a dictionary containing `mod` and all loaded submodules that belong to
the GEM namespace.
"""
function get_all_submodules(
    mod::Module,
    found::Dict{String,Module}=Dict{String,Module}(),
)
    # Register the current module before traversing its bindings.
    fullname_string =
        join(
            fullname(mod),
            ".",
        )

    haskey(
        found,
        fullname_string,
    ) && return found

    found[fullname_string] =
        mod

    # Inspect all defined bindings in the current module.
    for name in names(
        mod;
        all=true,
    )
        # Skip compiler-generated and module-internal bindings.
        startswith(
            string(name),
            "#",
        ) && continue

        name == :eval &&
            continue

        name == :include &&
            continue

        isdefined(
            mod,
            name,
        ) || continue

        object =
            getfield(
                mod,
                name,
            )

        object isa Module ||
            continue

        # Traverse only modules that belong to the GEM namespace.
        object_fullname =
            join(
                fullname(object),
                ".",
            )

        if object_fullname == "GEM" ||
           startswith(
               object_fullname,
               "GEM.",
           )
            get_all_submodules(
                object,
                found,
            )
        end
    end

    return found
end


# Collect and sort all currently loaded GEM modules by fully qualified name.
all_modules =
    get_all_submodules(
        GEM,
    )

modules_to_document =
    collect(
        all_modules,
    )

sort!(
    modules_to_document;
    by=first,
)

println(
    "Discovered $(length(modules_to_document)) GEM modules:",
)

for (name, _) in modules_to_document
    println(
        "  - ",
        name,
    )
end


# ================================================================
# Generate example pages
# ================================================================

examples_directory =
    joinpath(
        @__DIR__,
        "..",
        "examples",
    )

examples_source_directory =
    joinpath(
        @__DIR__,
        "src",
        "examples",
    )

# These pages are generated artifacts. Remove pages left by examples that
# have been renamed or deleted before regenerating the current set.
removed_example_pages =
    clear_generated_markdown_pages(
        examples_source_directory,
    )

if !isempty(
    removed_example_pages,
)
    println(
        "Removed $(length(removed_example_pages)) stale/generated example pages.",
    )
end

# Continue building the manual even when the package has no examples directory.
julia_files =
    if isdir(
        examples_directory,
    )
        Glob.glob(
            "*.jl",
            examples_directory,
        )
    else
        @warn(
            "Examples directory does not exist; no example pages will be generated.",
            examples_directory,
        )

        String[]
    end

sort!(
    julia_files,
)

example_pages =
    Pair{String,String}[]

for julia_file in julia_files
    # Derive the page title and output filename from the Julia source filename.
    base_name =
        basename(
            julia_file,
        )

    name_without_extension =
        splitext(
            base_name,
        )[1]

    markdown_filename =
        "$(name_without_extension).md"

    markdown_filepath =
        joinpath(
            examples_source_directory,
            markdown_filename,
        )

    julia_content =
        read(
            julia_file,
            String,
        )

    # Display the complete example as source code without executing it.
    # Four backticks allow embedded docstrings to contain triple-backtick blocks.
    markdown_content = """
    # $(name_without_extension)

    Source file: `examples/$(base_name)`

    ````julia
    $(julia_content)
    ````
    """

    write(
        markdown_filepath,
        markdown_content,
    )

    push!(
        example_pages,
        name_without_extension =>
            "examples/$(markdown_filename)",
    )
end


# ================================================================
# Generate API reference pages
# ================================================================

api_source_directory =
    joinpath(
        @__DIR__,
        "src",
        "api",
    )

# API pages are also generated artifacts. Removing all old pages before
# regeneration prevents stale @autodocs blocks from referring to modules that
# no longer exist after a package refactor.
removed_api_pages =
    clear_generated_markdown_pages(
        api_source_directory,
    )

if !isempty(
    removed_api_pages,
)
    println(
        "Removed $(length(removed_api_pages)) stale/generated API pages.",
    )
end

api_subpages =
    Pair{String,String}[]

for (module_name, _) in modules_to_document
    # Convert the fully qualified module name into a filesystem-safe filename.
    filename =
        replace(
            module_name,
            "." => "_",
        ) *
        ".md"

    filepath =
        joinpath(
            api_source_directory,
            filename,
        )

    # Include the module docstring as well as its documented public objects.
    content = """
    # `$(module_name)`

    ```@autodocs
    Modules = [$(module_name)]
    Order = [:module, :type, :function, :macro, :constant]
    ```
    """

    write(
        filepath,
        content,
    )

    push!(
        api_subpages,
        module_name =>
            "api/$(filename)",
    )
end


# ================================================================
# Assemble the navigation tree
# ================================================================

pages_list =
    Any[
        "Home" => "index.md",
    ]

if !isempty(
    api_subpages,
)
    push!(
        pages_list,
        "API Reference" =>
            api_subpages,
    )
end

if !isempty(
    example_pages,
)
    push!(
        pages_list,
        "Examples" =>
            example_pages,
    )
end


# ================================================================
# Build the documentation
# ================================================================

makedocs(
    modules = [
        mod
        for (_, mod) in modules_to_document
    ],

    format = Documenter.HTML(
        prettyurls =
            get(
                ENV,
                "CI",
                "false",
            ) == "true",
    ),

    sitename = "GEM.jl Documentation",
    authors = "Wu Li",

    # Update the owner or repository name here if the GitHub remote changes.
    repo = Documenter.Remotes.GitHub(
        "LiWuR",
        "GEM.jl",
    ),

    pages = pages_list,

    # Keep selected documentation warnings non-fatal during development.
    warnonly = [
        :missing_docs,
        :cross_references,
        :eval_block,
    ],
)

# Deploy documentation from GitHub Actions.
deploydocs(
    repo = "github.com/LiWuR/GEM.jl.git",
    devbranch = "main",
)
