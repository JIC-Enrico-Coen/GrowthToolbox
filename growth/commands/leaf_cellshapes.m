function [aniso,flatness,diameters,cellaxes,cellcentres] = leaf_cellshapes( m, cellindexes )
%[aniso,flatness,diameters,cellaxes,cellcentres] = leaf_cellshapes( m, cellindexes )
%   Calculate the shape of the best-fit ellipse for the given cells (by default all of them).
%
% If there are N cells to be processed, the results of this are:
% 
% aniso: An Nx1 vector of a numerical measure of anisotropy for each cell.  This is
% a number varying between 0 (isotropic, about the same diameter in all directions)
% and 1 (stretched into a narrow line).  The actual value is (a-b)/(a+b),
% where a and b are the diameters of the cell along the major and minor axes.
% 
% flatness:  An Nx1 vector of a numerical measure of the flatness of each cell.
% This is the ratio c/a, where c is the thickness perpendicular to
% the plane of the cell.  It is 0 for a perfectly flat cell.
% Anything over 0.5 means that the cell is not even slightly flat.
% Typical values for a cell occupying a small part of the mesh surface
% are from 0 to 0.1.
%
% diameters: An Nx3 array containing for each cell its diameters along the major axis,
% the minor axis, and the perpendicular axis respectively.
% 
% cellaxes: A 3x3xN array in which the columns of each 3x3 matrix are orthogonal unit
% vectors in the directions of the major axis, the minor axis, and the perpendicular.
% 
% cellcentres: An Nx3 array containing the centre point of each cell.
    
    if nargin < 2
        cellindexes = 1:length( m.secondlayer.cells );
    elseif islogical( cellindexes )
        cellindexes = find(cellindexes);
    end
    numcells = length( cellindexes );
    aniso = zeros(numcells,1);
    flatness = zeros(numcells,1);
    diameters = zeros(numcells,3);
    eigs = zeros(numcells,3);
    cellaxes = zeros(3,3,numcells);
    cellcentres = zeros(numcells,3);
    for i=1:numcells
        ci = cellindexes(i);
        cvxs = m.secondlayer.cells(ci).vxs;
        cellcoords = m.secondlayer.cell3dcoords( cvxs, : );
        [ca,eigs(i,:),cellcentres(i,:)] = bestFitEllipsoid( cellcoords, 'area' );
        [eigs(i,:),perm] = sort( eigs(i,:), 'descend' );
%         eigs = max(eigs,0); % In theory the eigenvalues must be non-negative,
%                             % but finite accuracy can yield small negative values.
        ca = ca(:,perm);
        projections = cellcoords*ca;
        diameters(i,:) = max(projections,[],1) - min(projections,[],1);
        ANISO_FROM_EIGS = true;
        if ANISO_FROM_EIGS
            major = eigs(i,1);
            minor = eigs(i,2);
        else
            major = diameters(i,1);
            minor = diameters(i,2);
        end
        aniso(i) = (major - minor)/(major + minor);
        flatness(i) = diameters(i,3)/major;
        cellaxes(:,:,i) = ca;
    end
end
