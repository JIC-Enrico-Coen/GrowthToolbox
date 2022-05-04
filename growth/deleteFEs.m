function [m,deletionInfo] = deleteFEs(m,elementsToDelete)
%[m,deletionInfo] = deleteFEs(m,elementsToDelete)    Delete finite elements from the mesh.

    deletionInfo = [];
    if nargin==1, return; end
    
    if islogical(elementsToDelete)
        elementsToDelete = find(elementsToDelete);
    end
    if isempty(elementsToDelete), return; end
    
    if isVolumetricMesh(m)
        rFEmap = true( getNumberOfFEs(m), 1 );
        rFEmap(elementsToDelete) = false;

        % It is possible that deleting a set of elements results in a
        % non-manifold surface. When this happens, we delete more
        % elements until we get a manifold surface.
        % The problem is that if we delete an arbutrary subset of the
        % elements that share a given edge, that edge might be an edge
        % of more than two new surface faces. A vertex might also be a
        % member of two disjoint cycles of surface faces. All elements
        % containing any such problematic edge or face must be deleted
        % as well. This process of deleting more elements must be
        % repeated until no problematic edges or faces remain.

        % 1. Find all faces that will be surface faces in the new
        % mesh.

        % 2. For each edge of those faces, find how many of those faces
        % they belong to. Problematic edges are those belonging to more
        % than two faces.

        % 3. Add all elements that include any of these edges to the
        % deletion list.

        % 4. Find all surface vertexes of the new mesh. These are all
        % vertexes belonging to new surface edges.

        % 5. For each such vertex, find the surface faces and edges
        % they belong to.

        % 6. Determine how many cycles those edges and faces split
        % into. Problematic vertexes are those with more than one
        % cycle.

        % 7. Add all elements that include any of these vertexes to the
        % deletion list.



        [m,deletionInfo] = renumberMesh3D( m, 'fekeepmap', rFEmap );
        [result,m] = validmesh( m );
        if ~result
            xxxx = 1;
        end
        
        return;
    end
    
    numedges = size(m.edgeends,1);
    numelements = size(m.tricellvxs,1);
    elementsBitMap = true(numelements,1);
    edgesBitMap = true(numedges,1);
    elementsToDelete = unique(elementsToDelete);
    elementsBitMap(elementsToDelete) = false;
    if length(elementsToDelete)==numelements
        fprintf( 1, 'Attempt to delete entire mesh ignored.\n' );
        return;
    end

    % Find all edges bordering the elements and set the relevant element index to
    % zero.  Keep a list of edges that are to be deleted.
    numedgestodelete = 0;
    for cdi=1:length(elementsToDelete)
        fi = elementsToDelete(cdi);
        for fei=1:3
            ei = m.celledges(fi,fei);
            if m.edgecells(ei,2)==fi
                m.edgecells(ei,2) = 0;
            elseif m.edgecells(ei,1)==fi
                if m.edgecells(ei,2) == 0
                    m.edgecells(ei,1) = 0;
                    numedgestodelete = numedgestodelete+1;
                    edgesBitMap(ei) = false;
                else
                    m.edgecells(ei,:) = [m.edgecells(ei,2), 0];
                end
            end
        end
    end
    
    if numedgestodelete == 0
        nodesBitMap = [];
        edgesBitMap = [];
    else
        savednodes = m.edgeends(edgesBitMap,:);
        nodesBitMap(savednodes) = true;
    end
    
    m.secondlayer = deleteCellsInFEs( m.secondlayer, elementsBitMap, m.globalDynamicProps.currenttime );
    
    m = renumberMesh( m, [], [], [], ...
                         nodesBitMap, edgesBitMap, elementsBitMap );
    
    m.saved = 0;
  
    % Check validity.
    [result,m] = validmesh( m );
    if ~result
        xxxx = 1;
    end
end
