function [u,ok] = checkstructfields( s, mode, varargin )
%u = checkfields( s, mode, varargin )
%   Check that the set of fields of structure s includes/is included
%   in/equals the fields listed in varargin, according to whether mode is
%   'incl', 'only', or 'exact'.  Case is significant.

    switch mode
        case 'incl'
            % s must include every field in varargin.
            u.missing = missingFields( s, varargin );
            ok = isempty( u.missing );
        case 'only'
            % s must include no field outside varargin.
            u.extra = setDiff( fieldnames(s), varargin );
            ok = isempty( u.extra );
        case 'exact'
            % s must contain exactly the fields in varargin.
            u1 = missingFields( s, varargin );
            u2 = setDiff( fieldnames(s), varargin );
            u.missing = u1;
            u.extra = u2;
            ok = isempty( u.missing ) && isempty( u.extra );
        otherwise
            fprintf( 1, 'Error in checkstructfields: invalid mode "%s".\n', mode );
            u = [];
            ok = false;
    end
end

function u = missingFields( s, t )
%u = missingFields( s, t )
%   Set u to a cell array of strings consisting of those strings in the
%   cell array t which are not fields of the structure s.

    u = {};
    for i=1:length(t)
        if ~isfield( s, t{i} )
            u{length(u)+1} = t{i};
        end
    end
end
    

function u = setDiff( s, t )
%u = setDiff( s, t )
%   s and t are cell arrays of strings.  Set u to a cell array of all
%   strings which are in s but not in t.

    u = {};
    for i=1:length(s)
        in_t = 0;
        for j=1:length(t)
            if strcmp(s{i},t{j})
                in_t = 1;
                break;
            end
        end
        if ~in_t
            u{length(u)+1} = s{i};
        end
    end
end
