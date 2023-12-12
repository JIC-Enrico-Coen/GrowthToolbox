function s = renameFields( s, oldfns, newfns )
%s = renameFields( s, oldfns, newfns )
%   Rename fields of a struct. OLDFNS and NEWFNS are the lists of
%   corresponding old and new field names. They must be cell arrays of
%   field names of the same length. The members of OLDFNS and NEWFNS should
%   all be distinct. If there is only one field name in either array, it
%   does not have to be wrapped in a cell.
%
%   Field names in OLDFNS that are not fields of S are ignored. Fields in
%   NEWFNS are overwritten.

    if ischar( oldfns ) || isstring( oldfns )
        oldfns = { oldfns };
    end
    if ischar( newfns ) || isstring( newfns )
        newfns = { newfns };
    end
    numoldfields = min( length(oldfns), length(newfns) );
    replaced = false( 1, numoldfields );
    for i=1:numoldfields
        oldfn = oldfns{i};
        newfn = newfns{i};
        replaced(i) = isfield( s, oldfn ) && ~samestring( oldfn, newfn );
        if replaced(i)
            s.(newfn) = s.(oldfn);
        end
    end
    removeFields = setdiff( oldfns(replaced), newfns(replaced) );
    if ~isempty( removeFields )
        s = rmfield( s, removeFields );
    end
end
