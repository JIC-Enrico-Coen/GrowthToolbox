function m = deletepoints( m, pointstodelete )
%m = deletepoints( m, pointstodelete )
%   Delete the given set of vertexes from the finite element mesh.
%   Every finite element of which any of these vertexes is a vertex will be
%   deleted.  This may imply deleting some other vertexes that are left
%   without an element to be a vertex of.

    if nargin==1, return; end
    
    if isnumeric(pointstodelete)
        foo = true( 1, getNumberOfVertexes(m) );
        foo( pointstodelete ) = false;
        pointstodelete = foo;
    end
    if isVolumetricMesh(m)
        fesToDelete = any( pointstodelete(m.FEsets.fevxs), 2 );
    else
    	fesToDelete = any( pointstodelete(m.tricellvxs), 2 );
    end
    m = deleteFEs(m,fesToDelete);
    
%     if islogical( pointstodelete )
%         pointstodelete = find(pointstodelete);
%     end
%     if size(pointstodelete,2)==0, return; end
%     
%     numcells = size(m.tricellvxs,1);
%     nf = 0;
%     for pi=pointstodelete
%         for fi=1:numcells
%             if m.tricellvxs(fi,1)==pi
%                 nf = nf+1;
%                 cellsToDelete(nf) = fi;
%             end
%             if m.tricellvxs(fi,2)==pi
%                 nf = nf+1;
%                 cellsToDelete(nf) = fi;
%             end
%             if m.tricellvxs(fi,3)==pi
%                 nf = nf+1;
%                 cellsToDelete(nf) = fi;
%             end
%         end
%     end
%     if nf > 0
%         m = deleteFEs( m, cellsToDelete );
%     end
end

