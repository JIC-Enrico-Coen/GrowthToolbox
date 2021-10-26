function m = leaf_mgeninterpolation( m, varargin )
%m = leaf_mgeninterpolation( m, ... )
%   Set the interpolation mode of morphogens of m.  When an edge of the
%   mesh is split, this determines how the morphogen values at the new
%   vertex are determined from the values at either end of the edge.
%
%   Options:
%
%   'morphogen'     This can be a morphogen name or index, a cell array of
%                   morphogen names and indexes, or a vector of indexes.
%   'interpolation' Either 'min', 'max', or 'average'.  If 'min', the new
%                   values are the minimum of the old values, if 'max' the
%                   maximum, and if 'average' the average.
%
%   GUI equivalent: the radio buttons in the "On split" subpanel of the
%   "Morphogens" panel.  These set the interpolation mode for the current
%   morphogen.  As of the version of 2008 Sep 03, new meshes are created
%   with the interpolation mode for all morphogens set to 'min'.
%   Previously the default mode was 'average'.
%
%   Example:
%       m = leaf_mgeninterpolation( m, ...
%               'morphogen', 1:size(m.morphogens,2), ...
%               'interpolation', 'average' );
%       This sets the interpolation mode for every morphogen to 'average'.
%
%   Topics: Morphogens.

    if isempty(m), return; end
    [s,ok] = safemakestruct( mfilename(), varargin );
    if ~ok, return; end
    s = defaultfields( s, 'morphogen', '', 'interpolation', 'min' );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'morphogen', 'interpolation' );
    if ~ok, return; end
    
    mgenIndex = FindMorphogenIndex( m, s.morphogen, mfilename() );
    if false
        mgenIndex = [];
        if ischar(s.morphogen)
            mi = FindMorphogenIndex( m, s.morphogen, mfilename() );
            if ~isempty(mi)
                mgenIndex = mi;
            end
        elseif iscell( s.morphogen )
            for si=1:length(s)
                mi = FindMorphogenIndex( m, s.morphogen{si}, mfilename() );
                if ~isempty(mi)
                    mgenIndex = [ mgenIndex, mi ];
                end
            end
        else
            for si=1:length(s)
                mi = FindMorphogenIndex( m, s.morphogen(si), mfilename() );
                if ~isempty(mi)
                    mgenIndex = [ mgenIndex, mi ];
                end
            end
        end
    end

    if isempty(mgenIndex), return; end
    
    s.interpolation = lower(s.interpolation);
    switch s.interpolation
        case 'min'
            interpmode = 'min';
        case 'max'
            interpmode = 'max';
        otherwise
            interpmode = 'mid';
    end
    for i=1:length(mgenIndex)
        m.mgen_interpType{mgenIndex(i)} = interpmode;
    end

    saveStaticPart( m );
end
