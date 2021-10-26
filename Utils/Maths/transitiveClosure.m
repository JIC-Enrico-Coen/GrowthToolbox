function [rel,classes] = transitiveClosure( rel )
%rel = transitiveClosure( rel )
%   Find the transitive closure of a binary relation, specified as an N*N
%   boolean matrix.

    n = size(rel,1);
    while true
        rel2 = logical( (rel+rel'+eye(n))^2 );
        if all(rel2(:) == rel(:))
            break;
        end
        rel = rel2;
    end
    
    [~,~,classes] = unique( rel, 'rows' );
end
