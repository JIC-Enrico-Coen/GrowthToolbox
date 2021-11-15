function m = leaf_deletenodes( m, varargin )
%m = leaf_deletenodes( m, nodes )
%   Delete from the leaf every finite element for which any of the nodes is a vertex.
%
%   Arguments:
%   	nodes: A list of the nodes to delete, or a boolean map of the nodes
%   	       which is true for the nodes to be deleted.
%
%   Equivalent GUI operation: none.
%
%   Topics: Mesh editing.
%
%   See also: leaf_deleteElements

    if isempty(m), return; end
    [ok, nodes, args] = getTypedArg( mfilename(), {'numeric','logical'}, varargin );
    if ~ok, return; end
    if ~isempty(args)
        fprintf( 1, '%s: %d extra arguments ignored.\n', mfilename(), length(args) );
    end
    
    if ~islogical(nodes)
        nodemap = false( getNumberOfVertexes(m), 1 );
        nodemap(nodes) = true;
        nodes = nodemap;
    end
    listcells = find( cellMapFromNodeMap( m, nodes, 'any' ) );
    m = leaf_deleteElements( m, listcells );
end
