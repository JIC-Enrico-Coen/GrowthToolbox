function m = leaf_paintpatch( m, varargin )
%m = leaf_paintpatch( m, cells, morphogen, amount )
%   Apply the given amount of the given morphogen to every vertex of each
%   of the cells.  The cells are identified numerically; the numbers are
%   not user-accessible.  This command is therefore not easily used
%   manually; it is generated when the user clicks on a cell in the GUI.
%   Arguments:
%   1: A list of the cells to apply the morphogen to.
%   2: The morphogen name or index.
%   3: The amount of morphogen to apply.
%
%   Equivalent GUI operation: clicking on every vertex of the cell to be
%   painted, with the "Current mgen" item selected in the "Mouse mode" menu.
%   The morphogen to apply is specified in the "Displayed m'gen" menu in
%   the "Morphogens" panel.
%
%   Topics: Morphogens.

    if isempty(m), return; end
    [ok, vxs, args] = getTypedArg( mfilename(), 'numeric', varargin );
    if ~ok, return; end
    vxs = floor(vxs);
    [s,ok] = safemakestruct( mfilename(), args );
    if ~ok, return; end
    % s = defaultfields( s, 'param', 1, 'value', 0 );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'param', 'value' );
    
    g = FindMorphogenIndex( m, s.param, mfilename() );
    if isempty(g), return; end

    for ci = 1:length(cells)
        for i = m.tricellvxs(cells(ci),:)
            m.morphogens(i,g) = s.value;
            m.morphogenclamp(i,g) = 0;
        end
    end
    m.saved = 0;
end
