function s = computeIntervals( s )
%s = computeIntervals( s )
%   s is a tree structure whose nodes may each have these attributes:
%       natsize: natural size (a number)
%       actualsize: actual size (a number)
%       position: two numbers: startpos and length.
%       align: 'min', 'max', 'mid', or 'fill'.
%   When s is given, none of the position attributes are set.  All leaves
%   have a natsize and the root has a maxsize.

    s = computeNatsizes( s );
    s = convertRelToAbsPos( s, refpos );
end

function s = convertRelToAbsPos( s, refpos )
%s = convertRelToAbsPos( s )
%   Every non-root node of s is assumed to have attribs.relpos defined.
%   This procedure fills in attribs.abspos as attribs.relpos offset by
%   refpos.  The same is done for the children; for panel nodes, children's
%   positions are defined relative to [0 0], for other grouping nodes, the
%   refpos of the children is the same as for the parent.

    s.attribs.abspos = s.attribs.relpos + [refpos 0];
    if strcmp(s.type,'panel')
        refpos = [0 0];
    end
    for i=1:length(s.children)
        s.children{i} = convertRelToAbsPos( s.children{i}, refpos );
    end
end

function s = computeNatsizes( s )
%s = computeNatsizes( s )
%   Given natural sizes at the leaves, compute them up to the root.
    if isempty(s.children)
        return;
    end
    cnatsizes = zeros(1,length(s.children));
    for i=1:length(s.children)
        s.children{i} = computeNatsizes( s.children{i} );
        cnatsizes = s.children{i}.attribs.natsize;
    end
    if any(cnatsizes > 0) && any(cnatsizes==0)
        % If there is at least one child with positive natsize, then for
        % every child with a zero natsize, set its natsize to the minimum
        % of the positive natsizes.
        defaultsize = min( cnatsizes(cnatsizes>0) );
        for i=1:length(s.children)
            if cnatsizes(i)==0
                s.children{i} = setNatSizes( s.children{i}, defaultsize );
                cnatsizes(i) = defaultsize;
            end
        end
    end
    % At this point, the natsizes of the children are either all positive
    % or all zero.
    
    % Set the natural size of this element.
    s.attribs.natsize = sum( cnatsizes ) + s.attribs.margin*(length(s.children)+1);
    
    % If we have no actual size, or it is less than the natural size, set
    % it to the natural size.
    if s.attribs.actualsize <= s.attribs.natsize
        s.attribs.actualsize = s.attribs.natsize;
    end
    
    % Transmit the actual size to the chidren.
    s = transmitActualSize( s );
end

function s = transmitActualSize( s )
    if s.attribs.actualsize == s.attribs.natsize
        return;
    end
    numchildren = length(s.children);
    if numchildren==0
        return;
    end
    switch s.attribs.align
        case 'min'
            s.attribs.relpos = [0, s.attribs.natsize];
        case 'max'
            s.attribs.relpos = [s.attribs.actualsize-s.attribs.natsize, s.attribs.natsize];
        case 'mid'
            s.attribs.relpos = [(s.attribs.actualsize-s.attribs.natsize)/2, s.attribs.natsize];
        otherwise
            s.attribs.relpos = [0, s.attribs.actualsize];
    end
    if numchildren > 0
        excess = s.attribs.actualsize-s.attribs.natsize;
        switch s.attribs.distribution
            case 'equal'
                for i=1:numchildren
                    s.children{i}.attribs.actualsize = ...
                        s.children{i}.attribs.natsize + excess/numchildren;
                    s.children{i} = transmitActualSize( s.children{i} );
                end
            case 'proportional'
                csz = zeros(1,numchildren);
                for i=1:numchildren
                    csz(i) = s.children{i}.attribs.natsize;
                end
                weights = csz/sum(czs);
                excesses = excess*weights;
                for i=1:numchildren
                    s.children{i}.attribs.actualsize = ...
                        s.children{i}.attribs.natsize + excesses(i);
                    s.children{i} = transmitActualSize( s.children{i} );
                end
            case 'elastic'
                % Distribute the excess over the elastic children
                % only.
        end
    end
end

function s = setNatSizes( s, sz )
%s = setNatSizes( s );
%   Set the natural sizes for a structure, none of whose nodes have natural
%   sizes.

    s.attribs.natsize = sz;
    if ~isempty(c.shildren)
        csz = sz/length(s.children);
        for i=1:length(s.children)
            s.children{i}.attribs.natsize = csz;
        end
    end
end
