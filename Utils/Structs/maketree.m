function t = maketree( n, s, b, b1 )
%t = maketree( n, s, b )
%   n = number of items.
%   s = index of first item.
%   b = maximum number of descendants of a node.
%   b1 = maximum number of descendants of the root node (defaults to b).

  % fprintf( 1, 'maketree( %d, %d, %d )\n', n, s, b );
    if n==1
        t = s;
        return;
    end
    
    if nargin < 4
        b1 = b;
    end


    % Let k be such that b1*b^(k-2) < n <= b1*b^(k-1).
    k = 1;
    bk = b1;
    while bk < n
        k = k+1;
        bk = bk*b;
    end
    
    % If all of the items can be accommodated at top level, do so, and
    % return.
    if k==1
        t = s:(s+n-1);
        return;
    end

    % Otherwise, we have exactly b1 branches at the root, and at least one
    % of the leaves must be at depth at least 2.
    t = cell( 1, b1 );
    
    % bk is the number of possible nodes at depth k (the root being depth
    % zero).  Not all of these nodes need be occupied, but at least one is,
    % and there are no leaves at any greater depth.
    % bk1 is the number of nodes at depth k-1.
    bk1 = bk/b;
    k1 = bk/b1;
    k2 = bk1/b1;
    e = ceil( (n - bk1)/(k1 - k2) );
    numk2 = b1-e;
    % numk2 is the number of children of the root that have a complete b-ary
    % tree of depth k-2.  Each of these has k2 leaves.
    % Of the remaining e = b1-numk2 children of the root, all but at most one
    % have a complete b-ary tree of depth k-1.  Each of these has k1
    % leaves.  The single possible exception will be handled by a recursive
    % call of maketree.
    vacancies = numk2*k2 + e*k1 - n;
    % vacancies is the number of leaves whereby that single exception falls
    % short of completeness.  If this is zero there is no exception.
    numk1 = b1-numk2;
    if vacancies > 0
        numk1 = numk1-1;
    end
    % numk1 is the number of children of the root that have a complete b-ary
    % tree of depth k-1.  Each of these has k1 leaves.

    s1 = s;
    i = 1;

    % Insert the complete subtrees of depth k-2.
    for j=1:numk2
        t{i} = fulltree( s1, b, k-2 );
        s1 = s1 + k2;
        i = i+1;
    end

    % Insert the exceptional subtree.
    if vacancies > 0
        nummid = k1 - vacancies;  % The number of leaves in the exceptional
                                  % subtree.
        t{i} = maketree( nummid, s1, b );
        i = i+1;
        s1 = s1 + nummid;
    end

    % Insert the complete subtrees of depth k-1.
    for j=1:numk1 % (a+1):b1
        t{i} = fulltree( s1, b, k-1 );
        i = i+1;
        s1 = s1 + k1;
    end
    
    %printtree( 1, t )
end

% function printtree( fid, t, indent )
%     if nargin < 3
%         indent = 0;
%     end
%     if isnumeric(t)
%         fprintf( fid, '%*s', indent, ' ' );
%         fprintf( fid, ' %d', t );
%         fprintf( fid, '\n' );
%     else
%         fprintf( fid, '%*s----\n', indent, ' ' );
%         indent = indent+2;
%         for i=1:length(t)
%             printtree( fid, t{i}, indent );
%         end
%     end
% end


function [t,n] = fulltree( s, b, k )
    if k==0
        t = s;
        n = 1;
    elseif k==1
        t = s:(s+b-1);
        n = b;
    else
        t = cell( 1, b );
        s1 = s;
        for i=1:b
            [t{i},n] = fulltree( s1, b, k-1 );
            s1 = s1 + n;
        end
        n = n*b;
    end
end

