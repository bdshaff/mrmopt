# Expose a hierarchical fit as a list of single-curve models for optimization

Converts a `mrmfit_hier` object into a named list of lightweight,
single-curve model views — one per unit at a chosen level of the
hierarchy — that can be passed directly to
[`opt_mix`](https://bdshaff.github.io/mrmopt/reference/opt_mix.md). This
is how optimization is performed "at any level" of the hierarchy: pass
the subtype level to optimize across sub-types, the innermost level to
optimize across individual units, and so on.

## Usage

``` r
as_mrmfit_list(mrm, level = NULL)
```

## Arguments

- mrm:

  A fitted `mrmfit_hier` object from
  [`fit_response_hier`](https://bdshaff.github.io/mrmopt/reference/fit_response_hier.md).

- level:

  Optional cumulative grouping term naming the level to expand (e.g.
  `"subtype"` or `"subtype:station"`). Defaults to the innermost level.

## Value

A named list of `mrmfit_hier_unit` objects (names are unit ids),
suitable as the `mrms` argument to
[`opt_mix`](https://bdshaff.github.io/mrmopt/reference/opt_mix.md).

## Details

Each element is a list of class `mrmfit_hier_unit` (which also inherits
`"mrmfit"`) carrying that unit's composed posterior draws, response
curve, summary, and parameters in original data units, plus the shared
global scaling metadata. Both `opt_mix` methods work: the point path
reads the unit's parameters; the posterior path reads its draws.

## See also

[`opt_mix`](https://bdshaff.github.io/mrmopt/reference/opt_mix.md),
[`fit_response_hier`](https://bdshaff.github.io/mrmopt/reference/fit_response_hier.md)
