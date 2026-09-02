function results = runDcsOdsSpotBeamSimulator(siteSelection, options)
%runDcsOdsSpotBeamSimulator Select a DCS case and calculate ODS angles.
%   RESULTS = runDcsOdsSpotBeamSimulator() displays the 12 receiver and
%   GOES-boresight choices. A menu number, SiteId, or unique combined label
%   can be supplied for noninteractive operation. Set ZaRadiusKm to change
%   the geographic no-user/active-beam-center radius consistently.

arguments
    siteSelection = []
    options.WorkbookFile (1,1) string {mustBeFile} = fullfile( ...
        fileparts(mfilename("fullpath")), "data", "DCS_Receivers.xlsx")
    options.OutputRoot (1,1) string = string(fileparts( ...
        mfilename("fullpath")))
    options.GeodeticHeightM (1,1) double = NaN
    options.ZaRadiusKm (1,1) double {mustBeFinite,mustBeNonnegative} = 30
    options.DurationSeconds (1,1) double {mustBePositive} = 7200
    options.TimeStepSec (1,1) double {mustBePositive} = 2
    options.MonteCarloRuns (1,1) double {mustBeInteger,mustBePositive} = 4
    options.WriteDetailedTimeSeries (1,1) logical = true
    options.RegenerateAtmosphericLookup (1,1) logical = false
    options.DryRun (1,1) logical = false
end

projectFolder = string(fileparts(mfilename("fullpath")));
originalPath = path;
pathCleanup = onCleanup(@() path(originalPath));
addpath(projectFolder, fullfile(projectFolder, "config"), ...
    fullfile(projectFolder, "src"));

sites = loadDcsReceiverSites(options.WorkbookFile);
selectedSite = selectDcsReceiverSite(sites, siteSelection);
cfg = defaultDcsOdsSpotBeamConfig(selectedSite, projectFolder, ...
    options.OutputRoot,options.ZaRadiusKm);
cfg.simulation.duration = seconds(options.DurationSeconds);
cfg.simulation.timeStepSec = options.TimeStepSec;
cfg.simulation.monteCarloRuns = options.MonteCarloRuns;
cfg.output.writeDetailedTimeSeries = options.WriteDetailedTimeSeries;
if isfinite(options.GeodeticHeightM)
    cfg.site.heightM = options.GeodeticHeightM;
    cfg.site.heightSourceStatus = ...
        "User-supplied geodetic antenna-reference height.";
end

if options.DryRun
    validateOdsConfig(cfg);
    results.config = cfg;
    results.siteCatalog = sites;
    results.selectedSite = selectedSite;
    displayConfiguration(cfg);
    clear pathCleanup
    return
end

if options.RegenerateAtmosphericLookup || ...
        ~isfile(cfg.propagation.atmosphericLookupFile)
    mapFolder = fullfile(fileparts(fileparts(projectFolder)), ...
        "work", "p618_maps", "extracted");
    assert(isfolder(mapFolder), "ODS:MissingItuMaps", ...
        "ITU digital-map folder not found: %s", mapFolder);
    fprintf("Generating site- and diameter-specific P.618 lookup...\n");
    generateP618AtmosphericLookup(cfg, mapFolder, ...
        string(cfg.propagation.atmosphericLookupFile));
end

validateOdsConfig(cfg);
results = runOdsAngleStudy(cfg);
writeDcsOdsSummary(results, selectedSite);

fprintf("\nDCS ODS Spot Beam Simulator result for %s | %s\n", ...
    cfg.site.name, cfg.site.boresight.satelliteAssignment);
fprintf("  Outer angle from boresight: %.2f deg\n", ...
    results.selected.outerAngleDeg);
fprintf("  Inner angle from boresight: %.2f deg\n", ...
    results.selected.innerAngleDeg);
fprintf("  Geographic ZA radius: %.2f km\n", ...
    results.config.za.protectedCoreRadiusKm);
fprintf("  Worst modeled exceedance: %.6f %%\n", ...
    results.selected.worstExceedancePercent);
fprintf("  Results folder: %s\n", cfg.output.folder);
clear pathCleanup
end

function displayConfiguration(cfg)
configuration = table(string(cfg.site.name), cfg.site.latitudeDeg, ...
    cfg.site.longitudeDeg, string(cfg.site.boresight.satelliteAssignment), ...
    cfg.site.boresight.geoLongitudeDeg, cfg.antenna.diameterM, ...
    cfg.propagation.receiverAntennaHeightAglM, cfg.site.heightM, ...
    cfg.za.protectedCoreRadiusKm, ...
    cfg.beams.numberPerSatellite, cfg.rf.maximumBeamEirpDensityDbwPerMHz, ...
    VariableNames=["Site","LatitudeDeg","LongitudeDeg", ...
    "GoesAssignment","BoresightLongitudeDeg","AntennaDiameterM", ...
    "FeedHeightAglM","GeodeticHeightM","GeographicZaRadiusKm", ...
    "BeamsPerSatellite", ...
    "MaximumBeamEirpDensityDbwPerMHz"]);
disp(configuration);
end
