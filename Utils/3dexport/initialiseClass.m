function initialiseClass( ob, varargin )
    if isempty(varargin)
        return;
    end
    if isempty(varargin{1})
        return;
    end
    if isstruct(varargin{1})
        s = varargin{1};
    else
        s = struct( varargin{:} );
    end            
    oknames = intersect( fieldnames(s), fieldnames(ob) );
    for i=1:length(oknames)
        fn = oknames{i};
        ob.(fn) = s.(fn);
    end
    badnames = setdiff( fieldnames(s), fieldnames(ob) );
    if ~isempty(badnames)
        fprintf( 1, 'Invalid fieldnames given when creating %s object:\n', class(ob) );
        fprintf( 1, '  %s', badnames{:} );
        fprintf( 1, '\n' );
    end
end
