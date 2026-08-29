```@meta
CurrentModule = GEM
```

# GEM.jl

> **Final standalone release.** GEM.jl has been integrated into
> `GeneralEquilibriumModeling.jl`. Active development now takes place there,
> where this low-level framework is available as the
> `GeneralEquilibriumModeling.GEM` submodule.

GEM formulates and solves general equilibrium models as mixed complementarity
problems. Consumers, producers, and other economic agents are represented
through a unified net-supply framework, while agent optimality conditions,
market-clearing conditions, and auxiliary equilibrium equations are assembled
into a single equilibrium system.

GEM exposes low-level net-supply, complementarity-condition,
model-construction, and solver interfaces. Direct use of GEM is useful when
fine-grained control is needed over agent net supplies, complementarity
conditions, variable bounds, or custom equilibrium structures.

GEM supports marginal-utility consumers, automatic revenue-expenditure-balance
conditions, production-stationarity conditions, cost-minimization KKT
conditions, multiple production activities, joint production, cross-agent
observable variables, and endogenous auxiliary variables. Commodity prices may
have nonnegative, nonpositive, free, or user-defined bounds. The resulting
complementarity problem is constructed with JuMP and solved using PATH.

## Main features

- Unified net-supply representation for economic agents
- Unit and total revenue-expenditure-balance condition rules
- Marginal-utility consumer conditions
- Production-stationarity conditions
- Cost-minimization KKT conditions
- Multiple activity levels and joint-production technologies
- Cross-agent observable equilibrium variables
- Endogenous auxiliary variables and auxiliary equations
- Flexible commodity-price bounds, including free and negative prices
- JuMP-based MCP construction and PATH solution
- Structured equilibrium results and residual diagnostics

## Basic workflow

1. Define consumers, producers, and other net-supply agents.
2. Assemble agents, commodities, the numeraire, and optional auxiliary
   equations into an equilibrium model.
3. Solve the mixed complementarity problem.
4. Inspect equilibrium prices, agent variables, net supplies, residuals, and
   solver diagnostics.

## Key API entry points

- [`NetSupplyEquilibriumModel`](@ref)
- [`NetSupplyAgent`](@ref)
- [`UnitRevenueExpenditureBalanceConditions`](@ref)
- [`TotalRevenueExpenditureBalanceConditions`](@ref)
- [`MarginalUtilityConsumerConditions`](@ref)
- [`ProductionStationarityConditions`](@ref)
- [`CostMinimizationKKTConditions`](@ref)
- [`ProductionNetSupply`](@ref)
- [`EquilibriumResult`](@ref)
