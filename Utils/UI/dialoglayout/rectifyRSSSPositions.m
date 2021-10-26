function s = rectifyRSSSPositions( s, pos )
    % Pass 1: Compact all space.
    s = compactSpace( s );
    % We now know the minimum size of every element.
    % Pass 2:
    s = forcePosition( s, pos );
end


function x = rowheight( s )
% Natural vsize = maximum of vsizes of non-fill children and
% minsizes of fill children, if any.  Otherwise, max minsize of
% any child.
    n = length(s.children);
    csizes = zeros( 1, n );
    cminsizes = zeros( 1, n );
    cfill = false( 1, n );
    for i=1:n
        csizes(i) = s.children{i}.attribs.position(4);
        cminsizes(i) = s.children{i}.attribs.minsize(2);
        cfill(i) = strcmp( s.children{i}.attribs.valign, 'fill' );
    end
    x = max( [ csizes(~cfill), cminsizes(cfill) ] );
    if isempty(x) || (x > 0)
        x = max( cminsizes );
    end
end

function x = rowwidth( s )
    n = length(s.children);
    csizes = zeros( 1, n );
    for i=1:n
        csizes(i) = s.children{i}.attribs.position(3);
    end
    x = sum( csizes );
end

function x = colwidth( s )
% Natural vsize = maximum of vsizes of non-fill children and
% minsizes of fill children, if any.  Otherwise, max minsize of
% any child.
    n = length(s.children);
    csizes = zeros( 1, n );
    cminsizes = zeros( 1, n );
    cfill = false( 1, n );
    for i=1:n
        csizes(i) = s.children{i}.attribs.position(3);
        cminsizes(i) = s.children{i}.attribs.minsize(1);
        cfill(i) = strcmp( s.children{i}.attribs.valign, 'fill' );
    end
    x = max( [ csizes(~cfill), cminsizes(cfill) ] );
    if isempty(x) || (x > 0)
        x = max( cminsizes );
    end
end

function x = colheight( s )
    n = length(s.children);
    csizes = zeros( 1, n );
    for i=1:n
        csizes(i) = s.children{i}.attribs.position(4);
    end
    x = sum( csizes );
end
