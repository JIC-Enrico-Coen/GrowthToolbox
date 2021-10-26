function packmenu( menuhandle, maxitems, firstitem )
%packmenu( menuhandle )
%   This takes a handle to a menu and reorganises it so that no submenu
%   contains more than maxitems items.

    if ~ishandle( menuhandle )
      % fprintf( 1, 'Not a handle.\n' );
        return;
    end
    if ~strcmp( get( menuhandle, 'Type' ), 'uimenu' )
      % fprintf( 1, 'Not a menu.\n' );
        return;
    end
    if maxitems < 2
      % fprintf( 1, 'Invalid children bound.\n' );
        return;
    end
    if nargin < 3
        firstitem = 1;
    end
    
    c = get( menuhandle, 'Children' );
    cl = length(c) - firstitem + 1;
  % fprintf( 1, 'lc %d, fi %d, cl %d, mi %d\n', length(c), firstitem, cl, maxitems );
    if cl <= maxitems
      % fprintf( 1, 'No packing required.\n' );
        return;
    end
    if nargin < 3
        firstitem = 1;
    end
    
    t = maketree( cl, 1, maxitems );
  % printtree( t );
    rebuildmenus( menuhandle, t, c((end-firstitem+1):-1:1) );
end

function rebuildmenus( mh, t, c )
    for i=1:length(t)
        buildmenus( t{i}, c, mh );
    end
end

function buildmenus( t, c, p )
  % fprintf( 1, 'buildmenus, parent %s\n', get( p, 'Label' ) );
    if isnumeric(t)
        h = c(t);
        if length(t)==1
            set( h, 'Parent', p );
        
%             ll = get( h, 'Label' );
%             pp = get( h, 'Position' );
%             fprintf( 1, '%3d %s\n', pp, ll );
        else
            label = makeMoreLabel( get(h(1),'Label'), get(h(end),'Label') );
          % hp = uimenu( p, 'Label', ['<html><i>' label '</i></html>'] );
            hp = uimenu( p, 'Label', label );
            for i=1:length(t)
                set( h(i), 'Parent', hp );
            end
            
%             ll = get( hp, 'Label' );
%             pp = get( hp, 'Position' );
%             fprintf( 1, '%3d %s\n', pp, ll );
        end
    else
      % h = uimenu( p, 'Label', '<html><i>More</i></html>' );
        h = uimenu( p, 'Label', 'More' );
        for i=1:length(t)
            buildmenus( t{i}, c, h );
        end
        label = makeMoreLabel( get( firstSubitem( h ), 'Label' ), ...
                               get( lastSubitem( h ), 'Label' ) );
      % set( h, 'Label', ['<html><i>' label '</i></html>'] );
        set( h, 'Label', label );
        
%         ll = get( h, 'Label' );
%         pp = get( h, 'Position' );
%         fprintf( 1, '%3d %s\n', pp, ll );
    end            
end

function mhfirst = firstSubitem( mh )
    c = get( mh, 'Children' );
    if isempty(c)
        mhfirst = mh;
    else
        mhfirst = firstSubitem( c(end) );
    end
end

function mhlast = lastSubitem( mh )
    c = get( mh, 'Children' );
    if isempty(c)
        mhlast = mh;
    else
        mhlast = lastSubitem( c(1) );
    end
end

function label = makeMoreLabel( first, last )
    maxchars = 20;
    if length(first) > maxchars
        first = [first(1:(maxchars-1)), '...'];
    end
    if length(last) > maxchars
        last = [last(1:(maxchars-1)), '...'];
    end
    label = [ first, ' - ', last ];
end
