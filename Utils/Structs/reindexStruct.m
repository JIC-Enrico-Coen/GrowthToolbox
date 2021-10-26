function s = reindexStruct( s, varargin )
    if ~isfield( s, 'types' )
        return;
    end
    
    oldToNew = struct();
    newToOld = struct();
    for i=1:3:(length(varargin)-2)
        fn = varargin{i};
        oldToNew.(fn) = varargin{i+1};
        newToOld.(fn) = varargin{i+2};
    end
    
    fns = fieldnames(s.types);
    for i=1:length(fns)
        fn = fns{i};
        if isempty(s.(fn))
            continue;
        end
        its = s.types.(fn).indextype;
        vt = s.types.(fn).valuetype;
        if iscell(s.(fn))
            for ci=1:numel(s.(fn))
                s.(fn){ci} = reindexArrayA( s.(fn){ci}, fn, its, vt, oldToNew, newToOld );
            end
        else
            s.(fn) = reindexArrayA( s.(fn), fn, its, vt, oldToNew, newToOld );
        end
    end
end

function s = reindexArrayA( s, fn, its, vt, oldToNew, newToOld )
    newsize = size( s.(fn) );
    for j=1:length(its)
        it = its{j};
        if isfield( newToOld, it )
            newsize(j) = length( newToOld.(it) );
            s.fn = reindexArrayB( s.fn, j, newToOld );
        end
        if isfield( oldToNew, vt )
            s.(fn) = oldToNew.(vt)( s.(fn) );
        end
    end
end

function a = reindexArrayB( a, dim, newToOld )
    oldsize = size(a);
    newsize = oldsize;
    newsize(dim) = length(newToOld);
    if dim==1
        a = reshape( a(newToOld,:), newsize );
    elseif dim==2
        a = reshape( a(:,newToOld,:), newsize );
    else
        a = reshape( a, prod(oldsize(1:(dim-1))), newsize(dim), [] );
        a = reshape( a(:,newToOld,:), newsize );
    end
end
