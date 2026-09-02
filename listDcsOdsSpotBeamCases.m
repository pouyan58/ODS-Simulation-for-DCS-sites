function sites = listDcsOdsSpotBeamCases(workbookFile)
%listDcsOdsSpotBeamCases Display the 12 selectable public cases.

arguments
    workbookFile (1,1) string {mustBeFile} = fullfile( ...
        fileparts(mfilename("fullpath")), "data", "DCS_Receivers.xlsx")
end

sites = loadDcsReceiverSites(workbookFile);
disp(sites(:, ["Index","Name","LatitudeDeg","LongitudeDeg", ...
    "Satellite","AntennaDiameterM","FeedHeightM"]));
end
