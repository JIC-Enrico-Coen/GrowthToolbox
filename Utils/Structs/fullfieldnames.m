function fns = fullfieldnames( s )
%fns = fullfieldnames( s )
%   Like the Matlab function fieldnames(), but returns a list of all
%   hierarchical fieldnames. For example:
% 
%     >>x.a.b.c.d = 234
% 
%     x = 
% 
%       struct with fields:
% 
%         a: [1×1 struct]
% 
%     >>fullfieldnames(x)
% 
%     ans =
% 
%       4×1 cell array
% 
%         {'a'      }
%         {'a.b'    }
%         {'a.b.c'  }
%         {'a.b.c.d'}

    fns = fieldnames(s);
    nestedfns = cell(size(fns));
    structfields = false(size(fns));
    for i=1:length(fns)
        fn = fns{i};
        if ~isempty(s) && isstruct( s(1).(fn) )
            structfields(i) = true;
            nfns = fullfieldnames( s.(fn) );
            for j=1:length( nfns )
                nfns{j} = [ fn, '.', nfns{j} ];
            end
            nestedfns{i} = nfns;
        end
    end
    nestedfns = nestedfns( structfields );
    nestedfns = vertcat( nestedfns{:} );
    fns = [ fns; nestedfns ];
end
