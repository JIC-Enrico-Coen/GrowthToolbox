function [v,ok,src] = getGuiItemValue( h )
%[v,ok,src] = getGuiItemValue( h )
%   Get the current value of any GUI item, if it has one, otherwise [] is
%   returned and ok is false.  src is for testing purposes and is either
%   the class of h or get(h,'Style').
%
%   An edit item returns a string, unless datainfo specifies a type to
%   parse the string to.
%
%   A text item is like an edit item, but only returns a string if datainfo
%   is 'char'.  Without datainfo it returns nothing.
%
%   A popupmenu returns the index of the selected item, unless datainfo is
%   'char', in which case it returns the name of the selected item.
%
%   A togglebutton or checkbox returns a logical, unless
%   datainfo is present.  In that case the value of datainfo is returned if
%   the boolean value is true, and [] is returned if false.
%
%   A radiobutton returns a logical, unless datainfo is present.  In that
%   case the value of datainfo is returned, whether the button is selected
%   or not.  It is presumed that the value is only of interest when the
%   button is selected.
%
%   A slider returns a double, unless datainfo specifies some other numeric
%   type.
%
%   A menu returns nothing, unless datainfo is 'logical', in which case it
%   returns its checkmark state.
%
%   Every other type of item returns nothing unless datavalue is defined,
%   in which case it returns that value.

    v = [];
    ok = true;
    hclass = class(h);
    hstyle = tryget(h,'Style');
    if isempty(hstyle)
        src = regexprep( hclass, '^.*\.', '' );
    else
        src = hstyle;
    end
    [datainfo,datainfo_ok] = getUserdataField( h, 'datainfo' );
    tryget(h,'UserData');
    switch hclass
        case 'matlab.ui.control.UIControl'
            switch hstyle
                case 'popupmenu'
                    v = int32( get( h, 'Value' ) );
                    if strcmp(datainfo,'char')
                        v = h.String{v};
                    end
                case { 'checkbox', 'togglebutton' }
                    v = logical( get( h, 'Value' ) );
                    if datainfo_ok
                        if v
                            v = datainfo;
                        else
                            v = [];
                        end
                    end
                case { 'radiobutton' }
                    if datainfo_ok
                        v = datainfo;
                    else
                        v = logical( get( h, 'Value' ) );
                    end
                case 'slider'
                    v = double( get( h, 'Value' ) );
                    if datainfo_ok
                        v = coerceValue( v, datainfo );
                    end
                case 'edit'
                    v = get( h, 'String' );
                    if datainfo_ok
                        v = coerceValue( v, datainfo );
                    end
                case 'text'
                    if datainfo_ok
                        v = get( h, 'String' );
                        if datainfo_ok
                            v = coerceValue( v, datainfo );
                        end
                    else
                        v = [];
                        ok = false;
                    end
                otherwise
                    v = ['(',hclass,':',hstyle,')'];
                    ok = false;
                    % pushbutton, text
            end
        case 'matlab.ui.container.Panel'
            if strcmp(datainfo,'color')
                v = get( h, 'BackgroundColor' );
            else
                ok = false;
            end
        case 'matlab.ui.container.Menu'
            % Some menu items may or may not be checked.
            if strcmp(datainfo,'logical')
                v = logical( strcmp( get( h, 'Checked' ), 'on' ) );
            elseif strcmp(datainfo,'char')
                v = get( h, 'Label' );
            else
                ok = false;
            end
%         case 'matlab.ui.container.ButtonGroup'
            % Perhaps not useful?
%             v = int32( find( h.SelectedObject==h.Children, 1 ) );
%             if isempty(v)
%                 v = int32(0);
%             end
        otherwise
            % matlab.ui.container.Panel
            % matlab.ui.container.ButtonGroup ?
            if datainfo_ok
                v = datainfo;
            else
                ok = false;
            end
    end
    if ~ok
        v = ['(',hclass,')'];
    end
end

function v = coerceValue( v, datainfo )
    switch datainfo
        case 'double'
            v = sscanf( v, '%f' );
        case 'int32'
            v = int32( sscanf( v, '%d' ) );
        case 'logical'
            v = logical( sscanf( v, '%d' ) );
        otherwise
            % No change.
    end
end