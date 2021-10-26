function [count,whichmap] = leaf_countBioCells( m, varargin )
% [count,whichmap] = countBioCells( m, mgen, threshold, mode )
%   Count cells in a region defined by a distribution on the finite element
%   vertexes.
%
%   MGEN is either a value per finite element vertex, or a morphogen name,
%   or a morphogen index.
%
%   THRESHOLD is a real number against which the morphogen will be compared
%   at the vertexes of the cellular mesh.
%
%   MODE determines the criterion for selecting a cell:
%
%   'min': (The default.)  A cell is included if every vertex of the cell
%          has a value >= the threshold.
%
%   'max': A cell is included if some vertex of the cell has a value >=
%          the threshold.
%
%   'ave': A cell is included if the average of the morphogen over the
%          vertexes of the cell is >= the threshold.
%
%   'maj': A cell is included if a strict majority of its vertexes have a
%          value of the morphogen >= the threshold.
%
%   COUNT will be the number of cells meeting the criterion.
%   WHICHMAP will be a boolean map of the cells meeting the criterion.

    count = 0;
    numcells = length(m.secondlayer.cells);
    whichmap = false( 1, numcells );
    
    if numcells==0
        return;
    end
    
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    setGlobals();
    s = defaultfields( s, 'morphogen', [], 'threshold', [], 'mode', 'min' );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'morphogen', 'threshold', 'mode' );
    if ~ok, return; end

    mpv = mgenPerCellVertex( m, s.morphogen );
    if isempty(mpv)
        return;
    end
    
    switch s.mode
        case 'min'
            for i=1:numcells
                whichmap(i) = all( mpv( m.secondlayer.cells(i).vxs ) >= s.threshold );
            end
        case 'max'
            for i=1:numcells
                whichmap(i) = any( mpv( m.secondlayer.cells(i).vxs ) >= s.threshold );
            end
        case 'ave'
            for i=1:numcells
                whichmap(i) = sum( mpv( m.secondlayer.cells(i).vxs ) ) / length( m.secondlayer.cells(i).vxs )  >= s.threshold;
            end
        case 'maj'
            for i=1:numcells
                whichmap(i) = sum( mpv( m.secondlayer.cells(i).vxs ) >= s.threshold ) * 2 > length( m.secondlayer.cells(i).vxs );
            end
    end
    count = sum(whichmap);
end
