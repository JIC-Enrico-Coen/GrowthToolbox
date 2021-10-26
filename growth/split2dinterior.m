function split2dinterior( edges )
%split2dinterior( edges )
%   Given a set of unit 2D vectors listed in clockwise order, determine
%   whether this is an opportunity to split the vertex at the centre.

    SPLIT_ANGLE = 0.6; % radians
    OPPOSITE_THRESHOLD = 2.5; % radians
    
    numedges = size(edges,1);

% Calculate the angles between every pair of edges, and between consecutive
% edges.
    consecangles = zeros(numedges,1);
    angles = zeros(numedges,numedges);
    for i=1:numedges-1
        angles(i,i) = 0;
        for j=i+1:numedges
            angles(i,j) = vecangle( edges(i,:), edges(j,:) );
            angles(j,i) = angles(i,j);
        end
        consecangles(i) = angles(i,i+1);
    end
    angles(numedges,numedges) = 0;
    consecangles(numedges) = angles(numedges,1);
    angles
    consecangles
    
    % Find the narrow angles.    
    narrowanglei = find(consecangles < SPLIT_ANGLE);
    % The edges bordering narrow angles are narrowanglei and
    % narrowanglei+1.
    narrowedges = unique( [narrowanglei;(mod(narrowanglei,numedges)+1)] )
    
    % Find two narrow edges that are in almost opposite directions.
    oppnarrowedges = angles(narrowedges,narrowedges) > OPPOSITE_THRESHOLD
    % What we really want to do here is to discover that oppnarrowedges is
    % a graph with exactly two connected components.  How can we do that
    % efficiently, assuming
end
