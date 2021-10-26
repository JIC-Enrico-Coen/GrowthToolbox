function m = leaf_delete_cellfactor( m, varargin )
%m = leaf_delete_cellfactor( m, name1, name2, ... )
%   Delete cellular values.  The names are strings. Invalid names are
%   ignored.

    if isempty(m) || isempty( varargin )
        return;
    end
    
    [m.secondlayer.valuedict,delindexes,oldnew,newold] = deleteNamesFromIndex( m.secondlayer.valuedict, varargin{:} );
    if isempty(delindexes)
        return;
    end
    m.secondlayer.cellvalue_plotpriority(delindexes) = [];
    m.secondlayer.cellvalue_plotthreshold(delindexes) = [];
    m.secondlayer.cellvalues(:,delindexes) = [];
    m.secondlayer.cellcolorinfo(delindexes) = [];
    m.plotdefaults.cellbodyvalue = intersect( m.secondlayer.valuedict.index2NameMap, m.plotdefaults.cellbodyvalue );
    if isempty(m.plotdefaults.cellbodyvalue) && ~isempty( m.secondlayer.valuedict.index2NameMap )
        m.plotdefaults.cellbodyvalue = m.secondlayer.valuedict.index2NameMap{1};
    end
    m.plotdefaults.defaultmultiplotcells = intersect( m.plotdefaults.defaultmultiplotcells, m.secondlayer.valuedict.index2NameMap );
    
    % If any of the deleted factors had a role associated with it, remove
    % the association.
    roleindexes = value2Index( m.secondlayer.cellfactorroles, delindexes );
    m.secondlayer.cellfactorroles.index2Value(roleindexes(roleindexes>0)) = 0; 
    
    setCellMgenMenuFromMesh( m );
    m = rewriteInteractionSkeleton( m, '', '', mfilename() );
    saveStaticPart( m );
end
