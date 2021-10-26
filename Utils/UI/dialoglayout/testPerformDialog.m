function testPerformDialog()
    dialogtitle = 'test dialog';
%     dialogspec = { { 'OK', 'Cancel' }; ...
%                    {'pushbutton', 'getDefaultButton', 'Get Default', @getDefaultButtonCallback}; ...
%                    {'edit', 'editableTextItem', '' } };
%     dialogspec = { 'OK', 'Cancel' };
%     dialogspec = { {'OK', 'Cancel'} };
      dialogspec = { {'OK', 'Cancel'}; ...
                     { {'panel','sdfafe4'}, { {'panel','weqwerewr'}, {'pushbutton','xxx','xx'} } }; ...
                     { {'panel','78967897'}, {'pushbutton','yyy','yy'}, {'togglebutton','zzz','zzzzz', 0} } ...
                   };
  % dialogspec = { {'OK', 'Cancel'}; {{{'panel','dfgsf'},{'pushbutton','xxx','xxx'}}, {{'panel','qweqer'}}} };
  % dialogspec = { {{'panel','foo'};{'text','sadfs'}}, {'OK', 'Cancel'} };
  % dialogspec = { 'OKCancel'; {{'panel','foo'};{'text','qwerqer'};{'text','dfgsf'}}; 'text' };
    result = performDialog( dialogtitle, dialogspec )
end

function getDefaultButtonCallback( hObject, eventData )
    handles = guidata( hObject );
    set( handles.editableTextItem, 'String', 'Default string' );
end
