function figspec = buildFigure( fig, figspec, parent, position )
% WORK IN PROGRESS
    if (nargin < 3) || isempty(parent)
        parent = fig;
    end
    if nargin < 4
        position = get( parent, 'Position' );
        position([1 2]) = 0;
    end
    % Calculate object position, using alignment info.
    if isfield( figspec, 'alignment' )
        alignment = figspec.alignment;
    else
        alignment = 'ff';
    end
    obposition = position;
    switch alignment(1)
        case 'r'
            obposition(1) = obposition(3) - naturalsize(1);
        case 'l'
            obposition(3) = naturalsize(1);
        case 'c'
            obposition(1) = obposition(1) + naturalsize(1)/2;
            obposition(3) = naturalsize(1);
        case 'f'
            % Nothing.
    end
    switch alignment(2)
        case 't'
            obposition(2) = obposition(4) - naturalsize(2);
        case 'b'
            obposition(4) = naturalsize(2);
        case 'c'
            obposition(2) = obposition(2) + naturalsize(2)/2;
            obposition(4) = naturalsize(2);
        case 'f'
            % Nothing.
    end
    cparent = parent;
    figspec.handle = [];
    if isfield( figspec, 'matlabGUI' )
        stdargs = figspec.matlabGUI;
    else
        stdargs = struct();
    end
    stdargs = defaultFromStruct( stdargs, ...
                struct( 'Parent', parent, 'Units', 'pixels', 'Position', obposition ) );
    stdargarray = struct2args( stdargs );
    switch figspec.type
        case 'group'
            cpos = obposition;
        case 'panel'
            % Make a panel in the required position.
            figspec.handle = uipanel( 'Title', 'xxxx', stdargarray{:} );
            cparent = figspec.handle;
        case 'OKButton'
            figspec.handle = makeOKButton( parent, obposition );
        case 'cancelButton'
            figspec.handle = makeCancelButton( parent, obposition );
        case 'statictext'
            figspec.handle = uicontrol( 'Style', 'text', stdargarray{:} );
        case 'edittext'
            figspec.handle = uicontrol( 'Style', 'text', stdargarray{:} );
    end
    if isfield( figspec, 'children' ) && ~isempty(figspec.children)
        c = figspec.children;
        for i=1:length(c)
            ci = c{i};
            % Determine position of ci.
            if strcmp( figspec.type, 'group' )
                cpos = [ position(1:2), ci.relpos(3:4) ];
            else
                cpos = ci.relpos;
            end
            buildFigure( fig, ci, cparent, cpos );
        end
    end
end

% The minimum width of a radio button is its extent plus 20. Its minimum height is
% 16.  The same for a checkbox.
%
% For a pushbutton, if the height is 23 or more it is drawn Mac-style,
% otherwise Java-style.  The width should be at least extent+8.  The height
% of the extent appears to always be the font size (in pixels) + 5.  Make
% things this tall and they are drawn Mac-style.

% Layout of VRMLParams figure:
% 
% 3 units vertically:
%     1: 2 units horiz
%         1: Box with title, containing:
%             3 vertical
%                 1: 3 horiz
%                     1: Radio button
%                     2: Text
%                     3: Edittext
%                 2: 3 horiz
%                     1: Radio button
%                     2: Text
%                     3: Edittext
%                 3: 2 Horiz
%                     1: Text
%                     2: Text
%         2: Box with title, containing:
%             4 vertical
%                 1: 3 horiz
%                     1: Radio button
%                     2: Text
%                     3: Edittext
%                 2: 3 horiz
%                     1: Radio button
%                     2: Text
%                     3: Edittext
%                 3: 3 horiz
%                     1: Radio button
%                     2: Text
%                     3: Edittext
%                 4: 2 Horiz
%                     1: Text
%                     2: Text
%     2: Boxed text
%     3: 2 horiz
%         1: OK button
%         2: Cancel button
% 
% What about units? mm, cm, inch, metre
% 
% To handle links among items, we must use tags instead of references.  When building, we can use
% the handles as references.
% 
% t111 is a radio button
% t111.matlabprops = struct( 'Style', 'radiobutton', 'String', 'Scale by:' );
% t112 is an editable text
% t11.children = { t111, t112 };
% t11.grid = 'h';
% t1.children = { t11, t12, t13 };
% t1.grid = 'v';
% t31 is an OK button
% t31.align = 'r';
% t32 is a Cancel button
% t31.align = 'l';
% t3.children = { t31, t32 };
% top.children = { t1, t2, t3 };
% top.grid = 'v';
% 


