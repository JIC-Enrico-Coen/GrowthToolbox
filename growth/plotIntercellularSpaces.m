function ph = plotIntercellularSpaces( m )
    ph = [];
    chains = getIntercellularSpaces( m, true );
    if isempty(chains)
        return;
    end
    
    % Calculate the maximum length of any chain.
    maxlen = 0;
    maxindex = [0 0];
    for i=1:length(chains)
        maxlen = max( length(chains{i}), maxlen );
        maxindex = max( maxindex, max( chains{i}, [], 1 ) );
    end
    
    % Calculate the faces array.  This is a ragged array in which the list
    % of vertexes of each chain is a row of the faces array, with unused
    % values filled by NaN.
    faces = NaN( length(chains), maxlen );
    for i=1:length(chains)
        ch = chains{i};
        nv = size(ch,1);
        if nv < 3
            xxxx = 1;
        end
        faces(i,1:nv) = ch(:,1)';
    end
    
    % Draw the faces.  I am assuming here that patch() does the right thing
    % with non-convex, non-planar 3D polygons.
    ph = patch( ...
            'Vertices', m.secondlayer.cell3dcoords, ...
            'Faces', faces, ...
            'FaceVertexCData', repmat( [1 0 0], length(chains), 1 ), ...
            'FaceColor', 'flat', ...
            'FaceAlpha', m.plotdefaults.bioAalpha, ...
            'FaceLighting', m.plotdefaults.lightmode, ...
            'AmbientStrength', m.plotdefaults.ambientstrength, ...
            'LineStyle', 'none', ...
            'Parent', m.pictures(1) ...
        );
end