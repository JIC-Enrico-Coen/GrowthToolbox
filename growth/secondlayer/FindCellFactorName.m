function cfname = FindCellFactorName( m, cellfactor, message )
% Convert any set of cell factors to names.
% cellfactor can be any of:
%   a single cell factor index
%   an array of cell factors
%   a string
%   a cell array of strings.
% The result is always a cell array of strings.
% Cell factor indexes that are out of range are ignored.
% Cell factor names are checked for validity, and invalid ones ignored.

    if isempty( cellfactor )
        cfname = {};
    elseif iscell( cellfactor )
        cfname = lower(cellfactor);
    elseif ischar( cellfactor )
        cfname = { lower(cellfactor) };
    else
        nummgens = length( m.secondlayer.valuedict.index2NameMap );
        cfname = m.secondlayer.valuedict.index2NameMap(cellfactor((cellfactor > 0) & (cellfactor <= nummgens) & (cellfactor == int32(cellfactor))));
    end
    cfname = cfname( isfield( m.secondlayer.valuedict.name2IndexMap, cfname ) );
end

