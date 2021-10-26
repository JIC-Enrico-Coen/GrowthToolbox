function m = leaf_deletepatch( m, varargin )
%m = leaf_deletepatch( m, fes )
%   Delete the specified finite elements from the leaf.
%
%   Arguments:
%   	cells: A list of the cells to delete, or a boolean map of the cells
%   	       which is true for the cells to be deleted.
%
%   Equivalent GUI operation: clicking on the mesh when the "Delete canvas"
%   item is selected in the "Mouse mode" pulldown menu.
%
%   Topics: Mesh editing.

    if isempty(m), return; end
    [ok, fes, args] = getTypedArg( mfilename(), {'numeric','logical'}, varargin );
    if ~ok, return; end
    if ~isempty(args)
        fprintf( 1, '%s: %d extra arguments ignored.\n', mfilename(), length(args) );
    end
    
    if islogical(fes)
        fes = find(fes);
    else
        fes = floor(fes);
    end
    m = deleteFEs( m, fes );
end
