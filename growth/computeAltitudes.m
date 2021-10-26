function [altitudes,altratios,pos] = computeAltitudes( nodes, tricellvxs )
% m = computeAltitudes( m )
%   Set m.altitudes to an N*3*3 array such that m.altitudes(ci,cei,:) is
%   the altitude vector in element ci perpendicular to edge cei.
%   m.altratios is set to an N*3 array in which m.altratios(ci,cei) is the
%   ratio in which the foot of the corresponding altitude vector divides
%   the edge.

    numcells = size(tricellvxs,1);
    dims = size(nodes,2);
    altitudes = zeros( 3, dims, numcells );
    if nargout==1
        for ci=1:numcells
            altitudes(:,:,ci) = triAltitudes( nodes(tricellvxs(ci,:),:) );
        end
    else
        altratios = zeros( numcells, 3 );
        pos = ones( numcells, 1 );
        for ci=1:numcells
            [altitudes(:,:,ci),altratios(ci,:),pos(ci)] = triAltitudes( nodes(tricellvxs(ci,:),:) );
        end
    end
    altitudes = permute( altitudes, [3,1,2] );
end
