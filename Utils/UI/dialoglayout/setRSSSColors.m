function s = setRSSSColors( s, parentcolor )
%s = setRSSSColors( s )

    if nargin < 2
        parentcolor = [];
    end
    switch s.type
        case 'figure'
            % Nothing.
          % set( s.handle, 'Color', [0.3 0.8 0.3] );
            parentcolor = get( s.handle, 'Color' );
        case 'group'
            % Nothing.
        case { 'panel', 'radiogroup', 'colorchooser' }
            % Make same colour as parent.
            if isfield( s.attribs, 'foregroundcolor' )
                set( s.handle, 'ForegroundColor', s.attribs.foregroundcolor );
            end
            if isfield( s.attribs, 'highlightcolor' )
                set( s.handle, 'HighlightColor', s.attribs.highlightcolor );
            end
            if isfield( s.attribs, 'shadowcolor' )
                set( s.handle, 'ShadowColor', s.attribs.shadowcolor );
            end
            if isfield( s.attribs, 'backgroundcolor' )
                set( s.handle, 'BackgroundColor', s.attribs.backgroundcolor );
                parentcolor = s.attribs.backgroundcolor;
            elseif isfield( s.attribs, 'color' )
                set( s.handle, 'BackgroundColor', s.attribs.color );
                parentcolor = s.attribs.color;
            elseif isempty( parentcolor )
                parentcolor = get( s.handle, 'BackgroundColor' );
            else
                set( s.handle, 'BackgroundColor', parentcolor );
            end
            % 	ForegroundColor = [0 0 0]
            % 	HighlightColor = [1 1 1]
            % 	BackgroundColor = [0.701961 0.701961 0.701961]
        case 'text'
            % Make same colour as parent.
            if isfield( s.attribs, 'backgroundcolor' )
                set( s.handle, 'BackgroundColor', s.attribs.backgroundcolor );
            elseif isempty( parentcolor )
                parentcolor = get( s.handle, 'BackgroundColor' );
            else
                set( s.handle, 'BackgroundColor', parentcolor );
            end
            % 	ForegroundColor = [0 0 0]
            % 	BackgroundColor = [0.701961 0.701961 0.701961]
        case 'popupmenu'
            % White
            set( s.handle, 'BackgroundColor', [1 1 1] );
            % 	BackgroundColor = [0.701961 0.701961 0.701961]
            % 	ForegroundColor = [0 0 0]
        case 'edit'
            % White
            set( s.handle, 'BackgroundColor', [1 1 1] );
            % 	BackgroundColor = [0.701961 0.701961 0.701961]
            % 	ForegroundColor = [0 0 0]
        case 'listbox'
            % White
            set( s.handle, 'BackgroundColor', [1 1 1] );
            % 	BackgroundColor = [0.701961 0.701961 0.701961]
            % 	ForegroundColor = [0 0 0]
        case { 'checkbox', 'radiobutton' }
            % Parent (actually unaffected by this setting).
            if isempty( parentcolor )
                parentcolor = get( s.handle, 'BackgroundColor' );
            else
                set( s.handle, 'BackgroundColor', parentcolor );
            end
            %	BackgroundColor = [0.701961 0.701961 0.701961]
        case { 'pushbutton', 'togglebutton' }
            % Special value.  Why?
            % set( s.handle, 'BackgroundColor', [0.701961 0.701961 0.701961] );
            set( s.handle, 'BackgroundColor', [1 1 1] );
            %	BackgroundColor = [0.701961 0.701961 0.701961]
    end

    for i=1:length(s.children)
        s.children{i} = setRSSSColors( s.children{i}, parentcolor );
    end
end
