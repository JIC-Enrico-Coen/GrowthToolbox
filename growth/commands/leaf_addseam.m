function m = leaf_addseam( m, varargin )
%m = leaf_addseam( m, ... )
%   Marks some edges of m as being or not being seams, according to
%   criteria given in the options.  Unlike most other toolbox commands, the
%   options to this command are processed sequentially and the same option
%   may occur multiple times in the list.
%
%   Options:
%       'init'      Either 'all' or 'none'.  Sets either all of the edges,
%                   or none of them, to be seam edges.
%       'edges'     An array of edge indexes.  All of these edges will
%                   become seam edges.
%       'nonedges'  An array of edge indexes.  All of these edges will
%                   become non-seam edges.
%       'nodes'     An array of node indexes.  All edges joining two nodes
%                   in this set will become seam edges.
%       'nonnodes'  An array of node indexes.  All edges touching any node
%                   in this set will become non-seam edges.
%       'edgemap', 'nonedgemap', 'nodemap', 'nonnodemap':
%                   As above, but these are arrays of booleans specifying
%                   the edges of nodes to be included or excluded from the
%                   seams.
%       'morphogen' A cell array of two elements.  The first is a
%                   morphogen name or index.  The second is a string
%                   specifying how the value of the morphogen will be used
%                   as a criterion for deciding whether an edge should
%                   become a seam.  It consists of three parts.  It begins
%                   with one of 'min', 'mid', or 'max'.  This is followed
%                   by one of '<', '<=', '>=', or '>'.  This is followed by
%                   a number.  Examples: 'min>0.5' means that an edge
%                   becomes a seam if the minimum value of the morphogen at
%                   either end is greater than 0.5.  'max' would take the
%                   maximum of the ends, and 'mid' would take the average.
%
%   Example:
%
%       m = leaf_addseam( m, 'init', 'none', ...
%                            'nodemap', m.morphogens(:,12) > 0.1 );
%
%   Topics: Mesh editing, Seams.

    if isempty(m), return; end
    nargs = length(varargin);
    for i=1:2:(nargs-1)
        option = varargin{i};
        value = varargin{i+1};
        switch varargin{i}
            case 'init'
                switch value
                    case 'all'
                        m.seams(:) = true;
                    case 'none'
                        m.seams(:) = false;
                    otherwise
                end
            case 'edgemap'
                m.seams(value) = true;
            case 'nonedgemap'
                m.seams(value) = false;
            case 'nodemap'
                edgemap = value(m.edgeends(:,1)) & value(m.edgeends(:,2));
                m.seams(edgemap) = true;
            case 'nonnodemap'
                edgemap = value(m.edgeends(:,1)) | value(m.edgeends(:,2));
                m.seams(edgemap) = false;
            case {'edges','nonedges'}
                % Check value is numeric.  Coerce it to int and check all values in range.
                value = round(value(:));
                inrange = all(value >= 1) && all(value <= size(m.edgeends,1));
                if inrange
                    m.seams(value) = strcmp(option,'edges');
                else
                    % complain
                end
            case { 'nodes', 'nonnodes' }
                % Check value is numeric.  Coerce it to int and check all values in range.
                value = round(value(:));
                inrange = all(value >= 1) && all(value <= size(m.nodes,1));
                if inrange
                    nodemap = false(size(m.nodes,1),1);
                    nodemap(value) = true;
                    if strcmp(option,'nodes')
                        edgemap = nodemap(m.edgeends(:,1)) & nodemap(m.edgeends(:,2));
                        m.seams(edgemap) = true;
                    else
                        edgemap = nodemap(m.edgeends(:,1)) | nodemap(m.edgeends(:,2));
                        m.seams(edgemap) = false;
                    end
                else
                    % complain
                end
            case 'morphogen'
                % Parse value.
            otherwise
        end
    end
end
