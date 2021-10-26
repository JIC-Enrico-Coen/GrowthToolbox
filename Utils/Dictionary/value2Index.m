function [indexes,names] = value2Index( dict, values )
%[indexes,names] = value2Index( dict, values )

    numvalues = length(values);
    if ~isfield( dict, 'index2Value' )
        indexes = zeros(1,numvalues);
    else
        indexes = zeros(1,numvalues);
        if isnumeric(values)
            for i=1:length(values)
                k = find(dict.index2Value==values(i), 1);
                if isempty(k)
                    k = 0;
                end
                indexes(i) = k;
            end
        else
            for i=1:length(values)
                for j=1:length(dict.index2Value)
                    if strcmp( dict.index2Value{j}, values{i} )
                        indexes(i) = j;
                    end
                end
            end
        end
    end
    if nargin >= 2
        if iscell(dict.index2NameMap)
            names = cell(1,length(values));
        else
            names = zeros(1,length(values));
        end
        names(indexes>0) = dict.index2NameMap(indexes(indexes>0));
    end
end