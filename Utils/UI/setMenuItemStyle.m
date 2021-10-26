function [label,oldlabel] = setMenuItemStyle( menuhandle, style )
%setMenuItemItalic( menuhandle, italic )
%   Set or remove the italic, bold, or underline properties of the given
%   menu handle.  The style is a string whose characters mean:
%       'I' italic
%       'i' nonitalic
%       'B' bold
%       'b' nonbold
%       'U' underline
%       'u' no underline
%       'H' coloured (colour is hard-wired in this procedure)
%       'h' uncoloured (black)
%   Type style settings for Matlab menu items are performed by using HTML
%   in the Label property of the menu handle.  Your menu callback for the
%   item should therefore not depend on the label to determine which menu
%   item it is.
%
%   The new label and the old label are returned.

    [label,ok] = tryget( menuhandle, 'Label' );
    if ~ok
        % Does not have a label property.  Silently give up.
        return
    end
    oldlabel = label;
    
    if isempty( style )
        return;
    end
    
    % Matlab 2011a does not support any way of setting menu item type styles
    % on Mac OS.  Therefore this feature of GFtbox has been disabled.
    STYLE_SUPPORT = false;
    
    highlighted = any( get( menuhandle, 'ForegroundColor' ) ~= [0 0 0] );
    
    if STYLE_SUPPORT
        html = ~isempty( regexpi( label, '<html>', 'once' ) );
        bold = ~isempty( regexpi( label, '<b>', 'once' ) );
        italic = ~isempty( regexpi( label, '<i>', 'once' ) );
        underline = ~isempty( regexpi( label, '<u>', 'once' ) );

        for c = style
            switch c
                case 'B'
                    bold = true;
                case 'b'
                    bold = false;
                case 'I'
                    italic = true;
                case 'i'
                    italic = false;
                case 'U'
                    underline = true;
                case 'u'
                    underline = false;
                case 'H'
                    highlight = true;
                case 'h'
                    highlight = false;
            end
        end

        if html
            label = regexprep( label, '<[^>]*>', '' );
        end
        if bold
            label = ['<b>' label '</b>'];
        end
        if italic
            label = ['<i>' label '</i>'];
        end
        if underline
            label = ['<u>' label '</u>'];
        end
        if bold || italic || underline
            label = ['<html>' label '</html>'];
        end
        if ishandle( menuhandle )
            set( menuhandle, 'Label', label );
        end
    else
        for c = style
            switch c
                case 'H'
                    highlight = true;
                case 'h'
                    highlight = false;
            end
        end
    end
    
    if highlight ~= highlighted
        if highlight
            highlightColor = [0.3 0.1 0];
            set( menuhandle, 'ForegroundColor', highlightColor );
        else
            set( menuhandle, 'ForegroundColor', [0 0 0] );
        end
    end
end
