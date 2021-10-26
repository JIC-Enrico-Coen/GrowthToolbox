function [indexes,values] = name2Index( ni, varargin )
    if length(varargin)==1
        if iscell(varargin{1})
            varargin = varargin{1};
        elseif isnumeric(varargin{1})
            indexes = varargin{1};
            indexes((indexes<1) | (indexes > length(ni.index2NameMap))) = [];
            return;
        end
    end
    indexes = zeros(1,length(varargin));
    for i=1:length(varargin)
        s = varargin{i};
        if isnumeric(s)
            if (s >= 1) && (s <= length(ni.index2NameMap))
                indexes(i) = s;
            end
        else
            s = setcase( ni.case, s );
            if isfield( ni.name2IndexMap, s )
                indexes(i) = ni.name2IndexMap.(s);
            end
        end
    end
    
    if nargout >= 2
        if isfield( ni, 'index2Value' )
            if iscell( ni.index2Value )
                values = cell(1,length(indexes));
            else
                values = zeros(1,length(indexes));
            end
            values(indexes>0) = ni.index2Value(indexes(indexes>0));
        else
            values = [];
        end
    end
end
