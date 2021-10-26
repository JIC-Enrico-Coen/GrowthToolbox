function [aniso,flatness,eigs,cloneaxes,clonecentres,cloneareas] = cloneshapes( m, cloneindexes )
    % Eliminate clone indexes of zero, and sort by cloneindex.
    clonecellmap = cloneindexes>0;
    cloneindexes = cloneindexes(clonecellmap);
    clonecells = find(clonecellmap);
    cloneindexes = cloneindexes(cloneindexes>0);
    [cloneindexes,perm] = sort( cloneindexes );
    clonecells = clonecells(perm);
    
    % Find the runs of the same value of clone index.
    [starts,ends] = runends( cloneindexes );
    
    cellcentres = biocellcentres( m, clonecells );
    cellareas = m.secondlayer.cellarea(clonecells,:);
    
    % For each clone...
    numclones = length(starts);
    dims = 3;
    aniso = zeros(numclones,1);
    flatness = zeros(numclones,1);
    eigs = zeros(numclones,dims);
    cloneaxes = zeros(dims,dims,numclones);
    clonecentres = zeros(numclones,dims);
    cloneareas = zeros(numclones,1);
    for i=1:numclones
        s = starts(i);
        e = ends(i);
        [ca,eig,clonecentres(i,:)] = bestFitEllipsoid( cellcentres(s:e,:), cellareas(s:e) );
        [eig,perm] = sort( eig, 'descend' );
        ca = ca(:,perm);
        major = eig(1);
        minor = eig(2);
        
        aniso(i) = (major - minor)/(major + minor);
        flatness(i) = eig(3)/major;
        eigs(i,:) = eig;
        cloneaxes(:,:,i) = ca;
        cloneareas(i) = sum( cellareas(s:e) );
        
        clonenormalguess = m.unitcellnormals( m.secondlayer.vxFEMcell( m.secondlayer.cells(s).vxs(1) ), : );
%         if dot( clonenormalguess(:), cloneaxes(:,3,i) ) < 0
%             cloneaxes(:,[2 3],i) = -cloneaxes(:,[2 3],i);
%         end
    end
end
