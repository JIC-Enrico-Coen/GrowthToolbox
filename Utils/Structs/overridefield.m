function s = overridefield( s, varargin )
%s = overridefield( s, fieldtokeep1, fieldstoremove1, fieldtokeep2, fieldstoremove2, ... )
% If certain fields of s are nonempty, set certain other fields to be
% empty, if they exist.  Fields not in s are ignored.

    for i=1:2:(length(varargin)-1)
        fn = varargin{i};
        fnremove = varargin{i+1};
        if isfield( s, fn ) && ~isempty( s.(fn) )
            if iscell( fnremove )
                for j=1:length(fnremove)
                    fnr = fnremove{j};
                    if isfield( s, fnr )
                        s.(fnr) = [];
                    end
                end
            elseif isfield( s, fnremove )
                s.(fnremove) = [];
            end
        end
    end
end

