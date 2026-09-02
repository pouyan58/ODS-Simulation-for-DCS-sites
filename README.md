# DCS ODS Spot Beam Simulator

## Purpose and scope

This MATLAB package estimates inner and outer operational data sharing
(ODS) angles for protected Direct Readout Ground Station (DCS) receivers.
Angles are measured from the protected DCS antenna boresight toward an
instantaneous LEO satellite direction; they are not measured from zenith.

The model combines LEO orbit geometry, ten independently steered spot-beam
positions per satellite, traffic and frequency reuse, aggregate received
interference, receiver antenna response, atmospheric and clutter loss,
prediction latency, and per-beam ODS actions. It searches for the smallest
modeled inner/outer pair meeting the configured interference-to-noise
criterion.

This is a public engineering sensitivity model. It is not a coordination
determination, spectrum authorization, or representation of an operator's
actual constellation, scheduler, antenna mask, traffic, or ODS performance.

## Release baseline

Package metadata identifies this release as `1.0.0`. The fixed public
baseline uses:

- 10 spot-beam steering positions per LEO satellite;
- a 60-degree satellite off-nadir field of regard;
- a 2-degree satellite-view half-power radius per spot;
- 30 dBW/MHz maximum boresight EIRP density per active spot;
- four 5-MHz carriers, with 3 of 10 positions assigned to the carrier
  containing the protected 1679.9 MHz receiver frequency;
- at most one simultaneous protected-carrier spot per satellite;
- a configurable geographic no-user/beam-center zone, defaulting to 30 km
  around the protected site;
- outer-zone retasking to a feasible beam center at least 180 km from the
  protected receiver;
- protected-carrier shutdown inside the inner ODS angle;
- all scheduled eligible satellites aggregated in linear power;
- a -6 dB I/N protection criterion with zero modeled exceedance;
- geometric LEO visibility down to the local horizon; and
- no minimum operational outer-angle floor.

The 60-degree value is a steering field, not an individual spot beamwidth.
The ten stored positions are a snapshot steering lattice and do not assert
continuous coverage of the complete field of regard.

## Requirements

- MATLAB R2025b or a compatible later release.
- Satellite Communications Toolbox for `satelliteScenario`, `walkerDelta`,
  and satellite state generation.
- The supplied site-specific ITU-R P.618 lookup CSV files in `data/`.
- MathWorks ITU digital maps only when regenerating P.618 lookup tables.

Normal simulations use the included lookup tables and require no internet
connection.

## Quick start

Add the package folder to the MATLAB path:

```matlab
packageFolder = "C:\path\to\DCS_ODS_Spot_Beam_Simulator";
addpath(packageFolder)
```

Display the 12-option menu and run one case interactively:

```matlab
results = runDcsOdsSpotBeamSimulator();
```

Run one case by menu number, `SiteId`, or combined label:

```matlab
results = runDcsOdsSpotBeamSimulator(10);
results = runDcsOdsSpotBeamSimulator("wallops_va_goes_east");
results = runDcsOdsSpotBeamSimulator("Wallops, VA | GOES East");
```

Set a different geographic ZA radius without editing source code:

```matlab
results = runDcsOdsSpotBeamSimulator( ...
    "wallops_va_goes_east", ZaRadiusKm=50);
```

`ZaRadiusKm` is in kilometers and may be zero. It must remain below both the
configured 150 km calibration-ramp endpoint and the 180 km outer retask
distance. The setter updates the protected core, active-beam-center limit,
calibration-ramp start, metadata, and output path together. A custom run is
written to a ZA-tagged folder such as
`results_wallops_va_goes_east_za50km`, preserving the default 30 km result.

List available cases without running the simulation:

```matlab
sites = listDcsOdsSpotBeamCases();
```

Run all 12 cases:

```matlab
summary = runAllDcsOdsSpotBeamCases(ResumeCompleted=true);
```

Set `ResumeCompleted=false` to force recalculation. A saved result is resumed
only when its release ID, site, beam count, duration, time step, and Monte
Carlo count match the requested run.

## Supplied receiver and boresight catalog

The selector reads `data/DCS_Receivers.xlsx`, worksheet `Sheet1`.

| No. | Receiver | Satellite | Dish diameter | Feed height |
|---:|---|---|---:|---:|
| 1 | Fairmont, WV | GOES East | 16.4 m | 5.0 m |
| 2 | Fairmont, WV | GOES West | 16.4 m | 5.0 m |
| 3 | Fairmont, WV | GOES Backup | 16.4 m | 5.0 m |
| 4 | Sioux Falls, SD | GOES West | 8.1 m | 7.4 m |
| 5 | Sioux Falls, SD | GOES Backup | 8.1 m | 7.4 m |
| 6 | Sioux Falls, SD | GOES East | 8.1 m | 7.4 m |
| 7 | Suitland, MD | GOES East | 9.1 m | 24.0 m |
| 8 | Suitland, MD | GOES West | 9.1 m | 24.0 m |
| 9 | Suitland, MD | GOES Backup | 9.1 m | 24.0 m |
| 10 | Wallops, VA | GOES East | 16.4 m | 5.0 m |
| 11 | Wallops, VA | GOES West | 16.4 m | 5.0 m |
| 12 | Wallops, VA | GOES Backup | 16.4 m | 5.0 m |

The GEO longitude mapping is -75.2 degrees for GOES East, -137.0 degrees
for GOES West, and -104.7 degrees for GOES Backup. The model calculates the
local antenna boresight vector from the selected receiver coordinates and
GEO longitude.

Required workbook columns are:

- `GOES Receiver Site`
- `Latitude (deg)`
- `Longitude (deg)`
- `Satellite`
- `Antenna Diameter (m)`
- `Antenna Feed Height (m)`

Feed height is height above local ground, not surveyed geodetic height. The
baseline uses it as a geodetic-height proxy. Supply `GeodeticHeightM` when a
surveyed antenna-reference height is available.

## Verified full-run results

Every case used two simulated hours, 2-second samples, four Monte Carlo
realizations, and the fixed release assumptions above.

| Receiver | Boresight | Outer angle | Inner angle | Maximum I/N | Exceedance |
|---|---|---:|---:|---:|---:|
| Fairmont, WV | GOES East | 14.5 deg | 1.0 deg | -6.300 dB | 0% |
| Fairmont, WV | GOES West | 1.0 deg | 1.0 deg | -6.514 dB | 0% |
| Fairmont, WV | GOES Backup | 43.0 deg | 1.5 deg | -6.703 dB | 0% |
| Sioux Falls, SD | GOES West | 120.0 deg | 3.5 deg | -6.669 dB | 0% |
| Sioux Falls, SD | GOES Backup | 106.5 deg | 21.0 deg | -6.168 dB | 0% |
| Sioux Falls, SD | GOES East | 89.0 deg | 16.5 deg | -6.396 dB | 0% |
| Suitland, MD | GOES East | 100.0 deg | 9.0 deg | -6.295 dB | 0% |
| Suitland, MD | GOES West | 120.5 deg | 2.5 deg | -7.910 dB | 0% |
| Suitland, MD | GOES Backup | 112.0 deg | 3.5 deg | -7.747 dB | 0% |
| Wallops, VA | GOES East | 19.5 deg | 2.5 deg | -6.341 dB | 0% |
| Wallops, VA | GOES West | 1.5 deg | 1.5 deg | -7.560 dB | 0% |
| Wallops, VA | GOES Backup | 45.5 deg | 1.5 deg | -7.027 dB | 0% |

The complete machine-readable table is
`dcs_ods_spot_beam_all_12_results.csv`.

Outer angles greater than 90 degrees mean the modeled avoidance cone extends
past the plane perpendicular to boresight and covers most of the visible sky
on that side. These large results are conditional sensitivity outputs, not
recommended operational limits. They are especially dependent on the common
-27 dBi far-angle receive-pattern assumption, the strict zero-event rule,
traffic scheduling, and the 180 km retasking model.

## Default receiver model

| Parameter | Value |
|---|---:|
| Center frequency | 1679.9 MHz |
| Receiver bandwidth | 0.4 MHz |
| Noise temperature | 28 K |
| Protection criterion | -6 dB I/N |
| Allowed modeled exceedance | 0% |
| Antenna efficiency | 0.70 |
| Polarization mismatch loss | 0 dB |
| Implementation loss | 1 dB |

Thermal noise at the antenna-terminal reference plane is

```text
N_W   = k T B
N_dBm = 10 log10(N_W) + 30
```

The receive-pattern envelope follows ITU-R S.580-6, using the attached
APEREC015 Appendix 8 extension when `D/lambda < 50`. Peak gain is calculated
from diameter, efficiency, and wavelength. Beyond the S.580 far-angle
breakpoint, the release applies a -27 dBi override to every catalog receiver.
That common level is an unverified sensitivity assumption; measured
azimuth/elevation patterns should replace it for operational work.

## Constellation, spot beams, and traffic

| Shell | Altitude | Inclination | Satellites | Planes | Phasing |
|---|---:|---:|---:|---:|---:|
| DTC-53 | 340 km | 53 deg | 325 | 13 | 1 |
| DTC-43 | 355 km | 43 deg | 325 | 13 | 1 |

Every satellite has ten candidate steering positions inside a 60-degree
off-nadir field of regard. The common lattice is stored in
`evidence/beam_packing_layout.csv` and scaled for each shell altitude. Each
spot has a separately configured 2-degree satellite-view half-power radius.

The per-spot pattern uses the ITU-R S.1528-0 LEO reference envelope. Scan
loss follows projected-aperture cosine loss, with modeled power control that
maintains the same 30 dBW/MHz peak EIRP-density ceiling at every steering
position. An optional off-axis mask credit exists in configuration but is
zero in the public baseline.

Four contiguous 5-MHz carriers cover 1675-1695 MHz. Static four-color reuse
assigns three of the ten positions to the protected carrier. The traffic
model schedules at most one protected-carrier spot per satellite, using a
20% mean carrier duty cycle, 30-second mean on time, 120-second mean off
time, 60% mean scheduled load, and bounded load variation. Other carriers
are outside the protected receiver bandwidth and are not added to I/N.

Every visible satellite remains a potential contributor through the active
spot's main lobe or sidelobes. The program does not limit the aggregate to a
fixed number of closest or strongest satellites.

## Geographic zone and ODS actions

No active protected-carrier beam center or served user is permitted within
the configured `ZaRadiusKm` of the selected receiver. The public default is
30 km. Use the runtime option or `configureDcsOdsZaRadius` so all ZA-dependent
fields remain synchronized.

ODS state is based on angular separation from the protected antenna
boresight:

- outside the outer angle: normal scheduled operation;
- between inner and outer angles: the protected-carrier spot is physically
  retasked to the feasible beam center nearest the receiver but at least
  180 km away, and gain toward the receiver is recalculated; and
- inside the inner angle: the protected carrier is shut down using an
  80 dB numerical floor.

The model applies 15 seconds of command latency, 1 second of clock allowance,
and therefore 16 seconds of explicit pre-entry prediction. Entry uses the
smaller of current and predicted angular separation. A 0.5-degree hysteresis
prevents rapid state changes. The public baseline applies no outer-angle
operating floor.

## Propagation and interference calculation

### Free-space spreading and PFD

For each active spot, boresight EIRP density is reduced by its transmit
pattern, loading, and uncertainty. Free-space spreading is applied once as
power-flux density:

```text
PFD_dBW/m2/MHz = EIRP_dBW/MHz - 10 log10(4 pi R^2)
```

The configured -80 dBW/m2/MHz PFD cap is then applied per beam.

### Receive effective area

For receive gain `G_rx` evaluated at LEO-to-boresight separation,

```text
A_e,dB(m2) = G_rx,dBi + 20 log10(lambda) - 10 log10(4 pi)
```

### Atmospheric attenuation

The supplied site/dish tables were generated with ITU-R P.618 through
MATLAB Satellite Communications Toolbox at 1679.9 MHz and a 5% annual
exceedance percentage. Gaseous, cloud, rain, and scintillation components
are combined in `TotalAtmosphericLossDb` and interpolated by elevation using
PCHIP. Tables cover 5 through 90 degrees; elevations below 5 degrees use the
5-degree value.

### Local clutter

The model uses the ITU-R P.2108 open/rural height-gain form with a 10 m
representative clutter height. For feed height below 10 m,

```text
L_clutter = -(21.8 + 6.2 log10(f_GHz)) log10(h_rx / 10 m)
```

and clutter loss is zero at or above 10 m. Feed and clutter heights are
provisional inputs, not site-survey values.

### Received interference and aggregation

The implemented per-link relationship is equivalent to

```text
P_r,dBm = PFD
          + 10 log10(receiver bandwidth / 1 MHz)
          + A_e,dB(m2)
          + 30
          + power uncertainty
          + 10 log10(scheduled loading)
          - ODS mitigation
          - polarization loss
          - implementation loss
          - atmospheric loss
          - clutter loss
```

All eligible post-mitigation link powers are converted to linear milliwatts,
summed, and converted back to dBm:

```text
I_aggregate,mW = sum(10^(P_r,dBm/10))
I/N_dB         = I_aggregate,dBm - N_dBm
```

The provisional NRAO calibration applies up to an additional -18 dB
distance-ramped satellite sidelobe correction between the configured ZA
boundary (30 km by default) and 150 km. It is
transferred from 1990-1995 MHz evidence to the hypothetical 1675-1695 MHz
case and must be replaced by band- and operator-specific measurements.

## Simulation, uncertainty, and search

| Parameter | Value |
|---|---:|
| Start time | 2026-08-01 00:00 UTC |
| Duration | 2 hours |
| Time step | 2 seconds |
| Samples | 3,601 |
| Monte Carlo runs | 4 |
| Random seed | 16751695 |
| Link-power sigma | 3 dB |
| Ephemeris-angle sigma | 0.05 deg |
| Receiver-pointing sigma | 0.10 deg |
| Scheduled-load sigma | 0.15 |
| Robust percentile | 95th across runs |

Positive power uncertainty is clipped at the configured 30 dBW/MHz beam
ceiling. Angular errors are constrained to visible-sky geometry.

Only pairs with `inner <= outer` are evaluated. Search stages are:

1. coarse candidates at 0, 0.5, 1, 2, 3, and 5-degree increments through
   145 degrees, clipped to the case's visible-sky separation;
2. 1-degree refinement within 7 degrees of coarse strict and practical
   candidates; and
3. 0.5-degree refinement within 1.5 degrees of refined candidates.

Strict feasibility requires no modeled sample with I/N greater than -6 dB.
Feasible pairs are ranked by `outer + inner`; ties prefer smaller outer and
then smaller inner angle. “Zero exceedance” applies only to the simulated
time grid and Monte Carlo realizations; it is not a proof over every orbit,
scheduler state, uncertainty realization, or year.

## Runtime options

`runDcsOdsSpotBeamSimulator` accepts:

| Option | Default | Purpose |
|---|---|---|
| `WorkbookFile` | supplied catalog | Use another compatible catalog |
| `OutputRoot` | package folder | Isolate results under another root |
| `GeodeticHeightM` | feed-height proxy | Supply surveyed height |
| `ZaRadiusKm` | 30 | Set geographic no-user/active-beam-center radius in km |
| `DurationSeconds` | 7200 | Change simulated duration |
| `TimeStepSec` | 2 | Change time resolution |
| `MonteCarloRuns` | 4 | Change realization count |
| `WriteDetailedTimeSeries` | `true` | Write selected time-series CSV |
| `RegenerateAtmosphericLookup` | `false` | Rebuild the selected P.618 table |
| `DryRun` | `false` | Validate/display configuration only |

Example short smoke test in a separate output folder:

```matlab
results = runDcsOdsSpotBeamSimulator( ...
    "wallops_va_goes_east", ...
    OutputRoot="C:\temp\ods_spot_smoke", ...
    DurationSeconds=300, TimeStepSec=10, MonteCarloRuns=1, ...
    WriteDetailedTimeSeries=false);
```

Run all 12 cases with one common radius:

```matlab
summary = runAllDcsOdsSpotBeamCases(ZaRadiusKm=50);
```

Or provide one radius per catalog row in the order returned by
`listDcsOdsSpotBeamCases`:

```matlab
zaByCase = [30 30 30 50 50 50 50 50 50 30 30 30];
summary = runAllDcsOdsSpotBeamCases(ZaRadiusKm=zaByCase);
```

For programmatic configuration work, call
`cfg = configureDcsOdsZaRadius(cfg, radiusKm)`. Do not change only
`cfg.za.protectedCoreRadiusKm`, because beam scheduling and the NRAO-informed
distance calibration also depend on the same boundary.

## Changing configuration

The central public configuration is
`config/defaultDcsOdsSpotBeamConfig.m`.

| Area | Fields or source |
|---|---|
| Site, dish, feed height | `data/DCS_Receivers.xlsx` |
| GEO mapping | `loadDcsReceiverSites.m` |
| Receiver and criterion | `cfg.receiver.*` |
| Receive pattern | `cfg.antenna.*` |
| LEO shells | `cfg.constellation.shells` |
| Spot geometry and S.1528 pattern | `cfg.beams.*` and packing CSV |
| Frequency reuse and traffic | `cfg.resources.*` |
| EIRP and fixed losses | `cfg.rf.*` |
| Geographic zone | `ZaRadiusKm` or `configureDcsOdsZaRadius` |
| P.618 and P.2108 propagation | `cfg.propagation.*` |
| Aggregation | `cfg.aggregation.*` |
| Retasking, shutdown, prediction | `cfg.ods.*` |
| NRAO transfer calibration | `cfg.calibration.*` |
| Uncertainty | `cfg.uncertainty.*` |
| Duration, time step, seed | `cfg.simulation.*` |
| Angle grids and scoring | `cfg.search.*` |

Important dependencies:

- Regenerate the P.618 table after changing site coordinates, receiver
  frequency, dish diameter, antenna efficiency, geodetic height, or annual
  percentage.
- A different beam count requires a matching layout CSV and intentional
  changes to validation, reuse mapping, documentation, and verification.
- A different field-of-regard angle changes Earth-intercept geometry and
  the minimum site elevation reachable by the satellite beams.
- A new GOES assignment name requires a longitude mapping in
  `loadDcsReceiverSites.m`.
- Use a separate `OutputRoot` for sensitivities to avoid replacing the
  supplied public results.

Advanced programmatic studies may construct and edit the configuration
directly:

```matlab
packageFolder = "C:\path\to\DCS_ODS_Spot_Beam_Simulator";
addpath(packageFolder, fullfile(packageFolder,"config"), ...
    fullfile(packageFolder,"src"))
sites = loadDcsReceiverSites( ...
    fullfile(packageFolder,"data","DCS_Receivers.xlsx"));
site = table2struct(sites(10,:));
cfg = defaultDcsOdsSpotBeamConfig(site, packageFolder, ...
    "C:\temp\custom_ods");
cfg.receiver.protectionCriterionDb = -3;
cfg.resources.meanSatelliteCarrierDutyCycle = 0.10;
validateOdsConfig(cfg)
results = runOdsAngleStudy(cfg);
```

When changing linked traffic fields, update their compatibility aliases and
derived fields consistently. The standard runner is preferred for ordinary
use.

## Output files

Each case writes to `results_<site_id>`:

- `ods_results.mat`: complete configuration, geometry summary, search table,
  baseline metrics, and selected time series;
- `configuration.json`: resolved configuration;
- `dcs_ods_angle_summary.csv`: public case summary;
- `selected_angles.csv`: strict selected metrics;
- `practical_selected_angles.csv`: 99.9%-availability sensitivity result;
- `selected_time_series.csv`: aggregate I/N and contributor counts;
- `angle_search.csv`: evaluated candidates and feasibility;
- `angle_search.png`: angle-search visualization;
- `aggregate_in_over_n.png` and `aggregate_in_over_n_cdf.png`: strict result
  plots; and
- `practical_aggregate_in_over_n.png` and its CDF: practical sensitivity
  plots.

The all-case runner also writes
`dcs_ods_spot_beam_all_12_results.csv` in the package root.

## Verification

Run the public-package checks after extraction:

```matlab
verification = verifyDcsOdsSpotBeamSimulator();
```

The verifier checks all 12 catalog/configuration mappings, the fixed
10-beam assumptions, the four P.618 lookup tables, result metadata, required
files, angle validity, feasibility, and the -6 dB/zero-exceedance result
criterion.

## Included evidence and references

- `references/R-REC-S.580-6-200401.pdf`
- `references/APEREC015V01.pdf`
- `evidence/beam_packing_layout.csv`
- `evidence/nrao_dtc_calibration.csv`

Users should independently validate regulatory, constellation, traffic,
antenna, propagation, receiver, and ODS inputs before relying on any result
for planning or coordination. The publisher should also add its chosen
software license and attribution terms before third-party redistribution.
