function [ob2class,class2ob,adjc] = graphEqClasses( adj, varargin )
%[ob2class,class2ob,adjc] = graphEqClasses( adj, ... )
%   Given an N*N adjacency matrix ADJ, return OB2CLASS, an N*1 array
%   mapping the N objects to their class indexes 1:K, and CLASS2OB,
%   mapping class indexes to objects. CLASS2OB is K*P, where P is the
%   size of the largest class. Each row lists the objects in that class,
%   in ascending order, padded with trailing zeros.
%
%   The first column of CLASS2OB can be used to select a representative of
%   each class. The representative will be the first object in the class.
%
%   ADJC is the matrix representing the relation of being in the same
%   clique.
%
%   If any of the optional arguments is 'reflexive', this is taken as an
%   assertion that the given relation is already reflexive (and therefore
%   the reflexive closure does not have to be computed.
%
%   If any of the optional arguments is 'symmetric', this is taken as an
%   assertion that the given relation is already symmetric (and therefore
%   the symmetric closure does not have to be computed.

    adjc = adj;
    reflexive = any( strcmpi( 'reflexive', varargin ) );
    symmetric = any( strcmpi( 'symmetric', varargin ) );
    if ~reflexive
        adjc = adjc | eye(size(adjc));
    end
    if ~symmetric
        adjc = adjc | adjc';
    end
    
    while true
        newadjc = (adjc*adjc) ~= 0;
        if all( newadjc(:)==adjc(:) )
            break;
        end
        adjc = newadjc;
    end
    
    [c,~,ob2class] = unique( adjc, 'rows', 'stable' );
    class2ob = c.*(1:size(c,2));
    class2ob(class2ob==0) = Inf;
    class2ob = sort(class2ob,2);
    class2ob(isinf(class2ob)) = 0;
    class2ob( :, all(class2ob==0,1) ) = [];
end
