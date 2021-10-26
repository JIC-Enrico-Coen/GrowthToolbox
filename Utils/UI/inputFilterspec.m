function filters = inputFilterspec( extensions, allowall )
%filters = inputFilterspec( extensions, allowall )
%   Given a cell array of file extensions (which must NOT include the initial
%   "."), construct a filterspec for use with uigetfile.
%   If allowall is given, it specifies whether to include the 'All files'
%   option.  The default is to include it.
%   If there is more than one extension in the list, the 'All suitable'
%   option will be included as the first filter.

    if nargin < 2, allowall = true; end
    allspec = cell(1,length(extensions));
    if length(extensions)==1
        offset = 0;
    else
        offset = 1;
    end
    filters = cell(length(extensions)+offset,2);
    for i=1:length(extensions)
        allspec{i} = ';*.';
        filters{i+offset,1} = [ '*.', extensions{i} ];
        filters{i+offset,2} = [ upper(extensions{i}), ' files' ];
    end
    allspec{1} = '*.';
    allspecwithext = { allspec{:}; extensions{:} };
    if offset > 0
        filters{1,1} = [ allspecwithext{:} ];
        filters{1,2} = 'All suitable';
    end
    if allowall
        allindex = length(extensions)+offset+1;
        filters{allindex,1} = '*';
        filters{allindex,2} = 'All files';
    end
end
