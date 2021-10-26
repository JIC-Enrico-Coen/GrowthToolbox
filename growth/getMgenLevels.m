function [i,p,a,l] = getMgenLevels( m, n )
%[i,p,a,l] = getMgenLevels( m, n )
%   m is a tissue mesh (foliate or volumetric) and n is a morphogen index,
%   a morphogen name, or an array of these.
%
%   The results are:
%
%   i: the indexes of the specified morphogens
%
%   p: the values of the specified morphogens at all of the vertexs of the
%   mesh, as a V*N array, there being V vertexes and N morphogens.
%
%   a: the "mutant level" of each of the specified morphogens.
%
%   l: a V*N array holding the effective value of each of the specified
%   morphogens at every vertex.  This is obtained fomr p by multiplying
%   every column by the mutant level of the correponding morphogen.

    i = FindMorphogenIndex( m, n );
    if isempty(i)
        fprintf('Missing morphogen %s\n',n);
    end
    
    if nargout == 1
        return;
    end

    p = m.morphogens(:,i);
    if ~m.allMutantEnabled
        a = ones(size(i));
        l = p;
    else
        a = m.mutantLevel(i);
        b = m.mgenswitch(:,i);
        if all(a==1) && all(b==1)
            l = p;
        else
            n = getNumberOfVertexes(m);
            a = repmat(a,n,1);
            if size(b,1)==1
                b = repmat(b,n,1);
            end
            l = p .* a .* b;
        end
    end
end
