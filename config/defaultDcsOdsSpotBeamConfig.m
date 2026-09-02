function cfg = defaultDcsOdsSpotBeamConfig(site, projectFolder, outputRoot, zaRadiusKm)
%defaultDcsOdsSpotBeamConfig Return the public 10-spot DCS configuration.

arguments
    site (1,1) struct
    projectFolder (1,1) string = string(fileparts(fileparts( ...
        mfilename("fullpath"))))
    outputRoot (1,1) string = projectFolder
    zaRadiusKm (1,1) double {mustBeFinite,mustBeNonnegative} = 30
end

siteName = string(site.Name);
siteId = string(site.SiteId);
diameterM = site.AntennaDiameterM;
diameterToken = replace(compose("%.1f", diameterM), ".", "p");
wavelengthM = physconst("LightSpeed") / 1679.9e6;
diameterWavelengths = diameterM / wavelengthM;
if diameterWavelengths < 50
    patternRegime = "APEREC015 Appendix 8 D/lambda < 50 extension";
else
    patternRegime = "ITU-R S.580-6 D/lambda >= 50 form";
end

cfg.meta.modelName = "DCS ODS Spot Beam Simulator";
cfg.meta.modelVersion = "1.0.0";
cfg.meta.releaseId = "DCS-ODS-SPOT-BEAM-SIMULATOR-PUBLIC-1.0.0";
cfg.meta.baselineId = "DCS-10-SPOT-60-FOR-30DBW-MHZ-ZA30";
cfg.meta.experimentId = "DCS-ODS-SPOT-" + upper(siteId);
cfg.meta.caseName = compose("DCS ODS Spot Beam Simulator - %s | %s | %.1f m", ...
    siteName, string(site.Satellite), diameterM);
cfg.meta.disclaimer = "Public engineering sensitivity simulation, not a coordination " + ...
    "determination or operator commitment. The -27 dBi far-angle receive level, traffic " + ...
    "scheduler, NRAO transfer calibration, and ODS actions require site/operator validation.";
cfg.meta.siteCatalogFile = string(site.SourceWorkbook);
cfg.meta.siteCatalogRow = site.SourceRow;

cfg.site.name = siteName;
cfg.site.siteId = siteId;
cfg.site.latitudeDeg = site.LatitudeDeg;
cfg.site.longitudeDeg = site.LongitudeDeg;
cfg.site.heightM = site.FeedHeightM;
cfg.site.antennaFeedHeightAglM = site.FeedHeightM;
cfg.site.heightSourceStatus = "Catalog feed height above local ground used as a geodetic-height " + ...
    "proxy; replace with surveyed antenna-reference height when available.";
cfg.site.minimumElevationDeg = 0;
cfg.site.visibilityConvention = "local geometric horizon (0-degree minimum LEO elevation)";
cfg.site.boresight.type = "geoLongitude";
cfg.site.boresight.satelliteAssignment = string(site.Satellite);
cfg.site.boresight.geoLongitudeDeg = site.BoresightLongitudeDeg;
cfg.site.boresight.longitudeSource = string(site.BoresightLongitudeSource);

cfg.receiver.centerFrequencyHz = 1679.9e6;
cfg.receiver.bandwidthHz = 0.4e6;
cfg.receiver.noiseTemperatureK = 28;
cfg.receiver.protectionCriterionDb = -6;
cfg.receiver.allowedExceedancePercent = 0;
cfg.receiver.referencePlane = "antenna terminals (SPRES-FO working-paper assumption)";

cfg.antenna.model = "ituRS580Aperec015SmallExtension";
cfg.antenna.diameterM = diameterM;
cfg.antenna.efficiency = 0.70;
cfg.antenna.sidelobeFloorDbi = -10;
cfg.antenna.sidelobeFloorUsage = "unused by the selected S.580/APEREC015 model";
cfg.antenna.pointingBiasDeg = 0;
cfg.antenna.farAngleGainDbiOverride = -27;
cfg.antenna.farAngleOverrideStartDeg = 10^(42/25);
cfg.antenna.farAngleOverrideStatus = "Unverified public sensitivity assumption applied to every catalog receiver beyond the S.580 far-angle breakpoint; replace with measured site data.";
cfg.antenna.reference = "ITU-R S.580-6 with attached APEREC015 Appendix 8 extension where applicable";
cfg.antenna.applicabilityNote = compose("D/lambda = %.6f; using %s.", ...
    diameterWavelengths, patternRegime);

cfg.constellation.shells = [ ...
    struct("name", "DTC-53", "altitudeKm", 340.0, "inclinationDeg", 53.0, ...
        "satellites", 325, "planes", 13, "phasing", 1); ...
    struct("name", "DTC-43", "altitudeKm", 355.0, "inclinationDeg", 43.0, ...
        "satellites", 325, "planes", 13, "phasing", 1)];
cfg.constellation.sourceNote = "Engineering two-shell D2C baseline: 325 satellites at 340 km/53 degrees and 325 at 355 km/43 degrees.";

cfg.beams.numberPerSatellite = 10;
cfg.beams.boresightDirection = "10 snapshot steering positions inside the field of regard";
cfg.beams.transmissionBoundary = "nadirConePackedSpots";
cfg.beams.coneHalfAngleDeg = 60;
cfg.beams.fullConeAngleDeg = 120;
cfg.beams.layoutModel = "optimizedTriangularClosePackedGeodesicCells";
cfg.beams.layoutOrientation = "Earth-fixed local east/north snapshot steering lattice";
cfg.beams.layoutFile = fullfile(projectFolder, "evidence", ...
    "beam_packing_layout.csv");
cfg.beams.nonOverlapToleranceDeg = 1e-7;
cfg.beams.transmitPatternModel = "ituRS1528LeoPerBeam";
cfg.beams.spotHalfPowerRadiusDeg = 2.0;
cfg.beams.spotFullHalfPowerBeamwidthDeg = 2 * cfg.beams.spotHalfPowerRadiusDeg;
cfg.beams.spotWidthInterpretation = "The 60-degree value is steering field of regard, not beamwidth. Each spot has a separately configurable -3 dB angular radius.";
cfg.beams.halfPowerBoundaryDefinition = "Configured satellite-view -3 dB angular radius for each independently steered spot.";
cfg.beams.nearSidelobeCrossPointDb = -6.75;
cfg.beams.farOutSidelobeGainDbi = 0;
cfg.beams.offAxisMaskMarginDb = 0.0;
cfg.beams.offAxisMaskTransitionStartNormalized = 1.0;
cfg.beams.offAxisMaskTransitionEndNormalized = 1.5;
cfg.beams.offAxisMaskMarginStatus = "Optional calibration assumption; zero in the default case so the S.1528 reference envelope is retained without extra satellite-pattern credit.";
cfg.beams.scanLossModel = "projectedApertureCosine";
cfg.beams.scanLossCosineExponent = 1;
cfg.beams.scanLossCompensationEnabled = true;
cfg.beams.scanLossCompensationNote = "Modeled power control compensates projected-aperture scan loss so every spot retains the same peak EIRP-density ceiling.";
cfg.beams.patternReference = "ITU-R S.1528-0 LEO reference pattern plus explicit configurable off-axis mask margin.";
cfg.beams.footprintModel = "10 narrow spots at snapshot steering positions; every visible satellite can couple through spot sidelobes";
cfg.beams.frequencyReuseAssumption = "Four 5-MHz carriers with cyclic assignment; 3 of 10 positions use the carrier containing 1679.9 MHz, with at most one such beam scheduled per satellite.";
cfg.beams.loadingInterpretation = "Two-state per-satellite scheduler with one protected-carrier spot at most.";
cfg.beams.cellEdgeInterpretation = "The configured spot half-power radius is independent of the 60-degree field of regard.";
cfg.beams.sourceNote = "The 10-point lattice defines snapshot steering locations only; it does not assert continuous tiling of the field of regard.";

cfg.za.enabled = true;
cfg.za.protectedCoreRadiusKm = 30;
cfg.za.minimumActiveBeamCenterDistanceKm = 30;
cfg.za.definition = "No D2D served user/active beam center inside 30 km of the protected receiver";
cfg.za.sourceStatus = "User-defined 30-km geographic avoidance radius; not a coordination result.";

cfg.resources.carrierBandwidthHz = 5e6;
cfg.resources.carrierEdgesHz = 1675e6:5e6:1695e6;
cfg.resources.carrierCount = 4;
cfg.resources.protectedCarrierIndex = 1;
cfg.resources.protectedCarrierIndices = 1;
cfg.resources.beamCarrierIndex = mod(0:(cfg.beams.numberPerSatellite - 1), cfg.resources.carrierCount) + 1;
cfg.resources.cochannelBeamIndices = find(cfg.resources.beamCarrierIndex == cfg.resources.protectedCarrierIndex);
cfg.resources.maximumSimultaneousCochannelBeamsPerSatellite = 1;
cfg.resources.schedulerMode = "oneBeamPerProtectedCarrier";
cfg.resources.beamInterferenceBandwidthHz = zeros(1,cfg.beams.numberPerSatellite);
cfg.resources.beamInterferenceBandwidthHz(cfg.resources.cochannelBeamIndices) = ...
    cfg.receiver.bandwidthHz;
cfg.resources.frequencyPlan = "Four contiguous 5-MHz carriers with static four-color assignment";
cfg.resources.frequencyPlanStatus = "Configurable constellation assumption, not a disclosed operator scheduler.";
cfg.resources.meanSatelliteCarrierDutyCycle = 0.20;
cfg.resources.meanOnDurationSec = 30;
cfg.resources.meanOffDurationSec = 120;
cfg.resources.meanScheduledLoad = 0.60;
cfg.resources.scheduledLoadSigma = 0.15;
cfg.resources.minimumScheduledLoad = 0.20;
cfg.resources.trafficModel = "Two-state burst scheduler; one protected-carrier spot per satellite; ZA-aware reassignment";
cfg.resources.trafficSourceStatus = "Engineering traffic assumption requiring operator validation.";

cfg.rf.studyBandHz = [1675e6 1695e6];
cfg.rf.sourceBandHz = [1990e6 1995e6];
cfg.rf.eirpDensityDbwPerMHz = 30;
cfg.rf.maximumBeamEirpDensityDbwPerMHz = 30;
cfg.rf.eirpBasis = "User-selected 30 dBW/MHz maximum EIRP density for every spot beam.";
cfg.rf.referencePeakAntennaGainDbi = 38;
cfg.rf.perCellEirpConvention = "Every active spot has the same 30 dBW/MHz maximum boresight EIRP density; pattern and load reduce off-axis/instantaneous EIRP only.";
cfg.rf.filedPolarizations = "RHCP and LHCP";
cfg.rf.maximumPfdCapEnabled = true;
cfg.rf.maximumPfdCapDbwM2MHz = -80;
cfg.rf.maximumPfdSource = "Prior FCC engineering-table assumption; applied per beam after range loss.";
cfg.rf.meanActiveProbability = cfg.resources.meanSatelliteCarrierDutyCycle;
cfg.rf.activitySourceStatus = "Compatibility alias for the burst scheduler.";
cfg.rf.polarizationLossDb = 0;
cfg.rf.polarizationStatus = "Worst-case co-polar coupling.";
cfg.rf.atmosphericLossDb = 0;
cfg.rf.atmosphericLossUsage = "zero when the propagation model is enabled";
cfg.rf.implementationLossDb = 1;

cfg.propagation.enabled = true;
cfg.propagation.atmosphericModel = "ituRP618Lookup";
cfg.propagation.atmosphericAnnualExceedancePercent = 5;
cfg.propagation.minimumLookupElevationDeg = 5;
cfg.propagation.belowLookupTreatment = "Use the 5-degree P.618 value for visible 0-to-5-degree links.";
cfg.propagation.atmosphericLookupFile = fullfile(projectFolder, "data", ...
    string(site.ReceiverId) + "_p618_1679p9MHz_" + diameterToken + "m_5pct.csv");
cfg.propagation.atmosphericReference = "ITU-R P.618 lookup generated with MATLAB Satellite Communications Toolbox";
cfg.propagation.clutterModel = "ituRP2108OpenRuralHeightGain";
cfg.propagation.clutterRepresentativeHeightM = 10;
cfg.propagation.receiverAntennaHeightAglM = site.FeedHeightM;
cfg.propagation.clutterReference = "ITU-R P.2108-1 open/rural height-gain model; provisional heights";

cfg.aggregation.selectionMode = "allEligible";
cfg.aggregation.powerCombinationMode = "linearSum";
cfg.aggregation.maxContributingSatellites = sum([cfg.constellation.shells.satellites]);
cfg.aggregation.contributorLimitApplied = false;
cfg.aggregation.selectionMetric = "all visible satellites with a scheduled ZA-permitted protected-carrier spot";
cfg.aggregation.selectionOrder = "calculate every link, apply ODS action, then sum powers linearly";
cfg.aggregation.dominantSelectionStage = "notApplicableAllSatelliteLinearSum";
cfg.aggregation.dominantDefinition = "All eligible scheduled satellites contribute.";

cfg.ods.steerMitigationDb = 0;
cfg.ods.muteMitigationDb = 80;
cfg.ods.deepNullMitigationDb = cfg.ods.muteMitigationDb;
cfg.ods.measuredMuteLowerBoundDb = 20;
cfg.ods.outerMinimumBeamCenterDistanceKm = 180;
cfg.ods.minimumOperationalOuterAngleDeg = 0;
cfg.ods.minimumOperationalOuterAngleStatus = "No operating floor; the search selects the unconstrained minimum modeled angle pair.";
cfg.ods.outerRetaskMode = "retask protected-carrier spots to a feasible center at least 180 km from the protected receiver and recompute gain";
cfg.ods.innerProtectedCarrierShutdownEnabled = true;
cfg.ods.actionMode = "physical outer beam retasking and inner protected-carrier shutdown";
cfg.ods.unaffectedBeamOperation = "Outside the outer cone operation is unchanged; in the annulus the protected-carrier spot is retasked; in the inner cone it is shut down.";
cfg.ods.mitigationSourceStatus = "180-km retasking is an NRAO-informed engineering assumption; inner action is exact protected-carrier shutdown; no outer-angle operating floor is applied.";
cfg.ods.demonstratedMuteAngleDeg = 0.5;
cfg.ods.demonstratedSteerExampleAngleDeg = 2;
cfg.ods.commandLatencySec = 15;
cfg.ods.clockErrorSec = 1;
cfg.ods.hysteresisDeg = 0.5;
cfg.ods.failSafeProbability = 0;
cfg.ods.failSafeMitigationDb = 80;

cfg.calibration.enabled = true;
cfg.calibration.evidenceFile = fullfile(projectFolder, "evidence", "nrao_dtc_calibration.csv");
cfg.calibration.sidelobeCorrectionDb = -18;
cfg.calibration.rampStartDistanceKm = cfg.za.minimumActiveBeamCenterDistanceKm;
cfg.calibration.fullCorrectionDistanceKm = 150;
cfg.calibration.sourceFrequencyHz = 1992.5e6;
cfg.calibration.transferMode = "Relative NRAO sidelobe correction transferred from 1990-1995 MHz to 1675-1695 MHz";
cfg.calibration.sourceStatus = "Provisional cross-service engineering calibration; receiver- and band-specific measurements supersede it.";

cfg.uncertainty.powerSigmaDb = 3;
cfg.uncertainty.powerTreatment = "Independent beam uncertainty below the 30 dBW/MHz ceiling; positive excursions clipped at the ceiling.";
cfg.uncertainty.ephemerisAngleSigmaDeg = 0.05;
cfg.uncertainty.pointingSigmaDeg = 0.10;
cfg.uncertainty.angularGeometryTreatment = "Angular errors are clamped to visible sky.";
cfg.uncertainty.loadingSigma = cfg.resources.scheduledLoadSigma;
cfg.uncertainty.temporalCorrelationSec = cfg.resources.meanOnDurationSec;
cfg.uncertainty.robustPercentile = 95;

cfg.reporting.strictAllowedExceedancePercent = 0;
cfg.reporting.practicalAllowedExceedancePercent = 0.1;
cfg.reporting.practicalAvailabilityPercent = 99.9;
cfg.reporting.practicalIOverNPercentile = 99.9;
cfg.reporting.note = "Strict result permits no modeled sample above -6 dB I/N in any Monte Carlo run.";

cfg.simulation.startTime = datetime(2026, 8, 1, 0, 0, 0, TimeZone="UTC");
cfg.simulation.duration = hours(2);
cfg.simulation.timeStepSec = 2;
cfg.simulation.monteCarloRuns = 4;
cfg.simulation.randomSeed = 16751695;

cfg.search.outerAngleRangeDeg = unique([0 0.5 1 2 3 5:5:145]);
cfg.search.innerAngleRangeDeg = unique([0 0.5 1 2 3 5:5:145]);
cfg.search.adaptiveRefinementEnabled = true;
cfg.search.refinementStepDeg = 1;
cfg.search.refinementHalfWidthDeg = 7;
cfg.search.finalStepDeg = 0.5;
cfg.search.finalHalfWidthDeg = 1.5;
cfg.search.serviceImpactWeight = 0;
cfg.search.serviceImpactNote = "Select the smallest outer-plus-inner angle pair meeting strict protection.";

cfg.output.writeDetailedTimeSeries = true;
cfg.output.folder = fullfile(outputRoot, "results_" + siteId);
cfg = configureDcsOdsZaRadius(cfg,zaRadiusKm);
end
