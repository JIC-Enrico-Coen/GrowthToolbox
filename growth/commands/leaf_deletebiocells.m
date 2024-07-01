function m = leaf_deletebiocells( m, varargin )
%m = leaf_deletebiocells( m, ... )
%   Delete selected cells from the biological layer.
%
%   Options:
%
%   cellstodelete: Either a boolean map of the cells to delete, or a list
%           of their indexes.
%
%   numtodelete: An integer, the number of cells to delete.
%
%   fractodelete: A number between 0 and 1, the proportion of cells to
%           delete. If numtodelete and fractodelete are both specified,
%           only numtodelete is used.
%
%   probperbiocell: For each biological cell, the probability that that
%           cell will be deleted.  The name or index of a cellular
%           morphogen can also be given.
%
%   probperFEvx: For each vertex of the finite element mesh, the
%           probability that a cell located there will be deleted.
%           The name or index of a tissue morphogen can also
%           be given.
%
%   probperFE: For each finite element, the probability that a cell located
%           there will be deleted.
%
%   threshold: A pair of numbers [x y].  If this is given, and one or more
%           of the probability options is given, then the probabilities are
%           reinterpreted.  Every cell for which the "probability" lies in
%           the range x...y (including the endpoints) will be deleted. x
%           may validly be -Inf, to delete all cells where the
%           "probability" is y or less.  y may be Inf, to delete all cells
%           where the "probability" is x or more.  If a single number is
%           given it is taken to be x, with y set to Inf. 'threshold' is
%           ignored if none of the probability distributions are given.
%
%   Note that when transferring finite element values to cells, a certain
%   amount of "blurring" is unavoidable, and this should be considered when
%   selecting a suitable threshold.
%
%   If cellstodelete is given and nonempty, all other options are ignored.
%   Exactly the specified cells are deleted.
%
%   If multiple options among probperbiocell, probperFEvx, and probperFE
%   are given, the resulting probabilities for the cells will be
%   multiplied together.  If no probabilities are given, a uniform
%   distribution is assumed.
%
%   If either numtodelete or fractodelete is given, the absolute number of
%   cells to be deleted is calculated, and the cells are then selected in
%   accordance with the probabilities until the exact number has been
%   selected for deletion.  When probability distributions are used, a cell
%   whose probability is zero is never selected for deletion, even if this
%   means that the requested number to be deleted cannot be achieved.
%
%   EXAMPLES.
%
%   To delete a specific set of cells, make a boolean map of the cells to
%   be deleted, and supply it as the probperbiocell option.  For example,
%   if it is desired to delete every cell for which cellular morphogen
%   number 4 is above 0.8:
%
%       m = leaf_deletebiocells( m,
%               'probperbiocell', m.secondlayer.cellvalues(:,4) > 0.8 );
%
%   To delete all cells where the tissue morphogen 'ID_NOCELLSPLEASE' is 1
%   (assuming it is 0 or 1 at every finite element vertex):
%
%       m = leaf_deletebiocells( m,
%               'probperFEvx', 'ID_NOCELLSPLEASE',
%               'threshold', 0.5 );
%
%   To delete all cells where the tissue morphogen 'ID_KEEPTHESECELLS' is 0:
%
%       m = leaf_deletebiocells( m,
%               'probperFEvx', 'ID_KEEPTHESECELLS',
%               'threshold', [-Inf 0.5] );

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, ...
        'cellstodelete', -1, ...
        'numtodelete', [], ...
        'fractodelete', [], ...
        'probperbiocell', [], ...
        'probperFEvx', [], ...
        'probperFE', [], ...
        'threshold', [] );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'cellstodelete', ...
        'numtodelete', ...
        'fractodelete', ...
        'probperbiocell', ...
        'probperFEvx', ...
        'probperFE', ...
        'threshold' );
    if ~ok, return; end
    
    numcells = length( m.secondlayer.cells );
    if numcells==0
        % There are already no cells. Nothing to do.
        return;
    end
    
    if isempty(s.cellstodelete)
        return;
    end
    
    if s.cellstodelete(1) ~= -1
        m.secondlayer = deleteSecondLayerCells( m.secondlayer, s.cellstodelete, m.globalDynamicProps.currenttime );
        return;
    end
    
    pb = 1;
    if ~isempty( s.probperbiocell )
        if ischar( s.probperbiocell ) || (length(s.probperbiocell)==1)
            cellmgenindex = name2Index( m.secondlayer.valuedict, s.probperbiocell );
            if ~isempty(cellmgenindex) && (cellmgenindex ~= 0)
                pb = m.secondlayer.cellvalues(cellmgenindex,:);
            end
        elseif length(s.probperbiocell)==numcells
            pb = s.probperbiocell;
        end
    end
    
    pv = 1;
    if ~isempty( s.probperFEvx )
        if ischar( s.probperFEvx ) || (length(s.probperFEvx)==1)
            mgenindex = FindMorphogenIndex( m.secondlayer.valuedict, s.probperbiocell );
            if ~isempty(mgenindex) && (mgenindex ~= 0)
                pv = m.morphogens(mgenindex,:);
            end
        elseif length(s.probperFEvx)==getNumberOfVertexes(m)
            pv = s.probperFEvx;
        end
        if length(pv)==getNumberOfVertexes(m)
            pv = leaf_FEVertexToCellularValue( m, pv, 'mode', 'cell' );
        else
            pv = 1;
        end
    end
    
    pf = 1;
    if length( s.probperFE )==getNumberOfFEs( m )
        pf = perFEtoperVertex( m, s.probperFE );
        pf = leaf_FEVertexToCellularValue( m, pf, 'mode', 'cell' );
    end
    
    p = pb .* pv .* pf;
    
    if ~isempty( s.numtodelete )
        N = s.numtodelete;
    elseif ~isempty( s.fractodelete )
        N = round( s.fractodelete * numcells );
    else
        N = [];
    end
    
    if length(p)==numcells
        if ~isempty( s.threshold )
            if length( s.threshold )==1
                p = p >= s.threshold;
            else
                p = (p >= s.threshold(1)) & (p <= s.threshold(2));
            end
        end
        if isempty(N)
            cellstodelete = rand(numcells,1) < p;
        else
            [~,cellstodelete] = randSampleNoReplace( numcells, N, p );
        end
    else
        [~,cellstodelete] = randSampleNoReplace( numcells, N );
    end
    
    m.secondlayer = deleteSecondLayerCells( m.secondlayer, cellstodelete, m.globalDynamicProps.currenttime );
end
