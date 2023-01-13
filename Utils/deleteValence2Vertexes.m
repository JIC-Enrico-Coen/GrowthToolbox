function volcells = deleteValence2Vertexes( volcells )
% INCOMPLETE
    numvxs = size(volcells.vxs3d,1);
    [vxedges,numvxnbs] = invertArrayToCellArray( volcells.edgevxs, numvxs );
    % Choose the first edge to elide.
    edgesToElide = vxedges(:,1);
    
    v2vxs = numvxnbs==2;
    
    % These vertexes must be deleted from vxs3d, vxfe, and vxbc.
    % For each such vertex, one of the two edges it belongs to must be
    % elided.
    
    renumbervxs = (1:numvxs)';
    renumbervxs( 
end

%              vxs3d: [584×3 double]
%               vxfe: [584×1 uint32]
%               vxbc: [584×4 double]
%            edgevxs: [1036×2 uint32]
%          edgefaces: {1036×1 cell}
%            facevxs: {511×1 cell}
%          faceedges: {511×1 cell}
%          polyfaces: {58×1 cell}
%      polyfacesigns: {58×1 cell}
%        atcornervxs: [584×1 logical]
%          onedgevxs: [584×1 logical]
%         surfacevxs: [584×1 logical]
%       surfaceedges: [1036×1 logical]
%       surfacefaces: [511×1 logical]
%     surfacevolumes: [58×1 logical]
