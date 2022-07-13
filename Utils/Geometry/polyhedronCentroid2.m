function [totalcentroid,totalmoment,totalvolume,eachcentroid,eachmoment,eachvolume] = polyhedronCentroid2( vxs3d, faces, volumes )
%[totalcentroid,totalmoment,totalvolume,eachcentroid,eachmoment,eachvolume] = polyhedronCentroid2( vxs, faces, volumes )
%   VXS is an N*3 array giving the coordinates of N points.
%   FACES is a cell array of F*1 cells, each containing an X*1 array of
%   indexes info VXS, the indexes being those of the face listed in order
%   around the face.
%   VOLUMES is a V*1 cell array in which each cell is an X*1 array listing
%   the faces of a polyhedron.
%
%   Alternatively, and single argument can be given called VOLCELLS, and
%   the three arguments are then volcells.vxs3d, volcells.facevxs, and
%   volcells.polyfaces.
%
%   TOTALCENTROID will be the centroid of the whole volume.
%   TOTALMOMENT will be the 3x3 moment of inertia tensor of the whole volume
%   relative to its centroid (assuming unit density).
%   TOTALVOLUME will be the total volume of all the polyhedra.
%   EACHCENTROID will be a V*3 array giving the centroid of each
%   polyhedron.
%   EACHMOMENT will be a 3*3*V array of the moment tensors of each
%   polyhedron.
%   EACHVOLUME will be  V*1 array of all the polyhedra.


    if nargin==1
        volcells = vxs3d;
        vxs3d = volcells.vxs3d;
        faces = volcells.facevxs;
        volumes = volcells.polyfaces;
    end

    numdims = size(vxs3d,2);
    numvols = length(volumes);
    
    eachmoment = zeros( numdims, numdims, numvols );
    eachcentroid = zeros( numvols, numdims );
    eachvolume = zeros( numvols, 1 );
    for vi=1:numvols
        % Find a "centre" for every face by taking the centroid of its
        % vertexes. Find a "centre" for the volume by either taking the mean of
        % the face centres or the mean of all the vertexes. The precise
        % placement of these is not important. What is important is that the
        % tetrahedrons that each volume is divided into are disjoint. This
        % requires the volume centre to lie in a position from which the entire
        % inside surface of the polyhedron can be seen. It also requires each
        % face centre to see all of the edges of the face. Using the vertex
        % centroids is a rough rule of thumb.
        volfaces = volumes{vi};
        volvxs = unique( cell2mat( faces(volfaces) ) );
        facevxcentre = zeros( length(volfaces), numdims );
        for fi=1:length(volfaces)
            facevxcentre(fi,:) = mean( vxs3d( faces{volfaces(fi)}, : ), 1 );
        end
%         volvxcentre = mean( facevxcentre, 1 );
        volvxcentre = mean( vxs3d(volvxs,:), 1 );
        
        facemoments = zeros( numdims, numdims, length(volfaces) );
        facecentroids = zeros( length(volfaces), numdims);
        facevols = zeros( length(volfaces), 1 );
        for fi=1:length(volfaces)
            % Find the moment, centroid, and volume of every tetrahedron
            % making up this face pyramid.
            face1 = faces{volfaces(fi)};
            nfvxs = length(face1);
            facevolvxs = [ vxs3d( face1, : ); facevxcentre(fi,:); volvxcentre ];
            tetras = [ (1:nfvxs)', [2:nfvxs 1]', repmat( [nfvxs+1, nfvxs+2], nfvxs, 1 ) ]; % nfvxs * (numdims+1)
            
            tetravectors = permute( reshape( facevolvxs( tetras', : ), numdims+1, nfvxs, numdims ), [1 3 2] ); % (numdims+1) * numdims * nfvxs
            tetracentroids = zeros( nfvxs, numdims );
            tetramoments = zeros( numdims, numdims, nfvxs );
            tetravols = zeros( nfvxs, 1 );
            for ti=1:nfvxs
               [tetramoments(:,:,ti),tetracentroids(ti,:),tetravols(ti)] = tetrahedronMoment( tetravectors(:,:,ti) );
            end
            % Combine the tetrahedron properties to get properties of the face pyramid.
            [facemoments(:,:,fi),facecentroids(fi,:),facevols(fi)] = combineMoments( tetramoments, tetracentroids, tetravols );
        end
        % Combine the face properties to get the volume properties.
        [eachmoment(:,:,vi),eachcentroid(vi,:),eachvolume(vi)] = combineMoments( facemoments, facecentroids, facevols );
    end
    % Combine the volume properties to get the total properties.
    [totalmoment,totalcentroid,totalvolume] = combineMoments( eachmoment, eachcentroid, eachvolume );
end

function [totalmoment,totalcentroid,totalvolume] = combineMoments( moments, centroids, volumes )
%[totalmoment,totalcentroid,totalvolume] = combineMoments( moments, centroids, volumes )
%   Given volumes, centres of mess, and momemnts of inertia tensors about
%   the centres of mass for some number of objects, calculate the volume,
%   centre of mass, and inertia tensor of the union relative to the union
%   centre of mass.

    totalvolume = sum( volumes );
    totalcentroid = sum( centroids .* volumes, 1 )/totalvolume;
    totalmoment = sum( moments, 3 );
    for i=1:length(volumes )
        totalmoment = totalmoment + pointMassInertia( centroids(i,:) - totalcentroid, volumes(i) );
    end
end
