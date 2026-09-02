function sites = loadDcsReceiverSites(workbookFile)
%loadDcsReceiverSites Import and validate the 12-option receiver catalog.

arguments
    workbookFile (1,1) string {mustBeFile} = fullfile( ...
        fileparts(mfilename("fullpath")), "data", "DCS_Receivers.xlsx")
end

sheetName = "Sheet1";
availableSheets = sheetnames(workbookFile);
assert(any(availableSheets == sheetName), "ODS:MissingSiteSheet", ...
    "Required worksheet '%s' is not present in %s.", ...
    sheetName, workbookFile);

requiredVariables = ["GOES Receiver Site", "Latitude (deg)", ...
    "Longitude (deg)", "Satellite", "Antenna Diameter (m)", ...
    "Antenna Feed Height (m)"];
importOptions = detectImportOptions(workbookFile, Sheet=sheetName, ...
    VariableNamingRule="preserve");
assert(all(ismember(requiredVariables, string(importOptions.VariableNames))), ...
    "ODS:SiteCatalogColumns", ...
    "The receiver workbook does not contain all required columns.");
% Force mixed numeric/text Excel columns to strings so cells such as
% "8.1<line break>" are not silently converted to NaN.
importOptions = setvartype(importOptions, requiredVariables, "string");
raw = readtable(workbookFile, importOptions);

name = cleanText(raw.(requiredVariables(1)));
latitudeDeg = parseNumber(raw.(requiredVariables(2)), requiredVariables(2));
longitudeDeg = parseNumber(raw.(requiredVariables(3)), requiredVariables(3));
satellite = cleanText(raw.(requiredVariables(4)));
antennaDiameterM = parseNumber(raw.(requiredVariables(5)), ...
    requiredVariables(5));
feedHeightM = parseNumber(raw.(requiredVariables(6)), requiredVariables(6));

isEast = strcmpi(satellite, "GOES East");
isWest = strcmpi(satellite, "GOES West");
isBackup = strcmpi(satellite, "GOES Backup");
assert(all(isEast | isWest | isBackup), ...
    "ODS:UnsupportedGoesAssignment", ...
    "Every receiver must be assigned to GOES East, GOES West, or GOES Backup.");
boresightLongitudeDeg = nan(height(raw), 1);
boresightLongitudeDeg(isEast) = -75.2;
boresightLongitudeDeg(isWest) = -137.0;
boresightLongitudeDeg(isBackup) = -104.7;
boresightLongitudeSource = strings(height(raw), 1);
boresightLongitudeSource(isEast | isWest) = ...
    "NOAA GOES-R fleet: GOES-East 75.2 W; GOES-West 137.0 W";
boresightLongitudeSource(isBackup) = ...
    "NOAA GOES-R fleet: GOES-16 primary backup at 104.7 W";
receiverId = strings(height(raw), 1);
siteId = strings(height(raw), 1);
for rowIndex = 1:height(raw)
    receiverId(rowIndex) = makeIdentifier(name(rowIndex));
    siteId(rowIndex) = receiverId(rowIndex) + "_" + ...
        makeIdentifier(satellite(rowIndex));
end

assert(all(latitudeDeg >= -90 & latitudeDeg <= 90), ...
    "ODS:SiteLatitude", "Catalog latitudes must lie within [-90, 90].");
assert(all(longitudeDeg >= -180 & longitudeDeg <= 180), ...
    "ODS:SiteLongitude", "Catalog longitudes must lie within [-180, 180].");
assert(all(antennaDiameterM > 0), "ODS:SiteDiameter", ...
    "Catalog antenna diameters must be positive.");
assert(all(feedHeightM > 0), "ODS:SiteFeedHeight", ...
    "Catalog antenna feed heights must be positive.");
assert(numel(unique(siteId)) == height(raw), "ODS:DuplicateSiteId", ...
    "Each receiver-site and satellite combination must be unique.");

index = (1:height(raw)).';
sourceWorkbook = repmat(string(workbookFile), height(raw), 1);
sourceRow = index + 1;
sites = table(index, siteId, receiverId, name, latitudeDeg, longitudeDeg, satellite, ...
    antennaDiameterM, feedHeightM, boresightLongitudeDeg, ...
    boresightLongitudeSource, sourceWorkbook, sourceRow, ...
    VariableNames=["Index", "SiteId", "ReceiverId", "Name", "LatitudeDeg", ...
    "LongitudeDeg", "Satellite", "AntennaDiameterM", "FeedHeightM", ...
    "BoresightLongitudeDeg", "BoresightLongitudeSource", ...
    "SourceWorkbook", "SourceRow"]);
end

function values = parseNumber(rawValues, variableName)
values = str2double(cleanText(rawValues));
assert(all(isfinite(values)), "ODS:SiteCatalogNumber", ...
    "Column '%s' contains a missing or nonnumeric value.", variableName);
end

function values = cleanText(rawValues)
values = strip(regexprep(string(rawValues), "\s+", " "));
assert(all(strlength(values) > 0), "ODS:SiteCatalogText", ...
    "The receiver catalog contains a blank required text value.");
end

function identifier = makeIdentifier(label)
identifier = lower(regexprep(label, "[^A-Za-z0-9]+", "_"));
identifier = regexprep(identifier, "^_+|_+$", "");
end
