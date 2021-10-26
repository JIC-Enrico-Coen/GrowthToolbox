function [m,ok] = leaf_mgen_plotpriority( m, morphogen, priority, thresholds )
%m = leaf_mgen_plotpriority( m, morphogen, priority, thresholds )
%   Set the plotting priorities of specified morphogens.  In multi-plot
%   mode, the priorities determine whether morphogens present at the same
%   place are mixed, or one overlies the other.
%   The default priority for all morphogens is 0.  When multiple morphogens
%   of differing priorities are plotted together, the procedure for
%   determining the colour of a vertex is as follows:
%   1.  For each group of morphogens of the same priority, the colors for
%       those morphogens are mixed.  This gives one coloring of the whole
%       mesh for each priority group.
%   2.  At each vertex of the mesh, the chosen colour is taken from the
%       color map of highest priority for which at least one of the
%       associated morphogens is above its plotting threshold at that
%       vertex.
%   If the canvas has a background colour, it is considered to have
%   the same priority as the morphogen with least priority, or zero,
%   whichever is less.
%
%   Arguments:
%   1: The name or index of a morphogen, or a cell array of names or an
%      array of indexes
%   2: The priorities of the listed morphogens.  If a single value is given
%      it is applied to all of them. If multiple values are given there
%      must be exactly as many of them as in the list of morphogens.
%      Priorities can be any numerical value.
%   3: (Optional) Thresholds for each of the listed morphogens. In
%      multi-plotting mode, a morphogen whose value is less than or equal
%      to its threshold will be treated as zero for the purpose of masking
%      lower-priority morphogens.  The default threshold is zero.
%
%   Example:
%       m = leaf_mgen_plotpriority( m, ...
%                   {'id_sink','id_source','id_ridge'}, [1 1 2], [0,0,0.1] );
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

    if nargin < 4
        thresholds = zeros(1,length(priority) );
    end
    [m,ok] = leaf_plotpriority( m, morphogen, priority, thresholds, 'type', 'morphogen' );
end
