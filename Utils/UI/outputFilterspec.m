function filters = outputFilterspec( extensions )
%filters = inputFilterspec( extensions )
%   Given a cell array of file extensions (which must NOT include the initial
%   "."), construct a filterspec for use with uiputfile.

    filters = cell(length(extensions),2);
    for i=1:length(extensions)
        filters{i,1} = [ '*.', extensions{i} ];
        filters{i,2} = [ upper(extensions{i}), ' files' ];
    end
end
