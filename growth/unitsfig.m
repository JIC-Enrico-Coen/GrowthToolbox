function varargout = unitsfig(varargin)

    % Begin initialization code - DO NOT EDIT
    gui_Singleton = 1;
    gui_State = struct('gui_Name',       mfilename, ...
                       'gui_Singleton',  gui_Singleton, ...
                       'gui_OpeningFcn', @unitsfig_OpeningFcn, ...
                       'gui_OutputFcn',  @unitsfig_OutputFcn, ...
                       'gui_LayoutFcn',  [] , ...
                       'gui_Callback',   []);

    if nargout
        [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
    else
        gui_mainfcn(gui_State, varargin{:});
    end
% End initialization code - DO NOT EDIT
end


% --- Executes just before unitsfig is made visible.
function unitsfig_OpeningFcn(hObject, eventdata, handles, varargin)
    setDefaultGUIColors( hObject );

    handles.output = -1;

    % Update handles structure
    guidata(hObject, handles);

    % Insert default values.
    if ~isempty(varargin)
        for index = 1:2:(length(varargin)-1),
            if nargin-3==index, break, end
            switch lower(varargin{index})
              case 'timescale'
                set(handles.timescaleText, 'String', '1');
              case 'timeunitname'
                set(handles.oldtimeunitText, 'String', [ '= 1 ' varargin{index+1} ]);
                set(handles.newtimeunitText, 'String', '');
              case 'spacescale'
                set(handles.spacescaleText, 'String', '1' );
              case 'spaceunitname'
                set(handles.oldspaceunitText, 'String', [ '= 1 ' varargin{index+1} ]);
                set(handles.newspaceunitText, 'String', '');
            end
        end
    end

    centreDialog(hObject);
    
    % Make the GUI modal
    set(handles.figure1,'WindowStyle','modal');

    uiwait(handles.figure1);
end


% --- Outputs from this function are returned to the command line.
function varargout = unitsfig_OutputFcn(hObject, eventdata, handles) 
    varargout{1} = handles.output;

    % The figure can be deleted now.
    delete(hObject);
end
