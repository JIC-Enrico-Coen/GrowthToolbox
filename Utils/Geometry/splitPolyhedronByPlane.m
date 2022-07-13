function [ newpolyfaces1, newpolyfaces2, newvxs ] = splitPolyhedronByPlane( vxs, polyfaces, planePoint, planeNormal )
%[newvxs1, newpolyfaces1, newvxs2, newpolyfaces2 ] = splitPolyhedronByPlane( vxs, polyfaces, planePoint, planeNormal )
%   Split the given polyhedron into two polyhedra by the plane that passes
%   through the given point witht he given normal vector.
%
%   The first of the two new polyhedra is the one on the positive side of
%   the plane.
%
%   The polyhedron is assumed to be convex.

% WORK IN PROGRESS. VERY PRELIMINARY STAGE. 2022-06-21.

% I need to have edge data as well, or else I'll have to recompute it. So
% perhaps best to take a volcells structure as input, and specify which
% cell we want to split.

% We also don't necessarily want to split the cell, just find the area of
% the splitting plane.

    % Find which side of the plane each vertex lies on.
    
    projections = dot( vxs-planePoint, planeNormal );
    vxsides = sign( projections );
    
    % Classify faces into those lying all on one side or the other, and
    % those that were positively cut.
    
    for i=1:length(polyfaces)
        facevxsides = vxsides( polyfaces{i} );
        polyedges
    end
    
    % For each edge going from one side to the other, find the cutting
    % point. Find also the vertexes lying in the plane.
    
    % Make a new vertex for each cut edge.

    % For each face positively cut, there should be exactly two points at
    % which it was cut. This gives a binary relation on the cutting points,
    % which should form a cycle. Caution: the cutting plane might pass
    % exactly through an edge. So the binary relation we are looking for
    % should be: two cut edges or non-adjacent vertexes of the same face,
    % or two ends of the same edge.
    
    % Make a new face for this cycle of cutting points.
    
    % Make two new faces for each cut face.
    
    % NEWVXS will be an array of the 3d positions of the new vertexes.
    % NEWPOLYFACES1 and 2 will index these as if they were appended to VXS.
end