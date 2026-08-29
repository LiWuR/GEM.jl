# GEM.jl

> [!IMPORTANT]
> **GEM.jl has been integrated into [GeneralEquilibriumModeling.jl](https://github.com/LiWuR/GeneralEquilibriumModeling.jl).**
>
> Version **0.2.0** is the final standalone synchronization release of GEM.jl.
> Active development now takes place in `GeneralEquilibriumModeling.jl`, where
> the low-level framework is available as the `GeneralEquilibriumModeling.GEM`
> submodule. This repository is retained for historical reference and is not
> intended for further feature development.

[![CI](https://github.com/LiWuR/GEM.jl/actions/workflows/CI.yml/badge.svg)](https://github.com/LiWuR/GEM.jl/actions/workflows/CI.yml)
[![Documentation](https://img.shields.io/badge/docs-dev-blue.svg)](https://LiWuR.github.io/GEM.jl/dev/)

## Migration

New projects should install and load `GeneralEquilibriumModeling.jl` rather than
the standalone GEM package.

```julia
import Pkg
Pkg.add(url = "https://github.com/LiWuR/GeneralEquilibriumModeling.jl")
```

Then load the low-level GEM framework with

```julia
using GeneralEquilibriumModeling
using GeneralEquilibriumModeling.GEM
```

Code written against the final standalone GEM release used

```julia
using GEM
```

The standalone repository is retained to preserve the package history and the
final pre-integration state.

## Overview

GEM is the low-level general-equilibrium framework for representing and solving
equilibrium systems through net-supply agents and mixed complementarity
conditions. It provides the equilibrium representation, equilibrium-variable
references, agent condition rules, auxiliary variables and equations, JuMP
construction, PATH solver interface, and structured equilibrium results.

The current implementation is maintained as the `GEM` submodule of
`GeneralEquilibriumModeling.jl`. The higher-level `GEMB` submodule provides
economic specifications and model-building interfaces on top of GEM.

## PATH solver and licensing

GEM uses PATHSolver.jl to solve mixed complementarity problems. PATHSolver.jl is
an open-source Julia wrapper, while the underlying PATH solver is separate
software with its own licensing terms.

Without a PATH license, PATH can solve problems with at most **300 variables**
and **2000 Jacobian nonzeros**. Larger models require a valid PATH license.

GEM does not include or distribute a PATH license. A license can be configured
through the `PATH_LICENSE_STRING` environment variable or directly through
PATHSolver.

## Documentation

The historical standalone documentation is hosted at:

https://LiWuR.github.io/GEM.jl/dev/

Current development and documentation belong to:

https://github.com/LiWuR/GeneralEquilibriumModeling.jl

## License

GEM.jl is released under the MIT License. See [`LICENSE`](LICENSE).

## Development note

Parts of the implementation and documentation have been developed with
assistance from generative-AI tools. The maintainer reviews, tests, and takes
responsibility for the code and documentation included in the package.
