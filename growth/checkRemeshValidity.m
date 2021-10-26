function [ok,newvxs,newtetras] = checkRemeshValidity( vxs, tetras, merges )
%[ok,newvxs,newtetras] = checkRemeshValidity( vxs, tetras, merges )
%   Determine whether a proposed transformation of a tetrahedral mesh is
%   valid.
%
%   VXS is a V*3 set of vertex positions.
%   TETRAS is a T*4 set of quadruples of vertex indexes.
%   MERGES is a set of sets of vertexes to be merged, given as an M*1 array
%   in which the sets are terminated by zeros.
%
%   Three tests are performed.
%
%   1.  No two of the resulting tetrahedra may have the same set of
%   vertexes.
%
%   2.  No tetrahedron may be turned inside out.
%
%   3.  The minimum quality of the set of tetrahedra must not be reduced.

    ok = true;

    % Find the start and end of each set.
    numvxs = size(vxs,1);
%     numtetras = size(tetras,1);
    ends = find(merges(:)==0) - 1;
    starts = [ 1; ends(1:(end-1))+2 ];
    numsets = length(starts);
    centroids = zeros(numsets,3);
%     numelidedvxs = sum(ends-starts);
%     numnewvxs = numvxs - numelidedvxs;
    keepvxs = true(numvxs,1);
    renumvxs = 1:numvxs;
    for i=1:numsets
        set = merges(starts(i):ends(i));
        centroids(i,:) = sum(vxs(set,:),1)/length(set);
        keepvxs(set(2:end)) = false;
        renumvxs(set) = set(1);
    end
    [~,~,urenumvxs] = unique(renumvxs);
    newvxs = vxs;
    newvxs(merges(starts),:) = centroids;
    newvxs = newvxs( keepvxs, : );
    newtetras = reshape( urenumvxs(tetras), size(tetras) ); % The reshape is necessary when size(tetras,1) = 1. Matlab idiocy.
    
    % Tetras in which any two nodes were merged are deleted
    snewtetras = sort(newtetras,2);
    keeptetras = all( snewtetras(:,1:3) ~= snewtetras(:,2:4), 2 );
    numKeptTetras = sum( keeptetras );
    newToOldTetras = find(keeptetras);
    oldtetras = tetras(keeptetras,:);
    newtetras = newtetras(keeptetras,:);
    snewtetras = snewtetras(keeptetras,:);

    
    % 1.  After merging, no two tetras should have the same set of
    % vertexes.
    [uniquetetras,~,ic] = unique(sort(snewtetras,2),'rows');
    if size(uniquetetras,1) ~= numKeptTetras
        % At least two tetras get the same set of vertexes.
        ok = false;
        [sic,sip] = sort(ic);
        dups = sic(1:(end-1))==sic(2:end);
        dups = [dups; false] | [false; dups];
        fprintf( 1, 'Some tetras get the same sets of vertexes.\n' );
        olddups = tetras( newToOldTetras(sip(dups)), : )
        newdups = newtetras( sip(dups), : )
        xxxx = 1;
    end
        
    % 2.  The signed volume must not change sign.
    oldvolumes = tetravolume( vxs, oldtetras );
    newvolumes = tetravolume( newvxs, newtetras );
    flipped = sign(oldvolumes) ~= sign(newvolumes);
    if any( flipped )
        % At least one tetra gets flipped.
        ok = false;
        fprintf( 1, '%d tetras are turned inside out.\n', sum( flipped ) );
        fprintf( 1, '%4d %4d %4d %4d %8.3g %4d %4d %4d %4d %8.3g\n', ...
            [ oldtetras(flipped,:), ...
              oldvolumes(flipped), ...
              newtetras(flipped,:), ...
              newvolumes(flipped) ]' );
        xxxx = 1;
    end
    
    % 3.  The qualities of the tetrahedra should not decrease.
    [oldquality,oldvolume] = tetraquality( vxs, tetras );
    [newquality,newvolume] = tetraquality( newvxs, newtetras );
    [oldminq,oldmini] = min(oldquality);
    [newminq,newmini] = min(newquality);
    if min(newquality) < min(oldquality)
        ok = false;
        fprintf( 1, '%s: Minimum quality is reduced from %.4g to %.4g.\n', mfilename(), oldminq, newminq );
    end

end
