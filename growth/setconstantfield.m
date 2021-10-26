function m = setconstantfield(m,amount,whichGrowth, add, whichVertexes)
%mesh = setconstantfield(mesh,amount,whichGrowth, add)
%   Set or add constant growth factor for all points.

    if nargin < 4, add = 0; end
    if nargin < 5
        whichVertexes = true(size(m.morphogens,1),1);
    end
    if isempty(whichVertexes), return; end
    if add
        m.morphogens(whichVertexes,whichGrowth) = amount + m.morphogens(whichVertexes,whichGrowth);
    else
        m.morphogens(whichVertexes,whichGrowth) = amount;
    end
    m.saved = 0;
end
