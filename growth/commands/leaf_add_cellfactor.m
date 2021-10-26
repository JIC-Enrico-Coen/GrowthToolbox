function [m,indexes] = leaf_add_cellfactor( m, varargin )
%m = leaf_add_cellfactor( m, name1, name2, ... )
%   Add new cellular values.  The names are strings, and new per-cell
%   values will be added with those names.  If any of them exist already they
%   will be unchanged.  The new ones will be set to zero everywhere.
%   If there is no cellular layer this procedure does nothing.

    global gSecondLayerColorInfo
    if isempty(m) || isempty( varargin )
        return;
    end
    [m.secondlayer.valuedict,indexes] = addNames2Index( m.secondlayer.valuedict, varargin );
    m.secondlayer.cellvalues(:,indexes) = zeros( size(m.secondlayer.cellvalues,1), length(indexes) );
    m.secondlayer.cellcolorinfo(indexes) = gSecondLayerColorInfo;
    m.secondlayer.cellvalue_plotpriority(indexes) = 0;
    m.secondlayer.cellvalue_plotthreshold(indexes) = 0;
    if ~isempty(indexes)
        m.plotdefaults.cellbodyvalue = FindCellFactorName( m, indexes(1) );
    end
    
    setCellMgenMenuFromMesh( m );
    m = rewriteInteractionSkeleton( m, '', '', mfilename() );
    saveStaticPart( m );
end
