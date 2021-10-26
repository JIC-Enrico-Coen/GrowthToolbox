function mgenindexes = lookUpVVmgens( vvlayer, mgens )
%mgenindexes = lookUpVVmgens( vvlayer, mgens )
%   Translate VV morphogen names to indexes.  mgens can be a cell array of
%   strings, a single string, or a vector of indexes.  The result is a
%   vector of indexes which will be zero wherever the specified morphogen
%   does not exist.

    if isnumeric( mgens )
        mgenindexes = mgens;
        mgenindexes( (mgenindexes <= 0) | (mgenindexes > length(vvlayer.mgendict.indexToName)) ) = 0;
    else
        if ischar(mgens)
            mgens = { mgens };
        end
        mgenindexes = zeros(1,length(mgens));
        for i=1:length(mgens)
            if isfield( vvlayer.mgendict.nameToIndex, mgens{i} )
                mgenindexes(i) = vvlayer.mgendict.nameToIndex.( mgens{i} );
            end
        end
    end
end
