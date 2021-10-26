function result = mgenTotalArea( m, mgen, threshold )
%result = mgenTotalArea( m, mgen )
%   Calculate the total area where a given morphogen is above a threshold.
%   If only a fraction of the vertexes of a finite element have the
%   morphogen above the threshold, then the corresponding fraction of its
%   area will be used.
%
%   The possible values of MGEN and THESHOLD are as for mgenTotalLength.

    if nargin < 3
        threshold = 0;
    end
    if isnumeric(mgen) && (size(mgen,1)==size(m.morphogens,1))
        val = mgen;
    else
        mgen = FindMorphogenIndex( m, mgen );
        if isempty(mgen)
            result = 0;
            return;
        end
        val = m.morphogens(:,mgen);
    end
    
    result = mgenTotalAmount( m, val>threshold );
end
