function selectedSite = selectDcsReceiverSite(sites, siteSelection)
%selectDcsReceiverSite Resolve an interactive or programmatic site choice.

arguments
    sites table
    siteSelection = []
end

if isempty(siteSelection) || ...
        (isstring(siteSelection) && all(strlength(strip(siteSelection)) == 0))
    fprintf("\nDCS ODS Spot Beam Simulator receiver/satellite options:\n");
    disp(sites(:, ["Index", "Name", "Satellite", ...
        "AntennaDiameterM", "FeedHeightM"]));
    selectedIndex = input(compose( ...
        "Choose a site number (1-%d): ", height(sites)));
else
    selectedIndex = resolveSelection(sites, siteSelection);
end

assert(isnumeric(selectedIndex) && isscalar(selectedIndex) && ...
    isfinite(selectedIndex) && mod(selectedIndex, 1) == 0 && ...
    selectedIndex >= 1 && selectedIndex <= height(sites), ...
    "ODS:InvalidSiteSelection", ...
    "Site selection must be an integer from 1 through %d.", height(sites));
selectedSite = table2struct(sites(selectedIndex, :));
fprintf("Selected %s: %.4f m dish, %.2f m feed height, %s boresight.\n", ...
    selectedSite.Name, selectedSite.AntennaDiameterM, ...
    selectedSite.FeedHeightM, selectedSite.Satellite);
end

function selectedIndex = resolveSelection(sites, siteSelection)
if isnumeric(siteSelection)
    selectedIndex = siteSelection;
    return
end

selectionText = strip(string(siteSelection));
assert(isscalar(selectionText), "ODS:InvalidSiteSelection", ...
    "Text site selection must be scalar.");
displayName = sites.Name + " | " + sites.Satellite;
exactMatch = strcmpi(sites.SiteId, selectionText) | ...
    strcmpi(displayName, selectionText);
if nnz(exactMatch) == 1
    selectedIndex = find(exactMatch);
    return
end
nameMatch = strcmpi(sites.Name, selectionText);
if nnz(nameMatch) == 1
    selectedIndex = find(nameMatch);
    return
end
searchText = lower(displayName + " " + sites.SiteId);
partialMatch = contains(searchText, lower(selectionText));
assert(nnz(partialMatch) == 1, "ODS:UnknownSiteSelection", ...
    "Selection '%s' did not uniquely identify one receiver/satellite row. " + ...
    "Use its menu number, SiteId, or 'Site | GOES assignment'.", selectionText);
selectedIndex = find(partialMatch);
end
