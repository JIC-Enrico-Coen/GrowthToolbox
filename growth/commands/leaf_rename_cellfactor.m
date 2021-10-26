function m = leaf_rename_cellfactor( m, varargin )
%m = leaf_rename_cellfactor( m, oldname1, newname1, oldname1, newname1, ... )
%   Rename cellular values.  The names are strings; old names can also be
%   indexes. Invalid names are ignored. No value can be renamed to an
%   existing value.

    if isempty(m), return; end
    if isempty(m.secondlayer)
        return;
    end
    
    % Convert all the names to upper case.
    % A trailing old name with no new name is ignored.
    oldvalues = varargin{1:2:(end-1)};
    newnames = varargin{2:2:end};
    
    cellbodyvalueindex = FindCellFactorIndex( m, m.plotdefaults.cellbodyvalue );
    multicellbodyvalueindex = FindCellFactorIndex( m, m.plotdefaults.defaultmultiplotcells );
    [m.secondlayer.valuedict,ok] = renameInDict( m.secondlayer.valuedict, oldvalues, newnames );
    m.plotdefaults.cellbodyvalue = FindCellFactorName( m, cellbodyvalueindex );
    m.plotdefaults.defaultmultiplotcells = FindCellFactorName( m, multicellbodyvalueindex );
    
    setCellMgenMenuFromMesh( m );
    m = rewriteInteractionSkeleton( m, '', '', mfilename() );
    saveStaticPart( m );
end










