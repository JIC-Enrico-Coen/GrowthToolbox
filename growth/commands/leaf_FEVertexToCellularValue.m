function cv = leaf_FEVertexToCellularValue( m, fev, varargin )
%cv = leaf_FEVertexToCellularValue( m, fev, ... )
%   Convert the value fev, defined for each vertex of the finite element
%   mesh, to a value defined for each vertex of the biological layer.
%
%   Options:
%       'mode'  If this is 'cell', then one value is returned per
%               biological cell.  If it is 'vertex', one value is returned
%               per vertex of the biological layer.
%
%   Note that there is no inverse to this function.  Given a value defined
%   on every vertex or cell of the cellular layer, there is no function to
%   compute an equivalent value all over the finite element mesh, as there
%   is no simple way to establish which biological cell, if any, a given
%   finite element vertex lies in.

    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'mode', 'vertex' );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'mode' );
    if ~ok, return; end

    % Calculate the global coordinates of the cellular vertexes.
    if isVolumetricMesh( m )
        cv = sum( m.secondlayer.vxBaryCoords .* fev(m.FEsets.fevxs(m.secondlayer.vxFEMcell,:)), 2 );
    else
        cv = sum( m.secondlayer.vxBaryCoords .* fev(m.tricellvxs(m.secondlayer.vxFEMcell,:)), 2 );
    end
    
    if strcmp(s.mode,'cell')
        cv1 = zeros( length(m.secondlayer.cells), 1 );
        for i=1:length(m.secondlayer.cells)
            cv1(i) = sum(cv(m.secondlayer.cells(i).vxs))/length(m.secondlayer.cells(i).vxs);
        end
        cv = cv1;
    end
end
