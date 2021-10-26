function [m,ok] = leaf_plotpriority( m, values, priority, threshold, varargin )
%m = leaf_plotpriority( m, factors, priority, thresholds, ... )
%   Set the plotting priorities of specified factors or cell factors --
%   hereafter called factors.  In multi-plot mode, the priorities determine
%   whether factors present at the same place are mixed, or one overlies
%   the other.
%   The default priority for all factors is 0.  When multiple factors
%   of differing priorities are plotted together, the procedure for
%   determining the colour of a vertex is as follows:
%   1.  For each group of factors of the same priority, the colors for
%       those factors are mixed.  This gives one coloring of the whole
%       mesh for each priority group.
%   2.  At each vertex of the mesh, the chosen colour is taken from the
%       color map of highest priority for which at least one of the
%       associated factors is above its plotting threshold at that
%       vertex.
%   If the canvas has a background colour, it is considered to have
%   the same priority as the factor with least priority, or zero,
%   whichever is less.
%
%   Arguments:
%   1: The name or index of a factor, or a cell array of names or an
%      array of indexes.
%   2: The priorities of the listed factors.  If a single value is given
%      it is applied to all of them. If multiple values are given there
%      must be exactly as many of them as in the list of factors.
%      Priorities can be any numerical value.
%   3: Thresholds for each of the listed factors.  If a single
%      value is given it is applied to all of them. If multiple values are
%      given there must be exactly as many of them as in the list of
%      factors. A factor whose value is less than or equal
%      to its threshold will be treated as zero for the purpose of masking
%      lower-priority factors.  Use zero if no threshold is to be applied.
%
%   Example:
%       m = leaf_mgen_plotpriority( m, ...
%              {'id_sink','id_source','id_ridge'}, [1 1 2], [0,0,0.1], ...
%              'type', 'morphogen' );
%   This gives priority 2 to the morphogen id_ridge, 1 to id_sink and
%   id_source, and leaves all others with the default priority of zero.  If
%   all morphogens are being plotted together, then where id_ridge is
%   greater than 0.1, its colour will be plotted.  Elsewhere, where id_sink or
%   id_source is greater than zero, their colours will be mixed and plotted.
%   Everywhere else, the other morphogen colours will be mixed together.
%   This will have the effect that id_source will overlie id_sink, and both
%   will overlie all other morphogens.
%
%   Equivalent GUI operation: None.
%
%   Topics: Plotting.

    ok = false;
    if isempty(m), return; end
    ok1 = checkType( mfilename(), {'numeric','char','cell'}, values );
    if ok1
        ok2 = checkType( mfilename(), 'numeric', priority );
    end
    if ~(ok1 && ok2), return; end
    ok = checkType( mfilename(), 'numeric', threshold );
    if ~ok, return; end
    s = struct( varargin{:} );
    s = defaultfields( s, 'type', 'morphogen' );
    ok = checkcommandargs( mfilename(), s, 'exact', ...
        'type' );
    if ~ok, return; end

    switch s.type
        case 'morphogen'
            g = FindMorphogenIndex( m, values, mfilename() );
            valuename = 'morphogen';
        case 'cellvalue'
            g = FindCellValueIndex( m, values, mfilename() );
            valuename = 'cell value';
        otherwise
            complain( '%s: type option ''%s'' unrecognised. ''morphogen'' or ''cellvalue'' expected.\n', ...
                mfilename(), s.type );
            return;
    end
    if (length(priority) ~= 1) && (length(priority) ~= length(g))
        if length(g)==1
            complain( '%s: wrong number of priorities given: 1 expected, %d found.\n', ...
                mfilename(), length(priority) );
        else
            complain( '%s: wrong number of priorities given: 1 or %d expected, %d found.\n', ...
                mfilename(), length(g), length(priority) );
        end
        return;
    end
    if (length(threshold) ~= 1) && (length(threshold) ~= length(g))
        if length(g)==1
            complain( '%s: wrong number of thresholds given: 1 expected, %d found.\n', ...
                mfilename(), length(threshold) );
        else
            complain( '%s: wrong number of thresholds given: 1 or %d expected, %d found.\n', ...
                mfilename(), length(g), length(threshold) );
        end
        return;
    end
    if any(g==0)
        complain( '%s: %ss not found:\n', valuename, mfilename() );
        values(g==0)
        priority = priority(g ~= 0);
        values = values(g ~= 0);
        g = g(g~=0);
    end
    ok = true;
    if isempty(g)
        return;
    end
    switch s.type
        case 'morphogen'
            m.mgen_plotpriority(g) = priority;
            m.mgen_plotthreshold(g) = threshold;
        case 'cellvalue'
            m.secondlayer.cellvalue_plotpriority(g) = priority;
            m.secondlayer.cellvalue_plotthreshold(g) = threshold;
    end
    saveStaticPart( m );
end
